-- DB Hardening Migration
-- Fixes: missing RPCs, RLS visibility gaps, missing indexes, missing CHECK constraints
--
-- Issues addressed:
--   1. toggle_post_save RPC missing → save_count drifts, race condition on save toggle
--   2. create_post_with_tags RPC missing → non-atomic post creation (3 separate INSERTs)
--   3. leave_gathering RPC missing → no group-chat cleanup on leave
--   4. posts SELECT RLS ignores school_only / followers_only visibility
--   5. Post child tables (images, tags, likes, comments) readable by anyone regardless of post visibility
--   6. gathering_feedback readable by anyone (labeled "members only" but USING(true))
--   7. Missing indexes on follows(following_id), blocks(blocked_id), post_comments(parent_comment_id)
--   8. No CHECK constraints on post counter columns (can go negative)
--   9. Missing storage UPDATE policy on post-images bucket

BEGIN;

-- ============================================================
-- 1. NEW RPC: toggle_post_save (atomic, recount-based)
--    Mirrors toggle_post_like pattern from migration 20260323400002
-- ============================================================
CREATE OR REPLACE FUNCTION public.toggle_post_save(p_post_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_existed BOOLEAN;
    v_new_count INT;
BEGIN
    -- Atomic: try insert, if conflict → already saved → delete
    BEGIN
        INSERT INTO public.post_saves (post_id, user_id)
        VALUES (p_post_id, v_user_id);
        v_existed := false;
    EXCEPTION WHEN unique_violation THEN
        DELETE FROM public.post_saves
        WHERE post_id = p_post_id AND user_id = v_user_id;
        v_existed := true;
    END;

    -- Recount for accuracy (no ±1 drift)
    SELECT COUNT(*) INTO v_new_count
    FROM public.post_saves WHERE post_id = p_post_id;

    UPDATE public.posts SET save_count = v_new_count
    WHERE id = p_post_id;

    RETURN json_build_object('saved', NOT v_existed, 'save_count', v_new_count);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 2. NEW RPC: create_post_with_tags (atomic post + images + tags)
-- ============================================================
CREATE OR REPLACE FUNCTION public.create_post_with_tags(
    p_content TEXT,
    p_visibility TEXT DEFAULT 'public',
    p_image_urls TEXT[] DEFAULT '{}',
    p_tags TEXT[] DEFAULT '{}',
    p_city TEXT DEFAULT NULL,
    p_school TEXT DEFAULT NULL,
    p_linked_gathering_id UUID DEFAULT NULL
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_post_id UUID := gen_random_uuid();
    v_url TEXT;
    v_idx INT := 0;
    v_tag TEXT;
BEGIN
    -- Insert post
    INSERT INTO public.posts (
        id, author_id, content, visibility,
        linked_gathering_id, city, school,
        like_count, comment_count, save_count
    ) VALUES (
        v_post_id, v_user_id, p_content, p_visibility,
        p_linked_gathering_id, p_city, p_school,
        0, 0, 0
    );

    -- Insert images with display_order from array position
    IF p_image_urls IS NOT NULL AND array_length(p_image_urls, 1) > 0 THEN
        FOREACH v_url IN ARRAY p_image_urls LOOP
            INSERT INTO public.post_images (post_id, image_url, display_order)
            VALUES (v_post_id, v_url, v_idx);
            v_idx := v_idx + 1;
        END LOOP;
    END IF;

    -- Insert tags
    IF p_tags IS NOT NULL AND array_length(p_tags, 1) > 0 THEN
        FOREACH v_tag IN ARRAY p_tags LOOP
            INSERT INTO public.post_tags (post_id, tag_value)
            VALUES (v_post_id, v_tag)
            ON CONFLICT DO NOTHING;
        END LOOP;
    END IF;

    RETURN json_build_object('post_id', v_post_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 3. NEW RPC: leave_gathering (with group-chat cleanup)
-- ============================================================
CREATE OR REPLACE FUNCTION public.leave_gathering(p_gathering_id UUID)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_conv_id UUID;
    v_host_id UUID;
BEGIN
    -- Cannot leave if you're the host
    SELECT host_id INTO v_host_id
    FROM public.gatherings WHERE id = p_gathering_id;

    IF v_host_id = v_user_id THEN
        RAISE EXCEPTION 'Host cannot leave their own gathering';
    END IF;

    -- Remove membership
    DELETE FROM public.gathering_members
    WHERE gathering_id = p_gathering_id AND user_id = v_user_id;

    -- Remove from gathering's group chat
    SELECT id INTO v_conv_id FROM public.conversations
    WHERE type = 'gathering_group' AND gathering_id = p_gathering_id;

    IF v_conv_id IS NOT NULL THEN
        DELETE FROM public.conversation_members
        WHERE conversation_id = v_conv_id AND user_id = v_user_id;
    END IF;

    RETURN json_build_object('left', true);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;


-- ============================================================
-- 4. FIX: posts SELECT RLS — add school_only & followers_only
--    Previous: only visibility='public' OR author_id=auth.uid()
--    This blocked direct SELECT for school_only and followers_only posts
-- ============================================================
DROP POLICY IF EXISTS "Public posts viewable by everyone" ON public.posts;

CREATE POLICY "Posts viewable by authorized users"
    ON public.posts FOR SELECT
    USING (
        author_id = auth.uid()
        OR visibility = 'public'
        OR (
            visibility = 'school_only'
            AND EXISTS (
                SELECT 1 FROM public.users u
                WHERE u.id = auth.uid()
                  AND u.school IS NOT NULL
                  AND u.school != ''
                  AND u.school = (SELECT school FROM public.users WHERE id = posts.author_id)
            )
        )
        OR (
            visibility = 'followers_only'
            AND EXISTS (
                SELECT 1 FROM public.follows
                WHERE follower_id = auth.uid() AND following_id = posts.author_id
            )
        )
    );


-- ============================================================
-- 5. FIX: Post child table RLS — inherit parent post visibility
--    Previous: USING(true) on all child tables leaked data for
--    non-public posts when queried directly
-- ============================================================

-- 5a. post_images: inherit post visibility
DROP POLICY IF EXISTS "Post images viewable with post" ON public.post_images;

CREATE POLICY "Post images viewable with post"
    ON public.post_images FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts p
            WHERE p.id = post_images.post_id
        )
    );

-- 5b. post_tags: inherit post visibility
DROP POLICY IF EXISTS "Post tags viewable by everyone" ON public.post_tags;

CREATE POLICY "Post tags viewable with post"
    ON public.post_tags FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts p
            WHERE p.id = post_tags.post_id
        )
    );

-- 5c. post_likes: inherit post visibility
DROP POLICY IF EXISTS "Post likes viewable by everyone" ON public.post_likes;

CREATE POLICY "Post likes viewable with post"
    ON public.post_likes FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts p
            WHERE p.id = post_likes.post_id
        )
    );

-- 5d. post_comments: inherit post visibility
DROP POLICY IF EXISTS "Comments viewable by everyone" ON public.post_comments;

CREATE POLICY "Comments viewable with post"
    ON public.post_comments FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.posts p
            WHERE p.id = post_comments.post_id
        )
    );


-- ============================================================
-- 6. FIX: gathering_feedback SELECT — restrict to participants
--    Previous: USING(true) labeled "viewable by gathering members"
-- ============================================================
DROP POLICY IF EXISTS "Feedback viewable by gathering members" ON public.gathering_feedback;

CREATE POLICY "Feedback viewable by participants"
    ON public.gathering_feedback FOR SELECT
    USING (
        user_id = auth.uid()
        OR EXISTS (
            SELECT 1 FROM public.gatherings g
            WHERE g.id = gathering_feedback.gathering_id
              AND g.host_id = auth.uid()
        )
    );


-- ============================================================
-- 7. INDEXES: add missing indexes for hot paths
-- ============================================================

-- 7a. follows(following_id) — "who follows user X?" queries
-- PK is (follower_id, following_id), only helps follower_id-leading queries
CREATE INDEX IF NOT EXISTS idx_follows_following
    ON public.follows (following_id);

-- 7b. blocks(blocked_id) — "am I blocked by user X?" checks in RPCs
-- PK is (blocker_id, blocked_id), can't serve blocked_id-leading lookups
CREATE INDEX IF NOT EXISTS idx_blocks_blocked
    ON public.blocks (blocked_id);

-- 7c. post_comments(parent_comment_id) — reply thread lookups
CREATE INDEX IF NOT EXISTS idx_post_comments_parent
    ON public.post_comments (parent_comment_id)
    WHERE parent_comment_id IS NOT NULL;


-- ============================================================
-- 8. CHECK constraints: prevent counter columns from going negative
-- ============================================================
ALTER TABLE public.posts
    ADD CONSTRAINT posts_like_count_nonneg    CHECK (like_count >= 0),
    ADD CONSTRAINT posts_comment_count_nonneg CHECK (comment_count >= 0),
    ADD CONSTRAINT posts_save_count_nonneg    CHECK (save_count >= 0);


-- ============================================================
-- 9. STORAGE: add missing UPDATE policy for post-images bucket
--    Without this, upsert=true fails when replacing an existing image
-- ============================================================
CREATE POLICY "Users can update own post images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'post-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );


-- ============================================================
-- 10. DATA FIX: recount save_count for any existing posts
--     save_count was never updated by the old manual toggle code
-- ============================================================
UPDATE public.posts p
SET save_count = (
    SELECT COUNT(*) FROM public.post_saves ps WHERE ps.post_id = p.id
)
WHERE p.save_count != (
    SELECT COUNT(*) FROM public.post_saves ps WHERE ps.post_id = p.id
);

COMMIT;
