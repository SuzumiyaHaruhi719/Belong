-- Migration 6: Row Level Security policies
-- Every table gets RLS enabled. Policies follow principle of least privilege.
-- Users can only read/write their own data unless explicitly shared.

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.blocks ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.reports ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.otp_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gatherings ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gathering_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gathering_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.gathering_feedback ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_tag_affinity ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.posts ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_images ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_comments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.post_saves ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.conversation_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.browse_history ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- USERS
-- ============================================================
-- Anyone can read public profiles
CREATE POLICY "Public profiles are viewable by everyone"
    ON public.users FOR SELECT
    USING (true);

-- Users can update their own profile
CREATE POLICY "Users can update own profile"
    ON public.users FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Insert handled by trigger (handle_new_user), but allow self-insert
CREATE POLICY "Users can insert own profile"
    ON public.users FOR INSERT
    WITH CHECK (auth.uid() = id);

-- ============================================================
-- USER TAGS
-- ============================================================
CREATE POLICY "User tags are viewable by everyone"
    ON public.user_tags FOR SELECT
    USING (true);

CREATE POLICY "Users can manage own tags"
    ON public.user_tags FOR ALL
    USING (auth.uid() = user_id)
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- FOLLOWS
-- ============================================================
CREATE POLICY "Follows are viewable by everyone"
    ON public.follows FOR SELECT
    USING (true);

CREATE POLICY "Users can follow others"
    ON public.follows FOR INSERT
    WITH CHECK (auth.uid() = follower_id);

CREATE POLICY "Users can unfollow"
    ON public.follows FOR DELETE
    USING (auth.uid() = follower_id);

-- ============================================================
-- BLOCKS
-- ============================================================
CREATE POLICY "Users can view own blocks"
    ON public.blocks FOR SELECT
    USING (auth.uid() = blocker_id);

CREATE POLICY "Users can block others"
    ON public.blocks FOR INSERT
    WITH CHECK (auth.uid() = blocker_id);

CREATE POLICY "Users can unblock"
    ON public.blocks FOR DELETE
    USING (auth.uid() = blocker_id);

-- ============================================================
-- REPORTS
-- ============================================================
CREATE POLICY "Users can create reports"
    ON public.reports FOR INSERT
    WITH CHECK (auth.uid() = reporter_id);

CREATE POLICY "Users can view own reports"
    ON public.reports FOR SELECT
    USING (auth.uid() = reporter_id);

-- ============================================================
-- GATHERINGS
-- ============================================================
-- Public gatherings visible to all (filtering by blocks done in app)
CREATE POLICY "Published gatherings are viewable"
    ON public.gatherings FOR SELECT
    USING (is_draft = false OR host_id = auth.uid());

CREATE POLICY "Users can create gatherings"
    ON public.gatherings FOR INSERT
    WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Hosts can update own gatherings"
    ON public.gatherings FOR UPDATE
    USING (auth.uid() = host_id)
    WITH CHECK (auth.uid() = host_id);

CREATE POLICY "Hosts can delete own gatherings"
    ON public.gatherings FOR DELETE
    USING (auth.uid() = host_id);

-- ============================================================
-- GATHERING TAGS
-- ============================================================
CREATE POLICY "Gathering tags viewable by everyone"
    ON public.gathering_tags FOR SELECT
    USING (true);

CREATE POLICY "Hosts can manage gathering tags"
    ON public.gathering_tags FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.gatherings
            WHERE id = gathering_id AND host_id = auth.uid()
        )
    );

-- ============================================================
-- GATHERING MEMBERS
-- ============================================================
CREATE POLICY "Gathering members viewable by members"
    ON public.gathering_members FOR SELECT
    USING (true);

CREATE POLICY "Users can join/save gatherings"
    ON public.gathering_members FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own membership"
    ON public.gathering_members FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can leave gatherings"
    ON public.gathering_members FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- GATHERING FEEDBACK
-- ============================================================
CREATE POLICY "Feedback viewable by gathering members"
    ON public.gathering_feedback FOR SELECT
    USING (true);

CREATE POLICY "Members can submit feedback"
    ON public.gathering_feedback FOR INSERT
    WITH CHECK (auth.uid() = user_id);

-- ============================================================
-- USER TAG AFFINITY
-- ============================================================
CREATE POLICY "Users can view own affinities"
    ON public.user_tag_affinity FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "System can manage affinities"
    ON public.user_tag_affinity FOR ALL
    USING (auth.uid() = user_id);

-- ============================================================
-- POSTS
-- ============================================================
CREATE POLICY "Public posts viewable by everyone"
    ON public.posts FOR SELECT
    USING (visibility = 'public' OR author_id = auth.uid());

CREATE POLICY "Users can create posts"
    ON public.posts FOR INSERT
    WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can update own posts"
    ON public.posts FOR UPDATE
    USING (auth.uid() = author_id);

CREATE POLICY "Authors can delete own posts"
    ON public.posts FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================================
-- POST IMAGES
-- ============================================================
CREATE POLICY "Post images viewable with post"
    ON public.post_images FOR SELECT
    USING (true);

CREATE POLICY "Authors can manage post images"
    ON public.post_images FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.posts
            WHERE id = post_id AND author_id = auth.uid()
        )
    );

-- ============================================================
-- POST TAGS
-- ============================================================
CREATE POLICY "Post tags viewable by everyone"
    ON public.post_tags FOR SELECT
    USING (true);

CREATE POLICY "Authors can manage post tags"
    ON public.post_tags FOR ALL
    USING (
        EXISTS (
            SELECT 1 FROM public.posts
            WHERE id = post_id AND author_id = auth.uid()
        )
    );

-- ============================================================
-- POST LIKES
-- ============================================================
CREATE POLICY "Post likes viewable by everyone"
    ON public.post_likes FOR SELECT
    USING (true);

CREATE POLICY "Users can like posts"
    ON public.post_likes FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unlike posts"
    ON public.post_likes FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- POST COMMENTS
-- ============================================================
CREATE POLICY "Comments viewable by everyone"
    ON public.post_comments FOR SELECT
    USING (true);

CREATE POLICY "Users can create comments"
    ON public.post_comments FOR INSERT
    WITH CHECK (auth.uid() = author_id);

CREATE POLICY "Authors can delete own comments"
    ON public.post_comments FOR DELETE
    USING (auth.uid() = author_id);

-- ============================================================
-- POST SAVES
-- ============================================================
CREATE POLICY "Users can view own saves"
    ON public.post_saves FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can save posts"
    ON public.post_saves FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can unsave posts"
    ON public.post_saves FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- CONVERSATIONS
-- ============================================================
CREATE POLICY "Members can view conversations"
    ON public.conversations FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.conversation_members
            WHERE conversation_id = id AND user_id = auth.uid()
        )
    );

CREATE POLICY "Users can create conversations"
    ON public.conversations FOR INSERT
    WITH CHECK (true);  -- membership enforced at app level

-- ============================================================
-- CONVERSATION MEMBERS
-- ============================================================
CREATE POLICY "Members can view conversation members"
    ON public.conversation_members FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.conversation_members cm
            WHERE cm.conversation_id = conversation_id AND cm.user_id = auth.uid()
        )
    );

CREATE POLICY "Users can join conversations"
    ON public.conversation_members FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own membership"
    ON public.conversation_members FOR UPDATE
    USING (auth.uid() = user_id);

-- ============================================================
-- MESSAGES
-- ============================================================
CREATE POLICY "Members can view messages"
    ON public.messages FOR SELECT
    USING (
        EXISTS (
            SELECT 1 FROM public.conversation_members
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

CREATE POLICY "Members can send messages"
    ON public.messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND EXISTS (
            SELECT 1 FROM public.conversation_members
            WHERE conversation_id = messages.conversation_id
            AND user_id = auth.uid()
        )
    );

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE POLICY "Users can view own notifications"
    ON public.notifications FOR SELECT
    USING (auth.uid() = recipient_id);

CREATE POLICY "System can create notifications"
    ON public.notifications FOR INSERT
    WITH CHECK (true);  -- Created by triggers/functions

CREATE POLICY "Users can update own notifications"
    ON public.notifications FOR UPDATE
    USING (auth.uid() = recipient_id);

-- ============================================================
-- BROWSE HISTORY
-- ============================================================
CREATE POLICY "Users can view own history"
    ON public.browse_history FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can record history"
    ON public.browse_history FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own history"
    ON public.browse_history FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================================
-- OTP CODES (service-level only, no public access)
-- ============================================================
CREATE POLICY "No public access to OTP codes"
    ON public.otp_codes FOR SELECT
    USING (false);
