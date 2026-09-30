-- Structural RLS checks. Run with `supabase test db` after local setup.
begin;

select plan(8);

select ok((select relrowsecurity from pg_class where oid='public.places'::regclass), 'places has RLS enabled');
select ok((select relrowsecurity from pg_class where oid='public.place_private_locations'::regclass), 'private locations have RLS enabled');
select ok((select relrowsecurity from pg_class where oid='public.user_roles'::regclass), 'user roles have RLS enabled');
select ok((select relrowsecurity from pg_class where oid='public.audit_logs'::regclass), 'audit logs have RLS enabled');
select ok(exists(select 1 from pg_proc where proname='has_permission'), 'has_permission exists');
select ok(exists(select 1 from pg_proc where proname='my_permissions'), 'my_permissions exists');
select ok(exists(select 1 from pg_policies where tablename='place_private_locations' and policyname='private_locations_manager_read'), 'private coordinates require a permission-backed policy');
select ok(not exists(select 1 from pg_policies where tablename='user_roles' and cmd='INSERT' and 'authenticated' = any(roles)), 'authenticated role has no user_roles insert policy');

select * from finish();
rollback;
