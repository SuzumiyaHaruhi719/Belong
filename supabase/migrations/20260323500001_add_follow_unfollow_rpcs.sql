-- Add idempotent follow_user / unfollow_user RPCs.
--
-- The app previously did direct INSERT / DELETE on the follows table,
-- which bypassed block checks, self-follow prevention, notification
-- creation, and atomic mutual detection. These two RPCs replace
-- the client-side logic with a single, authoritative write path.

-- ============================================================
-- FOLLOW USER (idempotent, with block + notification + mutual)
-- ============================================================
CREATE OR REPLACE FUNCTION public.follow_user(p_target_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_is_mutual BOOLEAN;
    v_was_inserted BOOLEAN;
BEGIN
    -- Cannot follow yourself
    IF v_user_id = p_target_id THEN
        RAISE EXCEPTION 'Cannot follow yourself';
    END IF;

    -- Block check (either direction)
    IF EXISTS(
        SELECT 1 FROM public.blocks
        WHERE (blocker_id = p_target_id AND blocked_id = v_user_id)
           OR (blocker_id = v_user_id AND blocked_id = p_target_id)
    ) THEN
        RAISE EXCEPTION 'Unable to follow this user';
    END IF;

    -- Atomic idempotent insert via ON CONFLICT DO NOTHING.
    -- Detect whether a row was actually inserted using CTE.
    WITH ins AS (
        INSERT INTO public.follows (follower_id, following_id)
        VALUES (v_user_id, p_target_id)
        ON CONFLICT (follower_id, following_id) DO NOTHING
        RETURNING 1
    )
    SELECT EXISTS(SELECT 1 FROM ins) INTO v_was_inserted;

    -- Check if the relationship is now mutual
    SELECT EXISTS(
        SELECT 1 FROM public.follows
        WHERE follower_id = p_target_id AND following_id = v_user_id
    ) INTO v_is_mutual;

    -- Create notification only when a NEW follow row was inserted
    IF v_was_inserted THEN
        INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
        SELECT p_target_id, v_user_id, 'follow', 'user', v_user_id,
               u.display_name || ' started following you'
        FROM public.users u WHERE u.id = v_user_id;
    END IF;

    RETURN json_build_object('following', true, 'is_mutual', v_is_mutual);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- UNFOLLOW USER (idempotent)
-- ============================================================
CREATE OR REPLACE FUNCTION public.unfollow_user(p_target_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    DELETE FROM public.follows
    WHERE follower_id = v_user_id AND following_id = p_target_id;

    RETURN json_build_object('following', false, 'is_mutual', false);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
