# Take@Shoot

Take@Shoot is a mobile social network for instant photobooth memories.

## Current Status

The project is in MVP bootstrap. The validated product and architecture baseline is in:

```text
docs/superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md
```

## Monorepo

```text
apps/mobile   Expo mobile app
apps/admin    Next.js admin back-office
packages/shared  Shared product contracts and validation
packages/ui      Shared design tokens
supabase      Local Supabase project assets
docs          Product, architecture, and setup docs
```

## Commands

```powershell
pnpm install
pnpm dev
pnpm typecheck
pnpm lint
pnpm build
```

## Rules

- Do not commit real secrets.
- Keep `_BRAIN/` as untracked source material unless explicitly approved.
- Product scope changes must update the MVP spec before implementation.
