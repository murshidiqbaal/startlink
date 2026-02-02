-- AI Mentor Feedback
alter table public.ideas
add column if not exists ai_mentor_summary text,
add column if not exists ai_mentor_strengths jsonb,
add column if not exists ai_mentor_concerns jsonb,
add column if not exists ai_mentor_suggestions jsonb;

-- Investor Analytics
create table if not exists public.investor_analytics (
  id uuid primary key default gen_random_uuid(),
  investor_id uuid not null,
  idea_id uuid, -- nullable (metrics might be general)
  action text not null, -- 'view', 'bookmark', 'express_interest'
  domain_viewed text, -- e.g. 'FinTech'
  stage_viewed text, -- e.g. 'MVP'
  trust_score_viewed integer,
  created_at timestamptz default timezone('utc', now()),
  
  foreign key (investor_id) references profiles(id) on delete cascade
);

-- RLS for Analytics
alter table public.investor_analytics enable row level security;
create policy "Investors can view own analytics"
on public.investor_analytics for select using (auth.uid() = investor_id);
create policy "Investors can insert own analytics"
on public.investor_analytics for insert with check (auth.uid() = investor_id);

-- Confidence History
create table if not exists public.idea_confidence_history (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid not null,
  confidence_score integer, -- 0-100 derived
  calculated_at timestamptz default timezone('utc', now()),
  
  foreign key (idea_id) references ideas(id) on delete cascade
);

-- Policies
alter table public.idea_confidence_history enable row level security;
create policy "Everyone can read confidence history"
on public.idea_confidence_history for select using (true);
-- Write: only system/triggers ideally, but we'll allow owner for MVP simulation or Edge Functions
create policy "System updates confidence"
on public.idea_confidence_history for insert with check (
  exists (select 1 from ideas where id = idea_confidence_history.idea_id and owner_id = auth.uid()) 
  or 
  exists (select 1 from profiles where id = auth.uid() and role = 'Admin')
);
