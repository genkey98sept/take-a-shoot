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
