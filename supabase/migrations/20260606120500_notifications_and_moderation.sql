-- Take@Shoot — notifications + modération (reports, alerts, admin_actions).

-- =====================================================================
-- notifications
-- Créées par triggers/backend (SECURITY DEFINER / service-role), pas par
-- insert direct des clients. L'utilisateur lit et marque comme lu les siennes.
-- =====================================================================
create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  recipient_id uuid not null references public.profiles (id) on delete cascade,
  actor_id uuid references public.profiles (id) on delete set null,
  type public.notification_type not null,
  shoot_id uuid references public.shoots (id) on delete cascade,
  comment_id uuid references public.shoot_comments (id) on delete cascade,
  friend_request_id uuid references public.friend_requests (id) on delete cascade,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create index notifications_recipient_idx on public.notifications (recipient_id, created_at desc);
create index notifications_unread_idx on public.notifications (recipient_id) where read_at is null;

-- Rappel produit : maximum 1 par jour (UTC) et par destinataire (garantie DB ;
-- le serveur applique aussi un rate-limit applicatif).
create unique index notifications_daily_reminder_key
  on public.notifications (recipient_id, ((created_at at time zone 'UTC')::date))
  where type = 'product_reminder';

-- =====================================================================
-- reports (signalements créés par les utilisateurs)
-- =====================================================================
create table public.reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid references public.profiles (id) on delete set null,
  target_type public.report_target_type not null,
  target_shoot_id uuid references public.shoots (id) on delete cascade,
  target_comment_id uuid references public.shoot_comments (id) on delete cascade,
  target_profile_id uuid references public.profiles (id) on delete cascade,
  reason text,
  details text,
  status public.report_status not null default 'open',
  created_at timestamptz not null default now(),
  resolved_at timestamptz,
  resolved_by uuid references public.profiles (id) on delete set null,
  constraint reports_target_matches check (
    (target_type = 'shoot'
      and target_shoot_id is not null and target_comment_id is null and target_profile_id is null)
    or (target_type = 'comment'
      and target_comment_id is not null and target_shoot_id is null and target_profile_id is null)
    or (target_type = 'profile'
      and target_profile_id is not null and target_shoot_id is null and target_comment_id is null)
  )
);

create index reports_status_idx on public.reports (status, created_at);
create index reports_reporter_idx on public.reports (reporter_id);

-- =====================================================================
-- moderation_alerts (détection automatique, non bloquante) — back-office only
-- =====================================================================
create table public.moderation_alerts (
  id uuid primary key default gen_random_uuid(),
  type public.moderation_alert_type not null,
  status public.moderation_alert_status not null default 'open',
  subject_profile_id uuid references public.profiles (id) on delete cascade,
  subject_shoot_id uuid references public.shoots (id) on delete cascade,
  subject_comment_id uuid references public.shoot_comments (id) on delete cascade,
  details jsonb,
  created_at timestamptz not null default now(),
  reviewed_at timestamptz,
  reviewed_by uuid references public.profiles (id) on delete set null
);

create index moderation_alerts_status_idx on public.moderation_alerts (status, created_at);

-- =====================================================================
-- admin_actions (journal des actions sensibles) — back-office only
-- =====================================================================
create table public.admin_actions (
  id uuid primary key default gen_random_uuid(),
  admin_id uuid references public.profiles (id) on delete set null,
  action_type public.admin_action_type not null,
  target_type text,
  target_id uuid,
  details jsonb,
  created_at timestamptz not null default now()
);

create index admin_actions_created_idx on public.admin_actions (created_at desc);

-- =====================================================================
-- RLS deny-by-default + GRANTs.
-- notifications : pas d'insert client (triggers/définer). select + update (read).
-- reports : insert + select (les siens).
-- moderation_alerts & admin_actions : AUCUN grant => service-role uniquement.
-- =====================================================================
alter table public.notifications enable row level security;
alter table public.reports enable row level security;
alter table public.moderation_alerts enable row level security;
alter table public.admin_actions enable row level security;

grant select, update on public.notifications to authenticated;
grant select, insert on public.reports to authenticated;
-- moderation_alerts / admin_actions : aucun GRANT à authenticated (service-role only).
