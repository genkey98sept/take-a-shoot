-- Take@Shoot — graphe social : demandes d'amis, amitiés (paire canonique), blocages.

-- =====================================================================
-- friend_requests
-- =====================================================================
create table public.friend_requests (
  id uuid primary key default gen_random_uuid(),
  sender_id uuid not null references public.profiles (id) on delete cascade,
  receiver_id uuid not null references public.profiles (id) on delete cascade,
  status public.friend_request_status not null default 'pending',
  created_at timestamptz not null default now(),
  responded_at timestamptz,
  constraint friend_requests_distinct check (sender_id <> receiver_id),
  constraint friend_requests_unique_pair unique (sender_id, receiver_id)
);

create index friend_requests_receiver_idx on public.friend_requests (receiver_id, status);
create index friend_requests_sender_idx on public.friend_requests (sender_id, status);

-- =====================================================================
-- friendships (paire canonique user_low < user_high => une seule ligne par paire)
-- =====================================================================
create table public.friendships (
  user_low uuid not null references public.profiles (id) on delete cascade,
  user_high uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_low, user_high),
  constraint friendships_ordered check (user_low < user_high)
);

-- Recherche dans le sens inverse (le sens user_low est couvert par la PK).
create index friendships_user_high_idx on public.friendships (user_high);

-- =====================================================================
-- blocks
-- =====================================================================
create table public.blocks (
  blocker_id uuid not null references public.profiles (id) on delete cascade,
  blocked_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  constraint blocks_distinct check (blocker_id <> blocked_id)
);

create index blocks_blocked_idx on public.blocks (blocked_id);

-- =====================================================================
-- RLS deny-by-default + GRANTs.
-- friendships : insert UNIQUEMENT via RPC SECURITY DEFINER accept_friend_request
-- (pas de grant insert direct). unfriend = delete d'une ligne dont on est membre.
-- =====================================================================
alter table public.friend_requests enable row level security;
alter table public.friendships enable row level security;
alter table public.blocks enable row level security;

grant select, insert, update on public.friend_requests to authenticated;
grant select, delete on public.friendships to authenticated;
grant select, insert, delete on public.blocks to authenticated;
