-- User Verifications Table
create table if not exists public.user_verifications (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null,
  role text not null,
  verification_type text not null, -- 'ProfileCompletion', 'LinkedIn', 'Document'
  status text not null default 'Pending',
  verified_at timestamptz,
  metadata jsonb,
  created_at timestamptz not null default timezone('utc', now()),

  constraint verification_status_check
  check (status in ('Pending', 'Approved', 'Rejected')),

  foreign key (profile_id) references profiles(id) on delete cascade
);

-- User Badges Table
create table if not exists public.user_badges (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null,
  badge_key text not null, -- 'profile_verified', 'trusted_mentor', 'verified_investor', 'active_innovator'
  badge_label text not null,
  badge_description text,
  icon text,
  awarded_at timestamptz not null default timezone('utc', now()),

  foreign key (profile_id) references profiles(id) on delete cascade
);

-- RLS Policies (Simple for now: Users can read own, public logic handled by app for now or public read)
alter table public.user_verifications enable row level security;
alter table public.user_badges enable row level security;

create policy "Public badges are viewable by everyone"
on public.user_badges for select
using ( true );

create policy "Users can view own verifications"
on public.user_verifications for select
using ( auth.uid() = profile_id );

-- Allow insertion for system (if using service role) or simple authenticated insert for now (to function)
create policy "Users can insert own verifications request"
on public.user_verifications for insert
with check ( auth.uid() = profile_id );

-- Admin Access Policy
create policy "Admins can view all verifications"
on public.user_verifications for select
using (
  exists (
    select 1 from public.profiles
    where id = auth.uid() and role = 'Admin'
  )
);

