-- AI Analysis Complete Schema

-- 1. Add missing AI columns (Idempotent)
alter table public.ideas
add column if not exists ai_score integer,
add column if not exists ai_last_analyzed_at timestamptz;

-- Ensure previous columns exist (from previous steps)
alter table public.ideas
add column if not exists ai_investment_summary text,
add column if not exists ai_market_potential text,
add column if not exists ai_execution_risk text,
add column if not exists ai_strengths jsonb,
add column if not exists ai_risks jsonb;

-- 2. RLS Policies for AI Analysis
-- Only Owner or Admin can trigger analysis (logic in Edge Function, but useful here)
-- Everyone can read (Public/Investors)

-- 3. RPC Function (Optional wrapper)
-- This function can be called to "mark" analysis as requested, 
-- or reset the timestamp to force re-analysis.
create or replace function analyze_idea_ai(idea_uuid uuid)
returns void
language plpgsql
security definer
as $$
begin
  -- Check permissions (Owner or Admin)
  if not exists (
    select 1 from ideas 
    where id = idea_uuid 
    and (owner_id = auth.uid() or exists (select 1 from profiles where id = auth.uid() and role = 'Admin'))
  ) then
    raise exception 'Permission denied';
  end if;

  -- Update timestamp to now (locking mechanism / status)
  update public.ideas
  set ai_last_analyzed_at = now() -- marks 'in progress' effectively if checked against 'null' or old date
  where id = idea_uuid;
  
  -- NOTE: This RPC does NOT call the Edge Function directly to avoid pg_net dependency issues.
  -- The Client should call the Edge Function immediately after or instead of this.
  -- Ideally, the Edge Function updates this field upon COMPLETION.
end;
$$;
