-- Fix create_or_get_dm to return 'id' field instead of 'conversation_id'
-- so it matches DBConversation decoding in Swift client
CREATE OR REPLACE FUNCTION public.create_or_get_dm(p_other_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv_id UUID;
BEGIN
    IF EXISTS(SELECT 1 FROM public.blocks WHERE
        (blocker_id = v_user_id AND blocked_id = p_other_user_id) OR
        (blocker_id = p_other_user_id AND blocked_id = v_user_id)
    ) THEN
        RAISE EXCEPTION 'Cannot message this user';
    END IF;

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

    INSERT INTO public.conversations (type) VALUES ('dm') RETURNING id INTO v_conv_id;
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, v_user_id);
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, p_other_user_id);

    RETURN json_build_object('id', v_conv_id, 'type', 'dm', 'created', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
