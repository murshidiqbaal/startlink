-- Table for chat rooms (one per idea)
CREATE TABLE IF NOT EXISTS chat_rooms (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    idea_id UUID REFERENCES ideas(id) ON DELETE CASCADE NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    CONSTRAINT chat_rooms_idea_id_key UNIQUE (idea_id)
);

-- Table for chat messages
CREATE TABLE IF NOT EXISTS messages (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    room_id UUID REFERENCES chat_rooms(id) ON DELETE CASCADE NOT NULL,
    sender_id UUID REFERENCES profiles(id) NOT NULL,
    message TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable RLS
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;

-- Policies for chat_rooms
CREATE POLICY "Team members can view chat rooms"
ON chat_rooms
FOR SELECT
USING (
    EXISTS (
        SELECT 1 FROM ideas i 
        WHERE i.id = chat_rooms.idea_id AND i.owner_id = auth.uid()
    )
    OR
    EXISTS (
        SELECT 1 FROM idea_collaborators ic 
        WHERE ic.idea_id = chat_rooms.idea_id AND ic.user_id = auth.uid()
    )
);

-- Policies for messages
CREATE POLICY "Team members can read messages"
ON messages
FOR SELECT
USING (
    EXISTS (
        SELECT 1
        FROM idea_collaborators ic
        JOIN chat_rooms cr ON cr.idea_id = ic.idea_id
        WHERE cr.id = messages.room_id
        AND ic.user_id = auth.uid()
    )
    OR
    EXISTS (
        SELECT 1
        FROM ideas i
        JOIN chat_rooms cr ON cr.idea_id = i.id
        WHERE cr.id = messages.room_id
        AND i.owner_id = auth.uid()
    )
);

CREATE POLICY "Team members can insert messages"
ON messages
FOR INSERT
WITH CHECK (
    EXISTS (
        SELECT 1
        FROM idea_collaborators ic
        JOIN chat_rooms cr ON cr.idea_id = ic.idea_id
        WHERE cr.id = messages.room_id
        AND ic.user_id = auth.uid()
    )
    OR
    EXISTS (
        SELECT 1
        FROM ideas i
        JOIN chat_rooms cr ON cr.idea_id = i.id
        WHERE cr.id = messages.room_id
        AND i.owner_id = auth.uid()
    )
);
