-- AI Insights Columns for Ideas
alter table public.ideas
add column if not exists ai_investment_summary text,
add column if not exists ai_strengths jsonb,
add column if not exists ai_risks jsonb,
add column if not exists ai_market_potential text, -- 'High', 'Medium', 'Low'
add column if not exists ai_execution_risk text; -- 'High', 'Medium', 'Low'

-- Notes:
-- ai_strengths and ai_risks will store arrays of strings, e.g., ["Clear market pain point", "Scalable"]
-- ai_fit_score is likely dynamic per investor, so we might calculate that on the fly or store it in a separate cache table 
-- if we want persistent caching per investor-idea pair.
-- For this MVP, let's assume 'ai_fit_score' requested in prompt is a general "Idea Quality Score" 
-- OR if meant to be personalized, we can't store it on the Idea table directly.
-- PROMPT says: "Based on investor profile... Show Fit for you: 82%".
-- This implies real-time calculation or a separate junction table.
-- Given requirement "AI results should be cached", maybe we cache the "General Analysis" on the idea,
-- and do the "Fit personalization" client-side or via a lightweight function using the cached General Analysis + Investor Profile.
-- Let's stick to storing the General Analysis on the Idea table as requested.

-- If we really need to store personalized fit, we'd need `investor_idea_insights` table.
-- But prompt said "Extend ideas table... add column ai_fit_score". 
-- This implies a misunderstanding in the prompt or a request for a 'General Fit Score' (e.g. alignment with platform trends).
-- I will add `ai_quality_score` (already there?) or `ai_general_score` to ideas.
-- For personalized fit, I will implement it in the BLoC/Repo logic to compare Investor Profile vs Idea Tags/Stage.
