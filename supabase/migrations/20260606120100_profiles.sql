-- Take@Shoot — profiles + notification_preferences.
-- L'identité d'auth (auth.users, email/mot de passe) est séparée de l'identité
-- publique (profiles.@pseudo). Un profil est créé pendant l'onboarding, pas au signup.

-- =====================================================================
-- profiles
-- =====================================================================
create table public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text not null,
  first_name text not null,
  country_code text not null,
  city text,
  bio text,
  avatar_path text,
  status public.account_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  deleted_at timestamptz,
  constraint profiles_username_format check (username ~ '^[a-z0-9_]{3,24}$'),
  constraint profiles_first_name_len check (char_length(first_name) between 1 and 60),
  constraint profiles_country_code_len check (char_length(country_code) = 2),
  constraint profiles_city_len check (city is null or char_length(city) <= 100),
  constraint profiles_bio_len check (bio is null or char_length(bio) <= 160)
);

-- Unicité du @pseudo, insensible à la casse (défense en profondeur ; l'app lowercase déjà).
create unique index profiles_username_lower_key on public.profiles (lower(username));
create index profiles_status_idx on public.profiles (status) where deleted_at is null;

create trigger profiles_set_updated_at
  before update on public.profiles
  for each row execute function public.set_updated_at();

-- =====================================================================
-- notification_preferences (une ligne par profil)
-- =====================================================================
create table public.notification_preferences (
  user_id uuid primary key references public.profiles (id) on delete cascade,
  friend_requests boolean not null default true,
  friend_accepted boolean not null default true,
  comments boolean not null default true,
  replies boolean not null default true,
  reactions boolean not null default true,
  tags boolean not null default true,
  product_reminders boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create trigger notification_preferences_set_updated_at
  before update on public.notification_preferences
  for each row execute function public.set_updated_at();

-- Crée des préférences par défaut dès la création du profil.
create or replace function public.handle_new_profile()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.notification_preferences (user_id)
  values (new.id)
  on conflict (user_id) do nothing;
  return new;
end;
$$;

create trigger profiles_create_notification_preferences
  after insert on public.profiles
  for each row execute function public.handle_new_profile();

-- =====================================================================
-- RLS deny-by-default (policies définies dans la migration RLS dédiée).
-- =====================================================================
alter table public.profiles enable row level security;
alter table public.notification_preferences enable row level security;

-- Privilèges table (auto_expose_new_tables = false => GRANTs explicites).
-- La RLS filtre ensuite les lignes. Pas de DELETE : suppression = soft delete / cascade auth.
grant select, insert, update on public.profiles to authenticated;
grant select, insert, update on public.notification_preferences to authenticated;
