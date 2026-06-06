-- Take@Shoot — helpers SECURITY DEFINER (après création des tables) + RPC.
-- security definer (owner = postgres) => contournent la RLS des tables lues,
-- ce qui évite toute récursion de policy. auth.uid() reste le user JWT courant.

-- Amitié réciproque acceptée (paire canonique).
create or replace function public.are_friends(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.friendships f
    where f.user_low = least(a, b)
      and f.user_high = greatest(a, b)
  );
$$;

-- Blocage dans un sens ou l'autre.
create or replace function public.is_blocked(a uuid, b uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.blocks bl
    where (bl.blocker_id = a and bl.blocked_id = b)
       or (bl.blocker_id = b and bl.blocked_id = a)
  );
$$;

-- L'utilisateur est-il tagué sur ce Shoot ?
create or replace function public.is_tagged(p_shoot_id uuid, p_user_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shoot_tags t
    where t.shoot_id = p_shoot_id
      and t.tagged_user_id = p_user_id
  );
$$;

-- L'utilisateur courant est-il propriétaire actif d'un Shoot non supprimé ?
create or replace function public.owns_shoot(p_shoot_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shoots s
    where s.id = p_shoot_id
      and s.owner_id = auth.uid()
      and s.deleted_at is null
  );
$$;

-- L'utilisateur courant peut-il voir ce Shoot ?
-- propriétaire OU (ami non bloqué, publié, fenêtre 24 h) OU tagué.
create or replace function public.can_view_shoot(p_shoot_id uuid)
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from public.shoots s
    where s.id = p_shoot_id
      and s.deleted_at is null
      and (
        s.owner_id = auth.uid()
        or (
          s.published_at is not null
          and s.published_at + interval '24 hours' > now()
          and public.are_friends(s.owner_id, auth.uid())
          and not public.is_blocked(s.owner_id, auth.uid())
        )
        or public.is_tagged(s.id, auth.uid())
      )
  );
$$;

-- =====================================================================
-- RPC accept_friend_request : insère l'amitié (paire canonique) + passe la
-- demande à 'accepted'. Seul le destinataire d'une demande 'pending' peut l'accepter.
-- (friendships n'a aucun GRANT insert direct : l'insert passe par ici.)
-- =====================================================================
create or replace function public.accept_friend_request(p_request_id uuid)
returns void
language plpgsql
security definer
set search_path = ''
as $$
declare
  r public.friend_requests;
begin
  select * into r from public.friend_requests where id = p_request_id for update;
  if not found then
    raise exception 'Demande introuvable';
  end if;
  if r.receiver_id <> auth.uid() then
    raise exception 'Non autorisé';
  end if;
  if r.status <> 'pending' then
    raise exception 'Demande non en attente';
  end if;

  insert into public.friendships (user_low, user_high)
  values (least(r.sender_id, r.receiver_id), greatest(r.sender_id, r.receiver_id))
  on conflict do nothing;

  update public.friend_requests
  set status = 'accepted', responded_at = now()
  where id = p_request_id;
end;
$$;

-- =====================================================================
-- RPC de découverte : vue PRÉ-amitié limitée (id, @pseudo, prénom, avatar).
-- La table profiles n'expose en SELECT que soi + amis ; la recherche/affichage
-- d'un non-ami passe par ces RPC qui ne renvoient que des colonnes publiques.
-- =====================================================================
create or replace function public.search_profiles(p_query text)
returns table (id uuid, username text, first_name text, avatar_path text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.username, p.first_name, p.avatar_path
  from public.profiles p
  where p.deleted_at is null
    and p.status = 'active'
    and p.id <> auth.uid()
    and not public.is_blocked(p.id, auth.uid())
    and p.username like lower(p_query) || '%'
  order by p.username
  limit 20;
$$;

create or replace function public.get_public_profile(p_id uuid)
returns table (id uuid, username text, first_name text, avatar_path text)
language sql
stable
security definer
set search_path = ''
as $$
  select p.id, p.username, p.first_name, p.avatar_path
  from public.profiles p
  where p.id = p_id
    and p.deleted_at is null
    and p.status = 'active'
    and not public.is_blocked(p.id, auth.uid());
$$;

-- =====================================================================
-- Privilèges d'exécution (révoquer de public, accorder à authenticated).
-- Les helpers sont référencés par les policies RLS => authenticated doit pouvoir
-- les exécuter.
-- =====================================================================
revoke all on function
  public.are_friends(uuid, uuid),
  public.is_blocked(uuid, uuid),
  public.is_tagged(uuid, uuid),
  public.owns_shoot(uuid),
  public.can_view_shoot(uuid),
  public.accept_friend_request(uuid),
  public.search_profiles(text),
  public.get_public_profile(uuid)
from public;

grant execute on function
  public.are_friends(uuid, uuid),
  public.is_blocked(uuid, uuid),
  public.is_tagged(uuid, uuid),
  public.owns_shoot(uuid),
  public.can_view_shoot(uuid),
  public.accept_friend_request(uuid),
  public.search_profiles(text),
  public.get_public_profile(uuid)
to authenticated;
