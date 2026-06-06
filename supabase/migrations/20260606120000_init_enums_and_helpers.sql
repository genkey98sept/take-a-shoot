-- Take@Shoot — Fondations du schéma : enums + helpers ne dépendant d'aucune table métier.
-- Postgres 17. gen_random_uuid() est natif (pas besoin de pgcrypto).
-- Les helpers référençant les tables métier sont créés après celles-ci
-- (voir 20260606120600_relations_helpers.sql).

-- =====================================================================
-- Enums (états de cycle de vie stables ; template/filtre restent en text extensible)
-- =====================================================================
create type public.account_status as enum ('active', 'suspended', 'deactivated');
create type public.friend_request_status as enum ('pending', 'accepted', 'declined', 'cancelled');
create type public.shoot_reaction as enum ('love', 'fire', 'wow', 'haha', 'cool');
create type public.shoot_visibility as enum ('friends');
create type public.processing_status as enum ('pending', 'processing', 'ready', 'failed');
create type public.media_kind as enum ('source', 'render', 'feed', 'thumbnail');
create type public.notification_type as enum (
  'friend_request', 'friend_accepted', 'comment', 'reply', 'reaction', 'tag', 'product_reminder'
);
create type public.report_target_type as enum ('shoot', 'comment', 'profile');
create type public.report_status as enum ('open', 'reviewing', 'resolved', 'dismissed');
create type public.moderation_alert_type as enum (
  'suspicious_text', 'spam', 'abnormal_volume', 'repeated_reports', 'image_risk'
);
create type public.moderation_alert_status as enum ('open', 'reviewed', 'dismissed');
create type public.admin_action_type as enum (
  'content_delete', 'content_restore', 'account_suspend', 'account_reactivate', 'report_resolve', 'note'
);

-- =====================================================================
-- Fonction trigger : maintien de updated_at
-- =====================================================================
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- =====================================================================
-- Helper : email vérifié pour l'utilisateur courant (gate de publication).
-- Ne dépend que de auth.users (déjà présent). security definer + search_path=''.
-- =====================================================================
create or replace function public.is_email_verified()
returns boolean
language sql
stable
security definer
set search_path = ''
as $$
  select exists (
    select 1
    from auth.users u
    where u.id = auth.uid()
      and u.email_confirmed_at is not null
  );
$$;

revoke all on function public.is_email_verified() from public;
grant execute on function public.is_email_verified() to authenticated;
