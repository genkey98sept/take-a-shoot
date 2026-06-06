# Take@Shoot — Back-office admin

Back-office d'administration **Next.js 16 (App Router) / React 19 / Tailwind CSS 4**, en TypeScript.
Modération, gestion des utilisateurs, file des signalements et alertes, journal des actions sensibles.

## Prérequis

- Node `>= 22.12`
- pnpm `>= 10`
- Dépendances installées depuis la **racine** du monorepo : `pnpm install`

## Démarrer

```bash
# depuis la racine du monorepo
pnpm --filter admin dev
# ou depuis apps/admin
pnpm dev
```

Ouvrir <http://localhost:3000>.

## Environnement & sécurité

Copier `.env.example` vers `.env.local` (jamais committé). La validation est faite par `src/env.ts` (zod), qui sépare :

- `publicEnv` — variables `NEXT_PUBLIC_*` (URL + clé **anon**), exposables au navigateur ;
- `serverEnv` — ajoute `SUPABASE_SERVICE_ROLE_KEY`, **strictement côté serveur**.

Le client service-role (`src/lib/supabase/server.ts`) est protégé par `import "server-only"` : toute tentative de l'importer dans un composant client casse le build. La clé service-role ne doit **jamais** atteindre le bundle navigateur.

## Structure

```text
src/
  app/        App Router (pages, layout)
  lib/
    supabase/ Clients Supabase (server.ts = service-role, server-only)
  env.ts      Validation et séparation public/serveur des variables d'env
next.config.ts  turbopack.root pointé sur la racine du monorepo
```

> ⚠️ Next.js 16 introduit des changements récents. Lire `AGENTS.md` et `node_modules/next/dist/docs/` avant de coder.
