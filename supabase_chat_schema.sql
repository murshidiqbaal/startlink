-- Table for teams/groups (one per idea per type: 'team' or 'public')
CREATE TABLE IF NOT EXISTS groups (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    idea_id UUID NOT NULL REFERENCES ideas(id) ON DELETE CASCADE,
    name TEXT, -- Can store the idea title at creation time
    type TEXT DEFAULT 'team', -- 'team' or 'public'
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT groups_idea_type_key UNIQUE (idea_id, type)
);

-- Table for messages (group-based)
CREATE TABLE IF NOT EXISTS messages (
    id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
    group_id uuid NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    sender_id uuid NOT NULL REFERENCES profiles(id),
    content text NOT NULL,
    is_read boolean DEFAULT false,
    created_at timestamptz DEFAULT now()
);

-- Enable RLS
ALTER TABLE groups ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies for groups
CREATE POLICY "Public groups are visible to all"
ON groups FOR SELECT
USING (type = 'public' OR auth.uid() IS NOT NULL); -- Adjust as needed: if public, everyone sees it; otherwise, they need auth.

CREATE POLICY "Team members can view their private groups"
ON groups FOR SELECT
USING (
    type = 'team' AND (
        EXISTS (SELECT 1 FROM ideas i WHERE i.id = groups.idea_id AND i.owner_id = auth.uid())
        OR
        EXISTS (SELECT 1 FROM idea_collaborators ic WHERE ic.idea_id = groups.idea_id AND ic.user_id = auth.uid())
    )
);

-- Policies for messages
CREATE POLICY "Anyone can read and send messages in public groups"
ON messages
FOR ALL
USING (
    EXISTS (SELECT 1 FROM groups g WHERE g.id = messages.group_id AND g.type = 'public')
)
WITH CHECK (
    EXISTS (SELECT 1 FROM groups g WHERE g.id = messages.group_id AND g.type = 'public')
);

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
