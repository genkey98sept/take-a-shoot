# Setup Monorepo Bootstrap Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Bootstrap the Take@Shoot monorepo so the next development plans can implement the mobile app, admin app, Supabase backend, shared contracts, documentation, and CI on a clean foundation.

**Architecture:** Create a pnpm monorepo with `apps/mobile` for Expo, `apps/admin` for Next.js, `packages/shared` for product contracts and validation, `packages/ui` for design tokens, and `supabase` for local backend assets. Keep this session focused on tooling, project structure, docs, and verification; do not implement product features beyond foundational constants and schemas.

**Tech Stack:** pnpm workspaces, Turborepo, TypeScript, Biome, Expo + Expo Router, Next.js App Router, Supabase CLI, Zod, GitHub Actions.

---

## Required Context

Read this file first, then read:

- `docs/superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md`
- `_BRAIN/Project/TakeShoot CDC MVP V1.pdf`
- `_BRAIN/Project/visu/` only if visual context is needed

Current repo state before this plan:

- Git repo exists.
- MVP spec is committed at `9fcac2c docs: define Take@Shoot MVP scope`.
- `_BRAIN/` is untracked and must remain untracked unless the user explicitly asks to commit source assets.
- The next session should create a new branch before changing files.

Core product decisions already validated:

- Monorepo from the start.
- Mobile app: React Native + Expo + TypeScript + Expo Router.
- Admin app: Next.js + TypeScript.
- Backend: Supabase, Postgres, RLS, Storage, Edge Functions where needed.
- Auth MVP: email and password; `@pseudo` is public identity, not login identity.
- Feed MVP: accepted friends only, chronological, no algorithm, no suggestions.
- Capture MVP: live camera only, no gallery import.
- Media model: store 4 originals plus official rendered asset.
- Admin MVP: reporting, alerts, user/content moderation, protected web back-office.

Out of scope for this bootstrap session:

- Implementing auth flows.
- Implementing camera capture.
- Implementing feed, friends, comments, media rendering, RLS policies, or admin moderation flows.
- Connecting to production Supabase.
- Adding paid services or external providers.
- Committing `_BRAIN/`.

## Target File Map

The bootstrap session should create or modify these paths:

```text
.github/workflows/ci.yml
.editorconfig
.env.example
.gitignore
.npmrc
README.md
biome.json
package.json
pnpm-workspace.yaml
turbo.json
tsconfig.base.json
apps/mobile/
apps/mobile/.env.example
apps/mobile/app.config.ts
apps/mobile/src/env.ts
apps/mobile/src/lib/supabase.ts
apps/admin/
apps/admin/.env.example
apps/admin/src/env.ts
apps/admin/src/lib/supabase/server.ts
packages/shared/
packages/shared/package.json
packages/shared/tsconfig.json
packages/shared/src/index.ts
packages/shared/src/constants/filters.ts
packages/shared/src/constants/reactions.ts
packages/shared/src/constants/templates.ts
packages/shared/src/constants/visibility.ts
packages/shared/src/schemas/profile.ts
packages/ui/
packages/ui/package.json
packages/ui/tsconfig.json
packages/ui/src/index.ts
packages/ui/src/tokens.ts
supabase/
supabase/README.md
docs/setup/local-development.md
docs/setup/environment.md
docs/architecture/monorepo.md
docs/architecture/supabase.md
```

Generated scaffolds may create additional framework files inside `apps/mobile` and `apps/admin`; keep them if they are part of the official templates and do not conflict with this plan.

## Execution Rules

- Use PowerShell commands.
- Prefer `pnpm`.
- Use `apply_patch` for manual file edits.
- Commit after each completed task group.
- Keep `_BRAIN/` untracked.
- If a generated scaffold differs from this plan because tooling changed, adapt minimally and document the difference in the commit message body.
- If Docker is unavailable, still scaffold Supabase files and record in the final handoff that `supabase start` could not be verified.

---

### Task 1: Preflight And Branch

**Files:**

- Read: `docs/superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md`
- Modify: none

- [ ] **Step 1: Confirm repo status**

Run:

```powershell
git status --short
```

Expected:

```text
?? _BRAIN/
```

If other files appear, inspect them before continuing. Do not overwrite user work.

- [ ] **Step 2: Create setup branch**

Run:

```powershell
git switch -c setup/monorepo-bootstrap
```

Expected:

```text
Switched to a new branch 'setup/monorepo-bootstrap'
```

- [ ] **Step 3: Check toolchain**

Run:

```powershell
node --version
npm --version
git --version
```

Expected:

- Node prints a recent version compatible with Expo and Next.js.
- npm prints a version.
- git prints a version.

If Node is missing or too old for current Expo/Next templates, stop and tell the user to install/update Node before continuing.

- [ ] **Step 4: Activate pnpm through Corepack**

Run:

```powershell
corepack enable
corepack prepare pnpm@latest --activate
pnpm --version
```

Expected:

- `pnpm --version` prints a version.

- [ ] **Step 5: Commit checkpoint only if no files changed**

Run:

```powershell
git status --short
```

Expected:

```text
?? _BRAIN/
```

No commit is needed for this task because it should not change tracked files.

---

### Task 2: Root Monorepo Tooling

**Files:**

- Create: `package.json`
- Create: `pnpm-workspace.yaml`
- Create: `turbo.json`
- Create: `tsconfig.base.json`
- Create: `biome.json`
- Create: `.editorconfig`
- Create: `.npmrc`
- Create: `.gitignore`
- Create: `.env.example`

- [ ] **Step 1: Create root config files**

Use `apply_patch` to create these files.

`package.json`:

```json
{
  "name": "take-a-shoot",
  "private": true,
  "version": "0.0.0",
  "description": "Take@Shoot monorepo for mobile app, admin app, shared contracts, and Supabase backend.",
  "scripts": {
    "dev": "turbo dev",
    "build": "turbo build",
    "lint": "turbo lint",
    "format": "biome format . --write",
    "format:check": "biome format .",
    "check": "biome check .",
    "typecheck": "turbo typecheck",
    "test": "turbo test",
    "supabase:start": "pnpm dlx supabase@latest start",
    "supabase:stop": "pnpm dlx supabase@latest stop",
    "supabase:status": "pnpm dlx supabase@latest status",
    "supabase:types": "pnpm dlx supabase@latest gen types typescript --local --schema public > packages/shared/src/database.types.ts"
  },
  "devDependencies": {
    "@biomejs/biome": "latest",
    "turbo": "latest",
    "typescript": "latest"
  },
  "engines": {
    "node": ">=22.12.0",
    "pnpm": ">=10.0.0"
  }
}
```

`pnpm-workspace.yaml`:

```yaml
packages:
  - "apps/*"
  - "packages/*"
```

`turbo.json`:

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "dev": {
      "cache": false,
      "persistent": true
    },
    "build": {
      "dependsOn": ["^build"],
      "outputs": [".next/**", "dist/**", "build/**"]
    },
    "lint": {
      "dependsOn": ["^lint"]
    },
    "typecheck": {
      "dependsOn": ["^typecheck"]
    },
    "test": {
      "dependsOn": ["^test"]
    }
  }
}
```

`tsconfig.base.json`:

```json
{
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "allowJs": false,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "baseUrl": ".",
    "paths": {
      "@take-a-shoot/shared": ["packages/shared/src/index.ts"],
      "@take-a-shoot/ui": ["packages/ui/src/index.ts"]
    }
  }
}
```

`biome.json`:

```json
{
  "$schema": "https://biomejs.dev/schemas/2.0.0/schema.json",
  "formatter": {
    "enabled": true,
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 100
  },
  "linter": {
    "enabled": true,
    "rules": {
      "recommended": true,
      "correctness": {
        "noUnusedImports": "error",
        "noUnusedVariables": "warn"
      },
      "style": {
        "useImportType": "warn"
      }
    }
  },
  "javascript": {
    "formatter": {
      "quoteStyle": "double",
      "semicolons": "always",
      "trailingCommas": "all"
    }
  },
  "json": {
    "formatter": {
      "trailingCommas": "none"
    }
  },
  "files": {
    "ignoreUnknown": true,
    "includes": [
      "**",
      "!**/.next/**",
      "!**/.expo/**",
      "!**/node_modules/**",
      "!**/dist/**",
      "!**/build/**",
      "!**/coverage/**",
      "!**/ios/**",
      "!**/android/**"
    ]
  }
}
```

`.editorconfig`:

```ini
root = true

[*]
charset = utf-8
end_of_line = lf
indent_style = space
indent_size = 2
insert_final_newline = true
trim_trailing_whitespace = true

[*.md]
trim_trailing_whitespace = false
```

`.npmrc`:

```ini
auto-install-peers=true
strict-peer-dependencies=false
shared-workspace-lockfile=true
```

`.gitignore`:

```gitignore
# Dependencies
node_modules/
.pnpm-store/

# Build output
dist/
build/
.next/
.expo/
.turbo/
coverage/

# Native generated folders
apps/mobile/ios/
apps/mobile/android/

# Environment
.env
.env.*
!.env.example
!apps/*/.env.example

# Logs
*.log
npm-debug.log*
pnpm-debug.log*
yarn-debug.log*
yarn-error.log*

# OS/editor
.DS_Store
Thumbs.db
.idea/
.vscode/

# Supabase local runtime
supabase/.branches/
supabase/.temp/
```

`.env.example`:

```dotenv
# Shared local development values.
# Copy this file to .env only for local use. Never commit real secrets.

APP_ENV=development
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=replace-with-local-anon-key-after-supabase-start
SUPABASE_SERVICE_ROLE_KEY=replace-with-local-service-role-key-after-supabase-start
```

- [ ] **Step 2: Install root dependencies**

Run:

```powershell
pnpm install
```

Expected:

- `pnpm-lock.yaml` is created.
- `node_modules/` is created and ignored by git.

- [ ] **Step 3: Set exact package manager metadata**

Run:

```powershell
$pnpmVersion = pnpm --version
pnpm pkg set packageManager="pnpm@$pnpmVersion"
```

Expected:

- `package.json` now contains a `packageManager` value like `pnpm@10.x.x`.

- [ ] **Step 4: Verify root tooling**

Run:

```powershell
pnpm check
pnpm format:check
```

Expected:

- Commands complete without errors.

- [ ] **Step 5: Commit root tooling**

Run:

```powershell
git add package.json pnpm-lock.yaml pnpm-workspace.yaml turbo.json tsconfig.base.json biome.json .editorconfig .npmrc .gitignore .env.example
git commit -m "chore: bootstrap monorepo tooling"
```

Expected:

- Commit succeeds.

---

### Task 3: Shared Contracts Package

**Files:**

- Create: `packages/shared/package.json`
- Create: `packages/shared/tsconfig.json`
- Create: `packages/shared/src/index.ts`
- Create: `packages/shared/src/constants/filters.ts`
- Create: `packages/shared/src/constants/reactions.ts`
- Create: `packages/shared/src/constants/templates.ts`
- Create: `packages/shared/src/constants/visibility.ts`
- Create: `packages/shared/src/schemas/profile.ts`

- [ ] **Step 1: Create shared package files**

Use `apply_patch` to create these files.

`packages/shared/package.json`:

```json
{
  "name": "@take-a-shoot/shared",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json --noEmit",
    "lint": "biome check .",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "test": "node -e \"console.log('No shared tests required for bootstrap')\""
  },
  "dependencies": {
    "zod": "latest"
  },
  "devDependencies": {
    "typescript": "latest"
  }
}
```

`packages/shared/tsconfig.json`:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "baseUrl": "."
  },
  "include": ["src/**/*.ts"]
}
```

`packages/shared/src/constants/reactions.ts`:

```ts
export const SHOOT_REACTIONS = ["love", "fire", "wow", "haha", "cool"] as const;

export type ShootReaction = (typeof SHOOT_REACTIONS)[number];

export const SHOOT_REACTION_LABELS: Record<ShootReaction, string> = {
  love: "J'adore",
  fire: "Feu",
  wow: "Wow",
  haha: "Haha",
  cool: "Cool",
};
```

`packages/shared/src/constants/filters.ts`:

```ts
export const SHOOT_FILTERS = ["vintage", "black_and_white"] as const;

export type ShootFilter = (typeof SHOOT_FILTERS)[number];

export const SHOOT_FILTER_LABELS: Record<ShootFilter, string> = {
  vintage: "Vintage",
  black_and_white: "Noir & Blanc",
};
```

`packages/shared/src/constants/templates.ts`:

```ts
export const SHOOT_TEMPLATES = ["take_shoot_classic_v1"] as const;

export type ShootTemplate = (typeof SHOOT_TEMPLATES)[number];

export const DEFAULT_SHOOT_TEMPLATE: ShootTemplate = "take_shoot_classic_v1";
```

`packages/shared/src/constants/visibility.ts`:

```ts
export const SHOOT_VISIBILITIES = ["friends"] as const;

export type ShootVisibility = (typeof SHOOT_VISIBILITIES)[number];

export const DEFAULT_SHOOT_VISIBILITY: ShootVisibility = "friends";

export const FEED_VISIBILITY_HOURS = 24;
```

`packages/shared/src/schemas/profile.ts`:

```ts
import { z } from "zod";

export const usernameSchema = z
  .string()
  .trim()
  .min(3, "Le pseudo doit contenir au moins 3 caracteres.")
  .max(24, "Le pseudo doit contenir au maximum 24 caracteres.")
  .regex(
    /^[a-zA-Z0-9_]+$/,
    "Le pseudo peut contenir uniquement lettres, chiffres et underscores.",
  )
  .transform((value) => value.toLowerCase());

export const profileDraftSchema = z.object({
  firstName: z.string().trim().min(1).max(60),
  username: usernameSchema,
  countryCode: z.string().trim().length(2),
  city: z.string().trim().max(100).optional(),
  bio: z.string().trim().max(160).optional(),
});

export type ProfileDraft = z.infer<typeof profileDraftSchema>;
```

`packages/shared/src/index.ts`:

```ts
export * from "./constants/filters";
export * from "./constants/reactions";
export * from "./constants/templates";
export * from "./constants/visibility";
export * from "./schemas/profile";
```

- [ ] **Step 2: Install workspace dependencies**

Run:

```powershell
pnpm install
```

Expected:

- `zod` is installed for `packages/shared`.

- [ ] **Step 3: Typecheck shared package**

Run:

```powershell
pnpm --filter @take-a-shoot/shared typecheck
```

Expected:

- TypeScript exits successfully.

- [ ] **Step 4: Commit shared package**

Run:

```powershell
git add packages/shared package.json pnpm-lock.yaml
git commit -m "chore: add shared product contracts"
```

Expected:

- Commit succeeds.

---

### Task 4: UI Tokens Package

**Files:**

- Create: `packages/ui/package.json`
- Create: `packages/ui/tsconfig.json`
- Create: `packages/ui/src/index.ts`
- Create: `packages/ui/src/tokens.ts`

- [ ] **Step 1: Create UI package files**

Use `apply_patch` to create these files.

`packages/ui/package.json`:

```json
{
  "name": "@take-a-shoot/ui",
  "version": "0.0.0",
  "private": true,
  "type": "module",
  "main": "./src/index.ts",
  "types": "./src/index.ts",
  "scripts": {
    "build": "tsc -p tsconfig.json --noEmit",
    "lint": "biome check .",
    "typecheck": "tsc -p tsconfig.json --noEmit",
    "test": "node -e \"console.log('No UI tests required for bootstrap')\""
  },
  "devDependencies": {
    "typescript": "latest"
  }
}
```

`packages/ui/tsconfig.json`:

```json
{
  "extends": "../../tsconfig.base.json",
  "compilerOptions": {
    "rootDir": "src",
    "baseUrl": "."
  },
  "include": ["src/**/*.ts"]
}
```

`packages/ui/src/tokens.ts`:

```ts
export const colors = {
  background: "#050608",
  surface: "#101216",
  surfaceElevated: "#181B21",
  border: "#2A2E37",
  text: "#FFFFFF",
  textMuted: "#A5A8B1",
  textSubtle: "#6F737C",
  brand: "#FF2D6F",
  brandPressed: "#D91E59",
  success: "#35D07F",
  warning: "#FFB84D",
  danger: "#FF4D4D",
} as const;

export const spacing = {
  0: 0,
  1: 4,
  2: 8,
  3: 12,
  4: 16,
  5: 20,
  6: 24,
  8: 32,
  10: 40,
  12: 48,
  16: 64,
} as const;

export const radii = {
  sm: 6,
  md: 8,
  lg: 12,
  xl: 20,
  pill: 999,
} as const;

export const typography = {
  fontFamily: {
    sans: "System",
  },
  size: {
    xs: 12,
    sm: 14,
    md: 16,
    lg: 20,
    xl: 28,
    display: 36,
  },
  weight: {
    regular: "400",
    medium: "500",
    semibold: "600",
    bold: "700",
  },
} as const;

export const tokens = {
  colors,
  spacing,
  radii,
  typography,
} as const;
```

`packages/ui/src/index.ts`:

```ts
export * from "./tokens";
```

- [ ] **Step 2: Typecheck UI package**

Run:

```powershell
pnpm --filter @take-a-shoot/ui typecheck
```

Expected:

- TypeScript exits successfully.

- [ ] **Step 3: Commit UI tokens**

Run:

```powershell
git add packages/ui
git commit -m "chore: add shared design tokens"
```

Expected:

- Commit succeeds.

---

### Task 5: Expo Mobile App Scaffold

**Files:**

- Create/Generate: `apps/mobile/`
- Modify: `apps/mobile/package.json`
- Modify: `apps/mobile/app.config.ts`
- Create: `apps/mobile/.env.example`
- Create: `apps/mobile/src/env.ts`
- Create: `apps/mobile/src/lib/supabase.ts`

- [ ] **Step 1: Generate Expo app**

Run:

```powershell
pnpm dlx create-expo-app@latest apps/mobile --template default@sdk-56
```

Expected:

- `apps/mobile` is created.
- The generated app uses TypeScript and Expo Router.

If the exact SDK template is unavailable, run:

```powershell
pnpm dlx create-expo-app@latest apps/mobile --template default
```

Then record the generated Expo SDK version in the final handoff.

- [ ] **Step 2: Install mobile dependencies**

Run:

```powershell
pnpm --dir apps/mobile expo install expo-camera expo-image expo-location expo-notifications expo-secure-store expo-file-system expo-image-manipulator expo-media-library expo-haptics
pnpm --dir apps/mobile add @supabase/supabase-js react-native-url-polyfill zod "@take-a-shoot/shared@workspace:*" "@take-a-shoot/ui@workspace:*"
```

Expected:

- Expo-compatible native packages are installed.
- Supabase client and workspace packages are installed.

- [ ] **Step 3: Normalize mobile scripts**

Modify `apps/mobile/package.json` so scripts include at least:

```json
{
  "scripts": {
    "dev": "expo start",
    "start": "expo start",
    "android": "expo start --android",
    "ios": "expo start --ios",
    "web": "expo start --web",
    "lint": "expo lint",
    "typecheck": "tsc --noEmit",
    "test": "node -e \"console.log('No mobile tests required for bootstrap')\""
  }
}
```

Keep other generated fields and dependencies.

- [ ] **Step 4: Add mobile app config**

Create or replace `apps/mobile/app.config.ts`:

```ts
import type { ExpoConfig } from "expo/config";

const config: ExpoConfig = {
  name: "Take@Shoot",
  slug: "take-a-shoot",
  scheme: "takeashoot",
  version: "0.1.0",
  orientation: "portrait",
  userInterfaceStyle: "dark",
  icon: "./assets/images/icon.png",
  splash: {
    image: "./assets/images/splash-icon.png",
    resizeMode: "contain",
    backgroundColor: "#050608",
  },
  ios: {
    supportsTablet: false,
    bundleIdentifier: "app.takeashoot.mobile",
    infoPlist: {
      NSCameraUsageDescription:
        "Take@Shoot utilise la camera pour capturer tes Shoots et MugShoots.",
      NSLocationWhenInUseUsageDescription:
        "Take@Shoot utilise ta position pour proposer la ville, le pays et les lieux proches.",
      NSPhotoLibraryAddUsageDescription:
        "Take@Shoot peut enregistrer tes Shoots dans ta galerie quand tu le demandes.",
    },
  },
  android: {
    package: "app.takeashoot.mobile",
    permissions: [
      "CAMERA",
      "ACCESS_COARSE_LOCATION",
      "ACCESS_FINE_LOCATION",
      "WRITE_EXTERNAL_STORAGE",
    ],
  },
  experiments: {
    typedRoutes: true,
  },
  extra: {
    appEnv: process.env.EXPO_PUBLIC_APP_ENV ?? "development",
    supabaseUrl: process.env.EXPO_PUBLIC_SUPABASE_URL,
  },
};

export default config;
```

- [ ] **Step 5: Add mobile env files**

`apps/mobile/.env.example`:

```dotenv
EXPO_PUBLIC_APP_ENV=development
EXPO_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
EXPO_PUBLIC_SUPABASE_ANON_KEY=replace-with-local-anon-key-after-supabase-start
```

`apps/mobile/src/env.ts`:

```ts
import { z } from "zod";

const envSchema = z.object({
  EXPO_PUBLIC_APP_ENV: z.enum(["development", "staging", "production"]).default("development"),
  EXPO_PUBLIC_SUPABASE_URL: z.string().url(),
  EXPO_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
});

export const env = envSchema.parse({
  EXPO_PUBLIC_APP_ENV: process.env.EXPO_PUBLIC_APP_ENV,
  EXPO_PUBLIC_SUPABASE_URL: process.env.EXPO_PUBLIC_SUPABASE_URL,
  EXPO_PUBLIC_SUPABASE_ANON_KEY: process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY,
});
```

`apps/mobile/src/lib/supabase.ts`:

```ts
import "react-native-url-polyfill/auto";

import AsyncStorage from "@react-native-async-storage/async-storage";
import { createClient } from "@supabase/supabase-js";

import { env } from "../env";

export const supabase = createClient(env.EXPO_PUBLIC_SUPABASE_URL, env.EXPO_PUBLIC_SUPABASE_ANON_KEY, {
  auth: {
    storage: AsyncStorage,
    autoRefreshToken: true,
    persistSession: true,
    detectSessionInUrl: false,
  },
});
```

- [ ] **Step 6: Install missing AsyncStorage if needed**

Run:

```powershell
pnpm --dir apps/mobile expo install @react-native-async-storage/async-storage
```

Expected:

- AsyncStorage package is installed for Supabase session persistence.

- [ ] **Step 7: Typecheck mobile**

Run:

```powershell
pnpm --filter mobile typecheck
```

If the generated Expo app package name is not `mobile`, use:

```powershell
pnpm --dir apps/mobile typecheck
```

Expected:

- TypeScript exits successfully.

- [ ] **Step 8: Commit mobile scaffold**

Run:

```powershell
git add apps/mobile package.json pnpm-lock.yaml
git commit -m "chore: scaffold Expo mobile app"
```

Expected:

- Commit succeeds.

---

### Task 6: Next.js Admin App Scaffold

**Files:**

- Create/Generate: `apps/admin/`
- Modify: `apps/admin/package.json`
- Create: `apps/admin/.env.example`
- Create: `apps/admin/src/env.ts`
- Create: `apps/admin/src/lib/supabase/server.ts`

- [ ] **Step 1: Generate Next.js admin app**

Run:

```powershell
pnpm create next-app@latest apps/admin --yes --ts --tailwind --eslint --app --src-dir --import-alias "@/*"
```

Expected:

- `apps/admin` is created.
- The app uses TypeScript, App Router, Tailwind, ESLint config from scaffold, and `src/`.

- [ ] **Step 2: Install admin dependencies**

Run:

```powershell
pnpm --dir apps/admin add @supabase/ssr @supabase/supabase-js zod lucide-react server-only "@take-a-shoot/shared@workspace:*" "@take-a-shoot/ui@workspace:*"
```

Expected:

- Supabase SSR/client packages, Zod, icons, and workspace packages are installed.

- [ ] **Step 3: Normalize admin scripts**

Modify `apps/admin/package.json` so scripts include at least:

```json
{
  "scripts": {
    "dev": "next dev --turbopack",
    "build": "next build",
    "start": "next start",
    "lint": "biome check .",
    "typecheck": "tsc --noEmit",
    "test": "node -e \"console.log('No admin tests required for bootstrap')\""
  }
}
```

Keep generated dependencies and framework config.

- [ ] **Step 4: Add admin env validation**

`apps/admin/.env.example`:

```dotenv
NEXT_PUBLIC_APP_ENV=development
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=replace-with-local-anon-key-after-supabase-start
SUPABASE_SERVICE_ROLE_KEY=replace-with-local-service-role-key-after-supabase-start
```

`apps/admin/src/env.ts`:

```ts
import { z } from "zod";

const publicEnvSchema = z.object({
  NEXT_PUBLIC_APP_ENV: z.enum(["development", "staging", "production"]).default("development"),
  NEXT_PUBLIC_SUPABASE_URL: z.string().url(),
  NEXT_PUBLIC_SUPABASE_ANON_KEY: z.string().min(1),
});

const serverEnvSchema = publicEnvSchema.extend({
  SUPABASE_SERVICE_ROLE_KEY: z.string().min(1),
});

export const publicEnv = publicEnvSchema.parse({
  NEXT_PUBLIC_APP_ENV: process.env.NEXT_PUBLIC_APP_ENV,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
});

export const serverEnv = serverEnvSchema.parse({
  NEXT_PUBLIC_APP_ENV: process.env.NEXT_PUBLIC_APP_ENV,
  NEXT_PUBLIC_SUPABASE_URL: process.env.NEXT_PUBLIC_SUPABASE_URL,
  NEXT_PUBLIC_SUPABASE_ANON_KEY: process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY,
  SUPABASE_SERVICE_ROLE_KEY: process.env.SUPABASE_SERVICE_ROLE_KEY,
});
```

- [ ] **Step 5: Add server-only Supabase service client**

`apps/admin/src/lib/supabase/server.ts`:

```ts
import "server-only";

import { createClient } from "@supabase/supabase-js";

import { serverEnv } from "@/env";

export const createAdminSupabaseClient = () =>
  createClient(serverEnv.NEXT_PUBLIC_SUPABASE_URL, serverEnv.SUPABASE_SERVICE_ROLE_KEY, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
```

- [ ] **Step 6: Typecheck admin**

Run:

```powershell
pnpm --dir apps/admin typecheck
```

Expected:

- TypeScript exits successfully.

- [ ] **Step 7: Commit admin scaffold**

Run:

```powershell
git add apps/admin package.json pnpm-lock.yaml
git commit -m "chore: scaffold Next admin app"
```

Expected:

- Commit succeeds.

---

### Task 7: Supabase Local Project Skeleton

**Files:**

- Create/Generate: `supabase/config.toml`
- Create: `supabase/README.md`

- [ ] **Step 1: Initialize Supabase CLI files**

Run:

```powershell
pnpm dlx supabase@latest init
```

Expected:

- `supabase/config.toml` is created.

If the command says Supabase is already initialized, continue.

- [ ] **Step 2: Add Supabase README**

Use `apply_patch` to create `supabase/README.md`:

````md
# Supabase - Take@Shoot

This folder contains local Supabase assets for Take@Shoot.

## Scope For Bootstrap

This setup session only initializes the Supabase project structure. It does not implement the full schema, RLS policies, storage buckets, or Edge Functions.

Those will be created in dedicated plans:

- database schema and RLS plan
- storage and media access plan
- auth/profile onboarding plan
- admin moderation plan

## Local Commands

```powershell
pnpm supabase:start
pnpm supabase:status
pnpm supabase:types
pnpm supabase:stop
```

## Secrets

Never commit real Supabase keys. Use `.env.example` files as templates only.
````

- [ ] **Step 3: Try local Supabase startup if Docker is available**

Run:

```powershell
docker --version
```

If Docker prints a version, run:

```powershell
pnpm supabase:start
pnpm supabase:status
```

Expected:

- Supabase local services start.
- Status prints local API URL and keys.

If Docker is not available or not running, do not block the bootstrap. Record this in the final handoff.

- [ ] **Step 4: Commit Supabase skeleton**

Run:

```powershell
git add supabase
git commit -m "chore: initialize Supabase project"
```

Expected:

- Commit succeeds.

---

### Task 8: Project Documentation

**Files:**

- Create: `README.md`
- Create: `docs/setup/local-development.md`
- Create: `docs/setup/environment.md`
- Create: `docs/architecture/monorepo.md`
- Create: `docs/architecture/supabase.md`

- [ ] **Step 1: Add root README**

Use `apply_patch` to create `README.md`:

````md
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
````

- [ ] **Step 2: Add local development docs**

`docs/setup/local-development.md`:

````md
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
````

`docs/setup/environment.md`:

````md
# Environment Variables

Never commit real `.env` files.

## Root

Use `.env.example` as the shared template.

## Mobile

Copy:

```powershell
Copy-Item apps/mobile/.env.example apps/mobile/.env
```

Expected variables:

```dotenv
EXPO_PUBLIC_APP_ENV=development
EXPO_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
EXPO_PUBLIC_SUPABASE_ANON_KEY=replace-with-local-anon-key
```

Only `EXPO_PUBLIC_` values are available to the mobile client. Never put service-role keys in mobile env.

## Admin

Copy:

```powershell
Copy-Item apps/admin/.env.example apps/admin/.env.local
```

Expected variables:

```dotenv
NEXT_PUBLIC_APP_ENV=development
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=replace-with-local-anon-key
SUPABASE_SERVICE_ROLE_KEY=replace-with-local-service-role-key
```

`SUPABASE_SERVICE_ROLE_KEY` must only be used in server-only admin code.
````

- [ ] **Step 3: Add architecture docs**

`docs/architecture/monorepo.md`:

```md
# Monorepo Architecture

Take@Shoot uses a monorepo from the start.

## Why

- Mobile and admin depend on the same product contracts.
- Supabase schema and generated types must stay aligned with app code.
- Design tokens should stay consistent across mobile and admin.
- CI can verify the full project from one place.

## Boundaries

- `apps/mobile`: user-facing Expo app.
- `apps/admin`: protected Next.js back-office.
- `packages/shared`: TypeScript contracts, constants, validation schemas, generated database types.
- `packages/ui`: design tokens and later shared UI primitives when they are genuinely cross-platform.
- `supabase`: migrations, functions, seeds, local config.

## Rule

Shared packages must contain stable contracts, not app-specific behavior. If code only makes sense for mobile or admin, keep it in that app.
```

`docs/architecture/supabase.md`:

```md
# Supabase Architecture

Supabase is the MVP backend platform for Take@Shoot.

## Responsibilities

- Auth: email/password first, Apple/Google later.
- Database: Postgres.
- Authorization: Row Level Security.
- Media: private/authenticated Storage.
- Functions: privileged server-side operations and async jobs where needed.
- Realtime: used selectively for feed/comment/notification/status updates.

## Security Rules

- Privacy must be enforced in database policies and storage access, not only in client code.
- Mobile uses anon key only.
- Admin service-role operations stay server-only.
- RLS tests are required when schema implementation begins.

## Future Plans

Dedicated plans will define:

- relational schema;
- RLS policies;
- storage buckets and object access;
- media rendering pipeline;
- admin moderation workflows.
```

- [ ] **Step 4: Commit docs**

Run:

```powershell
git add README.md docs/setup docs/architecture
git commit -m "docs: add bootstrap and architecture guides"
```

Expected:

- Commit succeeds.

---

### Task 9: CI Workflow

**Files:**

- Create: `.github/workflows/ci.yml`

- [ ] **Step 1: Add GitHub Actions workflow**

Use `apply_patch` to create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  pull_request:
  push:
    branches:
      - master
      - main

jobs:
  verify:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout
        uses: actions/checkout@v4

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: 22

      - name: Enable Corepack
        run: corepack enable

      - name: Install dependencies
        run: pnpm install --frozen-lockfile

      - name: Format check
        run: pnpm format:check

      - name: Lint
        run: pnpm lint

      - name: Typecheck
        run: pnpm typecheck

      - name: Build
        run: pnpm build
```

- [ ] **Step 2: Verify CI commands locally**

Run:

```powershell
pnpm format:check
pnpm lint
pnpm typecheck
pnpm build
```

Expected:

- All commands complete successfully.

If `pnpm build` fails because generated Expo or Next defaults need minor cleanup, fix only scaffold-generated errors. Do not implement product features.

- [ ] **Step 3: Commit CI workflow**

Run:

```powershell
git add .github/workflows/ci.yml package.json pnpm-lock.yaml apps packages
git commit -m "ci: verify monorepo"
```

Expected:

- Commit succeeds.

---

### Task 10: Final Verification And Handoff

**Files:**

- Modify: none unless verification reveals a scaffold issue

- [ ] **Step 1: Run final verification**

Run:

```powershell
pnpm format:check
pnpm lint
pnpm typecheck
pnpm build
git status --short
```

Expected:

- Format check passes.
- Lint passes.
- Typecheck passes.
- Build passes.
- `git status --short` shows only expected untracked `_BRAIN/`, unless user chose to commit it.

- [ ] **Step 2: Review final file tree**

Run:

```powershell
Get-ChildItem -Force
Get-ChildItem apps -Force
Get-ChildItem packages -Force
Get-ChildItem docs -Force
```

Expected:

- Root config files exist.
- `apps/mobile` exists.
- `apps/admin` exists.
- `packages/shared` exists.
- `packages/ui` exists.
- `supabase` exists.
- Docs exist.

- [ ] **Step 3: Final commit if verification fixes were needed**

If Step 1 required fixes, commit them:

```powershell
git add .
git reset _BRAIN
git commit -m "chore: stabilize monorepo bootstrap"
```

Expected:

- Commit succeeds.
- `_BRAIN/` remains untracked.

- [ ] **Step 4: Final handoff message**

Report:

- Branch name.
- Commit list created.
- Commands run and whether they passed.
- Whether Supabase local was started.
- Any scaffold differences caused by current Expo/Next/Supabase tooling.
- `_BRAIN/` status.
- Recommended next implementation plan: database schema and RLS, then auth/profile onboarding.

Do not claim the setup is complete unless final verification passed or failures are explicitly listed with exact causes.

---

## Self-Review Checklist For The Implementing Agent

Before final response, confirm:

- The monorepo uses pnpm workspaces.
- Root scripts run through Turbo.
- Expo app exists under `apps/mobile`.
- Next admin app exists under `apps/admin`.
- Shared contracts compile.
- UI tokens compile.
- Supabase CLI project is initialized.
- Env examples exist and contain no real secrets.
- CI exists.
- Docs explain local setup and architecture.
- `_BRAIN/` is not committed unless explicitly approved.
- No product feature implementation was mixed into bootstrap.
