-- 1. Create the Idea Matches Cache Table
CREATE TABLE public.idea_matches (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  idea_id uuid NOT NULL,
  matched_profile_id uuid NOT NULL,
  role text NOT NULL, -- 'Mentor' or 'Collaborator'
  match_score integer NOT NULL, -- 0 to 100
  match_reason jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz DEFAULT timezone('utc', now()),

  CONSTRAINT fk_idea_match FOREIGN KEY (idea_id) REFERENCES ideas(id) ON DELETE CASCADE,
  CONSTRAINT fk_profile_match FOREIGN KEY (matched_profile_id) REFERENCES profiles(id) ON DELETE CASCADE,
  UNIQUE (idea_id, matched_profile_id)
);

-- 2. Indexes for performance
CREATE INDEX idx_idea_matches_idea_id ON public.idea_matches(idea_id);
CREATE INDEX idx_idea_matches_score ON public.idea_matches(match_score DESC);

-- 3. RLS Policies
ALTER TABLE public.idea_matches ENABLE ROW LEVEL SECURITY;

-- Everyone can read matches (or restrict to idea owner + matched user + investors)
-- For now, open read for simplicity in MVP, or restrict to authenticated
CREATE POLICY "Public read for matches"
ON public.idea_matches
FOR SELECT
USING (true);

-- Allow authenticated users (system/business logic acting as user) to insert/update
CREATE POLICY "Authenticated users can manage matches"
ON public.idea_matches
FOR ALL
USING (auth.role() = 'authenticated');
