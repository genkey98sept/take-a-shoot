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
