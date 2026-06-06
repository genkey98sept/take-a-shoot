-- Take@Shoot — Tests RLS de durcissement (suite à la revue adversariale).
-- Couvre : blocage prime sur le tag (F1), transitions friend_requests (F3),
-- colonnes profil protégées (F4), liens commentaire figés (F5),
-- acceptation refusée si blocage (F6), kind média restreint (F7).

begin;
select plan(8);

-- Setup (postgres : bypass RLS).
insert into auth.users (id, instance_id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at)
values
  ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'a@h.dev', '', now(), now(), now()),
  ('00000000-0000-0000-0000-00000000000b', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'b@h.dev', '', now(), now(), now()),
  ('00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated', 'c@h.dev', '', now(), now(), now());

insert into public.profiles (id, username, first_name, country_code) values
  ('00000000-0000-0000-0000-00000000000a', 'alice', 'Alice', 'FR'),
  ('00000000-0000-0000-0000-00000000000b', 'bob', 'Bob', 'FR'),
  ('00000000-0000-0000-0000-00000000000c', 'carol', 'Carol', 'FR');

insert into public.friendships (user_low, user_high) values
  (least('00000000-0000-0000-0000-00000000000a'::uuid, '00000000-0000-0000-0000-00000000000b'::uuid),
   greatest('00000000-0000-0000-0000-00000000000a'::uuid, '00000000-0000-0000-0000-00000000000b'::uuid));

insert into public.shoots (id, owner_id, captured_at, published_at, processing_status)
values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', now(), now(), 'ready');

-- Bob est tagué sur le Shoot d'Alice.
insert into public.shoot_tags (shoot_id, tagged_user_id)
values ('00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000b');

-- Demande d'ami Carol -> Alice (pending).
insert into public.friend_requests (id, sender_id, receiver_id)
values ('00000000-0000-0000-0000-0000000000c1', '00000000-0000-0000-0000-00000000000c', '00000000-0000-0000-0000-00000000000a');

-- Commentaire d'Alice + réponse.
insert into public.shoot_comments (id, shoot_id, author_id, body)
values ('00000000-0000-0000-0000-0000000000d1', '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', 'top');
insert into public.shoot_comments (id, shoot_id, author_id, parent_id, body)
values ('00000000-0000-0000-0000-0000000000d2', '00000000-0000-0000-0000-0000000000a1', '00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-0000000000d1', 'reply');

-- ---------------------------------------------------------------------
set local role authenticated;

-- Sanity : Bob (ami + tagué) voit le Shoot AVANT blocage.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select ok(public.can_view_shoot('00000000-0000-0000-0000-0000000000a1'), 'Bob (ami+tagué) voit le Shoot avant blocage');

-- F4 : Alice ne peut pas changer son propre status.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select throws_ok(
  $$ update public.profiles set status = 'suspended' where id = '00000000-0000-0000-0000-00000000000a' $$,
  'P0001', null, 'F4 : un utilisateur ne peut pas modifier son status'
);

-- F5 : parent_id d'un commentaire est figé à l'UPDATE.
select throws_ok(
  $$ update public.shoot_comments set parent_id = '00000000-0000-0000-0000-0000000000d2'
     where id = '00000000-0000-0000-0000-0000000000d1' $$,
  'P0001', null, 'F5 : parent_id d''un commentaire est immuable (profondeur 1 sûre)'
);

-- F7 : un client ne peut pas insérer un média kind=render.
select throws_ok(
  $$ insert into public.shoot_media (shoot_id, kind, storage_path)
     values ('00000000-0000-0000-0000-0000000000a1', 'render', 'a/a1/render.jpg') $$,
  '42501', null, 'F7 : le client ne peut pas insérer un média render (réservé backend)'
);

-- F3 : Carol (émettrice) ne peut pas auto-accepter sa demande.
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000c","role":"authenticated"}';
select throws_ok(
  $$ update public.friend_requests set status = 'accepted'
     where id = '00000000-0000-0000-0000-0000000000c1' $$,
  '42501', null, 'F3 : l''émetteur ne peut pas passer sa demande à accepted'
);

-- F6 : Alice bloque Carol -> l'acceptation de la demande échoue.
reset role;
insert into public.blocks (blocker_id, blocked_id)
values ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000c');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000a","role":"authenticated"}';
select throws_ok(
  $$ select public.accept_friend_request('00000000-0000-0000-0000-0000000000c1') $$,
  'P0001', null, 'F6 : accept_friend_request refuse si blocage actif'
);

-- F1 : Alice bloque Bob -> le tag est purgé et le blocage prime.
reset role;
insert into public.blocks (blocker_id, blocked_id)
values ('00000000-0000-0000-0000-00000000000a', '00000000-0000-0000-0000-00000000000b');

set local role authenticated;
set local request.jwt.claims = '{"sub":"00000000-0000-0000-0000-00000000000b","role":"authenticated"}';
select ok(
  not public.can_view_shoot('00000000-0000-0000-0000-0000000000a1'),
  'F1 : après blocage, le tagué ne voit plus le Shoot (blocage prime sur tag)'
);

-- Vérif autoritaire de la purge du tag (postgres, hors RLS).
reset role;
select is(
  (select count(*)::int from public.shoot_tags where shoot_id = '00000000-0000-0000-0000-0000000000a1' and tagged_user_id = '00000000-0000-0000-0000-00000000000b'),
  0,
  'F1 : le tag est purgé lors du blocage'
);

select * from finish();
rollback;
