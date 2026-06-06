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
