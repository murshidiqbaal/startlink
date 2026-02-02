-- SEED DATA SCRIPT
-- Run this in Supabase SQL Editor to populate your app with test data.

DO $$
DECLARE
    test_user_id UUID;
    test_idea_id UUID;
BEGIN
    -- 1. GET A TEST USER (The first user found in profiles)
    SELECT id INTO test_user_id FROM public.profiles LIMIT 1;

    IF test_user_id IS NULL THEN
        RAISE NOTICE 'No users found in profiles. Please Sign Up in the app first!';
        RETURN;
    END IF;

    RAISE NOTICE 'Seeding data for User ID: %', test_user_id;

    -- 2. INSERT DUMMY VERIFICATIONS (For Admin Dashboard)
    -- Pending Request
    INSERT INTO public.user_verifications (profile_id, role, verification_type, status, created_at)
    VALUES (test_user_id, 'Innovator', 'LinkedIn', 'Pending', NOW() - INTERVAL '1 hour');

    -- Approved Request
    INSERT INTO public.user_verifications (profile_id, role, verification_type, status, verified_at, created_at)
    VALUES (test_user_id, 'Mentor', 'Document', 'Approved', NOW(), NOW() - INTERVAL '2 days');

    -- Rejected Request
    INSERT INTO public.user_verifications (profile_id, role, verification_type, status, metadata, created_at)
    VALUES (test_user_id, 'Investor', 'ProfileCompletion', 'Rejected', '{"rejection_reason": "Incomplete profile"}', NOW() - INTERVAL '5 days');


    -- 3. INSERT DUMMY IDEA (For Dashboard)
    INSERT INTO public.ideas (id, author_id, title, description, problem_statement, solution, target_market, current_stage, tags, status, created_at)
    VALUES (
        gen_random_uuid(),
        test_user_id,
        'EcoTrack AI',
        'An AI-powered waste management solution for smart cities.',
        'Cities struggle with inefficient waste collection.',
        'Smart sensors and route optimization AI.',
        'Smart Cities',
        'Seed',
        ARRAY['AI', 'CleanTech', 'IoT'],
        'Open',
        NOW()
    )
    RETURNING id INTO test_idea_id;

    -- 4. INSERT IDEA DNA (For Detail Screen)
    INSERT INTO public.idea_dna (idea_id, overall_score, market, risk, innovation, revenue)
    VALUES (
        test_idea_id,
        78,
        '{"score": 85, "summary": "High demand in urban areas.", "metrics": [{"label": "Size", "value": 90}, {"label": "Growth", "value": 80}]}'::jsonb,
        '{"score": 65, "summary": "Regulatory hurdles present.", "metrics": [{"label": "Competition", "value": 60}, {"label": "Tech Risk", "value": 70}]}'::jsonb,
        '{"score": 80, "summary": "Novel sensor integration.", "metrics": [{"label": "IP", "value": 85}, {"label": "Moat", "value": 75}]}'::jsonb,
        '{"score": 75, "summary": "SaaS B2G model.", "metrics": [{"label": "LTV", "value": 80}, {"label": "Scale", "value": 70}]}'::jsonb
    );

    RAISE NOTICE 'Data Seeded Successfully!';
END $$;
