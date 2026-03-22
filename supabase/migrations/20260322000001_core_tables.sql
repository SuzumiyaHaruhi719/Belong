-- Migration 1: Core user tables
-- Tables: users (profile extension), user_tags, follows, blocks, reports, otp_codes

-- ============================================================
-- USERS (extends Supabase auth.users)
-- We store profile data in public.users, linked to auth.users.id
-- ============================================================
CREATE TABLE public.users (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    email TEXT UNIQUE NOT NULL,
    email_verified BOOLEAN DEFAULT false,
    phone TEXT,
    username TEXT UNIQUE NOT NULL,
    display_name TEXT DEFAULT '',
    avatar_url TEXT,
    default_avatar_id INT DEFAULT 1,
    bio TEXT DEFAULT '',
    city TEXT NOT NULL DEFAULT '',
    school TEXT NOT NULL DEFAULT '',
    app_language TEXT DEFAULT 'en',
    privacy_profile TEXT DEFAULT 'public'
        CHECK (privacy_profile IN ('public', 'school_only', 'followers_only')),
    privacy_dm TEXT DEFAULT 'mutual_only'
        CHECK (privacy_dm IN ('mutual_only', 'everyone')),
    notifications_enabled BOOLEAN DEFAULT true,
    profile_background_url TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now(),
    last_active_at TIMESTAMPTZ DEFAULT now()
);

COMMENT ON TABLE public.users IS 'User profiles extending Supabase auth. Linked 1:1 with auth.users.';

-- ============================================================
-- USER TAGS (cultural background, language, interest/vibe)
-- ============================================================
CREATE TABLE public.user_tags (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    category TEXT NOT NULL CHECK (category IN ('cultural_background', 'language', 'interest_vibe')),
    tag_value TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(user_id, category, tag_value)
);

CREATE INDEX idx_user_tags_user ON public.user_tags(user_id);
CREATE INDEX idx_user_tags_tag ON public.user_tags(tag_value);

-- ============================================================
-- FOLLOWS (follower → following)
-- Mutual follow = both rows exist
-- ============================================================
CREATE TABLE public.follows (
    follower_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    following_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (follower_id, following_id),
    CHECK (follower_id != following_id)  -- Can't follow yourself
);

CREATE INDEX idx_follows_following ON public.follows(following_id);

-- ============================================================
-- BLOCKS
-- ============================================================
CREATE TABLE public.blocks (
    blocker_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    blocked_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (blocker_id, blocked_id),
    CHECK (blocker_id != blocked_id)
);

-- ============================================================
-- REPORTS (content moderation)
-- ============================================================
CREATE TABLE public.reports (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    reporter_id UUID NOT NULL REFERENCES public.users(id),
    target_type TEXT NOT NULL CHECK (target_type IN ('user', 'post', 'gathering', 'message')),
    target_id UUID NOT NULL,
    reason TEXT NOT NULL,
    details TEXT,
    status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'reviewed', 'resolved')),
    created_at TIMESTAMPTZ DEFAULT now()
);

-- ============================================================
-- OTP CODES (email verification)
-- ============================================================
CREATE TABLE public.otp_codes (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email TEXT NOT NULL,
    code TEXT NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_otp_email ON public.otp_codes(email, created_at DESC);

-- ============================================================
-- Helper: auto-update updated_at timestamp
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON public.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- Helper: auto-create public.users row on auth.users insert
-- This trigger fires when a new user signs up via Supabase Auth
-- ============================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, username, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(NEW.raw_user_meta_data->>'username', split_part(NEW.email, '@', 1)),
        COALESCE(NEW.raw_user_meta_data->>'display_name', split_part(NEW.email, '@', 1))
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
