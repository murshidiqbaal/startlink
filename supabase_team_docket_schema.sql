-- ==========================================
-- TEAM DOCKET SCHEMA MIGRATION
-- ==========================================

-- 1. Create specialized tables
CREATE TABLE teams (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    idea_id uuid NOT NULL REFERENCES ideas(id) ON DELETE CASCADE,
    name text NOT NULL,
    created_at timestamptz DEFAULT now(),
    UNIQUE(idea_id)
);

CREATE TABLE team_members (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id uuid NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    user_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    role text NOT NULL CHECK (role IN ('admin', 'member')),
    joined_at timestamptz DEFAULT now(),
    UNIQUE(team_id, user_id)
);

CREATE TABLE team_messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    team_id uuid NOT NULL REFERENCES teams(id) ON DELETE CASCADE,
    sender_id uuid NOT NULL REFERENCES profiles(id) ON DELETE CASCADE,
    content text NOT NULL,
    created_at timestamptz DEFAULT now()
);

-- 2. Automation: handle_collaboration_accept()
CREATE OR REPLACE FUNCTION handle_collaboration_accept()
RETURNS TRIGGER AS $$
DECLARE
    v_team_id uuid;
    v_idea_title text;
    v_innovator_id uuid;
BEGIN
    -- 1. Get Idea Details
    SELECT title, owner_id INTO v_idea_title, v_innovator_id 
    FROM ideas WHERE id = NEW.idea_id;

    -- 2. Ensure Team exists
    INSERT INTO teams (idea_id, name)
    VALUES (NEW.idea_id, v_idea_title)
    ON CONFLICT (idea_id) DO UPDATE SET name = v_idea_title
    RETURNING id INTO v_team_id;

    -- 3. Add Innovator (Admin) if not already member
    INSERT INTO team_members (team_id, user_id, role)
    VALUES (v_team_id, v_innovator_id, 'admin')
    ON CONFLICT DO NOTHING;

    -- 4. Add accepted Collaborator (Member)
    IF NEW.status = 'accepted' THEN
        INSERT INTO team_members (team_id, user_id, role)
        VALUES (v_team_id, NEW.user_id, 'member')
        ON CONFLICT DO NOTHING;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Trigger on idea_collaborators (since collaboration_requests already handles this sync)
CREATE TRIGGER tr_on_collaboration_added
AFTER INSERT OR UPDATE ON idea_collaborators
FOR EACH ROW
WHEN (NEW.status = 'accepted')
EXECUTE FUNCTION handle_collaboration_accept();

-- 3. RLS Policies
ALTER TABLE teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE team_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Team members can view their teams" ON teams
    FOR SELECT USING (EXISTS (SELECT 1 FROM team_members WHERE team_id = teams.id AND user_id = auth.uid()));

CREATE POLICY "Team members can view membership" ON team_members
    FOR SELECT USING (EXISTS (SELECT 1 FROM team_members tm WHERE tm.team_id = team_members.team_id AND tm.user_id = auth.uid()));

CREATE POLICY "Team members can read messages" ON team_messages
    FOR SELECT USING (EXISTS (SELECT 1 FROM team_members WHERE team_id = team_messages.team_id AND user_id = auth.uid()));

CREATE POLICY "Team members can send messages" ON team_messages
    FOR INSERT WITH CHECK (EXISTS (SELECT 1 FROM team_members WHERE team_id = team_messages.team_id AND user_id = auth.uid()));

-- 4. Seed Query: Existing teams
INSERT INTO teams (idea_id, name)
SELECT id, title FROM ideas
ON CONFLICT DO NOTHING;

INSERT INTO team_members (team_id, user_id, role)
SELECT t.id, i.owner_id, 'admin'
FROM teams t JOIN ideas i ON t.idea_id = i.id
ON CONFLICT DO NOTHING;
