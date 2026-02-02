-- Create table for Idea DNA
CREATE TABLE IF NOT EXISTS public.idea_dna (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    idea_id UUID REFERENCES public.ideas(id) ON DELETE CASCADE NOT NULL UNIQUE,
    overall_score NUMERIC DEFAULT 0,
    market JSONB DEFAULT '{}'::jsonb,
    risk JSONB DEFAULT '{}'::jsonb,
    innovation JSONB DEFAULT '{}'::jsonb,
    revenue JSONB DEFAULT '{}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE public.idea_dna ENABLE ROW LEVEL SECURITY;

-- Policies
-- 1. Everyone can view DNA analysis
CREATE POLICY "Enable read access for all users" ON public.idea_dna
    FOR SELECT USING (true);

-- 2. Only system (service_role) or the idea owner should probably update it.
-- For simplicity in this demo, we'll allow authenticated users to insert if they own the idea (requires join)
-- or easier: just allow service role (Supabase Edge Function) to write to it.
-- Service role always bypasses RLS, so no specific policy needed for it.
