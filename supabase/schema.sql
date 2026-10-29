-- Human Takeaway: lines, profiles and the feed, with row-level security.
-- Applied to the project as migrations create_lines, add_builder_role and add_profiles_and_feed.

create table if not exists public.lines (
  id           uuid primary key,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  line         text not null check (char_length(line) between 1 and 140),
  event_title  text not null default '',
  industries   text[] not null default '{}',
  functions    text[] not null default '{}',
  role         text not null default 'job' check (role in ('job', 'mkt', 'founder', 'builder')),
  source_name  text not null default '',
  posts        jsonb,
  visibility   text not null default 'private' check (visibility in ('private', 'public')),
  event_summary text not null default '' check (char_length(event_summary) <= 200),
  created_at   timestamptz not null default now()
);

create index if not exists lines_user_created_idx on public.lines (user_id, created_at desc);
create index if not exists lines_public_event_idx on public.lines (lower(event_title)) where visibility = 'public';

alter table public.lines enable row level security;

-- Signed-in users can only see and change their own lines.
create policy "own lines: read" on public.lines
  for select to authenticated using ((select auth.uid()) = user_id);
create policy "own lines: insert" on public.lines
  for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "own lines: update" on public.lines
  for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);
create policy "own lines: delete" on public.lines
  for delete to authenticated using ((select auth.uid()) = user_id);

-- Feed: public profiles, and a separate table holding only what is shared
-- (the line, the event and its summary). Posts, tags and file names stay in `lines`.
create table if not exists public.profiles (
  user_id    uuid primary key default auth.uid() references auth.users (id) on delete cascade,
  name       text not null check (char_length(btrim(name)) between 1 and 50),
  bio        text not null default '' check (char_length(bio) <= 160),
  updated_at timestamptz not null default now()
);
alter table public.profiles enable row level security;
create policy "profiles: anyone reads" on public.profiles for select to anon, authenticated using (true);
create policy "profiles: own insert" on public.profiles for insert to authenticated with check ((select auth.uid()) = user_id);
create policy "profiles: own update" on public.profiles for update to authenticated using ((select auth.uid()) = user_id) with check ((select auth.uid()) = user_id);

create table if not exists public.feed_posts (
  id            uuid primary key references public.lines (id) on delete cascade,
  user_id       uuid not null default auth.uid() references public.profiles (user_id) on delete cascade,
  line          text not null check (char_length(line) between 1 and 140),
  event_title   text not null default '' check (char_length(event_title) <= 80),
  event_key     text generated always as (lower(regexp_replace(btrim(event_title), '\s+', ' ', 'g'))) stored,
  event_summary text not null default '' check (char_length(event_summary) <= 200),
  created_at    timestamptz not null default now()
);
create index if not exists feed_posts_created_idx on public.feed_posts (created_at desc);
create index if not exists feed_posts_event_idx on public.feed_posts (event_key, created_at desc);
create index if not exists feed_posts_user_idx on public.feed_posts (user_id);
alter table public.feed_posts enable row level security;
create policy "feed: anyone reads" on public.feed_posts for select to anon, authenticated using (true);
create policy "feed: own insert" on public.feed_posts for insert to authenticated
  with check ((select auth.uid()) = user_id
    and exists (select 1 from public.lines l where l.id = feed_posts.id and l.user_id = (select auth.uid())));
create policy "feed: own delete" on public.feed_posts for delete to authenticated using ((select auth.uid()) = user_id);
