-- Migration: adds the profiles table (height/age/sex/activity/goal) for BMI + target calories.
-- Run this in the Supabase SQL Editor (your project -> SQL Editor -> New query).

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
