-- Take@Shoot — Policies RLS (RLS déjà activée deny-by-default à la création des tables).
-- Rôle ciblé : authenticated. anon n'a aucun GRANT (app authentifiée uniquement).
-- moderation_alerts & admin_actions n'ont AUCUNE policy => service-role only.

-- =====================================================================
-- profiles : soi + amis (ligne complète). Vue pré-amitié limitée via RPC
-- search_profiles / get_public_profile (colonnes publiques seulement).
-- =====================================================================
create policy "profiles_select_self_or_friends" on public.profiles
  for select to authenticated
  using (
    id = auth.uid()
    or (public.are_friends(id, auth.uid()) and not public.is_blocked(id, auth.uid()))
  );

create policy "profiles_insert_self" on public.profiles
  for insert to authenticated
  with check (id = auth.uid());

create policy "profiles_update_self" on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

-- =====================================================================
-- notification_preferences : propriétaire uniquement.
-- =====================================================================
create policy "notif_prefs_all_self" on public.notification_preferences
  for select to authenticated using (user_id = auth.uid());
create policy "notif_prefs_insert_self" on public.notification_preferences
  for insert to authenticated with check (user_id = auth.uid());
create policy "notif_prefs_update_self" on public.notification_preferences
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- =====================================================================
-- friend_requests : émetteur ou destinataire. Envoi soumis à non-amitié + non-blocage.
-- =====================================================================
create policy "friend_requests_select_party" on public.friend_requests
  for select to authenticated
  using (sender_id = auth.uid() or receiver_id = auth.uid());

create policy "friend_requests_insert_sender" on public.friend_requests
  for insert to authenticated
  with check (
    sender_id = auth.uid()
    and sender_id <> receiver_id
    and status = 'pending'
    and not public.are_friends(sender_id, receiver_id)
    and not public.is_blocked(sender_id, receiver_id)
  );

create policy "friend_requests_update_party" on public.friend_requests
  for update to authenticated
  using (sender_id = auth.uid() or receiver_id = auth.uid())
  with check (sender_id = auth.uid() or receiver_id = auth.uid());

-- =====================================================================
-- friendships : membres uniquement (insert via RPC accept_friend_request).
-- =====================================================================
create policy "friendships_select_member" on public.friendships
  for select to authenticated
  using (user_low = auth.uid() or user_high = auth.uid());

create policy "friendships_delete_member" on public.friendships
  for delete to authenticated
  using (user_low = auth.uid() or user_high = auth.uid());

-- =====================================================================
-- blocks : le bloqueur uniquement (on ne révèle pas qui vous a bloqué).
-- =====================================================================
create policy "blocks_select_blocker" on public.blocks
  for select to authenticated using (blocker_id = auth.uid());
create policy "blocks_insert_blocker" on public.blocks
  for insert to authenticated with check (blocker_id = auth.uid() and blocker_id <> blocked_id);
create policy "blocks_delete_blocker" on public.blocks
  for delete to authenticated using (blocker_id = auth.uid());

-- =====================================================================
-- places : référentiel partagé, lisible par tous les authentifiés.
-- =====================================================================
create policy "places_select_all" on public.places
  for select to authenticated using (true);
create policy "places_insert_author" on public.places
  for insert to authenticated with check (created_by = auth.uid());

-- =====================================================================
-- mugshoots : propriétaire + amis non bloqués.
-- =====================================================================
create policy "mugshoots_select_owner_or_friends" on public.mugshoots
  for select to authenticated
  using (
    owner_id = auth.uid()
    or (public.are_friends(owner_id, auth.uid()) and not public.is_blocked(owner_id, auth.uid()))
  );
create policy "mugshoots_insert_owner" on public.mugshoots
  for insert to authenticated with check (owner_id = auth.uid());
create policy "mugshoots_update_owner" on public.mugshoots
  for update to authenticated using (owner_id = auth.uid()) with check (owner_id = auth.uid());
create policy "mugshoots_delete_owner" on public.mugshoots
  for delete to authenticated using (owner_id = auth.uid());

-- =====================================================================
-- shoots : propriétaire (toujours), ami non bloqué dans la fenêtre 24 h, ou tagué.
-- Publication (published_at non null) conditionnée à l'email vérifié.
-- =====================================================================
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
      or public.is_tagged(id, auth.uid())
    )
  );

create policy "shoots_insert_owner" on public.shoots
  for insert to authenticated
  with check (owner_id = auth.uid() and (published_at is null or public.is_email_verified()));

create policy "shoots_update_owner" on public.shoots
  for update to authenticated
  using (owner_id = auth.uid())
  with check (owner_id = auth.uid() and (published_at is null or public.is_email_verified()));

-- =====================================================================
-- shoot_media : visibilité alignée sur le Shoot. Insert = propriétaire du Shoot.
-- (rendu/feed/thumbnail écrits par le backend service-role.)
-- =====================================================================
create policy "shoot_media_select_visible" on public.shoot_media
  for select to authenticated using (public.can_view_shoot(shoot_id));
create policy "shoot_media_insert_owner" on public.shoot_media
  for insert to authenticated with check (public.owns_shoot(shoot_id));

-- =====================================================================
-- shoot_tags : visible si on voit le Shoot. Tag par le propriétaire sur un pote
-- accepté. Retrait par le propriétaire OU l'utilisateur tagué.
-- =====================================================================
create policy "shoot_tags_select_visible" on public.shoot_tags
  for select to authenticated using (public.can_view_shoot(shoot_id));
create policy "shoot_tags_insert_owner" on public.shoot_tags
  for insert to authenticated
  with check (
    public.owns_shoot(shoot_id)
    and public.are_friends(auth.uid(), tagged_user_id)
    and not public.is_blocked(auth.uid(), tagged_user_id)
  );
create policy "shoot_tags_delete_owner_or_tagged" on public.shoot_tags
  for delete to authenticated
  using (public.owns_shoot(shoot_id) or tagged_user_id = auth.uid());

-- =====================================================================
-- shoot_reactions : une seule active par user (PK). Réagir/changer sur Shoot visible.
-- =====================================================================
create policy "shoot_reactions_select_visible" on public.shoot_reactions
  for select to authenticated using (public.can_view_shoot(shoot_id));
create policy "shoot_reactions_insert_self" on public.shoot_reactions
  for insert to authenticated with check (user_id = auth.uid() and public.can_view_shoot(shoot_id));
create policy "shoot_reactions_update_self" on public.shoot_reactions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "shoot_reactions_delete_self" on public.shoot_reactions
  for delete to authenticated using (user_id = auth.uid());

-- =====================================================================
-- shoot_comments : visibles si on voit le Shoot (et non supprimés). Auteur édite les siens.
-- =====================================================================
create policy "shoot_comments_select_visible" on public.shoot_comments
  for select to authenticated using (deleted_at is null and public.can_view_shoot(shoot_id));
create policy "shoot_comments_insert_author" on public.shoot_comments
  for insert to authenticated with check (author_id = auth.uid() and public.can_view_shoot(shoot_id));
create policy "shoot_comments_update_author" on public.shoot_comments
  for update to authenticated using (author_id = auth.uid()) with check (author_id = auth.uid());

-- =====================================================================
-- notifications : destinataire (lecture + marquage lu). Création par backend/triggers.
-- =====================================================================
create policy "notifications_select_recipient" on public.notifications
  for select to authenticated using (recipient_id = auth.uid());
create policy "notifications_update_recipient" on public.notifications
  for update to authenticated using (recipient_id = auth.uid()) with check (recipient_id = auth.uid());

-- =====================================================================
-- reports : le rapporteur crée et voit les siens.
-- =====================================================================
create policy "reports_select_own" on public.reports
  for select to authenticated using (reporter_id = auth.uid());
create policy "reports_insert_own" on public.reports
  for insert to authenticated with check (reporter_id = auth.uid());

-- moderation_alerts & admin_actions : aucune policy => service-role only.
