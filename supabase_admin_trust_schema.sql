-- User Trust Scores Table
create table if not exists public.user_trust_scores (
  profile_id uuid primary key references profiles(id) on delete cascade,
  role text not null,
  trust_score integer default 0,
  last_calculated timestamptz default timezone('utc', now())
);

-- Add Boosting columns to Ideas table
alter table public.ideas 
add column if not exists is_boosted boolean default false,
add column if not exists boost_score integer default 0;

-- RLS for Trust Scores
alter table public.user_trust_scores enable row level security;

create policy "Trust scores are viewable by everyone"
on public.user_trust_scores for select
using ( true );

-- Only system/admin (or trigger) should update trust scores ideally. 
-- For now, allowing authenticated users to insert/update their own for calculation logic flow
-- checking auth.uid() = profile_id
create policy "Users can update own trust score calculation"
on public.user_trust_scores for insert
with check ( auth.uid() = profile_id );

create policy "Users can update own trust score"
on public.user_trust_scores for update
using ( auth.uid() = profile_id );
