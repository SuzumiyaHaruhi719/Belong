-- Fix recommend_gatherings to work when user has no city set
-- Also improve fallback: if no matching gatherings, return popular ones

CREATE OR REPLACE FUNCTION public.recommend_gatherings(
    p_limit INT DEFAULT 10
)
RETURNS SETOF JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_user RECORD;
    v_count INT;
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
        WHERE g.status = 'upcoming'
          AND g.is_draft = false
          AND g.starts_at > now()
          AND g.host_id NOT IN (SELECT blocked_id FROM user_blocks)
          AND g.id NOT IN (SELECT gathering_id FROM already_joined)
          -- City filter: if user has a city, prefer same city; if not, show all
          AND (v_user.city IS NULL OR v_user.city = '' OR g.city = v_user.city)
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
    SELECT row_to_json(s)
    FROM scored s
    ORDER BY score DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
