# Base de données, RLS & Storage — Take@Shoot

Référence technique du backend Supabase (Postgres 17). Décrit le schéma MVP, le
modèle de sécurité (RLS deny-by-default), le Storage privé et les règles métier
appliquées **côté serveur**.

> Statut : **implémenté** (Phase 2). Migrations versionnées dans
> `supabase/migrations/`, tests pgTAP dans `supabase/tests/`.

## 1. Mise en route

```powershell
pnpm supabase:start         # démarre la stack locale (Docker requis)
pnpm dlx supabase@latest db reset   # recrée la base + applique migrations + seed
pnpm dlx supabase@latest test db    # exécute les tests RLS (pgTAP)
pnpm supabase:types         # régénère packages/shared/src/database.types.ts
```

- Base locale : `postgresql://postgres:postgres@127.0.0.1:54322/postgres`.
- `auto_expose_new_tables = false` (config.toml) : **aucune table n'est exposée
  à l'API sans GRANT explicite**. Les migrations accordent les privilèges au rôle
  `authenticated` table par table ; `anon` n'a aucun accès (app authentifiée).

## 2. Conventions

- Clés primaires `uuid` (`gen_random_uuid()`), sauf `profiles.id` = `auth.users.id`.
- Horodatage : `created_at` / `updated_at` (trigger `set_updated_at`).
- **Soft delete** : colonne `deleted_at` (null = actif) sur le contenu ; purge
  réelle différée (job backend, voir §9).
- Enums Postgres pour les états stables ; `template`/`filter` en `text` + CHECK
  (extensibles, alignés sur `@take-a-shoot/shared`).

## 3. Entités

### Identité
| Table | Rôle | Points clés |
|---|---|---|
| `profiles` | Identité publique (≠ auth) | `id`→auth.users, `username` unique (insensible casse), `first_name`, `country_code`, `city`/`bio` opt., `avatar_path`, `status` (active/suspended/deactivated), `deleted_at` |
| `notification_preferences` | Préférences par catégorie | 1 ligne/profil, créée par trigger à la création du profil |

### Graphe social
| Table | Rôle | Points clés |
|---|---|---|
| `friend_requests` | Demandes d'ami | `sender`/`receiver`, `status` (pending/accepted/declined/cancelled), unique par paire |
| `friendships` | Amitiés acceptées | **paire canonique** `user_low < user_high` (1 ligne/paire) ; insert via RPC `accept_friend_request` |
| `blocks` | Blocages | `blocker`/`blocked` ; bidirectionnel via `is_blocked()` |

### Contenu
| Table | Rôle | Points clés |
|---|---|---|
| `places` | Lieux (référentiel partagé) | saisie libre ou fournisseur (`provider`/`provider_place_id`) |
| `mugshoots` | MugShoot d'onboarding | 1 actif/profil, `source_paths[4]` + `render_path`, `processing_status` |
| `shoots` | Publication principale | `owner`, `template`, `filter`, `visibility=friends`, lieu (`place_id`/`place_label`/`city`/`country_code`), `captured_at`, `published_at`, `processing_status`, `render_path`, `deleted_at`. Fenêtre feed = `published_at + 24h` (calculée) |
| `shoot_media` | Médias d'un Shoot | `kind` (source/render/feed/thumbnail), `position` (1-4 pour sources), `storage_path` |

### Engagement
| Table | Rôle | Points clés |
|---|---|---|
| `shoot_tags` | Tags de potes | PK (shoot, tagged_user) ; tag réservé aux amis acceptés |
| `shoot_reactions` | Réactions | **PK (shoot, user)** = une seule réaction active/user ; `reaction` (love/fire/wow/haha/cool) |
| `shoot_comments` | Commentaires | **profondeur 1** (trigger), `parent_id`, `deleted_at` |

### Notifications & modération
| Table | Rôle | Points clés |
|---|---|---|
| `notifications` | Notifs sociales + rappel | `type`, refs (`shoot`/`comment`/`friend_request`), `read_at` ; **max 1 rappel produit/jour** (unique index UTC) ; créées par backend/triggers |
| `reports` | Signalements | cible shoot/comment/profile (CHECK), `status` |
| `moderation_alerts` | Alertes auto (non bloquantes) | **service-role only** (aucune policy) |
| `admin_actions` | Journal d'actions sensibles | **service-role only** |

Enums : `account_status`, `friend_request_status`, `shoot_reaction`,
`shoot_visibility`, `processing_status`, `media_kind`, `notification_type`,
`report_target_type`, `report_status`, `moderation_alert_type`,
`moderation_alert_status`, `admin_action_type`.

## 4. Modèle de sécurité (RLS)

**Deny-by-default** : RLS activée sur toutes les tables `public` ; accès accordé
uniquement par des policies explicites. La confidentialité repose sur la base, pas
sur le client.

### Fonctions helper (`SECURITY DEFINER`, `search_path=''`)
Contournent la RLS des tables lues (évite la récursion de policy) ; `auth.uid()`
reste l'utilisateur courant.

| Fonction | Rôle |
|---|---|
| `are_friends(a,b)` | Amitié acceptée (paire canonique) |
| `is_blocked(a,b)` | Blocage dans un sens ou l'autre |
| `is_tagged(shoot,user)` | Tag présent |
| `owns_shoot(shoot)` | Propriétaire d'un Shoot non supprimé |
| `can_view_shoot(shoot)` | **Visibilité unifiée** : propriétaire OU (ami non bloqué, publié, fenêtre 24 h) OU (tagué, publié, non bloqué) |
| `is_email_verified()` | Email confirmé (gate de publication) |

### RPC (`SECURITY DEFINER`)
| RPC | Rôle |
|---|---|
| `accept_friend_request(id)` | Crée l'amitié + passe la demande à `accepted` (refuse si blocage) ; seul le destinataire d'une demande `pending` |
| `search_profiles(query)` | Recherche par `@pseudo` — **colonnes publiques uniquement** (id, username, first_name, avatar) |
| `get_public_profile(id)` | Carte publique pré-amitié d'un profil |

### Résumé des accès par table
| Table | Lecture | Écriture |
|---|---|---|
| `profiles` | soi + amis (ligne complète) ; non-amis via RPC (colonnes publiques) | soi (insert/update ; `status`/`deleted_at`/`id` protégés par trigger) |
| `friend_requests` | émetteur/destinataire | envoi (non-ami, non bloqué) ; **décliner**/**annuler** (transitions strictes) ; accept via RPC |
| `friendships` | membres | delete (unfriend) ; insert via RPC |
| `blocks` | le bloqueur | bloquer/débloquer |
| `places` | tous (authentifiés) | insert (auteur) |
| `mugshoots` | soi + amis non bloqués | propriétaire |
| `shoots` | `can_view_shoot` (inline) | propriétaire ; **publier conditionné à l'email vérifié** |
| `shoot_media` | `can_view_shoot` | propriétaire, `kind='source'` (render/feed/thumb = backend) |
| `shoot_tags` | `can_view_shoot` | tag par propriétaire (amis only) ; retrait propriétaire OU tagué |
| `shoot_reactions` | `can_view_shoot` | soi, sur Shoot visible |
| `shoot_comments` | `can_view_shoot` (non supprimés) | auteur ; `parent`/`shoot`/`author` figés (trigger) |
| `notifications` | destinataire | marquer lu ; création backend/triggers |
| `reports` | rapporteur | insert (rapporteur) |
| `moderation_alerts`, `admin_actions` | — | **service-role uniquement** |

## 5. Storage (buckets privés)

Tous `public = false`. Convention de chemins (hors bucket) :

| Bucket | Chemin | Lecture | Écriture |
|---|---|---|---|
| `avatars` | `{user}/avatar.<ext>` | tous (affichés en recherche) | propriétaire, nom canonique |
| `mugshoots` | `{owner}/{mugshoot}/…` | propriétaire + amis non bloqués | propriétaire |
| `shoots` | `{owner}/{shoot}/source_n\|render\|feed\|thumb.<ext>` | `can_view_shoot(shoot)` | propriétaire du Shoot, nom en liste blanche |

> Les 4 originaux ne sont **jamais** publics. La consultation des sources suit la
> visibilité du Shoot ; la restriction de **téléchargement** (propriétaire/tagué)
> est une feature applicative (voir §9).

## 6. Règles métier appliquées côté serveur

Feed = amis acceptés uniquement · fenêtre 24 h · originaux privés · 1 réaction
active/user/Shoot · profondeur commentaire 1 · profil pré-amitié restreint
(pseudo/prénom/avatar) · publication conditionnée à l'email vérifié · soft delete ·
blocage bidirectionnel (prime sur le tag) · tag réservé aux amis · rappel produit
≤ 1/jour · modération en service-role.

## 7. Durcissement sécurité (revue adversariale)

Migration `…120900_security_hardening.sql` (suite à une revue multi-agents) :
- **F1** : la branche taguée exige désormais publication + non-blocage ; trigger
  `purge_tags_on_block` retire les tags lors d'un blocage.
- **F3** : transitions `friend_requests` strictes (décliner/annuler) + identités
  immuables ; acceptation exclusivement via RPC.
- **F4** : `profiles.status`/`deleted_at`/`id` non modifiables par `authenticated`
  (le service-role/postgres passent → modération préservée).
- **F5** : `parent_id`/`shoot_id`/`author_id` d'un commentaire figés à l'UPDATE.
- **F6** : `accept_friend_request` refuse si blocage actif.
- **F7** : le client n'insère que `shoot_media.kind='source'`.
- **F2 (écriture)/F9** : upload Storage ciblant un Shoot possédé + noms en liste
  blanche ; bucket `avatars` restreint au fichier canonique.

## 8. Tests

`supabase test db` (pgTAP) — **19 assertions** :
- `rls_visibility.test.sql` (11) : RLS partout, propriétaire vs ami vs étranger,
  originaux privés, fenêtre 24 h, blocage, profil protégé, insert refusé.
- `rls_hardening.test.sql` (8) : blocage prime sur tag + purge, transitions
  friend_requests, colonnes profil protégées, liens commentaire figés,
  acceptation refusée si blocage, kind média restreint.

## 9. Différé (prochaines phases)

- **Téléchargement vs consultation** des originaux (export propriétaire/tagué) — feature Phase 4.
- **Purge asynchrone** des médias Storage au soft delete + rétention 30 j — job/Edge Function (Phase 5/6).
- **Triggers de création de notifications** (réaction/commentaire/tag/demande) — Phase 4.
- **Schémas zod d'entrée** (shoot, comment, reaction, report…) dans `@take-a-shoot/shared` — avec leurs features.
- **Durcissement auth** (`minimum_password_length ≥ 8`, `enable_confirmations=true`) — Phase 3.
- Hors MVP : niveau de relation « Proches ».
