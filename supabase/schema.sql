-- Human Takeaway: lines table with row-level security.
-- Run once in the Supabase SQL editor.

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

-- Owners can do everything with their own lines.
drop policy if exists "own lines: read" on public.lines;
create policy "own lines: read" on public.lines
  for select using (auth.uid() = user_id);

drop policy if exists "own lines: insert" on public.lines;
create policy "own lines: insert" on public.lines
  for insert with check (auth.uid() = user_id);

drop policy if exists "own lines: update" on public.lines;
create policy "own lines: update" on public.lines
  for update using (auth.uid() = user_id) with check (auth.uid() = user_id);

drop policy if exists "own lines: delete" on public.lines;
create policy "own lines: delete" on public.lines
  for delete using (auth.uid() = user_id);

-- Public lines: only the line and its event are exposed, through this view.
-- Posts, source names and author ids stay private.
create or replace view public.public_lines
with (security_invoker = false) as
  select id, line, event_title, industries, functions, role, created_at
  from public.lines
  where visibility = 'public';

grant select on public.public_lines to anon, authenticated;
