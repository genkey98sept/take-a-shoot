# Variables d'environnement

Ne jamais committer de vrai fichier `.env`. Seuls les modèles `.env.example` sont suivis.

## Clés Supabase locales

`pnpm supabase:status` affiche les clés locales. Le CLI récent utilise le format
**`Publishable` / `Secret`** (équivalents des anciennes `anon` / `service_role`) :

- **`Publishable`** → clé **anon** (client) → `*_SUPABASE_ANON_KEY`.
- **`Secret`** → clé **service-role** (serveur uniquement) → `SUPABASE_SERVICE_ROLE_KEY`.

## Racine
Modèle partagé : `.env.example`.

## Mobile
```powershell
Copy-Item apps/mobile/.env.example apps/mobile/.env
```
```dotenv
EXPO_PUBLIC_APP_ENV=development
EXPO_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
EXPO_PUBLIC_SUPABASE_ANON_KEY=<clé Publishable locale>
```
Seules les valeurs `EXPO_PUBLIC_` sont exposées au client mobile. **Jamais** de
clé service-role/secret dans le mobile.

## Admin
```powershell
Copy-Item apps/admin/.env.example apps/admin/.env.local
```
```dotenv
NEXT_PUBLIC_APP_ENV=development
NEXT_PUBLIC_SUPABASE_URL=http://127.0.0.1:54321
NEXT_PUBLIC_SUPABASE_ANON_KEY=<clé Publishable locale>
SUPABASE_SERVICE_ROLE_KEY=<clé Secret locale>
```
`SUPABASE_SERVICE_ROLE_KEY` (secret) ne doit être utilisée que dans le code
**server-only** de l'admin (`src/lib/supabase/server.ts`, protégé par `server-only`).
