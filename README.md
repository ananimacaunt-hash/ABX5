# Abandix

Abandix is a production-oriented community archive for abandoned places, field reports, historical research, people, groups and sources.

> **Document, don't exploit.**
>
> Abandix exists to preserve knowledge about places — not to encourage trespass, vandalism, evasion or dangerous exploration.

## Stack

- Next.js 16 App Router + React 19 + TypeScript
- Tailwind CSS 4
- Supabase: PostgreSQL, Auth, Storage, RLS
- Server-side authorization through permission checks plus database-enforced RLS
- Vercel-ready Node deployment

Next.js 16 requires Node.js 20.9+ and uses `proxy.ts` instead of the deprecated `middleware.ts` convention. Supabase Auth is wired through `@supabase/ssr` with cookie-based SSR/PKCE sessions.

## Phase 1 status

Implemented:

- project structure and App Router shell
- archival visual language and responsive navigation
- Supabase SSR browser/server clients
- auth callback + email/password sign-in/sign-up
- proxy-based session refresh and `/admin` login gate
- database foundation migration with normalized schema, roles/permissions, indexes and RLS
- storage buckets + storage policies
- admin control-room shell and permission-aware navigation
- health endpoint
- SEO foundation: metadata, robots, sitemap
- about/guidelines/privacy/terms

Not yet implemented (scheduled for later phases): full Places UI/search/map, reports, comments, people/groups, source workflows, corrections, follows/notifications and full moderation tooling.

## Local setup

1. Install Node.js 20.9+.
2. Create a Supabase project.
3. Copy `.env.example` to `.env.local` and add the Supabase Project URL and publishable key. Keep `SUPABASE_SERVICE_ROLE_KEY` server-only.
4. Install dependencies: `npm install`.
5. Run the SQL migration in `supabase/migrations/0001_foundation.sql` in the Supabase SQL editor, or use `supabase db push` with a configured Supabase CLI project.
6. Run `npm run dev`.

## Auth setup

In Supabase Auth settings, enable Email provider. For local development, use the hosted Supabase email flow or a configured SMTP provider. The callback route is `/auth/callback`.

## Admin bootstrap

The schema deliberately does not provide users with any client-side path to grant themselves a privileged role. After creating an account, bootstrap the first administrator from a trusted server/admin SQL environment by inserting a row into `public.user_roles` for that account's UUID and the `admin` role UUID, or use a later controlled provisioning tool.

## Storage

Three private media buckets are created by the migration (public pages should use short-lived signed URLs):

- `avatars`
- `place-media`
- `report-media`

The browser never receives the Supabase service-role key. Upload authorization is enforced with Storage RLS and, for privileged workflows, server-side checks.

## Deployment

### Vercel

- Import the repository into Vercel.
- Set the production environment variables from `.env.example`.
- Set `NEXT_PUBLIC_SITE_URL` to the production URL.
- Deploy using the standard Next.js preset.

### Cloudflare later

Keep Cloudflare in front of Vercel as DNS/CDN/WAF only. The application does not rely on Cloudflare-specific runtime APIs, so this does not change the domain model or data layer.

## Security notes

- No service-role secret in client code.
- Privileged operations use explicit permissions and server-side authorization.
- RLS remains enabled on all `public` tables.
- Exact/sensitive coordinates are stored separately from public location data.
- Anonymous display mode hides the public author label but keeps internal ownership for moderation.
- Audit logs are immutable from ordinary client roles.
- Retention for moderation metadata is configurable.
- Demo records use fictional place data and do not encode real sensitive locations.

## Project map

```text
src/
  app/              routes, layouts and route handlers
  components/       reusable UI and navigation
  lib/              Supabase, RBAC, i18n and shared utilities
  types/            shared TypeScript/database types
supabase/
  migrations/       PostgreSQL schema + RLS
  seed/             safe demo content
```


## Cloudflare Workers Builds

This repository is configured for Next.js on Cloudflare Workers with OpenNext. In Cloudflare Dashboard → Workers → Settings → Builds, use:

- Build command: `bun run build:cloudflare` (or `npm run build:cloudflare` if Workers Builds is configured to use npm)
- Deploy command: `npx wrangler deploy`

Workers Builds runs the build step separately from the deploy step; the build command must be configured in the Cloudflare project settings. The Wrangler `build` field is intentionally not used here.
