-- 1. Create the Idea Activity Log Table
CREATE TABLE public.idea_activity_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  idea_id uuid NOT NULL,
  actor_profile_id uuid, -- Nullable, generic system events might not have a profile
  actor_role text,
  event_type text NOT NULL,
  title text NOT NULL,
  description text,
  metadata jsonb DEFAULT '{}'::jsonb,
  created_at timestamptz NOT NULL DEFAULT timezone('utc', now()),

  CONSTRAINT fk_idea FOREIGN KEY (idea_id) REFERENCES ideas(id) ON DELETE CASCADE,
  CONSTRAINT fk_actor FOREIGN KEY (actor_profile_id) REFERENCES profiles(id) ON DELETE SET NULL
);

-- 2. Index for performance
CREATE INDEX idx_idea_activity_log_idea_id ON public.idea_activity_log(idea_id);
CREATE INDEX idx_idea_activity_log_created_at ON public.idea_activity_log(created_at DESC);

-- 3. RLS Policies
ALTER TABLE public.idea_activity_log ENABLE ROW LEVEL SECURITY;

-- Allow read access to everyone (public timeline)
CREATE POLICY "Public read for idea activity"
ON public.idea_activity_log
FOR SELECT
USING (true);

-- Allow system/backend to insert (and authenticated users triggering events)
-- In a real production app, you might restrict insertion to server-side functions only.
-- For this architecture, we allow authenticated users to insert logs relevant to their actions if we do it client-side,
-- BUT ideally, this should be wrapped in Postgres Functions to prevent spoofing.
-- For now, we allow authenticated users to insert.
CREATE POLICY "Authenticated users can insert activity logs"
ON public.idea_activity_log
FOR INSERT
WITH CHECK (auth.role() = 'authenticated');

-- No updates or deletes allowed for standard users (Append Only)
-- Admins might need bypass (not implemented here)

-- 4. Comment on columns
COMMENT ON COLUMN public.idea_activity_log.event_type IS 'Standardized event keys: idea_created, mentor_feedback_added, etc.';
COMMENT ON COLUMN public.idea_activity_log.metadata IS 'JSON payload for extra details like scores, deltas, specific achievement IDs.';
