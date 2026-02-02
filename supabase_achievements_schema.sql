-- User Achievements System
create table if not exists public.user_achievements (
  id uuid primary key default gen_random_uuid(),
  profile_id uuid not null,
  role text not null, -- 'Innovator', 'Mentor', 'Investor', 'All'
  achievement_key text not null, -- e.g. 'first_idea', 'verified_user'
  title text not null,
  description text,
  icon_url text, -- Asset path or remote URL
  awarded_at timestamptz not null default timezone('utc', now()),
  metadata jsonb,

  foreign key (profile_id) references profiles(id) on delete cascade,
  unique (profile_id, achievement_key) -- Prevent duplicate awards
);

-- RLS: Public can read achievements, System writes
alter table public.user_achievements enable row level security;

create policy "Users can read all achievements"
on public.user_achievements for select using (true);

-- Insert policy: strictly controlled, ideally via Trigger or RPC
-- For MVP, allow Insert if Auth matches Profile (though typically Rule Engine should be backend/RPC)
-- We will use a secure function for awarding to enforce logic.

-- Function to Award Achievement
create or replace function award_achievement(
  target_profile_id uuid,
  target_role text,
  key_text text,
  title_text text,
  desc_text text,
  icon_path text default null
)
returns void
language plpgsql
security definer
as $$
begin
  -- Insert if not exists (ON CONFLICT DO NOTHING)
  insert into public.user_achievements (profile_id, role, achievement_key, title, description, icon_url)
  values (target_profile_id, target_role, key_text, title_text, desc_text, icon_path)
  on conflict (profile_id, achievement_key) do nothing;
  
  -- Integrating with Aura: Award One-Time Bonus Points if newly inserted
  if found then
     -- Example bonus logic: 50 points for any achievement
     perform award_aura_points(target_profile_id, 50, 'Achievement Unlocked: ' || title_text);
  end if;
end;
$$;
