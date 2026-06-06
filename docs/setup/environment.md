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
