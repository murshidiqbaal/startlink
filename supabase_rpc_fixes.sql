-- Corrected RPC functions to resolve column ambiguity (Error 42702)

-- 1. Get My Conversations
CREATE OR REPLACE FUNCTION get_my_conversations()
RETURNS TABLE (
    idea_id UUID,
    idea_title TEXT,
    other_user_id UUID,
    other_user_name TEXT,
    other_user_avatar TEXT,
    last_message TEXT,
    last_message_at TIMESTAMPTZ,
    unread_count BIGINT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    RETURN QUERY
    WITH last_messages AS (
        SELECT 
            m.idea_id as msg_idea_id,
            m.sender_id,
            m.receiver_id,
            m.content,
            m.created_at,
            m.is_read,
            ROW_NUMBER() OVER (
                PARTITION BY m.idea_id, 
                CASE WHEN m.sender_id = auth.uid() THEN m.receiver_id ELSE m.sender_id END 
                ORDER BY m.created_at DESC
            ) as rn
        FROM messages m
        WHERE m.sender_id = auth.uid() OR m.receiver_id = auth.uid()
    ),
    convo_partners AS (
        SELECT DISTINCT
            lm.msg_idea_id,
            CASE WHEN lm.sender_id = auth.uid() THEN lm.receiver_id ELSE lm.sender_id END as partner_id
        FROM last_messages lm
    )
    SELECT 
        i.id as idea_id,
        i.title as idea_title,
        p.id as other_user_id,
        p.full_name as other_user_name,
        p.avatar_url as other_user_avatar,
        (SELECT lm.content FROM last_messages lm 
         WHERE lm.msg_idea_id = i.id 
         AND (lm.sender_id = p.id OR lm.receiver_id = p.id) 
         AND lm.rn = 1 
         LIMIT 1) as last_message,
        (SELECT lm.created_at FROM last_messages lm 
         WHERE lm.msg_idea_id = i.id 
         AND (lm.sender_id = p.id OR lm.receiver_id = p.id) 
         AND lm.rn = 1 
         LIMIT 1) as last_message_at,
        (SELECT COUNT(*) FROM messages m2
         WHERE m2.idea_id = i.id 
         AND m2.sender_id = p.id 
         AND m2.receiver_id = auth.uid() 
         AND m2.is_read = FALSE) as unread_count
    FROM convo_partners cp
    JOIN ideas i ON i.id = cp.msg_idea_id
    JOIN profiles p ON p.id = cp.partner_id
    ORDER BY last_message_at DESC;
END;
$$;

-- 2. Increment View Count
CREATE OR REPLACE FUNCTION increment_view_count(idea_uuid UUID)
RETURNS VOID
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE public.ideas
    SET view_count = COALESCE(view_count, 0) + 1
    WHERE ideas.id = increment_view_count.idea_uuid;
END;
$$;

-- 3. Get Innovator Chats
CREATE OR REPLACE FUNCTION get_innovator_chats()
RETURNS TABLE (
  idea_id UUID,
  title TEXT,
  room_id UUID,
  collaborator_name TEXT,
  collaborator_avatar TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  select
    i.id as idea_id,
    i.title as title,
    cr.id as room_id,
    p.full_name as collaborator_name,
    p.avatar_url as collaborator_avatar
  from ideas i
  join idea_collaborators ic on ic.idea_id = i.id
  join chat_rooms cr on cr.idea_id = i.id
  join profiles p on p.id = ic.user_id
  join collaborator_profiles cp on cp.profile_id = ic.user_id
  where i.owner_id = auth.uid();
END;
$$;

-- 4. Get Collaborator Chats
CREATE OR REPLACE FUNCTION get_collaborator_chats()
RETURNS TABLE (
  idea_id UUID,
  title TEXT,
  room_id UUID,
  innovator_name TEXT,
  innovator_avatar TEXT
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  RETURN QUERY
  select
    i.id as idea_id,
    i.title as title,
    cr.id as room_id,
    p.full_name as innovator_name,
    p.avatar_url as innovator_avatar
  from idea_collaborators ic
  join ideas i on i.id = ic.idea_id
  join chat_rooms cr on cr.idea_id = i.id
  join profiles p on p.id = i.owner_id
  join collaborator_profiles cp on cp.profile_id = ic.user_id
  where ic.user_id = auth.uid();
END;
$$;
