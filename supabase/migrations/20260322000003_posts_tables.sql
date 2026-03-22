-- Migration 3: Posts tables (小红书-style social posts)
-- Tables: posts, post_images, post_tags, post_likes, post_comments, post_saves

-- ============================================================
-- POSTS
-- ============================================================
CREATE TABLE public.posts (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    visibility TEXT DEFAULT 'public'
        CHECK (visibility IN ('public', 'school_only', 'followers_only')),
    linked_gathering_id UUID REFERENCES public.gatherings(id) ON DELETE SET NULL,
    city TEXT NOT NULL DEFAULT '',
    school TEXT,
    latitude FLOAT,
    longitude FLOAT,
    like_count INT DEFAULT 0,
    comment_count INT DEFAULT 0,
    save_count INT DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_posts_author ON public.posts(author_id);
CREATE INDEX idx_posts_city ON public.posts(city);
CREATE INDEX idx_posts_created ON public.posts(created_at DESC);

CREATE TRIGGER posts_updated_at
    BEFORE UPDATE ON public.posts
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- POST IMAGES (multiple images per post, ordered)
-- ============================================================
CREATE TABLE public.post_images (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    display_order INT DEFAULT 0,
    width INT,
    height INT
);

CREATE INDEX idx_post_images_post ON public.post_images(post_id, display_order);

-- ============================================================
-- POST TAGS (hashtags, stored without #)
-- ============================================================
CREATE TABLE public.post_tags (
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    tag_value TEXT NOT NULL,
    PRIMARY KEY (post_id, tag_value)
);

CREATE INDEX idx_post_tags_tag ON public.post_tags(tag_value);

-- ============================================================
-- POST LIKES (toggle)
-- ============================================================
CREATE TABLE public.post_likes (
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (post_id, user_id)
);

-- ============================================================
-- POST COMMENTS (with optional nested replies)
-- ============================================================
CREATE TABLE public.post_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    author_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    parent_comment_id UUID REFERENCES public.post_comments(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_post_comments_post ON public.post_comments(post_id, created_at);

-- ============================================================
-- POST SAVES (bookmarks)
-- ============================================================
CREATE TABLE public.post_saves (
    post_id UUID NOT NULL REFERENCES public.posts(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (post_id, user_id)
);
