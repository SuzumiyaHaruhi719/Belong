-- Migration 5: Notifications and browsing history
-- Tables: notifications, browse_history

-- ============================================================
-- NOTIFICATIONS
-- ============================================================
CREATE TABLE public.notifications (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    recipient_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    actor_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
    type TEXT NOT NULL CHECK (type IN (
        'like', 'comment', 'follow', 'mention',
        'gathering_reminder', 'gathering_joined',
        'new_post_from_following', 'new_gathering_from_following',
        'dm_message', 'follow_suggestion'
    )),
    target_type TEXT CHECK (target_type IN ('post', 'gathering', 'comment', 'user')),
    target_id UUID,
    message TEXT NOT NULL DEFAULT '',
    is_read BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_notif_recipient ON public.notifications(recipient_id, created_at DESC);
-- Partial index: only unread notifications (most queries filter on this)
CREATE INDEX idx_notif_unread ON public.notifications(recipient_id, is_read)
    WHERE is_read = false;

-- ============================================================
-- BROWSE HISTORY (posts and gatherings the user has viewed)
-- ============================================================
CREATE TABLE public.browse_history (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    target_type TEXT NOT NULL CHECK (target_type IN ('post', 'gathering')),
    target_id UUID NOT NULL,
    viewed_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_history_user ON public.browse_history(user_id, viewed_at DESC);
