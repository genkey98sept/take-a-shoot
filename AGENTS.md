# Take@Shoot — Règles de travail (toutes IA)

Réseau social mobile de souvenirs « photobooth » (fermé, amis acceptés uniquement).
Monorepo pnpm/Turbo : `apps/mobile` (Expo SDK 56, **dark-only**), `apps/admin` (Next 16),
`packages/shared` (contrats + types DB), `packages/ui` (design tokens), `supabase` (DB/RLS/Storage).
**Réponds et documente en français.**

## 📚 Documentation — RÈGLE D'OR

**Une seule maison pour la doc technique durable : `docs/`. Index unique : `docs/README.md`.**

- Avant d'écrire de la doc : trouve le fichier existant qui couvre le sujet et **mets-le à jour**.
  Ne crée un nouveau fichier que si aucune catégorie ne convient — et **ajoute-le à `docs/README.md`**.
- **Pas d'éparpillement, pas de doublon, pas de doc morte.** Le strict nécessaire, haute densité
  d'information. Élague ce qui n'est plus vrai au lieu d'empiler.
- Où mettre quoi :

  | Sujet | Emplacement |
  |---|---|
  | Périmètre / règles produit | `docs/superpowers/specs/` |
  | Design (DA, palette, composants) | `docs/design/design-system.md` (+ `packages/ui/tokens.ts`) |
  | Base de données / RLS / Storage | `docs/architecture/database.md` |
  | Architecture (monorepo, backend) | `docs/architecture/` |
  | Mise en route / variables d'env | `docs/setup/` |
  | **État & handoff de session** | `Nextsession.md` (RACINE, local, gitignoré — **jamais** dans `docs/`) |

- `Nextsession.md` = mémoire de session (éphémère, locale, non versionnée).
  `docs/` = documentation durable (versionnée). Ne pas confondre les deux.

## 🔄 Cohérence obligatoire (à modifier ENSEMBLE)

- **Schéma DB** → migration `supabase/migrations/` **+** `docs/architecture/database.md` **+** types
  (`pnpm supabase:types`) **+** tests pgTAP `supabase/tests/`.
- **Design** → `docs/design/design-system.md` **+** `packages/ui/tokens.ts`.
- **Périmètre produit** → mettre à jour la spec MVP **avant** d'implémenter.
- **Fin de session** → mettre à jour `Nextsession.md` (état courant + prochain chantier).

## 🛠️ Méthodologie

- **Sécurité = serveur** : toute table a une RLS + policy (ou est service-role explicite, sans policy).
  Le schéma évolue **par migration uniquement**, jamais en direct.
- **Git** : 1 branche par phase → merge dans `main` à la fin ; commits atomiques
  (Conventional Commits). **L'utilisateur pousse lui-même** (ne pas `git push` sans demande).
- **Avant de pousser / clore une session** :
  `pnpm format:check && pnpm lint && pnpm typecheck && pnpm build && pnpm test`
  (+ `pnpm dlx supabase@latest db reset` & `test db` si la DB est touchée).
- **Invariants** : mobile **dark-only** ; deux roses `accent #FA195E` (UI) / `brand #E6215A` (logo)
  à ne **pas** fusionner ; service-role **jamais** côté client ; « Proches » **hors MVP** ;
  ne **jamais** committer `_BRAIN/`.
- **Stack bleeding-edge** : lire `apps/*/AGENTS.md` + la doc versionnée (Expo 56 / Next 16)
  avant de toucher ces zones.

## 🚀 Démarrer une session

1. Lire `Nextsession.md` (état + prochain chantier).
2. `docs/README.md` → le document précis du sujet.
3. Coder, puis vérifier (commandes ci-dessus) et mettre à jour la doc concernée.
