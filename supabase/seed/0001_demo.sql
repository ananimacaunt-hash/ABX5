-- Safe demo records. All locations are intentionally non-real / non-sensitive.

insert into public.places (
  slug, name, place_type_id, country, region, city, district, summary, history,
  condition, location_visibility, publication_state, moderation_state, is_demo
)
select
  'meridian-factory-demo',
  'Meridian Works (Demo)',
  id,
  'Demo Republic', 'North Coast', 'Greyhaven', 'West Yard',
  'Fictional demo industrial site used to exercise the Abandix archive UI.',
  'Demo record. No real location or historical claim is intended. This entry demonstrates how a site can retain a documented chronology.',
  'partially_damaged', 'public_approximate', 'published', 'visible', true
from public.place_types where key='factory'
on conflict (slug) do nothing;

insert into public.places (
  slug, name, place_type_id, country, region, city, district, summary, history,
  condition, location_visibility, publication_state, moderation_state, is_demo
)
select
  'northline-terminal-demo',
  'Northline Terminal (Demo)',
  id,
  'Demo Republic', 'North Coast', 'Greyhaven', 'Old Transit',
  'Fictional railway terminal demonstrating time-based status history.',
  'Demo record. The chronology is synthetic and exists to demonstrate structure only.',
  'critical_condition', 'hidden', 'published', 'visible', true
from public.place_types where key='railway'
on conflict (slug) do nothing;

insert into public.places (
  slug, name, place_type_id, country, region, city, district, summary, history,
  condition, location_visibility, publication_state, moderation_state, is_demo
)
select
  'lark-hill-sanatorium-demo',
  'Lark Hill Sanatorium (Demo)',
  id,
  'Demo Republic', 'Inland Province', 'Larkhill', 'Upper Ridge',
  'Fictional former sanatorium demonstrating source-first historical records.',
  'Demo record. Any resemblance to a real place is coincidental.',
  'preserved', 'public_approximate', 'published', 'visible', true
from public.place_types where key='hospital'
on conflict (slug) do nothing;

insert into public.place_public_locations (place_id, label, precision)
select id, 'Approximate demo area', 'city' from public.places where is_demo=true and slug='meridian-factory-demo'
on conflict (place_id) do nothing;
insert into public.place_public_locations (place_id, label, precision)
select id, 'Location intentionally withheld in demo', 'unknown' from public.places where is_demo=true and slug='northline-terminal-demo'
on conflict (place_id) do nothing;
insert into public.place_public_locations (place_id, label, precision)
select id, 'Approximate demo area', 'district' from public.places where is_demo=true and slug='lark-hill-sanatorium-demo'
on conflict (place_id) do nothing;

insert into public.sources (title,url,author,publisher,source_type,description,citation,verification_state,publication_state,moderation_state,is_demo)
values
('Abandix demo field note','https://example.com/abandix-demo-field-note','Abandix Demo','Abandix','abandix_submission','Synthetic source record for development.','Abandix demo field note (synthetic).','verified','published','visible',true),
('Greyhaven Municipal Archive — Demo Catalogue','https://example.com/greyhaven-demo-archive','Demo Archive','Greyhaven Municipal Archive','historical_archive','Synthetic archive record for development.','Greyhaven Municipal Archive, demo catalogue entry.','community_confirmed','published','visible',true)
on conflict do nothing;

insert into public.reports (slug,place_id,title,occurred_at,content,anonymous_display,verification_state,publication_state,moderation_state,is_demo)
select 'meridian-first-survey-demo', p.id, 'First survey — demo', '2025-05-18 11:00:00+00',
  'Synthetic report. In a real record this section would separate direct observations from historical claims and cite the original material.',
  false, 'verified','published','visible',true
from public.places p where p.slug='meridian-factory-demo'
on conflict (slug) do nothing;

insert into public.place_timeline (place_id,event_date,title,description,event_type,confidence)
select p.id,'2018-06-01','Closure recorded','Synthetic chronology: operations cease in the demo scenario.','closure','verified'
from public.places p where p.slug='meridian-factory-demo';
insert into public.place_timeline (place_id,event_date,title,description,event_type,confidence)
select p.id,'2022-09-17','Roof damage reported','Synthetic chronology: weather damage is recorded in a later report.','damage','community_confirmed'
from public.places p where p.slug='meridian-factory-demo';

insert into public.place_status_history (place_id,condition,effective_at,explanation,verification_state)
select p.id,'preserved','2018-06-01','Synthetic baseline condition.','verified'
from public.places p where p.slug='meridian-factory-demo';
insert into public.place_status_history (place_id,condition,effective_at,explanation,verification_state)
select p.id,'partially_damaged','2022-09-17','Synthetic status change used to demonstrate historical state tracking.','community_confirmed'
from public.places p where p.slug='meridian-factory-demo';

insert into public.tags (slug,label) values ('urban-history','Urban history') on conflict (slug) do nothing;
insert into public.place_tags(place_id,tag_id)
select p.id,t.id from public.places p cross join public.tags t where p.slug='meridian-factory-demo' and t.slug in ('demo','industrial','historical')
on conflict do nothing;

-- A disposable demo account for local/staging UI checks. It uses a reserved invalid domain.
insert into auth.users (id, aud, role, email, encrypted_password, email_confirmed_at, created_at, updated_at, raw_user_meta_data)
values (
  '11111111-1111-4111-8111-111111111111',
  'authenticated', 'authenticated', 'demo@abandix.invalid',
  crypt('AbandixDemoOnly-DoNotUse-2026!', gen_salt('bf')),
  now(), now(), now(), jsonb_build_object('username','abandix_demo')
)
on conflict (id) do nothing;

update public.profiles set username='abandix_demo', bio='Demo account for local/staging UI checks only.' where id='11111111-1111-4111-8111-111111111111';

insert into public.people (slug,name,aliases,known_as,biography,exploration_entry,verification_state,publication_state,moderation_state,is_demo)
values ('mira-vale-demo','Mira Vale (Demo)',array['M. Vale'],array['Demo documentarian'],'Synthetic historical-person record for the Abandix interface.','Synthetic account used to demonstrate how a public historical record can separate source-backed biography from reported claims.','verified','published','visible',true)
on conflict (slug) do nothing;

insert into public.groups (slug,name,group_type,history,publications,verification_state,publication_state,moderation_state,is_demo)
values ('northline-archive-demo','Northline Archive Circle (Demo)','archive community','Synthetic group history for development.','Synthetic publication references for development.','verified','published','visible',true)
on conflict (slug) do nothing;

insert into public.posts (slug,title,body,anonymous_display,publication_state,moderation_state,created_by,is_demo)
values ('field-notes-demo','Field notes: what makes a useful archive entry?','Demo discussion post. In production, discussions remain attached to evidence and avoid publishing operational instructions for unsafe entry.',false,'published','visible','11111111-1111-4111-8111-111111111111',true)
on conflict (slug) do nothing;

insert into public.comments (post_id,author_id,body,moderation_state)
select p.id,'11111111-1111-4111-8111-111111111111','Demo comment: separate observation, interpretation and source attribution.', 'visible'
from public.posts p where p.slug='field-notes-demo'
  and not exists (select 1 from public.comments c where c.post_id=p.id);

insert into public.group_members (group_id,person_id,role_label,source_id)
select g.id,p.id,'documentarian',s.id
from public.groups g, public.people p, public.sources s
where g.slug='northline-archive-demo' and p.slug='mira-vale-demo' and s.is_demo=true
on conflict (group_id, person_id) do nothing;

insert into public.place_people (place_id,person_id,relationship)
select pl.id,pe.id,'demo-related record'
from public.places pl, public.people pe
where pl.slug='meridian-factory-demo' and pe.slug='mira-vale-demo'
on conflict do nothing;

insert into public.place_groups (place_id,group_id,relationship)
select pl.id,g.id,'demo research record'
from public.places pl, public.groups g
where pl.slug='meridian-factory-demo' and g.slug='northline-archive-demo'
on conflict do nothing;

insert into public.source_links (source_id,place_id,context_note)
select s.id,p.id,'Synthetic field-note citation.'
from public.sources s, public.places p where s.title='Abandix demo field note' and p.slug='meridian-factory-demo'
on conflict do nothing;

insert into public.source_links (source_id,person_id,context_note)
select s.id,p.id,'Synthetic biographical citation.'
from public.sources s, public.people p where s.title='Greyhaven Municipal Archive — Demo Catalogue' and p.slug='mira-vale-demo'
on conflict do nothing;
