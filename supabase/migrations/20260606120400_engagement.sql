-- Take@Shoot — engagement : tags, réactions, commentaires.

-- =====================================================================
-- shoot_tags (seuls des potes acceptés peuvent être tagués — appliqué en RLS)
-- =====================================================================
create table public.shoot_tags (
  shoot_id uuid not null references public.shoots (id) on delete cascade,
  tagged_user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (shoot_id, tagged_user_id)
);

-- Section privée « Identifié·e » de l'utilisateur tagué.
create index shoot_tags_tagged_idx on public.shoot_tags (tagged_user_id);

-- =====================================================================
-- shoot_reactions (une seule réaction active par utilisateur et par Shoot)
-- =====================================================================
create table public.shoot_reactions (
  shoot_id uuid not null references public.shoots (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  reaction public.shoot_reaction not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  primary key (shoot_id, user_id)
);

create index shoot_reactions_shoot_idx on public.shoot_reactions (shoot_id);

create trigger shoot_reactions_set_updated_at
  before update on public.shoot_reactions
  for each row execute function public.set_updated_at();

-- =====================================================================
-- shoot_comments (profondeur de réponse maximale = 1)
-- =====================================================================
create table public.shoot_comments (
  id uuid primary key default gen_random_uuid(),
  shoot_id uuid not null references public.shoots (id) on delete cascade,
  author_id uuid not null references public.profiles (id) on delete cascade,
  parent_id uuid references public.shoot_comments (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint shoot_comments_body_len check (char_length(body) between 1 and 500)
);

create index shoot_comments_shoot_idx on public.shoot_comments (shoot_id, created_at)
  where deleted_at is null;
create index shoot_comments_parent_idx on public.shoot_comments (parent_id)
  where parent_id is not null;

create trigger shoot_comments_set_updated_at
  before update on public.shoot_comments
  for each row execute function public.set_updated_at();

-- Profondeur 1 : un parent doit exister, appartenir au même Shoot, et être lui-même top-level.
create or replace function public.enforce_comment_depth()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
declare
  parent_shoot uuid;
  parent_parent uuid;
begin
  if new.parent_id is not null then
    select shoot_id, parent_id
      into parent_shoot, parent_parent
      from public.shoot_comments
      where id = new.parent_id;

    if not found then
      raise exception 'Commentaire parent % introuvable', new.parent_id;
    end if;
    if parent_shoot <> new.shoot_id then
      raise exception 'La réponse doit porter sur le même Shoot que le commentaire parent';
    end if;
    if parent_parent is not null then
      raise exception 'Profondeur de réponse maximale (1) dépassée';
    end if;
  end if;
  return new;
end;
$$;

create trigger shoot_comments_enforce_depth
  before insert on public.shoot_comments
  for each row execute function public.enforce_comment_depth();

-- =====================================================================
-- RLS deny-by-default + GRANTs.
-- =====================================================================
alter table public.shoot_tags enable row level security;
alter table public.shoot_reactions enable row level security;
alter table public.shoot_comments enable row level security;

-- tag : insert par le propriétaire ; delete par le propriétaire OU l'utilisateur tagué.
grant select, insert, delete on public.shoot_tags to authenticated;
grant select, insert, update, delete on public.shoot_reactions to authenticated;
-- commentaire : édition/soft delete via update (deleted_at) ; pas de hard delete direct.
grant select, insert, update on public.shoot_comments to authenticated;
