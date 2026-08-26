-- Migration: adds habit tracking (gym visits, steps, custom habits).
-- Run this in the Supabase SQL Editor (your project -> SQL Editor -> New query).

create table if not exists habits (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  name text not null,
  type text not null check (type in ('checkbox', 'number')),
  unit text,
  created_at timestamptz not null default now(),
  unique (user_id, name)
);

create table if not exists habit_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  habit_id uuid not null references habits(id) on delete cascade,
  date date not null,
  value numeric not null default 1,
  created_at timestamptz not null default now(),
  unique (habit_id, date)
);

alter table habits enable row level security;
alter table habit_logs enable row level security;

create policy "habits: owner select" on habits
  for select using (auth.uid() = user_id);
create policy "habits: owner insert" on habits
  for insert with check (auth.uid() = user_id);
create policy "habits: owner update" on habits
  for update using (auth.uid() = user_id);
create policy "habits: owner delete" on habits
  for delete using (auth.uid() = user_id);

create policy "habit_logs: owner select" on habit_logs
  for select using (auth.uid() = user_id);
create policy "habit_logs: owner insert" on habit_logs
  for insert with check (auth.uid() = user_id);
create policy "habit_logs: owner update" on habit_logs
  for update using (auth.uid() = user_id);
create policy "habit_logs: owner delete" on habit_logs
  for delete using (auth.uid() = user_id);
