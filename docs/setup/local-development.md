# Local Development

## Prerequisites

- Node compatible with the root `package.json` engines.
- Corepack enabled.
- pnpm activated through Corepack.
- Git.
- Docker Desktop for local Supabase.

## First Setup

```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
```

## Run Apps

Mobile:

```powershell
pnpm --dir apps/mobile dev
```

Admin:

```powershell
pnpm --dir apps/admin dev
```

All dev tasks:

```powershell
pnpm dev
```

## Supabase Local

```powershell
pnpm supabase:start
pnpm supabase:status
pnpm supabase:types
```

Copy local keys into app-specific `.env` files after `supabase:status`.

## Verification

```powershell
pnpm typecheck
pnpm lint
pnpm build
```
