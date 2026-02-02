-- Investor Interests Table
create table if not exists public.investor_interests (
  id uuid primary key default gen_random_uuid(),
  idea_id uuid not null,
  investor_id uuid not null,
  status text default 'Interested', -- 'Interested', 'Bookmarked', 'Rejected'
  created_at timestamptz default timezone('utc', now()),

  foreign key (idea_id) references ideas(id) on delete cascade,
  foreign key (investor_id) references profiles(id) on delete cascade
);

-- RLS
alter table public.investor_interests enable row level security;

-- Investors can see their own interests
create policy "Investors can view own interests"
on public.investor_interests for select
using ( auth.uid() = investor_id );

-- Investors can create interests
create policy "Investors can create interests"
on public.investor_interests for insert
with check ( auth.uid() = investor_id );

-- Investors can update own interests (e.g. unbookmark)
create policy "Investors can update own interests"
on public.investor_interests for update
using ( auth.uid() = investor_id );

-- Innovators can see who is interested in their ideas
create policy "Innovators can view interests on their ideas"
on public.investor_interests for select
using ( 
  exists (
    select 1 from ideas 
    where ideas.id = investor_interests.idea_id 
    and ideas.owner_id = auth.uid()
  )
);
