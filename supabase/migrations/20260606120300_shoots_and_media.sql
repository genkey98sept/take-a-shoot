-- Take@Shoot — lieux, MugShoots, Shoots et médias.

-- =====================================================================
-- places (référentiel partagé ; saisie libre ou fournisseur futur)
-- =====================================================================
create table public.places (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  city text,
  country_code text,
  provider text,
  provider_place_id text,
  latitude double precision,
  longitude double precision,
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  constraint places_name_len check (char_length(name) between 1 and 120),
  constraint places_country_code_len check (country_code is null or char_length(country_code) = 2)
);

-- Déduplication des lieux fournisseur (provider + id externe).
create unique index places_provider_key on public.places (provider, provider_place_id)
  where provider is not null and provider_place_id is not null;

-- =====================================================================
-- mugshoots (1 actif par profil ; 4 sources live + rendu)
-- =====================================================================
create table public.mugshoots (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null unique references public.profiles (id) on delete cascade,
  render_path text,
  source_paths text[],
  processing_status public.processing_status not null default 'pending',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint mugshoots_sources_count check (source_paths is null or array_length(source_paths, 1) = 4)
);

create trigger mugshoots_set_updated_at
  before update on public.mugshoots
  for each row execute function public.set_updated_at();

-- =====================================================================
-- shoots (objet de publication principal)
-- =====================================================================
create table public.shoots (
  id uuid primary key default gen_random_uuid(),
  owner_id uuid not null references public.profiles (id) on delete cascade,
  title text,
  template text not null default 'take_shoot_classic_v1',
  filter text,
  visibility public.shoot_visibility not null default 'friends',
  place_id uuid references public.places (id) on delete set null,
  place_label text,
  city text,
  country_code text,
  captured_at timestamptz not null,
  published_at timestamptz,
  processing_status public.processing_status not null default 'pending',
  render_path text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint shoots_title_len check (title is null or char_length(title) <= 120),
  constraint shoots_template_valid check (template in ('take_shoot_classic_v1')),
  constraint shoots_filter_valid check (filter is null or filter in ('vintage', 'black_and_white')),
  constraint shoots_place_label_len check (place_label is null or char_length(place_label) <= 120),
  constraint shoots_country_code_len check (country_code is null or char_length(country_code) = 2)
);

-- Feed : Shoots publiés des amis, fenêtre 24 h (calculée : published_at + interval '24 hours').
create index shoots_feed_idx on public.shoots (published_at desc)
  where published_at is not null and deleted_at is null;
-- Souvenirs du propriétaire.
create index shoots_owner_idx on public.shoots (owner_id, created_at desc)
  where deleted_at is null;

create trigger shoots_set_updated_at
  before update on public.shoots
  for each row execute function public.set_updated_at();

-- =====================================================================
-- shoot_media (4 sources + rendu officiel + variantes feed/thumbnail)
-- Les originaux ne sont jamais exposés comme fichiers publics (bucket privé).
-- =====================================================================
create table public.shoot_media (
  id uuid primary key default gen_random_uuid(),
  shoot_id uuid not null references public.shoots (id) on delete cascade,
  kind public.media_kind not null,
  position smallint,
  storage_path text not null,
  width int,
  height int,
  bytes bigint,
  created_at timestamptz not null default now(),
  constraint shoot_media_position_range check (position is null or position between 1 and 4)
);

-- Une seule entrée par (shoot, kind, position) pour les sources ; une seule par (shoot, kind) sinon.
create unique index shoot_media_positioned_key on public.shoot_media (shoot_id, kind, position)
  where position is not null;
create unique index shoot_media_single_key on public.shoot_media (shoot_id, kind)
  where position is null;
create index shoot_media_shoot_idx on public.shoot_media (shoot_id);

-- =====================================================================
-- RLS deny-by-default + GRANTs.
-- =====================================================================
alter table public.places enable row level security;
alter table public.mugshoots enable row level security;
alter table public.shoots enable row level security;
alter table public.shoot_media enable row level security;

grant select, insert on public.places to authenticated;
grant select, insert, update, delete on public.mugshoots to authenticated;
-- Pas de DELETE direct sur shoots : suppression = soft delete (update deleted_at) ; purge via service-role.
grant select, insert, update on public.shoots to authenticated;
-- L'app insère les sources ; le backend (service-role) écrit rendu/feed/thumbnail.
grant select, insert on public.shoot_media to authenticated;
