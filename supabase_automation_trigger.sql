-- Startlink Automation: Collaboration Acceptance Trigger
-- This script automates adding contributors to teams and initializing chat groups.

-- 1. Ensure unique constraint on groups for (idea_id, type)
ALTER TABLE groups ADD CONSTRAINT IF NOT EXISTS groups_idea_type_key UNIQUE (idea_id, type);

-- 2. Create the collaboration acceptance function
CREATE OR REPLACE FUNCTION handle_collaboration_accept()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER -- Runs with elevated permissions to bypass RLS for inserts
AS $$
BEGIN
    -- Only act when status changes to 'accepted'
    IF NEW.status = 'accepted' AND (OLD.status IS DISTINCT FROM NEW.status) THEN
        
        -- A. Insert into idea_collaborators
        -- This ensures the user is added to the official team list
        INSERT INTO idea_collaborators (
            idea_id,
            user_id,
            role,
            status,
            joined_at
        )
        VALUES (
            NEW.idea_id,
            NEW.applicant_id,
            NEW.role_applied,
            'Accepted',
            NOW()
        )
        ON CONFLICT (idea_id, user_id) DO UPDATE 
        SET status = 'Accepted', joined_at = NOW();

        -- B. Ensure 'team' group exists for the idea
        -- Group name defaults to the Idea Title
        INSERT INTO groups (
            idea_id,
            name,
            type,
            created_at
        )
        SELECT 
            i.id,
            i.title,
            'team',
            NOW()
        FROM ideas i
        WHERE i.id = NEW.idea_id
        ON CONFLICT (idea_id, type) DO NOTHING;

    END IF;

    RETURN NEW;
END;
$$;

-- 3. Create the trigger on collaboration_requests
-- Runs whenever an innovator updates an application status
DROP TRIGGER IF EXISTS collaboration_accept_trigger ON collaboration_requests;
CREATE TRIGGER collaboration_accept_trigger
AFTER UPDATE ON collaboration_requests
FOR EACH ROW
WHEN (OLD.status IS DISTINCT FROM NEW.status)
EXECUTE FUNCTION handle_collaboration_accept();

-- 4. RLS Update: Ensure idea owners and accepted collaborators can access team groups and messages

-- For groups
DROP POLICY IF EXISTS "Team members can view their private groups" ON groups;
CREATE POLICY "Team members can view their private groups"
ON groups FOR SELECT
USING (
    type = 'team' AND (
        EXISTS (SELECT 1 FROM ideas i WHERE i.id = groups.idea_id AND i.owner_id = auth.uid())
        OR
        EXISTS (SELECT 1 FROM idea_collaborators ic WHERE ic.idea_id = groups.idea_id AND ic.user_id = auth.uid() AND ic.status = 'Accepted')
    )
);

-- For messages
DROP POLICY IF EXISTS "Team members can read/send messages in private groups" ON messages;
CREATE POLICY "Team members can read/send messages in private groups"
ON messages
FOR ALL
USING (
    EXISTS (
        SELECT 1 FROM groups g
        JOIN ideas i ON i.id = g.idea_id
        WHERE g.id = messages.group_id AND g.type = 'team'
        AND (i.owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM idea_collaborators ic 
            WHERE ic.idea_id = g.idea_id AND ic.user_id = auth.uid() AND ic.status = 'Accepted'
        ))
    )
)
WITH CHECK (
    EXISTS (
        SELECT 1 FROM groups g
        JOIN ideas i ON i.id = g.idea_id
        WHERE g.id = messages.group_id AND g.type = 'team'
        AND (i.owner_id = auth.uid() OR EXISTS (
            SELECT 1 FROM idea_collaborators ic 
            WHERE ic.idea_id = g.idea_id AND ic.user_id = auth.uid() AND ic.status = 'Accepted'
        ))
    )
);
