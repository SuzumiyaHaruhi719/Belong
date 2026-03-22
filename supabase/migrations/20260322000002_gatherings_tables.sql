-- Migration 2: Gatherings tables
-- Tables: gatherings, gathering_tags, gathering_members, gathering_feedback

-- ============================================================
-- GATHERINGS
-- ============================================================
CREATE TABLE public.gatherings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    host_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    title TEXT NOT NULL,
    description TEXT DEFAULT '',
    template_type TEXT CHECK (template_type IN ('food', 'study', 'hangout', 'cultural', 'faith', 'active')),
    emoji TEXT,
    image_url TEXT,
    city TEXT NOT NULL,
    school TEXT,
    location_name TEXT NOT NULL DEFAULT '',
    latitude FLOAT,
    longitude FLOAT,
    starts_at TIMESTAMPTZ NOT NULL,
    ends_at TIMESTAMPTZ,
    max_attendees INT DEFAULT 6 CHECK (max_attendees >= 2 AND max_attendees <= 50),
    visibility TEXT DEFAULT 'matching_tags'
        CHECK (visibility IN ('open', 'matching_tags', 'invite_only')),
    vibe TEXT DEFAULT 'low_key'
        CHECK (vibe IN ('low_key', 'hype', 'chill', 'welcoming')),
    status TEXT DEFAULT 'upcoming'
        CHECK (status IN ('upcoming', 'ongoing', 'completed', 'cancelled')),
    is_draft BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_gatherings_city ON public.gatherings(city);
CREATE INDEX idx_gatherings_starts ON public.gatherings(starts_at);
CREATE INDEX idx_gatherings_status ON public.gatherings(status);
CREATE INDEX idx_gatherings_host ON public.gatherings(host_id);

CREATE TRIGGER gatherings_updated_at
    BEFORE UPDATE ON public.gatherings
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- GATHERING TAGS
-- ============================================================
CREATE TABLE public.gathering_tags (
    gathering_id UUID NOT NULL REFERENCES public.gatherings(id) ON DELETE CASCADE,
    tag_value TEXT NOT NULL,
    PRIMARY KEY (gathering_id, tag_value)
);

CREATE INDEX idx_gathering_tags_tag ON public.gathering_tags(tag_value);

-- ============================================================
-- GATHERING MEMBERS (join / maybe / saved / left)
-- ============================================================
CREATE TABLE public.gathering_members (
    gathering_id UUID NOT NULL REFERENCES public.gatherings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    status TEXT DEFAULT 'joined'
        CHECK (status IN ('joined', 'maybe', 'saved', 'left')),
    joined_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (gathering_id, user_id)
);

CREATE INDEX idx_gathering_members_user ON public.gathering_members(user_id);

-- ============================================================
-- GATHERING FEEDBACK (post-event emoji rating)
-- This is KEY for the recommendation feedback loop
-- ============================================================
CREATE TABLE public.gathering_feedback (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    gathering_id UUID NOT NULL REFERENCES public.gatherings(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    emoji_rating TEXT NOT NULL
        CHECK (emoji_rating IN ('meh', 'okay', 'good', 'great', 'amazing')),
    rating_score INT NOT NULL CHECK (rating_score >= 1 AND rating_score <= 5),
    created_at TIMESTAMPTZ DEFAULT now(),
    UNIQUE(gathering_id, user_id)
);

-- ============================================================
-- USER TAG AFFINITY (recommendation engine - feedback loop)
-- Updated after each gathering_feedback submission
-- ============================================================
CREATE TABLE public.user_tag_affinity (
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    tag_value TEXT NOT NULL,
    affinity_score FLOAT DEFAULT 3.0,
    sample_count INT DEFAULT 0,
    updated_at TIMESTAMPTZ DEFAULT now(),
    PRIMARY KEY (user_id, tag_value)
);
