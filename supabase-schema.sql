-- Run this in the Supabase SQL Editor (your project -> SQL Editor -> New query)

create table if not exists weights (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  value numeric not null,
  created_at timestamptz not null default now(),
  unique (user_id, date)
);

create table if not exists calorie_entries (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  date date not null,
  source text not null default 'manual',
  food text not null,
  serving text default '',
  servings numeric default 1,
  calories numeric not null default 0,
  created_at timestamptz not null default now()
);

alter table weights enable row level security;
alter table calorie_entries enable row level security;

create policy "weights: owner select" on weights
  for select using (auth.uid() = user_id);
create policy "weights: owner insert" on weights
  for insert with check (auth.uid() = user_id);
create policy "weights: owner update" on weights
  for update using (auth.uid() = user_id);
create policy "weights: owner delete" on weights
  for delete using (auth.uid() = user_id);

create policy "calories: owner select" on calorie_entries
  for select using (auth.uid() = user_id);
create policy "calories: owner insert" on calorie_entries
  for insert with check (auth.uid() = user_id);
create policy "calories: owner update" on calorie_entries
  for update using (auth.uid() = user_id);
create policy "calories: owner delete" on calorie_entries
  for delete using (auth.uid() = user_id);

-- Profile: height/age/sex/activity/goal, used to compute BMI and target calories.
create table if not exists profiles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  height_cm numeric,
  age integer,
  sex text check (sex in ('male', 'female')),
  activity_level text check (activity_level in ('sedentary', 'light', 'moderate', 'active', 'very_active')),
  goal text check (goal in ('maintain', 'fatloss')),
  updated_at timestamptz not null default now()
);

alter table profiles enable row level security;

create policy "profiles: owner select" on profiles
  for select using (auth.uid() = user_id);
create policy "profiles: owner insert" on profiles
  for insert with check (auth.uid() = user_id);
create policy "profiles: owner update" on profiles
  for update using (auth.uid() = user_id);

-- Habits: user-defined habits (gym visits, steps, custom) and their daily logs.
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
