-- Add indexes on frequently queried columns that lack them.
--
-- These columns appear in WHERE / JOIN clauses across multiple RPCs
-- and client queries but have no index beyond the primary key.

-- post_likes: user_id is used by toggle_post_like and "is liked" checks
CREATE INDEX IF NOT EXISTS idx_post_likes_user_id
    ON public.post_likes (user_id);

-- post_saves: user_id is used by toggle_post_save and "is saved" checks
CREATE INDEX IF NOT EXISTS idx_post_saves_user_id
    ON public.post_saves (user_id);

-- gathering_feedback: user_id is used to check if user already left feedback
CREATE INDEX IF NOT EXISTS idx_gathering_feedback_user_id
    ON public.gathering_feedback (user_id);

-- gatherings: is_draft filters out unpublished gatherings in every feed query
CREATE INDEX IF NOT EXISTS idx_gatherings_is_draft
    ON public.gatherings (is_draft) WHERE is_draft = false;

-- conversations: gathering_id is used to look up group chat for a gathering
CREATE INDEX IF NOT EXISTS idx_conversations_gathering_id
    ON public.conversations (gathering_id) WHERE gathering_id IS NOT NULL;
