# Abandix architecture — Phase 1

## Runtime shape

```text
Browser
  -> Next.js App Router (React Server Components + Client Components)
  -> proxy.ts (session refresh / login gate for /admin)
  -> Server Components / Server Actions / Route Handlers
  -> Supabase SSR client (cookie session)
  -> PostgreSQL + RLS
  -> Supabase Storage (private buckets + signed URLs)

Admin-only server operations
  -> service-role Supabase client (server-only)
  -> explicit permission checks + audit logging
```

## Authorization model

Authentication is handled by Supabase Auth. Authorization is modeled as:

```text
user -> user_roles -> roles -> role_permissions -> permissions
```

The application checks permission on the server, while PostgreSQL `has_permission()` and RLS policies enforce the same boundary at the database. No `isAdmin` field exists.

## Location privacy

Public place data deliberately has no exact coordinate columns. Public map data lives in `place_public_locations`; exact coordinates live in `place_private_locations`.

`location_visibility` controls whether the public location is exact, approximate, hidden or sensitive. Sensitive/private coordinate data is accessible only through permission-backed policies and server-side operations.

## Content lifecycle

Most editorial entities carry both `publication_state` and `moderation_state`. A public reader sees only records that are simultaneously `published` and `visible`.

Corrections and status history are append-oriented so the archive can retain change context instead of silently overwriting history.

## Core schema groups

- Identity: `profiles`, `roles`, `permissions`, `role_permissions`, `user_roles`
- Places: `place_types`, `places`, `place_public_locations`, `place_private_locations`, `place_media`, `place_people`, `place_groups`, `place_timeline`, `place_status_history`, `place_corrections`, `place_tags`
- Community: `posts`, `reports`, `comments`, `comment_replies`, `report_media`, `report_tags`, `notifications`, `follows`, `contributions`
- Archive: `sources`, `source_links`, `people`, `people_timeline`, `groups`, `groups_timeline`, `group_members`, `tags`
- Moderation: `content_reports`, `moderation_actions`, `audit_logs`, `settings`

## Storage

Buckets are private by default. User uploads use `<user_uuid>/<random_filename>`, which matches Storage RLS. Public image rendering should request short-lived signed URLs server-side after checking publication/access state.

## Search

The migration adds GIN indexes using PostgreSQL full-text search and `pg_trgm` for future autocomplete. Phase 2 will implement the cross-entity search query and filter layer without client-side mock arrays.

## Deployment boundary

The app is platform-neutral: Vercel can host the Next.js process; Cloudflare can sit in front as DNS/CDN/WAF later. Application logic does not depend on Cloudflare runtime APIs.
