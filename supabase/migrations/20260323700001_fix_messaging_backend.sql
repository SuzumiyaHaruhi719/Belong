-- Fix messaging/realtime backend: security, consistency, and race conditions.
--
-- BUG-MSG-01: leave_gathering doesn't remove user from group chat
-- BUG-MSG-02: create_or_get_dm race can create duplicate DM conversations
-- BUG-MSG-03: send_dm_message ice-breaker bypass via concurrent sends
-- BUG-MSG-05: send_dm_message missing block check (defense-in-depth)
-- BUG-MSG-06: notification INSERT policy allows arbitrary client inserts

-- ============================================================
-- 1. CREATE leave_gathering RPC
--    Removes user from both gathering_members AND the group chat
--    conversation_members.  Previously leave() only deleted from
--    gathering_members, leaving the user as a ghost member in
--    the group chat.
-- ============================================================
CREATE OR REPLACE FUNCTION public.leave_gathering(p_gathering_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv_id UUID;
BEGIN
    -- Remove from gathering membership
    DELETE FROM public.gathering_members
    WHERE gathering_id = p_gathering_id AND user_id = v_user_id;

    -- Also remove from the gathering's group chat
    SELECT id INTO v_conv_id FROM public.conversations
    WHERE type = 'gathering_group' AND gathering_id = p_gathering_id;

    IF v_conv_id IS NOT NULL THEN
        DELETE FROM public.conversation_members
        WHERE conversation_id = v_conv_id AND user_id = v_user_id;
    END IF;

    RETURN json_build_object('left', true, 'gathering_id', p_gathering_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 2. FIX create_or_get_dm — prevent duplicate DMs via advisory lock
--    Two concurrent calls for the same user pair could both pass
--    the "SELECT existing" check and each INSERT a new conversation.
--    Advisory lock serialises callers for the same user pair.
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_or_get_dm(p_other_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv_id UUID;
BEGIN
    -- Prevent self-DM
    IF v_user_id = p_other_user_id THEN
        RAISE EXCEPTION 'Cannot create DM with yourself';
    END IF;

    -- Block check
    IF EXISTS(SELECT 1 FROM public.blocks WHERE
        (blocker_id = v_user_id AND blocked_id = p_other_user_id) OR
        (blocker_id = p_other_user_id AND blocked_id = v_user_id)
    ) THEN
        RAISE EXCEPTION 'Cannot message this user';
    END IF;

    -- Advisory lock on ordered user pair to serialise concurrent calls
    PERFORM pg_advisory_xact_lock(
        hashtext(
            LEAST(v_user_id::text, p_other_user_id::text)
            || ':'
            || GREATEST(v_user_id::text, p_other_user_id::text)
        )
    );

    -- Check existing DM (now safe under the advisory lock)
    SELECT cm1.conversation_id INTO v_conv_id
    FROM public.conversation_members cm1
    JOIN public.conversation_members cm2 ON cm1.conversation_id = cm2.conversation_id
    JOIN public.conversations c ON c.id = cm1.conversation_id
    WHERE cm1.user_id = v_user_id
      AND cm2.user_id = p_other_user_id
      AND c.type = 'dm';

    IF v_conv_id IS NOT NULL THEN
        RETURN json_build_object('id', v_conv_id, 'type', 'dm', 'created', false);
    END IF;

    -- Create new DM
    INSERT INTO public.conversations (type) VALUES ('dm') RETURNING id INTO v_conv_id;
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, v_user_id);
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, p_other_user_id);

    RETURN json_build_object('id', v_conv_id, 'type', 'dm', 'created', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 3. FIX send_dm_message — row-level lock + block check
--    Previous version used check-then-act for the ice-breaker
--    limit (SELECT COUNT → INSERT).  Two concurrent sends could
--    both see count=0 and both succeed.  Fix: lock the
--    conversation row with FOR UPDATE to serialise senders.
--    Also adds a block check for defense-in-depth.
-- ============================================================
CREATE OR REPLACE FUNCTION public.send_dm_message(
    p_conversation_id UUID,
    p_content TEXT,
    p_message_type TEXT DEFAULT 'text',
    p_image_url TEXT DEFAULT NULL,
    p_shared_post_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv RECORD;
    v_other_user UUID;
    v_is_mutual BOOLEAN;
    v_msg_count INT;
    v_message RECORD;
BEGIN
    -- Lock conversation row to serialise concurrent sends
    SELECT * INTO v_conv FROM public.conversations
    WHERE id = p_conversation_id
    FOR UPDATE;
    IF NOT FOUND THEN RAISE EXCEPTION 'Conversation not found'; END IF;

    -- Verify membership
    IF NOT EXISTS(SELECT 1 FROM public.conversation_members
                  WHERE conversation_id = p_conversation_id AND user_id = v_user_id) THEN
        RAISE EXCEPTION 'Not a member of this conversation';
    END IF;

    -- DM-specific checks
    IF v_conv.type = 'dm' THEN
        SELECT cm.user_id INTO v_other_user
        FROM public.conversation_members cm
        WHERE cm.conversation_id = p_conversation_id AND cm.user_id != v_user_id
        LIMIT 1;

        -- Block check (defense-in-depth: block_user already removes membership,
        -- but this covers timing gaps between block and membership cleanup)
        IF EXISTS(SELECT 1 FROM public.blocks WHERE
            (blocker_id = v_user_id AND blocked_id = v_other_user) OR
            (blocker_id = v_other_user AND blocked_id = v_user_id)
        ) THEN
            RAISE EXCEPTION 'Cannot message this user';
        END IF;

        -- Mutual follow check
        v_is_mutual := EXISTS(
            SELECT 1 FROM public.follows f1
            JOIN public.follows f2 ON f1.follower_id = f2.following_id
                                   AND f1.following_id = f2.follower_id
            WHERE f1.follower_id = v_user_id AND f1.following_id = v_other_user
        );

        -- Ice-breaker limit: 1 message if not mutual follow
        -- (safe under FOR UPDATE lock — no concurrent bypass)
        IF NOT v_is_mutual THEN
            SELECT COUNT(*) INTO v_msg_count
            FROM public.messages
            WHERE conversation_id = p_conversation_id AND sender_id = v_user_id;

            IF v_msg_count >= 1 THEN
                RAISE EXCEPTION 'Follow each other to chat more';
            END IF;
        END IF;
    END IF;

    -- Insert message
    INSERT INTO public.messages (conversation_id, sender_id, content, message_type, image_url, shared_post_id)
    VALUES (p_conversation_id, v_user_id, p_content, p_message_type, p_image_url, p_shared_post_id)
    RETURNING * INTO v_message;

    -- Update conversation timestamp
    UPDATE public.conversations SET updated_at = now() WHERE id = p_conversation_id;

    RETURN json_build_object(
        'id', v_message.id,
        'conversation_id', v_message.conversation_id,
        'sender_id', v_message.sender_id,
        'content', v_message.content,
        'image_url', v_message.image_url,
        'shared_post_id', v_message.shared_post_id,
        'message_type', v_message.message_type,
        'created_at', v_message.created_at
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- 4. FIX notification INSERT policy — deny direct client inserts
--    Previous: WITH CHECK (true) — any authenticated user could
--    insert fake notifications for any recipient.
--    Fix: deny all direct INSERTs.  All notification creation
--    goes through SECURITY DEFINER RPCs which bypass RLS.
-- ============================================================
DROP POLICY IF EXISTS "System can create notifications" ON public.notifications;

CREATE POLICY "Notifications created via RPC only"
    ON public.notifications FOR INSERT
    WITH CHECK (false);
