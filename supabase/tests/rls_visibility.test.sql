-- Take@Shoot — Tests RLS (pgTAP). Lancer : supabase test db
-- Prouve l'isolation : feed amis uniquement, fenêtre 24 h, originaux privés,
-- blocage, et droit d'insertion conditionné à la visibilité.

begin;
select plan(11);

-- ---------------------------------------------------------------------
-- Setup (rôle postgres : bypass RLS pour préparer les données).
-- 3 utilisateurs : A (auteur), B (ami de A), C (étranger).
-- ---------------------------------------------------------------------
insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values
  ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'a@test.dev', '', now(), now(), now()),
  ('00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'b@test.dev', '', now(), now(), now()),
  ('00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'c@test.dev', '', now(), now(), now());

insert into public.profiles (id, username, first_name, country_code) values
  ('00000000-0000-0000-0000-00000000000a', 'alice', 'Alice', 'FR'),
  ('00000000-0000-0000-0000-00000000000b', 'bob', 'Bob', 'FR'),
  ('00000000-0000-0000-0000-00000000000c', 'carol', 'Carol', 'FR');

-- A et B sont amis (paire canonique).
insert into public.friendships (user_low, user_high) values
  (least('00000000-0000-0000-0000-00000000000a'::uuid, '00000000-0000-0000-0000-00000000000b'::uuid),
   greatest('00000000-0000-0000-0000-00000000000a'::uuid, '00000000-0000-0000-0000-00000000000b'::uuid));

-- Shoot 1 d'Alice : publié maintenant (dans la fenêtre 24 h).
insert into public.shoots (id, owner_id, captured_at, published_at, processing_status)
values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', now(), now(), 'ready');

-- Shoot 2 d'Alice : publié il y a 25 h (hors fenêtre feed, mais reste en souvenir).
insert into public.shoots (id, owner_id, captured_at, published_at, processing_status)
values ('00000000-0000-0000-0000-0000000000a2', '00000000-0000-0000-0000-00000000000a', now() - interval '25 hours', now() - interval '25 hours', 'ready');

-- Médias du shoot 1 : 4 sources + 1 rendu.
insert into public.shoot_media (shoot_id, kind, position, storage_path) values
  ('00000000-0000-0000-0000-0000000000a1', 'source', 1, 'a/a1/s1.jpg'),
  ('00000000-0000-0000-0000-0000000000a1', 'source', 2, 'a/a1/s2.jpg'),
  ('00000000-0000-0000-0000-0000000000a1', 'source', 3, 'a/a1/s3.jpg'),
  ('00000000-0000-0000-0000-0000000000a1', 'source', 4, 'a/a1/s4.jpg'),
  ('00000000-0000-0000-0000-0000000000a1', 'render', null, 'a/a1/render.jpg');

-- ---------------------------------------------------------------------
-- Méta : RLS activée sur toutes les tables public.
-- ---------------------------------------------------------------------
select is(
  (select count(*)::int
   from pg_class c
   join pg_namespace n on n.oid = c.relnamespace
   where n.nspname = 'public' and c.relkind = 'r' and not c.relrowsecurity),
  0,
  'RLS activée sur toutes les tables public'
);

-- ---------------------------------------------------------------------
-- Vue propriétaire (Alice) : voit ses 2 Shoots (y compris l'expiré = souvenirs).
-- ---------------------------------------------------------------------
set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';

select is((select count(*)::int from public.shoots), 2, 'Alice voit ses 2 Shoots (feed + souvenir)');
select ok(public.can_view_shoot('00000000-0000-0000-0000-0000000000a1'), 'Alice peut voir son Shoot publié');

-- ---------------------------------------------------------------------
-- Ami (Bob) : voit le Shoot dans la fenêtre, PAS l'expiré ; voit les 5 médias.
-- ---------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';

select is((select count(*)::int from public.shoots), 1, 'Bob (ami) voit seulement le Shoot dans la fenêtre 24 h');
select is(
  (select count(*)::int from public.shoot_media where shoot_id = '00000000-0000-0000-0000-0000000000a1'),
  5,
  'Bob voit les 5 médias (4 sources + rendu) du Shoot visible'
);

-- ---------------------------------------------------------------------
-- Étranger (Carol) : ne voit AUCUN Shoot ni média.
-- ---------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';

select is((select count(*)::int from public.shoots), 0, 'Carol (non-amie) ne voit aucun Shoot');
select is((select count(*)::int from public.shoot_media), 0, 'Carol ne voit aucun média (originaux privés)');
select ok(not public.can_view_shoot('00000000-0000-0000-0000-0000000000a1'), 'can_view_shoot = false pour une non-amie');

-- Carol ne peut pas réagir à un Shoot qu'elle ne voit pas (WITH CHECK échoue).
select throws_ok(
  $$ insert into public.shoot_reactions (shoot_id, user_id, reaction)
     values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000c', 'love') $$,
  '42501',
  null,
  'Carol ne peut pas réagir à un Shoot invisible (RLS)'
);

-- ---------------------------------------------------------------------
-- Blocage : Alice bloque Bob -> Bob ne voit plus le Shoot d'Alice.
-- ---------------------------------------------------------------------
reset role;
insert into public.blocks (blocker_id, blocked_id)
values ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000b');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select is((select count(*)::int from public.shoots), 0, 'Après blocage, Bob ne voit plus le Shoot d''Alice');

-- ---------------------------------------------------------------------
-- Confidentialité profil : Carol ne lit pas la ligne profil complète d'Alice
-- (mais la RPC de découverte renvoie les colonnes publiques).
-- ---------------------------------------------------------------------
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';
select is(
  (select count(*)::int from public.profiles where id = '00000000-0000-0000-0000-00000000000a'),
  0,
  'Carol ne lit pas le profil complet d''une non-amie'
);

select * from finish();
rollback;
