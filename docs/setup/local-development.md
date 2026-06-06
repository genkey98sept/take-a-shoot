# Développement local

## Prérequis
- Node compatible avec les `engines` du `package.json` racine (≥ 22.12).
- Corepack activé, pnpm activé via Corepack.
- Git.
- Docker Desktop (pour Supabase local).

## Première installation
```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
```

## Lancer les apps
```powershell
pnpm --dir apps/mobile dev   # app Expo
pnpm --dir apps/admin dev    # admin Next.js
pnpm dev                     # toutes les tâches dev (Turborepo)
```

## Supabase local
```powershell
pnpm supabase:start                  # démarre la stack (1er run : téléchargement d'images)
pnpm supabase:status                 # URLs + clés locales (voir setup/environment.md)
pnpm dlx supabase@latest db reset    # recrée la base + applique migrations + seed
pnpm dlx supabase@latest test db     # exécute les tests RLS (pgTAP)
pnpm supabase:types                  # régénère packages/shared/src/database.types.ts
```
Détails du schéma/RLS/Storage : [architecture/database.md](../architecture/database.md).

## Vérification (à passer avant de pousser)
```powershell
pnpm format:check
pnpm lint
pnpm typecheck
pnpm build
pnpm test
```
