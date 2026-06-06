# Documentation — Take@Shoot

Index de la documentation technique du projet. Tout est en français.

## Produit
- [Cadrage MVP](superpowers/specs/2026-06-06-take-a-shoot-mvp-design.md) — périmètre, règles produit, visibilité (source de vérité produit).

## Design
- [Design System](design/design-system.md) — direction artistique, palette (2 roses), typographie, composants, carte photobooth. Tokens : `packages/ui/src/tokens.ts`.

## Architecture
- [Monorepo](architecture/monorepo.md) — frontières des apps et packages.
- [Base de données, RLS & Storage](architecture/database.md) — **schéma MVP implémenté**, modèle de sécurité, helpers/RPC, buckets privés, tests.
- [Supabase](architecture/supabase.md) — rôle de la plateforme backend (vue d'ensemble).

## Mise en route
- [Développement local](setup/local-development.md) — install, lancer les apps, Supabase local.
- [Variables d'environnement](setup/environment.md) — `.env`, clés Supabase, séparation client/serveur.

## Plans
- [Bootstrap monorepo](superpowers/plans/2026-06-06-setup-monorepo-bootstrap.md).

## État du projet & prochaines étapes
Voir `Nextsession.md` à la racine (notes de travail locales, non suivies par Git) :
il détaille ce qui a été fait, l'état courant et le prochain chantier.

## Règles de documentation
La méthodologie complète (où mettre quoi, cohérence à maintenir, démarrage de session) est
définie dans **`AGENTS.md`** à la racine — chargé automatiquement par les IA. Règle d'or :
**toute la doc technique durable vit ici, dans `docs/`** (indexée par ce fichier) — pas de doc
éparpillée, ni dupliquée, ni morte. `Nextsession.md` (racine, local) ne contient que l'état de
session, pas de la doc durable.
