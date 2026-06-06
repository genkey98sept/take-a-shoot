-- Take@Shoot — Storage : buckets PRIVÉS + policies miroir des règles RLS.
-- Convention de chemins (name, hors bucket) :
--   avatars   : {user_id}/avatar.jpg
--   mugshoots : {owner_id}/{mugshoot_id}/source_1.jpg | render.jpg
--   shoots    : {owner_id}/{shoot_id}/source_1.jpg | render.jpg | feed.jpg | thumb.jpg
-- Les originaux ne sont JAMAIS exposés en public (public = false partout).

insert into storage.buckets (id, name, public)
values
  ('avatars', 'avatars', false),
  ('mugshoots', 'mugshoots', false),
  ('shoots', 'shoots', false)
on conflict (id) do nothing;

-- =====================================================================
-- avatars : lecture par tout authentifié (affichés en recherche pré-amitié) ;
-- écriture réservée au propriétaire du dossier (folder[1] = uid).
-- =====================================================================
create policy "avatars_read" on storage.objects
  for select to authenticated
  using (bucket_id = 'avatars');

create policy "avatars_insert_owner" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars_update_owner" on storage.objects
  for update to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "avatars_delete_owner" on storage.objects
  for delete to authenticated
  using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

-- =====================================================================
-- mugshoots : lecture par le propriétaire OU un ami non bloqué ; écriture owner.
-- =====================================================================
create policy "mugshoots_read_owner_or_friends" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'mugshoots'
    and array_length(storage.foldername(name), 1) >= 1
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or (
        public.are_friends(((storage.foldername(name))[1])::uuid, auth.uid())
        and not public.is_blocked(((storage.foldername(name))[1])::uuid, auth.uid())
      )
    )
  );

create policy "mugshoots_insert_owner" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'mugshoots' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "mugshoots_update_owner" on storage.objects
  for update to authenticated
  using (bucket_id = 'mugshoots' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'mugshoots' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "mugshoots_delete_owner" on storage.objects
  for delete to authenticated
  using (bucket_id = 'mugshoots' and (storage.foldername(name))[1] = auth.uid()::text);

-- =====================================================================
-- shoots : lecture alignée sur can_view_shoot(shoot_id = folder[2]) ; écriture owner.
-- =====================================================================
create policy "shoots_read_can_view" on storage.objects
  for select to authenticated
  using (
    bucket_id = 'shoots'
    and array_length(storage.foldername(name), 1) >= 2
    and public.can_view_shoot(((storage.foldername(name))[2])::uuid)
  );

create policy "shoots_insert_owner" on storage.objects
  for insert to authenticated
  with check (bucket_id = 'shoots' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "shoots_update_owner" on storage.objects
  for update to authenticated
  using (bucket_id = 'shoots' and (storage.foldername(name))[1] = auth.uid()::text)
  with check (bucket_id = 'shoots' and (storage.foldername(name))[1] = auth.uid()::text);

create policy "shoots_delete_owner" on storage.objects
  for delete to authenticated
  using (bucket_id = 'shoots' and (storage.foldername(name))[1] = auth.uid()::text);
