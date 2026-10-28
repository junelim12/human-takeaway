-- Human Takeaway: lines table with row-level security.
-- Applied to the project as migration "create_lines". Re-run safely on a fresh project.

create table if not exists public.lines (
  id           uuid primary key,
  user_id      uuid not null default auth.uid() references auth.users (id) on delete cascade,
  line         text not null check (char_length(line) between 1 and 140),
  event_title  text not null default '',
  industries   text[] not null default '{}',
  functions    text[] not null default '{}',
  role         text not null default 'job' check (role in ('job', 'mkt', 'founder')),
  source_name  text not null default '',
  posts        jsonb,
  visibility   text not null default 'private' check (visibility in ('private', 'public')),
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

-- Public lines are not readable by anyone else yet. Exposure for event pages
-- (line, event title and tags only) will be added with that feature.
