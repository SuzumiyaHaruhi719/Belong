-- Fix send_dm_message return to include full message fields for Swift DBMessage decoding
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
    SELECT * INTO v_conv FROM public.conversations WHERE id = p_conversation_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Conversation not found'; END IF;

    IF NOT EXISTS(SELECT 1 FROM public.conversation_members WHERE conversation_id = p_conversation_id AND user_id = v_user_id) THEN
        RAISE EXCEPTION 'Not a member of this conversation';
    END IF;

    IF v_conv.type = 'dm' THEN
        SELECT cm.user_id INTO v_other_user
        FROM public.conversation_members cm
        WHERE cm.conversation_id = p_conversation_id AND cm.user_id != v_user_id
        LIMIT 1;

        v_is_mutual := EXISTS(
            SELECT 1 FROM public.follows f1
            JOIN public.follows f2 ON f1.follower_id = f2.following_id AND f1.following_id = f2.follower_id
            WHERE f1.follower_id = v_user_id AND f1.following_id = v_other_user
        );

        IF NOT v_is_mutual THEN
            SELECT COUNT(*) INTO v_msg_count
            FROM public.messages
            WHERE conversation_id = p_conversation_id AND sender_id = v_user_id;

            IF v_msg_count >= 1 THEN
                RAISE EXCEPTION 'Follow each other to chat more';
            END IF;
        END IF;
    END IF;

    INSERT INTO public.messages (conversation_id, sender_id, content, message_type, image_url, shared_post_id)
    VALUES (p_conversation_id, v_user_id, p_content, p_message_type, p_image_url, p_shared_post_id)
    RETURNING * INTO v_message;

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
