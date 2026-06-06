# Architecture monorepo

Take@Shoot est un monorepo depuis le départ (pnpm workspaces + Turborepo).

## Pourquoi
- Mobile et admin dépendent des mêmes contrats produit.
- Le schéma Supabase et les types générés doivent rester alignés avec le code.
- Les design tokens restent cohérents entre mobile et admin.
- La CI vérifie tout le projet depuis un seul endroit.

## Frontières
- `apps/mobile` : app Expo destinée aux utilisateurs (dark-only).
- `apps/admin` : back-office Next.js protégé.
- `packages/shared` : contrats TypeScript, constantes, schémas de validation Zod, **types de base générés** (`database.types.ts`).
- `packages/ui` : design tokens (et, plus tard, primitifs UI réellement cross-plateforme).
- `supabase` : migrations, fonctions, seeds, config locale, tests RLS.

## Règle
Les packages partagés contiennent des **contrats stables**, pas du comportement
spécifique à une app. Si du code n'a de sens que pour mobile ou admin, il reste
dans cette app.
