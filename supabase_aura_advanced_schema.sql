-- Aura Leaderboards & Weekly Summaries & Decay

-- 1. Weekly Summaries Table
create table if not exists public.aura_weekly_summary (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null references profiles(id) on delete cascade,
  week_start date not null,
  week_end date not null,
  aura_earned integer default 0,
  top_actions jsonb default '[]'::jsonb, -- e.g. [{"action": "Published Idea", "points": 40}]
  created_at timestamptz default timezone('utc', now())
);

-- RLS for Summaries
alter table public.aura_weekly_summary enable row level security;
create policy "Users view own summaries"
on public.aura_weekly_summary for select using (auth.uid() = profile_id);

-- 2. Add Last Active Column for Decay Tracking
alter table public.profiles
add column if not exists last_active_at timestamptz default timezone('utc', now());

-- 3. Add Final Confidence Score to Ideas (Integration)
alter table public.ideas
add column if not exists final_confidence_score integer;

-- 4. Decay Logic Function (to be scheduled via pg_cron or Edge Function)
-- This function identifies inactive users and applies decay.
-- Logic: If inactive > 14 days, reduce by 5%.
create or replace function apply_aura_decay()
returns void
language plpgsql
security definer
as $$
declare
  user_rec record;
  decay_amount integer;
begin
  for user_rec in 
    select id, aura_points, last_active_at 
    from profiles 
    where last_active_at < (now() - interval '14 days')
    and aura_points > 0 -- Don't decay zero
  loop
    -- Calculate 5% decay
    decay_amount := floor(user_rec.aura_points * 0.05);
    
    -- Ensure at least 1 point if points > 0, but respect max 30% rule historically/logic-wise
    if decay_amount < 1 then decay_amount := 1; end if;

    -- Apply update using existing RPC logic preferably, or direct here for batch
    -- Log it first
    insert into user_aura (profile_id, role, points, reason, metadata)
    values (
      user_rec.id, 
      (select role from profiles where id = user_rec.id), 
      -decay_amount, 
      'Inactivity decay', 
      '{"system": "auto_decay"}'::jsonb
    );

    -- Update profile
    update profiles 
    set aura_points = greatest(0, aura_points - decay_amount)
    where id = user_rec.id;
    
  end loop;
end;
$$;
