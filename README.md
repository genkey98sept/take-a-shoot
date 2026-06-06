<div align="center">

# 📸 Take@Shoot

**A closed social network for instant photobooth memories.**

> Memories disappear from the feed, not from your mind.

[![Expo](https://img.shields.io/badge/Expo-000020?logo=expo&logoColor=white)](https://expo.dev/)
[![Next.js](https://img.shields.io/badge/Next.js-000000?logo=next.js&logoColor=white)](https://nextjs.org/)
[![React Native](https://img.shields.io/badge/React_Native-20232A?logo=react&logoColor=61DAFB)](https://reactnative.dev/)
[![Supabase](https://img.shields.io/badge/Supabase-3FCF8E?logo=supabase&logoColor=white)](https://supabase.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-3178C6?logo=typescript&logoColor=white)](https://www.typescriptlang.org/)
[![pnpm](https://img.shields.io/badge/pnpm-F69220?logo=pnpm&logoColor=white)](https://pnpm.io/)
[![Turborepo](https://img.shields.io/badge/Turborepo-EF4444?logo=turborepo&logoColor=white)](https://turborepo.com/)

</div>

---

## ✨ What is Take@Shoot?

Take@Shoot is a **mobile-first social network of instant memories**. It borrows BeReal's spontaneity, but the central object is not a plain photo — it's a **digital photobooth memory**.

It is a **closed network between accepted friends** who capture real moments and turn them into aesthetic souvenirs that vanish from the feed after 24h but stay forever in your private archive.

Take@Shoot is **not** a creator network, a performance network, a public discovery feed, or a selfie app.

> 📄 The validated product and architecture baseline lives in
> [`docs/superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md`](docs/superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md).

---

## 🎯 MVP at a glance

| Area | What ships in the MVP |
| --- | --- |
| **Auth & identity** | Email + password auth, mandatory public profile with a unique `@handle` |
| **Onboarding** | Mandatory **MugShoot** (4 live burst photos) during sign-up |
| **Social graph** | Friend-only network — search by `@handle`, request / accept, reciprocal friendships |
| **Capture** | A **Shoot** = 4 live photos, front/back camera, no gallery import |
| **Rendering** | Fast local preview on mobile + canonical official render on the backend |
| **Templates & filters** | One official photobooth template, **Vintage** & **Black & White** filters (versioned, extensible) |
| **Feed** | Chronological, friends only, Shoots live for 24h then move to private memories |
| **Engagement** | One active reaction per Shoot, comments with one reply level, friend tags |
| **Memories** | Private archive of your Shoots + private `Tagged` section |
| **Localization** | City / country, optional venue, FR / EN / ES |
| **Moderation** | Block, report, soft-delete, admin back-office, non-blocking auto-alerts |

> Out of MVP scope: public feed, algorithmic ranking, ads, friend suggestions, DMs, stories, groups, videos, creative AI, interactive map.

---

## 🧱 Monorepo structure

```text
take-a-shoot/
├── apps/
│   ├── mobile/        # Expo + React Native app (Expo Router) — the product
│   └── admin/         # Next.js admin back-office (moderation & support)
├── packages/
│   ├── shared/        # Product contracts: types, Zod schemas, constants (reactions, filters, templates)
│   └── ui/            # Shared design tokens
├── supabase/          # Local Supabase project (config, migrations, functions)
├── docs/              # Product, architecture & setup documentation
│   ├── architecture/  # monorepo.md, supabase.md
│   ├── setup/         # environment.md, local-development.md
│   └── superpowers/   # validated specs & plans
├── turbo.json         # Turborepo pipeline
├── biome.json         # Formatter & linter config
└── pnpm-workspace.yaml
```

The monorepo keeps a **single source of truth** for product contracts so the mobile app, the admin app, and the backend never diverge.

---

## 🛠️ Tech stack

| Layer | Technology |
| --- | --- |
| **Mobile** | React Native · Expo · Expo Router · TypeScript |
| **Admin** | Next.js · React · TypeScript |
| **Backend** | Supabase (Postgres · Auth · Storage · Edge Functions) |
| **Authorization** | Postgres Row Level Security (RLS) |
| **Shared code** | TypeScript types, Zod validation schemas, design tokens |
| **Tooling** | pnpm workspaces · Turborepo · Biome · GitHub Actions CI |

---

## 🚀 Getting started

### Prerequisites

- **Node.js** `>= 22.12.0`
- **pnpm** `>= 10` (managed via Corepack — `packageManager` is pinned in `package.json`)
- **Git**
- **Docker Desktop** (for running Supabase locally)

### 1. Install

```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm install
```

### 2. Configure environment

Copy the example files and fill them with your local Supabase keys (never commit real secrets):

```powershell
Copy-Item .env.example .env
Copy-Item apps/mobile/.env.example apps/mobile/.env
Copy-Item apps/admin/.env.example  apps/admin/.env.local
```

> See [`docs/setup/environment.md`](docs/setup/environment.md) for the full variable reference.
> ⚠️ `SUPABASE_SERVICE_ROLE_KEY` must only ever live in server-only admin code — never in the mobile client.

### 3. Start Supabase (local)

```powershell
pnpm supabase:start     # boot the local stack
pnpm supabase:status    # print local URLs and keys
pnpm supabase:types     # generate typed DB schema into packages/shared
```

Copy the printed local keys into the app `.env` files after `supabase:status`.

### 4. Run the apps

```powershell
pnpm dev                      # run every app dev task via Turborepo
pnpm --dir apps/mobile dev    # Expo app only
pnpm --dir apps/admin dev     # Next.js admin only
```

---

## 📜 Scripts

Run from the repo root:

| Command | Description |
| --- | --- |
| `pnpm dev` | Run all dev tasks (Turborepo) |
| `pnpm build` | Build all apps & packages |
| `pnpm lint` | Lint the workspace |
| `pnpm typecheck` | Type-check the workspace |
| `pnpm test` | Run tests |
| `pnpm format` | Format with Biome (write) |
| `pnpm format:check` | Check formatting |
| `pnpm check` | Biome combined check |
| `pnpm supabase:start` / `:stop` / `:status` | Manage the local Supabase stack |
| `pnpm supabase:types` | Regenerate typed DB schema |

### Verify before pushing

```powershell
pnpm typecheck
pnpm lint
pnpm build
```

---

## 🔐 Architecture notes

- **Identity is split** — the auth identity (email/password) is separate from the public identity (`@handle`).
- **Privacy is enforced server-side** — RLS policies enforce friend visibility, ownership, tag access, and private archives. Client-side checks are never sufficient.
- **Media follows the same authorization model** as database rows; originals are never exposed as public files.
- **Templates & filters are versioned** — a published Shoot keeps the template/filter identity it was created with, so future additions never alter existing memories.
- **Soft delete everywhere** — content is hidden immediately and purged after a retention window (default 30 days).

📚 Deep dives: [`docs/architecture/monorepo.md`](docs/architecture/monorepo.md) · [`docs/architecture/supabase.md`](docs/architecture/supabase.md)

---

## 🗺️ Roadmap (post-MVP)

Candidates for V1.x: Apple & Google sign-in · a `Close friends` filter · more templates & filters · richer place provider · place/event pages · friends-of-friends visibility · advanced auto-moderation · a memories calendar · shared collections · push notification refinement.

Explicitly later (not MVP): DMs · stories · groups · videos · public discovery · ads · full map experience.

---

## 🤝 Conventions

- **Commits** follow [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `chore:`, `docs:`, `ci:` …).
- **Never commit real secrets** — only `.env.example` templates are tracked.
- **Product scope changes** must update the MVP spec *before* implementation.
- `_BRAIN/` and `Nextsession.md` are local-only working notes and stay untracked.

---

## 📄 License

Private and proprietary. All rights reserved.
