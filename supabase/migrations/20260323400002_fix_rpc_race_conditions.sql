-- Fix race conditions in toggle_post_like, add_post_comment count,
-- and join_gathering capacity check.
--
-- Previous: check-then-act pattern (SELECT EXISTS → INSERT/DELETE)
-- allowed concurrent requests to produce incorrect counter values.
--
-- Fix: use atomic INSERT ON CONFLICT, row-level locking (FOR UPDATE),
-- and recount-based updates instead of incremental ±1.

-- ============================================================
-- TOGGLE POST LIKE (atomic, recount-based)
-- ============================================================
CREATE OR REPLACE FUNCTION public.toggle_post_like(p_post_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_existed BOOLEAN;
    v_new_count INT;
BEGIN
    -- Try to insert; if conflict, the like already exists → delete it.
    -- This is atomic: no window between check and act.
    BEGIN
        INSERT INTO public.post_likes (post_id, user_id)
        VALUES (p_post_id, v_user_id);
        v_existed := false;
    EXCEPTION WHEN unique_violation THEN
        DELETE FROM public.post_likes
        WHERE post_id = p_post_id AND user_id = v_user_id;
        v_existed := true;
    END;

    -- Recount to ensure accuracy (instead of ±1 which can drift)
    SELECT COUNT(*) INTO v_new_count
    FROM public.post_likes WHERE post_id = p_post_id;

    UPDATE public.posts SET like_count = v_new_count
    WHERE id = p_post_id;

    -- Create notification on like (not unlike)
    IF NOT v_existed THEN
        INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
        SELECT p.author_id, v_user_id, 'like', 'post', p_post_id,
               u.display_name || ' liked your post'
        FROM public.posts p
        CROSS JOIN public.users u
        WHERE p.id = p_post_id AND u.id = v_user_id
        AND p.author_id != v_user_id;
    END IF;

    RETURN json_build_object('liked', NOT v_existed, 'like_count', v_new_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- ADD POST COMMENT (recount-based)
-- ============================================================
CREATE OR REPLACE FUNCTION public.add_post_comment(
    p_post_id UUID,
    p_content TEXT,
    p_parent_comment_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_comment_id UUID;
    v_post_author UUID;
    v_parent_author UUID;
    v_new_count INT;
BEGIN
    -- Insert comment
    INSERT INTO public.post_comments (post_id, author_id, content, parent_comment_id)
    VALUES (p_post_id, v_user_id, p_content, p_parent_comment_id)
    RETURNING id INTO v_comment_id;

    -- Recount to ensure accuracy
    SELECT COUNT(*) INTO v_new_count
    FROM public.post_comments WHERE post_id = p_post_id;

    UPDATE public.posts SET comment_count = v_new_count WHERE id = p_post_id;

    -- Notify post author
    SELECT author_id INTO v_post_author FROM public.posts WHERE id = p_post_id;
    IF v_post_author != v_user_id THEN
        INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
        SELECT v_post_author, v_user_id, 'comment', 'post', p_post_id,
               u.display_name || ' commented on your post'
        FROM public.users u WHERE u.id = v_user_id;
    END IF;

    -- If reply, notify parent comment author too
    IF p_parent_comment_id IS NOT NULL THEN
        SELECT author_id INTO v_parent_author FROM public.post_comments WHERE id = p_parent_comment_id;
        IF v_parent_author IS NOT NULL AND v_parent_author != v_user_id AND v_parent_author != v_post_author THEN
            INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
            SELECT v_parent_author, v_user_id, 'comment', 'comment', p_parent_comment_id,
                   u.display_name || ' replied to your comment'
            FROM public.users u WHERE u.id = v_user_id;
        END IF;
    END IF;

    RETURN json_build_object('comment_id', v_comment_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- JOIN GATHERING (with row-level lock to prevent overselling)
-- ============================================================
CREATE OR REPLACE FUNCTION public.join_gathering(
    p_gathering_id UUID,
    p_status TEXT DEFAULT 'joined'
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_gathering RECORD;
    v_current_count INT;
    v_conv_id UUID;
BEGIN
    -- Lock the gathering row to prevent concurrent capacity check race
    SELECT * INTO v_gathering FROM public.gatherings
    WHERE id = p_gathering_id
    FOR UPDATE;

    IF NOT FOUND THEN RAISE EXCEPTION 'Gathering not found'; END IF;
    IF v_gathering.status = 'cancelled' THEN RAISE EXCEPTION 'Gathering is cancelled'; END IF;

    -- Check capacity for 'joined' status (under row lock)
    IF p_status = 'joined' THEN
        SELECT COUNT(*) INTO v_current_count
        FROM public.gathering_members
        WHERE gathering_id = p_gathering_id AND status = 'joined';

        IF v_current_count >= v_gathering.max_attendees THEN
            RAISE EXCEPTION 'Gathering is full';
        END IF;
    END IF;

    -- Upsert membership
    INSERT INTO public.gathering_members (gathering_id, user_id, status)
    VALUES (p_gathering_id, v_user_id, p_status)
    ON CONFLICT (gathering_id, user_id) DO UPDATE SET status = p_status, joined_at = now();

    -- If joining, add to group chat conversation
    IF p_status = 'joined' THEN
        SELECT id INTO v_conv_id FROM public.conversations
        WHERE type = 'gathering_group' AND gathering_id = p_gathering_id;

        IF v_conv_id IS NOT NULL THEN
            INSERT INTO public.conversation_members (conversation_id, user_id)
            VALUES (v_conv_id, v_user_id)
            ON CONFLICT DO NOTHING;
        END IF;

        -- Notify host
        IF v_gathering.host_id != v_user_id THEN
            INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
            SELECT v_gathering.host_id, v_user_id, 'gathering_joined', 'gathering', p_gathering_id,
                   u.display_name || ' joined your gathering'
            FROM public.users u WHERE u.id = v_user_id;
        END IF;
    END IF;

    RETURN json_build_object(
        'status', p_status,
        'gathering_id', p_gathering_id
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
