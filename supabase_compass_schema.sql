-- 1. Create Compass Recommendations Cache Table
CREATE TABLE public.user_compass_recommendations (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  profile_id uuid NOT NULL,
  role text NOT NULL, -- 'Innovator', 'Mentor', 'Investor'
  action_key text NOT NULL, -- e.g., 'complete_profile', 'improve_problem_clarity'
  title text NOT NULL,
  description text,
  expected_benefit jsonb DEFAULT '{}'::jsonb, -- e.g., {"aura": 20, "confidence": 5}
  priority integer NOT NULL DEFAULT 0, -- Higher is more important
  created_at timestamptz DEFAULT timezone('utc', now()),

  CONSTRAINT fk_compass_profile FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE
);

-- 2. Indexes
CREATE INDEX idx_compass_profile_id ON public.user_compass_recommendations(profile_id);
CREATE INDEX idx_compass_priority ON public.user_compass_recommendations(priority DESC);

-- 3. RLS
ALTER TABLE public.user_compass_recommendations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can read own compass"
ON public.user_compass_recommendations
FOR SELECT
USING (auth.uid() = profile_id);

CREATE POLICY "Authenticated users/system can output compass items"
ON public.user_compass_recommendations
FOR INSERT
WITH CHECK (auth.role() = 'authenticated'); -- or restrict to service role if server-side only

CREATE POLICY "Users can manage own compass items"
ON public.user_compass_recommendations
FOR DELETE
USING (auth.uid() = profile_id);
