-- Fix get_posts_feed: respect post visibility (school_only, followers_only)
-- and include visibility, city, school, save_count in JSON output.
--
-- Previously: hard-filtered to visibility='public' only, so school_only
-- and followers_only posts never appeared. Also omitted visibility from
-- the returned JSON, causing the Swift mapper to hardcode .publicPost.

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
        WHERE p.author_id NOT IN (SELECT blocked_id FROM user_blocks)
          -- Visibility enforcement:
          -- public: visible to everyone
          -- school_only: visible to users at the same school
          -- followers_only: visible to users who follow the author
          AND (
              p.visibility = 'public'
              OR (p.visibility = 'school_only'
                  AND v_user.school IS NOT NULL
                  AND v_user.school != ''
                  AND p.school = v_user.school)
              OR (p.visibility = 'followers_only'
                  AND p.author_id IN (SELECT following_id FROM user_following))
              OR p.author_id = v_user_id  -- always see own posts
          )
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
        'visibility', f.visibility,
        'city', f.city,
        'school', f.school,
        'image_urls', f.image_urls,
        'tags', f.tags,
        'like_count', f.like_count,
        'comment_count', f.comment_count,
        'save_count', f.save_count,
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
