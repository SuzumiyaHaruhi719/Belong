-- Migration 8: RPC functions for core business logic
-- Covers: like toggle, follow toggle, join gathering, feedback, recommendations

-- ============================================================
-- TOGGLE POST LIKE (atomic increment/decrement)
-- ============================================================
CREATE OR REPLACE FUNCTION public.toggle_post_like(p_post_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_exists BOOLEAN;
    v_new_count INT;
BEGIN
    SELECT EXISTS(
        SELECT 1 FROM public.post_likes
        WHERE post_id = p_post_id AND user_id = v_user_id
    ) INTO v_exists;

    IF v_exists THEN
        DELETE FROM public.post_likes
        WHERE post_id = p_post_id AND user_id = v_user_id;

        UPDATE public.posts SET like_count = GREATEST(like_count - 1, 0)
        WHERE id = p_post_id
        RETURNING like_count INTO v_new_count;

        RETURN json_build_object('liked', false, 'like_count', v_new_count);
    ELSE
        INSERT INTO public.post_likes (post_id, user_id) VALUES (p_post_id, v_user_id);

        UPDATE public.posts SET like_count = like_count + 1
        WHERE id = p_post_id
        RETURNING like_count INTO v_new_count;

        -- Create notification for post author (only on like, not unlike)
        INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
        SELECT p.author_id, v_user_id, 'like', 'post', p_post_id,
               u.display_name || ' liked your post'
        FROM public.posts p
        CROSS JOIN public.users u
        WHERE p.id = p_post_id AND u.id = v_user_id
        AND p.author_id != v_user_id;  -- Don't notify self

        RETURN json_build_object('liked', true, 'like_count', v_new_count);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- TOGGLE USER FOLLOW (with mutual detection)
-- ============================================================
CREATE OR REPLACE FUNCTION public.toggle_user_follow(p_target_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_exists BOOLEAN;
    v_is_mutual BOOLEAN;
BEGIN
    -- Can't follow yourself
    IF v_user_id = p_target_id THEN
        RAISE EXCEPTION 'Cannot follow yourself';
    END IF;

    -- Check if blocked
    IF EXISTS(SELECT 1 FROM public.blocks WHERE blocker_id = p_target_id AND blocked_id = v_user_id) THEN
        RAISE EXCEPTION 'Unable to follow this user';
    END IF;

    SELECT EXISTS(
        SELECT 1 FROM public.follows
        WHERE follower_id = v_user_id AND following_id = p_target_id
    ) INTO v_exists;

    IF v_exists THEN
        -- Unfollow
        DELETE FROM public.follows
        WHERE follower_id = v_user_id AND following_id = p_target_id;
        RETURN json_build_object('following', false, 'is_mutual', false);
    ELSE
        -- Follow
        INSERT INTO public.follows (follower_id, following_id) VALUES (v_user_id, p_target_id);

        -- Check if mutual
        SELECT EXISTS(
            SELECT 1 FROM public.follows
            WHERE follower_id = p_target_id AND following_id = v_user_id
        ) INTO v_is_mutual;

        -- Create notification
        INSERT INTO public.notifications (recipient_id, actor_id, type, target_type, target_id, message)
        SELECT p_target_id, v_user_id, 'follow', 'user', v_user_id,
               u.display_name || ' started following you'
        FROM public.users u WHERE u.id = v_user_id;

        RETURN json_build_object('following', true, 'is_mutual', v_is_mutual);
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- JOIN GATHERING (join/maybe/save with group chat auto-add)
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
    -- Get gathering info
    SELECT * INTO v_gathering FROM public.gatherings WHERE id = p_gathering_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Gathering not found'; END IF;
    IF v_gathering.status = 'cancelled' THEN RAISE EXCEPTION 'Gathering is cancelled'; END IF;

    -- Check capacity for 'joined' status
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

-- ============================================================
-- SUBMIT GATHERING FEEDBACK (with affinity update)
-- ============================================================
CREATE OR REPLACE FUNCTION public.submit_gathering_feedback(
    p_gathering_id UUID,
    p_emoji_rating TEXT,
    p_rating_score INT
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_tag RECORD;
BEGIN
    -- Insert feedback
    INSERT INTO public.gathering_feedback (gathering_id, user_id, emoji_rating, rating_score)
    VALUES (p_gathering_id, v_user_id, p_emoji_rating, p_rating_score)
    ON CONFLICT (gathering_id, user_id) DO UPDATE
    SET emoji_rating = p_emoji_rating, rating_score = p_rating_score;

    -- Update tag affinities using exponential moving average
    -- new_score = (old_score * count + new_rating) / (count + 1)
    FOR v_tag IN
        SELECT tag_value FROM public.gathering_tags WHERE gathering_id = p_gathering_id
    LOOP
        INSERT INTO public.user_tag_affinity (user_id, tag_value, affinity_score, sample_count)
        VALUES (v_user_id, v_tag.tag_value, p_rating_score::FLOAT, 1)
        ON CONFLICT (user_id, tag_value) DO UPDATE SET
            affinity_score = (user_tag_affinity.affinity_score * user_tag_affinity.sample_count + p_rating_score::FLOAT)
                           / (user_tag_affinity.sample_count + 1),
            sample_count = user_tag_affinity.sample_count + 1,
            updated_at = now();
    END LOOP;

    RETURN json_build_object('success', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- RECOMMEND GATHERINGS (scoring algorithm from spec)
-- ============================================================
CREATE OR REPLACE FUNCTION public.recommend_gatherings(
    p_limit INT DEFAULT 10
)
RETURNS SETOF JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_user RECORD;
BEGIN
    SELECT * INTO v_user FROM public.users WHERE id = v_user_id;

    RETURN QUERY
    WITH user_tags AS (
        SELECT category, tag_value FROM public.user_tags WHERE user_id = v_user_id
    ),
    user_affinities AS (
        SELECT tag_value, affinity_score FROM public.user_tag_affinity WHERE user_id = v_user_id
    ),
    user_following AS (
        SELECT following_id FROM public.follows WHERE follower_id = v_user_id
    ),
    user_blocks AS (
        SELECT blocked_id FROM public.blocks WHERE blocker_id = v_user_id
        UNION SELECT blocker_id FROM public.blocks WHERE blocked_id = v_user_id
    ),
    already_joined AS (
        SELECT gathering_id FROM public.gathering_members WHERE user_id = v_user_id
    ),
    candidates AS (
        SELECT
            g.*,
            ARRAY_AGG(DISTINCT gt.tag_value) FILTER (WHERE gt.tag_value IS NOT NULL) AS tags,
            COUNT(DISTINCT gm.user_id) FILTER (WHERE gm.status = 'joined') AS attendee_count
        FROM public.gatherings g
        LEFT JOIN public.gathering_tags gt ON g.id = gt.gathering_id
        LEFT JOIN public.gathering_members gm ON g.id = gm.gathering_id AND gm.status = 'joined'
        WHERE g.city = v_user.city
          AND g.status = 'upcoming'
          AND g.is_draft = false
          AND g.starts_at > now()
          AND g.host_id NOT IN (SELECT blocked_id FROM user_blocks)
          AND g.id NOT IN (SELECT gathering_id FROM already_joined)
        GROUP BY g.id
    ),
    scored AS (
        SELECT
            c.*,
            -- Tag matching scores
            COALESCE((
                SELECT SUM(CASE
                    WHEN ut.category = 'cultural_background' THEN 10
                    WHEN ut.category = 'language' THEN 8
                    WHEN ut.category = 'interest_vibe' THEN 5
                    ELSE 0
                END)
                FROM user_tags ut
                WHERE ut.tag_value = ANY(c.tags)
            ), 0)
            -- Affinity from feedback history
            + COALESCE((
                SELECT SUM((ua.affinity_score - 3.0) * 3)
                FROM user_affinities ua
                WHERE ua.tag_value = ANY(c.tags)
            ), 0)
            -- Social signals
            + CASE WHEN c.host_id IN (SELECT following_id FROM user_following) THEN 5 ELSE 0 END
            -- Same school bonus
            + CASE WHEN c.school = v_user.school THEN 3 ELSE 0 END
            -- Freshness: prefer sooner
            + CASE
                WHEN EXTRACT(EPOCH FROM c.starts_at - now()) / 86400 <= 2 THEN 4
                WHEN EXTRACT(EPOCH FROM c.starts_at - now()) / 86400 <= 7 THEN 1
                ELSE -3
              END
            -- Urgency: almost full
            + CASE
                WHEN c.max_attendees - c.attendee_count <= 2 THEN 3
                ELSE 0
              END
            AS score
        FROM candidates c
    )
    SELECT json_build_object(
        'id', s.id,
        'title', s.title,
        'description', s.description,
        'image_url', s.image_url,
        'emoji', s.emoji,
        'host_id', s.host_id,
        'city', s.city,
        'location_name', s.location_name,
        'starts_at', s.starts_at,
        'ends_at', s.ends_at,
        'max_attendees', s.max_attendees,
        'attendee_count', s.attendee_count,
        'tags', s.tags,
        'vibe', s.vibe,
        'visibility', s.visibility,
        'score', s.score
    )
    FROM scored s
    ORDER BY s.score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- PUBLISH GATHERING (atomic: create + tags + host member + group chat)
-- ============================================================
CREATE OR REPLACE FUNCTION public.publish_gathering(
    p_title TEXT,
    p_description TEXT,
    p_template_type TEXT,
    p_emoji TEXT,
    p_image_url TEXT,
    p_city TEXT,
    p_school TEXT,
    p_location_name TEXT,
    p_starts_at TIMESTAMPTZ,
    p_ends_at TIMESTAMPTZ,
    p_max_attendees INT,
    p_visibility TEXT,
    p_vibe TEXT,
    p_tags TEXT[],
    p_is_draft BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_gathering_id UUID;
    v_conv_id UUID;
    v_tag TEXT;
BEGIN
    -- Create gathering
    INSERT INTO public.gatherings (
        host_id, title, description, template_type, emoji, image_url,
        city, school, location_name, starts_at, ends_at,
        max_attendees, visibility, vibe, is_draft
    ) VALUES (
        v_user_id, p_title, p_description, p_template_type, p_emoji, p_image_url,
        p_city, p_school, p_location_name, p_starts_at, p_ends_at,
        p_max_attendees, p_visibility, p_vibe, p_is_draft
    ) RETURNING id INTO v_gathering_id;

    -- Insert tags
    IF p_tags IS NOT NULL THEN
        FOREACH v_tag IN ARRAY p_tags LOOP
            INSERT INTO public.gathering_tags (gathering_id, tag_value)
            VALUES (v_gathering_id, v_tag)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;

    -- Host auto-joins
    INSERT INTO public.gathering_members (gathering_id, user_id, status)
    VALUES (v_gathering_id, v_user_id, 'joined');

    -- Create group chat conversation
    INSERT INTO public.conversations (type, gathering_id)
    VALUES ('gathering_group', v_gathering_id)
    RETURNING id INTO v_conv_id;

    INSERT INTO public.conversation_members (conversation_id, user_id)
    VALUES (v_conv_id, v_user_id);

    RETURN json_build_object(
        'gathering_id', v_gathering_id,
        'conversation_id', v_conv_id,
        'is_draft', p_is_draft
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- ADD POST COMMENT (with count update + notification)
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
BEGIN
    -- Insert comment
    INSERT INTO public.post_comments (post_id, author_id, content, parent_comment_id)
    VALUES (p_post_id, v_user_id, p_content, p_parent_comment_id)
    RETURNING id INTO v_comment_id;

    -- Update post comment count
    UPDATE public.posts SET comment_count = comment_count + 1 WHERE id = p_post_id;

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
-- SEND DM MESSAGE (with mutual-follow validation)
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
    v_message_id UUID;
BEGIN
    -- Get conversation
    SELECT * INTO v_conv FROM public.conversations WHERE id = p_conversation_id;
    IF NOT FOUND THEN RAISE EXCEPTION 'Conversation not found'; END IF;

    -- Verify membership
    IF NOT EXISTS(SELECT 1 FROM public.conversation_members WHERE conversation_id = p_conversation_id AND user_id = v_user_id) THEN
        RAISE EXCEPTION 'Not a member of this conversation';
    END IF;

    -- DM mutual-follow check
    IF v_conv.type = 'dm' THEN
        SELECT cm.user_id INTO v_other_user
        FROM public.conversation_members cm
        WHERE cm.conversation_id = p_conversation_id AND cm.user_id != v_user_id
        LIMIT 1;

        -- Check if mutual follow
        v_is_mutual := EXISTS(
            SELECT 1 FROM public.follows f1
            JOIN public.follows f2 ON f1.follower_id = f2.following_id AND f1.following_id = f2.follower_id
            WHERE f1.follower_id = v_user_id AND f1.following_id = v_other_user
        );

        IF NOT v_is_mutual THEN
            -- Allow only 1 message if not mutual
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
    RETURNING id INTO v_message_id;

    -- Update conversation timestamp
    UPDATE public.conversations SET updated_at = now() WHERE id = p_conversation_id;

    RETURN json_build_object('message_id', v_message_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- CREATE OR GET DM CONVERSATION (idempotent)
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_or_get_dm(p_other_user_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv_id UUID;
BEGIN
    -- Check block
    IF EXISTS(SELECT 1 FROM public.blocks WHERE
        (blocker_id = v_user_id AND blocked_id = p_other_user_id) OR
        (blocker_id = p_other_user_id AND blocked_id = v_user_id)
    ) THEN
        RAISE EXCEPTION 'Cannot message this user';
    END IF;

    -- Check existing DM
    SELECT cm1.conversation_id INTO v_conv_id
    FROM public.conversation_members cm1
    JOIN public.conversation_members cm2 ON cm1.conversation_id = cm2.conversation_id
    JOIN public.conversations c ON c.id = cm1.conversation_id
    WHERE cm1.user_id = v_user_id
      AND cm2.user_id = p_other_user_id
      AND c.type = 'dm';

    IF v_conv_id IS NOT NULL THEN
        RETURN json_build_object('conversation_id', v_conv_id, 'created', false);
    END IF;

    -- Create new DM
    INSERT INTO public.conversations (type) VALUES ('dm') RETURNING id INTO v_conv_id;
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, v_user_id);
    INSERT INTO public.conversation_members (conversation_id, user_id) VALUES (v_conv_id, p_other_user_id);

    RETURN json_build_object('conversation_id', v_conv_id, 'created', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- BLOCK USER (with cascade: unfollow both + remove from shared convos)
-- ============================================================
CREATE OR REPLACE FUNCTION public.block_user(p_target_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
BEGIN
    -- Insert block
    INSERT INTO public.blocks (blocker_id, blocked_id)
    VALUES (v_user_id, p_target_id)
    ON CONFLICT DO NOTHING;

    -- Auto-unfollow both directions
    DELETE FROM public.follows WHERE
        (follower_id = v_user_id AND following_id = p_target_id) OR
        (follower_id = p_target_id AND following_id = v_user_id);

    -- Remove from shared DM conversations
    DELETE FROM public.conversation_members
    WHERE user_id = p_target_id
    AND conversation_id IN (
        SELECT cm.conversation_id
        FROM public.conversation_members cm
        JOIN public.conversations c ON c.id = cm.conversation_id
        WHERE cm.user_id = v_user_id AND c.type = 'dm'
    );

    RETURN json_build_object('blocked', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- GET POSTS FEED (weighted algorithm)
-- ============================================================
CREATE OR REPLACE FUNCTION public.get_posts_feed(
    p_page INT DEFAULT 1,
    p_limit INT DEFAULT 20,
    p_filter_tag TEXT DEFAULT NULL
)
RETURNS SETOF JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_user RECORD;
    v_offset INT := (p_page - 1) * p_limit;
BEGIN
    SELECT * INTO v_user FROM public.users WHERE id = v_user_id;

    RETURN QUERY
    WITH user_following AS (
        SELECT following_id FROM public.follows WHERE follower_id = v_user_id
    ),
    user_blocks AS (
        SELECT blocked_id FROM public.blocks WHERE blocker_id = v_user_id
        UNION SELECT blocker_id FROM public.blocks WHERE blocked_id = v_user_id
    ),
    feed AS (
        SELECT
            p.*,
            u.display_name AS author_name,
            u.username AS author_username,
            u.avatar_url AS author_avatar,
            u.default_avatar_id AS author_default_avatar,
            (SELECT ARRAY_AGG(pi.image_url ORDER BY pi.display_order)
             FROM public.post_images pi WHERE pi.post_id = p.id) AS image_urls,
            (SELECT ARRAY_AGG(pt.tag_value)
             FROM public.post_tags pt WHERE pt.post_id = p.id) AS tags,
            EXISTS(SELECT 1 FROM post_likes pl WHERE pl.post_id = p.id AND pl.user_id = v_user_id) AS is_liked,
            EXISTS(SELECT 1 FROM post_saves ps WHERE ps.post_id = p.id AND ps.user_id = v_user_id) AS is_saved,
            -- Scoring
            (CASE WHEN p.author_id IN (SELECT following_id FROM user_following) THEN 30 ELSE 0 END)
            + (CASE WHEN p.city = v_user.city THEN 10 ELSE 0 END)
            + (CASE WHEN p.school = v_user.school THEN 15 ELSE 0 END)
            + (p.like_count * 0.5 + p.comment_count * 1.0)::INT
            -- Recency decay: posts lose 5 points per day
            - (EXTRACT(EPOCH FROM now() - p.created_at) / 86400 * 5)::INT
            AS score
        FROM public.posts p
        JOIN public.users u ON p.author_id = u.id
        WHERE p.visibility = 'public'
          AND p.author_id NOT IN (SELECT blocked_id FROM user_blocks)
          AND (p_filter_tag IS NULL OR EXISTS(
              SELECT 1 FROM public.post_tags pt WHERE pt.post_id = p.id AND pt.tag_value = p_filter_tag
          ))
    )
    SELECT json_build_object(
        'id', f.id,
        'author_id', f.author_id,
        'author_name', f.author_name,
        'author_username', f.author_username,
        'author_avatar', f.author_avatar,
        'author_default_avatar', f.author_default_avatar,
        'content', f.content,
        'image_urls', f.image_urls,
        'tags', f.tags,
        'like_count', f.like_count,
        'comment_count', f.comment_count,
        'is_liked', f.is_liked,
        'is_saved', f.is_saved,
        'linked_gathering_id', f.linked_gathering_id,
        'created_at', f.created_at
    )
    FROM feed f
    ORDER BY f.score DESC
    LIMIT p_limit OFFSET v_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
