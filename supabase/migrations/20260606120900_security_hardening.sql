-- Take@Shoot — Durcissement sécurité RLS/Storage (suite à la revue adversariale).
-- Corrige : contournement du blocage via tag, transitions friend_requests,
-- mutation de colonnes-clés (profiles, shoot_comments), acceptation malgré
-- blocage, kind shoot_media forgeable, bucket avatars = host de fichiers.
-- NB : la LECTURE des originaux source_* reste alignée sur can_view_shoot
-- (la spec autorise la consultation des 4 sources par les visiteurs du Shoot ;
-- la restriction de TÉLÉCHARGEMENT propriétaire/tagué est une feature applicative).

-- =====================================================================
-- F1 — La branche taguée doit exiger publication + non-blocage.
-- =====================================================================
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
        or (
          s.published_at is not null
          and public.is_tagged(s.id, auth.uid())
          and not public.is_blocked(s.owner_id, auth.uid())
        )
      )
  );
$$;

drop policy "shoots_select_visible" on public.shoots;
create policy "shoots_select_visible" on public.shoots
  for select to authenticated
  using (
    deleted_at is null
    and (
      owner_id = auth.uid()
      or (
        published_at is not null
        and published_at + interval '24 hours' > now()
        and public.are_friends(owner_id, auth.uid())
        and not public.is_blocked(owner_id, auth.uid())
      )
      or (
        published_at is not null
        and public.is_tagged(id, auth.uid())
        and not public.is_blocked(owner_id, auth.uid())
      )
    )
  );

-- Le tag ne doit pas survivre à un blocage : purge à l'insertion d'un block.
create or replace function public.purge_tags_on_block()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  delete from public.shoot_tags t
  using public.shoots s
  where t.shoot_id = s.id
    and (
      (s.owner_id = new.blocker_id and t.tagged_user_id = new.blocked_id)
      or (s.owner_id = new.blocked_id and t.tagged_user_id = new.blocker_id)
    );
  return new;
end;
$$;

create trigger blocks_purge_tags
  after insert on public.blocks
  for each row execute function public.purge_tags_on_block();

-- =====================================================================
-- F2 (écriture) — l'upload dans le bucket shoots doit cibler un Shoot possédé,
-- avec un nom de fichier conforme à la convention.
-- =====================================================================
drop policy "shoots_insert_owner" on storage.objects;
create policy "shoots_insert_owner" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'shoots'
    and array_length(storage.foldername(name), 1) = 2
    and (storage.foldername(name))[1] = auth.uid()::text
    and public.owns_shoot(((storage.foldername(name))[2])::uuid)
    and storage.filename(name) ~ '^(source_[1-4]|render|feed|thumb)\.(jpg|jpeg|png|webp)$'
  );

drop policy "shoots_update_owner" on storage.objects;
create policy "shoots_update_owner" on storage.objects
  for update to authenticated
  using (bucket_id = 'shoots' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (
    bucket_id = 'shoots'
    and array_length(storage.foldername(name), 1) = 2
    and (storage.foldername(name))[1] = auth.uid()::text
    and public.owns_shoot(((storage.foldername(name))[2])::uuid)
    and storage.filename(name) ~ '^(source_[1-4]|render|feed|thumb)\.(jpg|jpeg|png|webp)$'
  );

-- =====================================================================
-- F3 — friend_requests : transitions strictes. Acceptation EXCLUSIVEMENT via RPC.
-- =====================================================================
drop policy "friend_requests_update_party" on public.friend_requests;

create policy "friend_requests_decline_receiver" on public.friend_requests
  for update to authenticated
  using (receiver_id = auth.uid() and status = 'pending')
  with check (receiver_id = auth.uid() and status = 'declined');

create policy "friend_requests_cancel_sender" on public.friend_requests
  for update to authenticated
  using (sender_id = auth.uid() and status = 'pending')
  with check (sender_id = auth.uid() and status = 'cancelled');

-- Ceinture + bretelles : identités immuables, transitions bornées (SECURITY INVOKER).
create or replace function public.enforce_friend_request_update()
returns trigger
language plpgsql
as $$
begin
  if new.sender_id <> old.sender_id or new.receiver_id <> old.receiver_id then
    raise exception 'sender_id/receiver_id immuables';
  end if;
  if new.status not in ('declined', 'cancelled', 'accepted') then
    raise exception 'Transition de statut non autorisée';
  end if;
  if old.status <> 'pending' and new.status is distinct from old.status then
    raise exception 'Une demande non-pending ne peut changer de statut';
  end if;
  return new;
end;
$$;

create trigger friend_requests_enforce_update
  before update on public.friend_requests
  for each row execute function public.enforce_friend_request_update();

-- =====================================================================
-- F4 — profiles : status / deleted_at / id non modifiables par l'utilisateur.
-- SECURITY INVOKER => current_user reflète le rôle appelant. Le service-role
-- (modération) et postgres passent outre ; 'authenticated' est bloqué.
-- =====================================================================
create or replace function public.protect_profile_columns()
returns trigger
language plpgsql
as $$
begin
  if current_user not in ('service_role', 'postgres', 'supabase_admin', 'supabase_auth_admin') then
    if new.status is distinct from old.status then
      raise exception 'status modifiable uniquement par la modération';
    end if;
    if new.deleted_at is distinct from old.deleted_at then
      raise exception 'deleted_at modifiable uniquement par le service-role';
    end if;
    if new.id is distinct from old.id then
      raise exception 'id immuable';
    end if;
  end if;
  return new;
end;
$$;

create trigger profiles_protect_columns
  before update on public.profiles
  for each row execute function public.protect_profile_columns();

-- =====================================================================
-- F5 — shoot_comments : author/parent/shoot figés à l'UPDATE (profondeur 1 sûre).
-- =====================================================================
create or replace function public.freeze_comment_links()
returns trigger
language plpgsql
as $$
begin
  if new.shoot_id is distinct from old.shoot_id then
    raise exception 'shoot_id immuable';
  end if;
  if new.parent_id is distinct from old.parent_id then
    raise exception 'parent_id immuable';
  end if;
  if new.author_id is distinct from old.author_id then
    raise exception 'author_id immuable';
  end if;
  return new;
end;
$$;

create trigger shoot_comments_freeze_links
  before update on public.shoot_comments
  for each row execute function public.freeze_comment_links();

-- =====================================================================
-- F6 — accept_friend_request : refuser si blocage actif.
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
  if public.is_blocked(r.sender_id, r.receiver_id) then
    update public.friend_requests
      set status = 'cancelled', responded_at = now()
      where id = p_request_id;
    raise exception 'Blocage actif : amitié impossible';
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
-- F7 — shoot_media : le client n'insère que des sources (render/feed/thumb = backend).
-- =====================================================================
drop policy "shoot_media_insert_owner" on public.shoot_media;
create policy "shoot_media_insert_owner" on public.shoot_media
  for insert to authenticated
  with check (public.owns_shoot(shoot_id) and kind = 'source');

-- =====================================================================
-- F9 — avatars : lecture/écriture restreintes au fichier avatar canonique
-- ({uid}/avatar.<ext>), empêche d'héberger des fichiers arbitraires.
-- =====================================================================
drop policy "avatars_read" on storage.objects;
create policy "avatars_read" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'avatars'
    and array_length(storage.foldername(name), 1) = 1
    and storage.filename(name) ~ '^avatar\.(jpg|jpeg|png|webp)$'
  );

drop policy "avatars_insert_owner" on storage.objects;
create policy "avatars_insert_owner" on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and array_length(storage.foldername(name), 1) = 1
    and (storage.foldername(name))[1] = auth.uid()::text
    and storage.filename(name) ~ '^avatar\.(jpg|jpeg|png|webp)$'
  );

drop policy "avatars_update_owner" on storage.objects;
create policy "avatars_update_owner" on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(name))[1] = auth.uid()::text
    and storage.filename(name) ~ '^avatar\.(jpg|jpeg|png|webp)$'
  )
  with check (
    bucket_id = 'avatars'
    and array_length(storage.foldername(name), 1) = 1
    and (storage.foldername(name))[1] = auth.uid()::text
    and storage.filename(name) ~ '^avatar\.(jpg|jpeg|png|webp)$'
  );
