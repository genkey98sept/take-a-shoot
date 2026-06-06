# Supabase — vue d'ensemble

Supabase est la plateforme backend du MVP Take@Shoot.

> Le schéma, la RLS et le Storage sont **implémentés** (Phase 2). Référence
> détaillée : [Base de données, RLS & Storage](database.md).

## Responsabilités
- **Auth** : email/mot de passe d'abord ; Apple/Google plus tard.
- **Base de données** : Postgres 17.
- **Autorisation** : Row Level Security (deny-by-default).
- **Média** : Storage privé/authentifié (buckets `public = false`).
- **Fonctions** : opérations privilégiées côté serveur et jobs asynchrones (Edge Functions) au besoin.
- **Realtime** : sélectif (feed, commentaires, notifications, statut de traitement).

## Règles de sécurité
- La confidentialité est imposée par les **policies RLS et l'accès Storage**, pas seulement côté client.
- Le mobile utilise uniquement la **clé anon (publishable)**.
- Les opérations admin en **service-role (secret)** restent côté serveur.
- Les **tests RLS** accompagnent toute évolution du schéma (`supabase test db`).

## Cycle de vie & jobs (à venir)
- Pipeline de rendu média (preview locale + rendu officiel backend).
- Purge asynchrone des médias au soft delete + rétention 30 j.
- Triggers/handlers de création de notifications.
- Workflows de modération back-office.
