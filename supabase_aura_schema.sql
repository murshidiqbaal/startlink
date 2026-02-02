-- User Aura Activity Log
create table public.user_aura (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null,
  role text not null, -- 'Originator', 'Innovator', 'Mentor', 'Investor'
  points integer not null,
  reason text not null, -- e.g., 'Published Idea', 'Profile Completion'
  metadata jsonb, -- Trigger event ID, source, etc.
  created_at timestamptz not null default timezone('utc', now()),

  foreign key (profile_id) references profiles(id) on delete cascade
);

-- Add aggregated Aura Points to Profile for fast access
alter table public.profiles
add column if not exists aura_points integer default 0;

-- RLS: Only system should insert typically (Edge Function or Service Role), 
-- but for MVP we might allow client-side inserts guarded by strict BL logic or triggers.
-- Actually, strict security would rely on Database Triggers for points.
-- For Clean Architecture/Client-driven MVP, we will allow Authenticated INSERTs 
-- only for their own profile, BUT a better approach is an RPC or Trigger.
-- Let's use RLS assuming backend validation, or an RPC.

alter table public.user_aura enable row level security;

-- Read policy (Public can see aura history? Maybe only self/admin for history. Total is public on profile)
create policy "Users can read own aura history"
on public.user_aura for select
using ( auth.uid() = profile_id );

-- Insert policy (Ideally this is handled by database triggers to avoid client spoofing)
-- For MVP speed:
create policy "Users can NOT insert aura history directly"
on public.user_aura for insert
with check ( false ); -- Force usage of a secure function

-- Secure RPC to award points
create or replace function award_aura_points(
  target_profile_id uuid,
  points_to_add integer,
  reason_text text,
  metadata_json jsonb default '{}'::jsonb
)
returns void
language plpgsql
security definer
as $$
declare
  current_points integer;
  target_role text;
begin
  -- Fetch current role
  select role into target_role from profiles where id = target_profile_id;
  
  -- Insert log
  insert into public.user_aura (profile_id, role, points, reason, metadata)
  values (target_profile_id, coalesce(target_role, 'Unknown'), points_to_add, reason_text, metadata_json);

  -- Update profile total
  -- Floor rule: max(0, current + add)
  update public.profiles
  set aura_points = greatest(0, coalesce(aura_points, 0) + points_to_add)
  where id = target_profile_id;
end;
$$;
