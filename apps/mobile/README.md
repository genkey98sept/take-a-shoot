# Take@Shoot — App mobile

App mobile **React Native / Expo (SDK 56) / Expo Router**, en TypeScript.
Réseau social fermé de souvenirs « photobooth » : capture live, feed des potes éphémère (24h), souvenirs privés.

> Direction artistique sombre et premium. App verrouillée en mode sombre (`userInterfaceStyle: "dark"`).

## Prérequis

- Node `>= 22.12`
- pnpm `>= 10` (géré via `packageManager` à la racine du monorepo)
- Dépendances installées depuis la **racine** du monorepo : `pnpm install`

## Démarrer

```bash
# depuis la racine du monorepo
pnpm --filter mobile dev
# ou depuis apps/mobile
pnpm dev
```

Puis ouvrir l'app dans un build de développement, un simulateur iOS, un émulateur Android ou Expo Go.

## Environnement

Copier `.env.example` vers `.env` (jamais committé) et renseigner les variables `EXPO_PUBLIC_*` (URL et clé **anon** Supabase locale). Le mobile n'utilise **jamais** la clé service-role. La validation est faite par `src/env.ts` (zod).

## Structure

```text
src/
  app/        Routes Expo Router (file-based)
  components/ Composants UI mobile
  constants/  Thème / constantes locales
  hooks/      Hooks partagés
  lib/        Client Supabase (anon)
  env.ts      Validation des variables d'environnement
app.config.ts Config Expo (permissions, plugins, icônes)
```

Les contrats partagés (types, schémas zod, constantes, design tokens) vivent dans `@take-a-shoot/shared` et `@take-a-shoot/ui`.

> ⚠️ Expo SDK 56 / RN 0.85 introduisent des changements récents. Lire `AGENTS.md` et la doc versionnée <https://docs.expo.dev/versions/v56.0.0/> avant de coder.
