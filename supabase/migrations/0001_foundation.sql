-- Abandix Foundation Schema
-- Safe baseline: no real sensitive coordinates, no client-granted admin privileges.

create extension if not exists pgcrypto;
create extension if not exists pg_trgm;

create type public.app_role as enum ('user', 'moderator', 'admin');
create type public.permission_key as enum (
  'content.read',
  'content.create',
  'content.update_own',
  'content.moderate',
  'places.manage',
  'sources.manage',
  'people.manage',
  'groups.manage',
  'users.manage',
  'roles.manage',
  'audit.read',
  'settings.manage'
);
create type public.publication_state as enum ('draft', 'published', 'archived');
create type public.moderation_state as enum ('visible', 'pending', 'hidden', 'deleted');
create type public.location_visibility as enum ('public_exact', 'public_approximate', 'hidden', 'sensitive');
create type public.location_precision as enum ('exact', 'building', 'block', 'district', 'city', 'region', 'unknown');
create type public.place_condition as enum ('preserved', 'partially_damaged', 'hazardous_sections', 'severely_damaged', 'critical_condition', 'nearly_destroyed', 'destroyed', 'unknown');
create type public.report_event_type as enum ('closure', 'discovery', 'damage', 'security_change', 'redevelopment', 'photography', 'other');
create type public.verification_state as enum ('unverified', 'community_confirmed', 'verified', 'disputed');
create type public.source_type as enum ('original_report', 'personal_blog', 'youtube', 'reddit', 'forum', 'telegram', 'historical_archive', 'newspaper', 'official_document', 'photography_archive', 'external_website', 'abandix_submission');
create type public.content_report_type as enum ('spam', 'harassment', 'copyright', 'unsafe_content', 'misinformation', 'privacy', 'other');
create type public.moderation_action_type as enum ('hide', 'restore', 'delete', 'warn', 'suspend', 'ban', 'unban', 'verify', 'reject');
create type public.follow_target_type as enum ('place', 'person', 'report');
create type public.contribution_type as enum ('report', 'correction', 'source', 'update', 'verification', 'historical_article');

create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create table public.roles (
  id uuid primary key default gen_random_uuid(),
  name public.app_role not null unique,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table public.permissions (
  id uuid primary key default gen_random_uuid(),
  key public.permission_key not null unique,
  description text not null default '',
  created_at timestamptz not null default now()
);

create table public.role_permissions (
  role_id uuid not null references public.roles(id) on delete cascade,
  permission_id uuid not null references public.permissions(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (role_id, permission_id)
);

create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  username text not null unique check (username ~ '^[a-zA-Z0-9_\.\-]{3,32}$'),
  avatar_path text,
  bio text not null default '' check (char_length(bio) <= 2000),
  reputation integer not null default 0 check (reputation >= 0),
  joined_at timestamptz not null default now(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.user_roles (
  user_id uuid not null references auth.users(id) on delete cascade,
  role_id uuid not null references public.roles(id) on delete restrict,
  granted_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (user_id, role_id)
);

create table public.place_types (
  id uuid primary key default gen_random_uuid(),
  key text not null unique,
  label text not null unique,
  description text not null default '',
  is_active boolean not null default true,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.places (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique check (slug ~ '^[a-z0-9]+(?:-[a-z0-9]+)*$'),
  name text not null check (char_length(name) between 2 and 180),
  place_type_id uuid not null references public.place_types(id) on delete restrict,
  country text not null default '',
  region text not null default '',
  city text not null default '',
  district text not null default '',
  summary text not null default '' check (char_length(summary) <= 1000),
  history text not null default '',
  condition public.place_condition not null default 'unknown',
  location_visibility public.location_visibility not null default 'public_approximate',
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  last_verified_at timestamptz,
  last_verified_by uuid references auth.users(id) on delete set null,
  created_by uuid references auth.users(id) on delete set null,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.place_public_locations (
  place_id uuid primary key references public.places(id) on delete cascade,
  latitude double precision,
  longitude double precision,
  precision public.location_precision not null default 'unknown',
  label text not null default '',
  updated_at timestamptz not null default now(),
  check ((latitude is null and longitude is null) or (latitude between -90 and 90 and longitude between -180 and 180)),
  check ((latitude is null) = (longitude is null))
);

create table public.place_private_locations (
  place_id uuid primary key references public.places(id) on delete cascade,
  exact_latitude double precision,
  exact_longitude double precision,
  internal_note text not null default '',
  updated_at timestamptz not null default now(),
  check ((exact_latitude is null and exact_longitude is null) or (exact_latitude between -90 and 90 and exact_longitude between -180 and 180)),
  check ((exact_latitude is null) = (exact_longitude is null))
);

create table public.sources (
  id uuid primary key default gen_random_uuid(),
  title text not null check (char_length(title) between 2 and 240),
  url text not null check (url ~* '^https?://'),
  author text not null default '',
  publisher text not null default '',
  publication_date date,
  source_type public.source_type not null,
  description text not null default '',
  citation text not null default '',
  verification_state public.verification_state not null default 'unverified',
  created_by uuid references auth.users(id) on delete set null,
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.people (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  aliases text[] not null default '{}',
  known_as text[] not null default '{}',
  biography text not null default '',
  exploration_entry text not null default '',
  publications text not null default '',
  historical_incidents text not null default '',
  controversies text not null default '',
  verification_state public.verification_state not null default 'unverified',
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  created_by uuid references auth.users(id) on delete set null,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.groups (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  group_type text not null default 'community',
  history text not null default '',
  publications text not null default '',
  verification_state public.verification_state not null default 'unverified',
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  created_by uuid references auth.users(id) on delete set null,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.posts (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  title text not null check (char_length(title) between 2 and 240),
  body text not null default '',
  anonymous_display boolean not null default false,
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  created_by uuid references auth.users(id) on delete set null,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.reports (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  place_id uuid not null references public.places(id) on delete restrict,
  title text not null check (char_length(title) between 2 and 240),
  occurred_at timestamptz not null,
  content text not null default '',
  anonymous_display boolean not null default false,
  verification_state public.verification_state not null default 'unverified',
  publication_state public.publication_state not null default 'draft',
  moderation_state public.moderation_state not null default 'pending',
  source_id uuid references public.sources(id) on delete set null,
  created_by uuid references auth.users(id) on delete set null,
  is_demo boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.report_media (
  id uuid primary key default gen_random_uuid(),
  report_id uuid not null references public.reports(id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null,
  byte_size bigint not null check (byte_size > 0),
  width integer,
  height integer,
  alt_text text not null default '',
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.place_media (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  storage_path text not null unique,
  mime_type text not null,
  byte_size bigint not null check (byte_size > 0),
  width integer,
  height integer,
  alt_text text not null default '',
  caption text not null default '',
  taken_at timestamptz,
  sort_order integer not null default 0,
  created_by uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now()
);

create table public.comments (
  id uuid primary key default gen_random_uuid(),
  post_id uuid references public.posts(id) on delete cascade,
  report_id uuid references public.reports(id) on delete cascade,
  place_id uuid references public.places(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete restrict,
  body text not null check (char_length(body) between 1 and 5000),
  moderation_state public.moderation_state not null default 'visible',
  edited_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  check (num_nonnulls(post_id, report_id, place_id) = 1)
);

create table public.comment_replies (
  id uuid primary key default gen_random_uuid(),
  comment_id uuid not null references public.comments(id) on delete cascade,
  author_id uuid not null references auth.users(id) on delete restrict,
  body text not null check (char_length(body) between 1 and 5000),
  moderation_state public.moderation_state not null default 'visible',
  edited_at timestamptz,
  deleted_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.place_timeline (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  event_date date not null,
  title text not null,
  description text not null default '',
  event_type public.report_event_type not null default 'other',
  source_id uuid references public.sources(id) on delete set null,
  confidence public.verification_state not null default 'unverified',
  author_id uuid references auth.users(id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.place_status_history (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  condition public.place_condition not null,
  effective_at timestamptz not null,
  explanation text not null default '',
  source_id uuid references public.sources(id) on delete set null,
  author_id uuid references auth.users(id) on delete set null,
  verification_state public.verification_state not null default 'unverified',
  created_at timestamptz not null default now()
);

create table public.place_corrections (
  id uuid primary key default gen_random_uuid(),
  place_id uuid not null references public.places(id) on delete cascade,
  proposed_by uuid not null references auth.users(id) on delete restrict,
  field_name text not null,
  current_value text not null default '',
  proposed_value text not null,
  reason text not null default '',
  source_id uuid references public.sources(id) on delete set null,
  moderation_state public.moderation_state not null default 'pending',
  reviewed_by uuid references auth.users(id) on delete set null,
  reviewed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table public.source_links (
  id uuid primary key default gen_random_uuid(),
  source_id uuid not null references public.sources(id) on delete cascade,
  place_id uuid references public.places(id) on delete cascade,
  post_id uuid references public.posts(id) on delete cascade,
  report_id uuid references public.reports(id) on delete cascade,
  person_id uuid references public.people(id) on delete cascade,
  group_id uuid references public.groups(id) on delete cascade,
  context_note text not null default '',
  created_at timestamptz not null default now(),
  check (num_nonnulls(place_id, report_id, person_id, group_id) = 1),
  unique (source_id, place_id),
  unique (source_id, report_id),
  unique (source_id, person_id),
  unique (source_id, group_id)
);

create table public.group_members (
  group_id uuid not null references public.groups(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete cascade,
  role_label text not null default 'member',
  starts_at date,
  ends_at date,
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (group_id, person_id)
);

create table public.place_people (
  place_id uuid not null references public.places(id) on delete cascade,
  person_id uuid not null references public.people(id) on delete cascade,
  relationship text not null default 'related',
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (place_id, person_id)
);

create table public.place_groups (
  place_id uuid not null references public.places(id) on delete cascade,
  group_id uuid not null references public.groups(id) on delete cascade,
  relationship text not null default 'related',
  source_id uuid references public.sources(id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (place_id, group_id)
);

create table public.people_timeline (
  id uuid primary key default gen_random_uuid(),
  person_id uuid not null references public.people(id) on delete cascade,
  event_date date not null,
  title text not null,
  description text not null default '',
  source_id uuid references public.sources(id) on delete set null,
  verification_state public.verification_state not null default 'unverified',
  created_at timestamptz not null default now()
);

create table public.groups_timeline (
  id uuid primary key default gen_random_uuid(),
  group_id uuid not null references public.groups(id) on delete cascade,
  event_date date not null,
  title text not null,
  description text not null default '',
  source_id uuid references public.sources(id) on delete set null,
  verification_state public.verification_state not null default 'unverified',
  created_at timestamptz not null default now()
);

create table public.tags (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  label text not null unique,
  created_at timestamptz not null default now()
);

create table public.place_tags (
  place_id uuid not null references public.places(id) on delete cascade,
  tag_id uuid not null references public.tags(id) on delete cascade,
  primary key (place_id, tag_id)
);

create table public.report_tags (
  report_id uuid not null references public.reports(id) on delete cascade,
  tag_id uuid not null references public.tags(id) on delete cascade,
  primary key (report_id, tag_id)
);

create table public.notifications (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  kind text not null,
  title text not null,
  body text not null default '',
  href text,
  read_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.follows (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  target_type public.follow_target_type not null,
  place_id uuid references public.places(id) on delete cascade,
  person_id uuid references public.people(id) on delete cascade,
  report_id uuid references public.reports(id) on delete cascade,
  created_at timestamptz not null default now(),
  check ((target_type='place' and place_id is not null and person_id is null and report_id is null) or (target_type='person' and person_id is not null and place_id is null and report_id is null) or (target_type='report' and report_id is not null and place_id is null and person_id is null)),
  unique (user_id, place_id),
  unique (user_id, person_id),
  unique (user_id, report_id)
);

create table public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references auth.users(id) on delete restrict,
  report_type public.content_report_type not null,
  reason text not null default '',
  place_id uuid references public.places(id) on delete cascade,
  post_id uuid references public.posts(id) on delete cascade,
  report_id uuid references public.reports(id) on delete cascade,
  comment_id uuid references public.comments(id) on delete cascade,
  source_id uuid references public.sources(id) on delete cascade,
  person_id uuid references public.people(id) on delete cascade,
  group_id uuid references public.groups(id) on delete cascade,
  moderation_state public.moderation_state not null default 'pending',
  assigned_to uuid references auth.users(id) on delete set null,
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  check (num_nonnulls(place_id, post_id, report_id, comment_id, source_id, person_id, group_id) = 1)
);

create table public.moderation_actions (
  id uuid primary key default gen_random_uuid(),
  actor_id uuid not null references auth.users(id) on delete restrict,
  target_user_id uuid references auth.users(id) on delete set null,
  target_place_id uuid references public.places(id) on delete set null,
  target_report_id uuid references public.reports(id) on delete set null,
  target_comment_id uuid references public.comments(id) on delete set null,
  target_source_id uuid references public.sources(id) on delete set null,
  action_type public.moderation_action_type not null,
  public_reason text not null default '',
  private_note text not null default '',
  metadata jsonb not null default '{}'::jsonb,
  ip_hash text,
  user_agent text,
  expires_at timestamptz,
  created_at timestamptz not null default now()
);

create table public.audit_logs (
  id bigserial primary key,
  actor_id uuid references auth.users(id) on delete set null,
  action text not null,
  entity_type text not null,
  entity_id uuid,
  metadata jsonb not null default '{}'::jsonb,
  ip_hash text,
  user_agent text,
  created_at timestamptz not null default now()
);

create table public.contributions (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  contribution_type public.contribution_type not null,
  points integer not null default 0 check (points >= 0),
  entity_id uuid,
  created_at timestamptz not null default now()
);

create table public.settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_by uuid references auth.users(id) on delete set null,
  updated_at timestamptz not null default now()
);

create index places_public_idx on public.places(publication_state, moderation_state, updated_at desc);
create index places_location_idx on public.places(country, region, city, place_type_id, condition);
create index posts_public_idx on public.posts(publication_state, moderation_state, created_at desc);
create index posts_search_idx on public.posts using gin (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(body,'')));
create index comments_post_idx on public.comments(post_id, created_at desc) where post_id is not null;
create index reports_place_idx on public.reports(place_id, occurred_at desc);
create index reports_public_idx on public.reports(publication_state, moderation_state, occurred_at desc);
create index comments_report_idx on public.comments(report_id, created_at desc) where report_id is not null;
create index comments_place_idx on public.comments(place_id, created_at desc) where place_id is not null;
create index sources_public_idx on public.sources(publication_state, moderation_state, publication_date desc);
create index timeline_place_idx on public.place_timeline(place_id, event_date asc);
create index status_history_idx on public.place_status_history(place_id, effective_at asc);
create index corrections_place_idx on public.place_corrections(place_id, moderation_state, created_at desc);
create index content_reports_queue_idx on public.content_reports(moderation_state, created_at desc);
create index moderation_actions_actor_idx on public.moderation_actions(actor_id, created_at desc);
create index audit_logs_actor_idx on public.audit_logs(actor_id, created_at desc);
create index notifications_user_idx on public.notifications(user_id, created_at desc);
create index contributions_user_idx on public.contributions(user_id, created_at desc);
create index profiles_username_trgm_idx on public.profiles using gin (username gin_trgm_ops);
create index places_search_idx on public.places using gin (to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(summary,'') || ' ' || coalesce(history,'')));
create index reports_search_idx on public.reports using gin (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(content,'')));
create index people_search_idx on public.people using gin (to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(biography,'')));
create index groups_search_idx on public.groups using gin (to_tsvector('simple', coalesce(name,'') || ' ' || coalesce(history,'')));
create index sources_search_idx on public.sources using gin (to_tsvector('simple', coalesce(title,'') || ' ' || coalesce(description,'')));

create or replace function public.has_permission(required_permission public.permission_key)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles ur
    join public.role_permissions rp on rp.role_id = ur.role_id
    join public.permissions p on p.id = rp.permission_id
    where ur.user_id = auth.uid()
      and p.key = required_permission
  );
$$;

create or replace function public.has_role(required_role public.app_role)
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select exists (
    select 1 from public.user_roles ur
    join public.roles r on r.id = ur.role_id
    where ur.user_id = auth.uid() and r.name = required_role
  );
$$;

create or replace function public.my_permissions()
returns public.permission_key[]
language sql
security definer
stable
set search_path = public
as $$
  select coalesce(array_agg(distinct p.key order by p.key), '{}'::public.permission_key[])
  from public.user_roles ur
  join public.role_permissions rp on rp.role_id = ur.role_id
  join public.permissions p on p.id = rp.permission_id
  where ur.user_id = auth.uid();
$$;

create or replace function public.is_moderator_or_admin()
returns boolean
language sql
security definer
stable
set search_path = public
as $$
  select public.has_role('moderator') or public.has_role('admin');
$$;

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  base_username text;
  candidate text;
  suffix text;
  attempt integer := 0;
  user_role_id uuid;
begin
  base_username := coalesce(new.raw_user_meta_data->>'username', 'user');
  base_username := regexp_replace(lower(base_username), '[^a-z0-9_\.-]', '_', 'g');
  base_username := left(base_username, 24);
  if char_length(base_username) < 3 then
    base_username := 'user';
  end if;

  loop
    suffix := substr(replace(new.id::text, '-', ''), 1 + attempt * 4, 8);
    candidate := left(base_username, 32 - char_length(suffix) - 1) || '_' || suffix;
    exit when not exists (select 1 from public.profiles where username = candidate);
    attempt := attempt + 1;
    exit when attempt > 7;
  end loop;

  insert into public.profiles (id, username)
  values (new.id, candidate);

  select id into user_role_id from public.roles where name = 'user';
  if user_role_id is not null then
    insert into public.user_roles (user_id, role_id) values (new.id, user_role_id)
    on conflict do nothing;
  end if;

  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

create trigger profiles_set_updated_at before update on public.profiles for each row execute function public.set_updated_at();
create trigger place_types_set_updated_at before update on public.place_types for each row execute function public.set_updated_at();
create trigger places_set_updated_at before update on public.places for each row execute function public.set_updated_at();
create trigger sources_set_updated_at before update on public.sources for each row execute function public.set_updated_at();
create trigger people_set_updated_at before update on public.people for each row execute function public.set_updated_at();
create trigger groups_set_updated_at before update on public.groups for each row execute function public.set_updated_at();
create trigger reports_set_updated_at before update on public.reports for each row execute function public.set_updated_at();
create trigger comments_set_updated_at before update on public.comments for each row execute function public.set_updated_at();
create trigger comment_replies_set_updated_at before update on public.comment_replies for each row execute function public.set_updated_at();
create trigger place_timeline_set_updated_at before update on public.place_timeline for each row execute function public.set_updated_at();
create trigger corrections_set_updated_at before update on public.place_corrections for each row execute function public.set_updated_at();
create trigger settings_set_updated_at before update on public.settings for each row execute function public.set_updated_at();

create or replace function public.validate_public_location_visibility()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  visibility public.location_visibility;
begin
  select location_visibility into visibility from public.places where id = new.place_id;
  if visibility in ('hidden','sensitive') and (new.latitude is not null or new.longitude is not null) then
    raise exception 'Public coordinates cannot be stored for hidden or sensitive places';
  end if;
  if visibility = 'public_exact' and new.latitude is null then
    raise exception 'Public exact location requires coordinates';
  end if;
  if visibility = 'public_approximate' and new.precision in ('exact','building') then
    raise exception 'Approximate public locations must use city, district, block or unknown precision';
  end if;
  return new;
end;
$$;

create or replace function public.validate_place_location_visibility()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  loc public.place_public_locations;
begin
  select * into loc from public.place_public_locations where place_id = new.id;
  if new.location_visibility in ('hidden','sensitive') and (loc.latitude is not null or loc.longitude is not null) then
    raise exception 'Hidden or sensitive places cannot retain public coordinates';
  end if;
  return new;
end;
$$;

create trigger validate_public_location before insert or update on public.place_public_locations
for each row execute function public.validate_public_location_visibility();
create trigger validate_place_visibility before update on public.places
for each row execute function public.validate_place_location_visibility();

-- RLS: every exposed public table is protected.
do $$
declare
  t text;
begin
  foreach t in array array[
    'roles','permissions','role_permissions','profiles','user_roles','place_types','places','place_public_locations',
    'place_private_locations','sources','people','groups','posts','reports','report_media','place_media','comments','comment_replies',
    'place_timeline','place_status_history','place_corrections','source_links','group_members','place_people','place_groups',
    'people_timeline','groups_timeline','tags','place_tags','report_tags','notifications','follows','content_reports',
    'moderation_actions','audit_logs','contributions','settings'
  ] loop
    execute format('alter table public.%I enable row level security', t);
  end loop;
end $$;

-- Conservative grants. service_role retains administrative access server-side.
revoke all on table public.roles, public.permissions, public.role_permissions, public.profiles, public.user_roles,
  public.place_types, public.places, public.place_public_locations, public.place_private_locations, public.sources,
  public.people, public.groups, public.posts, public.reports, public.report_media, public.place_media, public.comments,
  public.comment_replies, public.place_timeline, public.place_status_history, public.place_corrections, public.source_links,
  public.group_members, public.place_people, public.place_groups, public.people_timeline, public.groups_timeline, public.tags,
  public.place_tags, public.report_tags, public.notifications, public.follows, public.content_reports, public.moderation_actions,
  public.audit_logs, public.contributions, public.settings from anon, authenticated;

grant select on public.place_types, public.places, public.place_public_locations, public.sources, public.people, public.groups, public.reports,
  public.posts, public.report_media, public.place_media, public.place_timeline, public.place_status_history, public.source_links, public.group_members,
  public.place_people, public.place_groups, public.people_timeline, public.groups_timeline, public.tags, public.place_tags, public.report_tags
  to anon, authenticated;

grant select, insert, update, delete on public.profiles to authenticated;

grant select, insert, update, delete on public.posts, public.reports, public.report_media, public.place_media, public.comments, public.comment_replies,
  public.place_corrections, public.notifications, public.follows, public.content_reports, public.contributions to authenticated;
grant select on public.user_roles to authenticated;
grant select, insert, update, delete on public.roles, public.role_permissions to authenticated;
grant select on public.permissions to authenticated;


-- Public content policies.
create policy public_read_places on public.places for select to anon, authenticated
  using (publication_state = 'published' and moderation_state = 'visible');
create policy public_read_place_types on public.place_types for select to anon, authenticated
  using (is_active = true);
create policy public_read_locations on public.place_public_locations for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id = place_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_sources on public.sources for select to anon, authenticated
  using (publication_state='published' and moderation_state='visible');
create policy public_read_people on public.people for select to anon, authenticated
  using (publication_state='published' and moderation_state='visible');
create policy public_read_groups on public.groups for select to anon, authenticated
  using (publication_state='published' and moderation_state='visible');
create policy public_read_posts on public.posts for select to anon, authenticated using (publication_state='published' and moderation_state='visible');
create policy public_read_reports on public.reports for select to anon, authenticated
  using (publication_state='published' and moderation_state='visible');
create policy public_read_report_media on public.report_media for select to anon, authenticated
  using (exists (select 1 from public.reports r where r.id=report_id and r.publication_state='published' and r.moderation_state='visible'));
create policy public_read_place_media on public.place_media for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_timeline on public.place_timeline for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_status_history on public.place_status_history for select to anon, authenticated
  using (exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_source_links on public.source_links for select to anon, authenticated
  using (
    (place_id is not null and exists (select 1 from public.places p join public.sources s on s.id=source_id where p.id=place_id and p.publication_state='published' and p.moderation_state='visible' and s.publication_state='published' and s.moderation_state='visible'))
    or (report_id is not null and exists (select 1 from public.reports r join public.sources s on s.id=source_id where r.id=report_id and r.publication_state='published' and r.moderation_state='visible' and s.publication_state='published' and s.moderation_state='visible'))
    or (person_id is not null and exists (select 1 from public.people p join public.sources s on s.id=source_id where p.id=person_id and p.publication_state='published' and p.moderation_state='visible' and s.publication_state='published' and s.moderation_state='visible'))
    or (group_id is not null and exists (select 1 from public.groups g join public.sources s on s.id=source_id where g.id=group_id and g.publication_state='published' and g.moderation_state='visible' and s.publication_state='published' and s.moderation_state='visible'))
  );
create policy public_read_group_members on public.group_members for select to anon, authenticated using (exists (select 1 from public.groups g where g.id=group_id and g.publication_state='published' and g.moderation_state='visible') and exists (select 1 from public.people p where p.id=person_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_place_people on public.place_people for select to anon, authenticated using (exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible') and exists (select 1 from public.people pe where pe.id=person_id and pe.publication_state='published' and pe.moderation_state='visible'));
create policy public_read_place_groups on public.place_groups for select to anon, authenticated using (exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible') and exists (select 1 from public.groups g where g.id=group_id and g.publication_state='published' and g.moderation_state='visible'));
create policy public_read_people_timeline on public.people_timeline for select to anon, authenticated using (exists (select 1 from public.people p where p.id=person_id and p.publication_state='published' and p.moderation_state='visible'));
create policy public_read_groups_timeline on public.groups_timeline for select to anon, authenticated using (exists (select 1 from public.groups g where g.id=group_id and g.publication_state='published' and g.moderation_state='visible'));
create policy public_read_tags on public.tags for select to anon, authenticated using (true);
create policy public_read_place_tags on public.place_tags for select to anon, authenticated using (true);
create policy public_read_report_tags on public.report_tags for select to anon, authenticated using (true);

-- Authorized reviewers can see non-public records needed for moderation.
create policy places_manager_read on public.places for select to authenticated using (public.has_permission('places.manage'));
create policy public_locations_manager_all on public.place_public_locations for all to authenticated using (public.has_permission('places.manage')) with check (public.has_permission('places.manage'));
create policy private_locations_manager_read on public.place_private_locations for select to authenticated using (public.has_permission('places.manage'));
create policy private_locations_manager_insert on public.place_private_locations for insert to authenticated with check (public.has_permission('places.manage'));
create policy private_locations_manager_update on public.place_private_locations for update to authenticated using (public.has_permission('places.manage')) with check (public.has_permission('places.manage'));
create policy private_locations_manager_delete on public.place_private_locations for delete to authenticated using (public.has_permission('places.manage'));
create policy sources_manager_read on public.sources for select to authenticated using (public.has_permission('sources.manage') or public.has_permission('content.moderate'));
create policy people_manager_read on public.people for select to authenticated using (public.has_permission('people.manage') or public.has_permission('content.moderate'));
create policy groups_manager_read on public.groups for select to authenticated using (public.has_permission('groups.manage') or public.has_permission('content.moderate'));
create policy posts_moderator_read on public.posts for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = created_by);
create policy reports_moderator_read on public.reports for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = created_by);
create policy comments_moderator_read on public.comments for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = author_id or moderation_state='visible');
create policy replies_moderator_read on public.comment_replies for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = author_id or moderation_state='visible');
create policy corrections_moderator_read on public.place_corrections for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = proposed_by);
create policy content_reports_moderator_update on public.content_reports for update to authenticated using (public.has_permission('content.moderate')) with check (public.has_permission('content.moderate'));
create policy content_reports_moderator_delete on public.content_reports for delete to authenticated using (public.has_permission('content.moderate'));
create policy content_reports_moderator_select on public.content_reports for select to authenticated using (public.has_permission('content.moderate') or (select auth.uid()) = reporter_id);

-- Profile and user-specific policies.
create policy profiles_public_read on public.profiles for select to anon, authenticated using (true);
create policy profiles_self_insert on public.profiles for insert to authenticated with check ((select auth.uid()) = id);
create policy profiles_self_update on public.profiles for update to authenticated
  using ((select auth.uid()) = id)
  with check ((select auth.uid()) = id);

create policy user_roles_self_read on public.user_roles for select to authenticated
  using ((select auth.uid()) = user_id or public.has_permission('roles.manage'));

create policy posts_owner_insert on public.posts for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy posts_owner_update on public.posts for update to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'))
  with check ((select auth.uid()) = created_by or public.has_permission('content.moderate'));
create policy posts_owner_delete on public.posts for delete to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'));

create policy reports_owner_insert on public.reports for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy reports_owner_update on public.reports for update to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'))
  with check ((select auth.uid()) = created_by or public.has_permission('content.moderate'));
create policy reports_owner_delete on public.reports for delete to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'));

create policy report_media_owner_insert on public.report_media for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy report_media_owner_delete on public.report_media for delete to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'));

create policy place_media_owner_insert on public.place_media for insert to authenticated
  with check ((select auth.uid()) = created_by);
create policy place_media_owner_delete on public.place_media for delete to authenticated
  using ((select auth.uid()) = created_by or public.has_permission('content.moderate'));

create policy public_read_comments on public.comments for select to anon, authenticated using (moderation_state='visible' and deleted_at is null and ((post_id is not null and exists (select 1 from public.posts p where p.id=post_id and p.publication_state='published' and p.moderation_state='visible')) or (report_id is not null and exists (select 1 from public.reports r where r.id=report_id and r.publication_state='published' and r.moderation_state='visible')) or (place_id is not null and exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible'))));
create policy comments_owner_insert on public.comments for insert to authenticated
  with check ((select auth.uid()) = author_id and ((post_id is not null and exists (select 1 from public.posts p where p.id=post_id and p.publication_state='published' and p.moderation_state='visible')) or (report_id is not null and exists (select 1 from public.reports r where r.id=report_id and r.publication_state='published' and r.moderation_state='visible')) or (place_id is not null and exists (select 1 from public.places p where p.id=place_id and p.publication_state='published' and p.moderation_state='visible'))));
create policy comments_owner_update on public.comments for update to authenticated
  using ((select auth.uid()) = author_id or public.has_permission('content.moderate'))
  with check ((select auth.uid()) = author_id or public.has_permission('content.moderate'));
create policy comments_owner_delete on public.comments for delete to authenticated
  using ((select auth.uid()) = author_id or public.has_permission('content.moderate'));
create policy public_read_comment_replies on public.comment_replies for select to anon, authenticated using (moderation_state='visible' and deleted_at is null and exists (select 1 from public.comments c where c.id=comment_id and c.moderation_state='visible' and c.deleted_at is null));
create policy replies_owner_insert on public.comment_replies for insert to authenticated
  with check ((select auth.uid()) = author_id);
create policy replies_owner_update on public.comment_replies for update to authenticated
  using ((select auth.uid()) = author_id or public.has_permission('content.moderate'))
  with check ((select auth.uid()) = author_id or public.has_permission('content.moderate'));
create policy replies_owner_delete on public.comment_replies for delete to authenticated
  using ((select auth.uid()) = author_id or public.has_permission('content.moderate'));

create policy corrections_owner_insert on public.place_corrections for insert to authenticated
  with check ((select auth.uid()) = proposed_by);
create policy corrections_owner_read on public.place_corrections for select to authenticated
  using ((select auth.uid()) = proposed_by or public.has_permission('content.moderate'));

create policy notifications_self_read on public.notifications for select to authenticated using ((select auth.uid()) = user_id);
create policy notifications_self_update on public.notifications for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create policy follows_self_read on public.follows for select to authenticated using ((select auth.uid()) = user_id);
create policy follows_self_insert on public.follows for insert to authenticated with check ((select auth.uid()) = user_id);
create policy follows_self_delete on public.follows for delete to authenticated using ((select auth.uid()) = user_id);

create policy content_reports_self_insert on public.content_reports for insert to authenticated with check ((select auth.uid()) = reporter_id);
create policy content_reports_self_read on public.content_reports for select to authenticated
  using ((select auth.uid()) = reporter_id or public.has_permission('content.moderate'));

create policy contributions_self_read on public.contributions for select to authenticated using ((select auth.uid()) = user_id);

-- Privileged operations. These policies deliberately rely on permissions, not UI state.
create policy places_moderator_insert on public.places for insert to authenticated
  with check (public.has_permission('places.manage') and (created_by is null or (select auth.uid()) = created_by));
create policy places_moderator_update on public.places for update to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy places_moderator_delete on public.places for delete to authenticated using (public.has_permission('places.manage'));
create policy private_locations_admin_all on public.place_private_locations for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy place_types_admin_all on public.place_types for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy sources_manage on public.sources for all to authenticated
  using (public.has_permission('sources.manage') or (select auth.uid()) = created_by)
  with check (public.has_permission('sources.manage') or (select auth.uid()) = created_by);
create policy people_manage on public.people for all to authenticated
  using (public.has_permission('people.manage'))
  with check (public.has_permission('people.manage'));
create policy groups_manage on public.groups for all to authenticated
  using (public.has_permission('groups.manage'))
  with check (public.has_permission('groups.manage'));
create policy timeline_manage on public.place_timeline for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy status_history_manage on public.place_status_history for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy source_links_manage on public.source_links for all to authenticated
  using (public.has_permission('content.moderate'))
  with check (public.has_permission('content.moderate'));
create policy group_members_manage on public.group_members for all to authenticated
  using (public.has_permission('groups.manage'))
  with check (public.has_permission('groups.manage'));
create policy place_people_manage on public.place_people for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy place_groups_manage on public.place_groups for all to authenticated
  using (public.has_permission('places.manage'))
  with check (public.has_permission('places.manage'));
create policy people_timeline_manage on public.people_timeline for all to authenticated
  using (public.has_permission('people.manage'))
  with check (public.has_permission('people.manage'));
create policy groups_timeline_manage on public.groups_timeline for all to authenticated
  using (public.has_permission('groups.manage'))
  with check (public.has_permission('groups.manage'));
create policy tags_read on public.tags for select to anon, authenticated using (true);
create policy audit_admin_read on public.audit_logs for select to authenticated using (public.has_permission('audit.read'));
create policy audit_no_update on public.audit_logs for update to authenticated using (false);
create policy audit_no_delete on public.audit_logs for delete to authenticated using (false);
create policy roles_manage on public.roles for all to authenticated using (public.has_permission('roles.manage')) with check (public.has_permission('roles.manage'));
create policy permissions_read on public.permissions for select to authenticated using (public.has_permission('roles.manage'));
create policy role_permissions_manage on public.role_permissions for all to authenticated using (public.has_permission('roles.manage')) with check (public.has_permission('roles.manage'));
create policy settings_manage on public.settings for all to authenticated using (public.has_permission('settings.manage')) with check (public.has_permission('settings.manage'));

-- Seed RBAC.
insert into public.roles (name, description) values
  ('user', 'Standard community member'),
  ('moderator', 'Community moderation and review'),
  ('admin', 'Full administration')
on conflict (name) do nothing;

insert into public.permissions (key, description) values
  ('content.read', 'Read moderated content and moderation-safe metadata'),
  ('content.create', 'Create community content'),
  ('content.update_own', 'Update owned community content'),
  ('content.moderate', 'Review and moderate submitted content'),
  ('places.manage', 'Create, publish, edit and archive places'),
  ('sources.manage', 'Manage source records and verification state'),
  ('people.manage', 'Manage historical people records'),
  ('groups.manage', 'Manage historical group records'),
  ('users.manage', 'Manage user accounts and moderation states'),
  ('roles.manage', 'Manage role assignments and permissions'),
  ('audit.read', 'Read administrative audit history'),
  ('settings.manage', 'Manage application settings')
on conflict (key) do nothing;

insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p where r.name='user' and p.key in ('content.read','content.create','content.update_own')
on conflict do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p where r.name='moderator' and p.key in ('content.read','content.create','content.update_own','content.moderate','sources.manage')
on conflict do nothing;
insert into public.role_permissions (role_id, permission_id)
select r.id, p.id from public.roles r cross join public.permissions p where r.name='admin'
on conflict do nothing;

insert into public.place_types (key,label,description,sort_order) values
('factory','Factory','Industrial production site.',10),
('hospital','Hospital','Medical institution and former care site.',20),
('school','School','Educational institution.',30),
('hotel','Hotel','Former hotel or guest property.',40),
('residential','Residential','Homes, apartment blocks and residential estates.',50),
('military','Military','Military infrastructure and former defense property.',60),
('industrial','Industrial','Industrial sites that do not fit another type.',70),
('infrastructure','Infrastructure','Utilities, water, power and public works.',80),
('railway','Railway','Railway stations, yards and related structures.',90),
('office','Office','Former commercial or administrative office space.',100),
('religious','Religious','Religious buildings and related sites.',110),
('amusement','Amusement','Former amusement and leisure properties.',120),
('commercial','Commercial','Retail, market and other commercial spaces.',130),
('other','Other','Expandable catch-all category.',999)
on conflict (key) do nothing;

insert into public.settings (key,value) values ('moderation.retention_days', jsonb_build_object('days',90)) on conflict (key) do nothing;

insert into public.tags (slug,label) values
('demo','Demo'),('industrial','Industrial'),('historical','Historical'),('research','Research'),('documentary','Documentary')
on conflict (slug) do nothing;

-- Storage buckets. Public readability is paired with database-level media publication checks.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types) values
('avatars','avatars',false,5242880,array['image/jpeg','image/png','image/webp','image/avif']),
('place-media','place-media',false,15728640,array['image/jpeg','image/png','image/webp','image/avif']),
('report-media','report-media',false,15728640,array['image/jpeg','image/png','image/webp','image/avif'])
on conflict (id) do update set public=excluded.public, file_size_limit=excluded.file_size_limit, allowed_mime_types=excluded.allowed_mime_types;

-- Storage RLS. Object ownership is encoded in path prefix: <user_id>/...
create policy storage_own_read on storage.objects for select to authenticated
using (bucket_id in ('avatars','place-media','report-media') and ((storage.foldername(name))[1] = (select auth.uid())::text or public.has_permission('content.moderate')));
create policy storage_own_insert on storage.objects for insert to authenticated
with check (bucket_id in ('avatars','place-media','report-media') and (storage.foldername(name))[1] = (select auth.uid())::text);
create policy storage_own_update on storage.objects for update to authenticated
using (bucket_id in ('avatars','place-media','report-media') and ((storage.foldername(name))[1] = (select auth.uid())::text or public.has_permission('content.moderate')))
with check (bucket_id in ('avatars','place-media','report-media') and ((storage.foldername(name))[1] = (select auth.uid())::text or public.has_permission('content.moderate')));
create policy storage_own_delete on storage.objects for delete to authenticated
using (bucket_id in ('avatars','place-media','report-media') and ((storage.foldername(name))[1] = (select auth.uid())::text or public.has_permission('content.moderate')));
