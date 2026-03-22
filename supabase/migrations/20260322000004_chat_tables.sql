-- Migration 4: Chat & messaging tables
-- Tables: conversations, conversation_members, messages

-- ============================================================
-- CONVERSATIONS (DMs and gathering group chats)
-- ============================================================
CREATE TABLE public.conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type TEXT NOT NULL CHECK (type IN ('dm', 'gathering_group')),
    gathering_id UUID REFERENCES public.gatherings(id) ON DELETE SET NULL,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TRIGGER conversations_updated_at
    BEFORE UPDATE ON public.conversations
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ============================================================
-- CONVERSATION MEMBERS
-- ============================================================
CREATE TABLE public.conversation_members (
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    last_read_at TIMESTAMPTZ,
    PRIMARY KEY (conversation_id, user_id)
);

CREATE INDEX idx_conv_members_user ON public.conversation_members(user_id);

-- ============================================================
-- MESSAGES
-- ============================================================
CREATE TABLE public.messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES public.conversations(id) ON DELETE CASCADE,
    sender_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
    content TEXT,
    image_url TEXT,
    shared_post_id UUID REFERENCES public.posts(id) ON DELETE SET NULL,
    message_type TEXT DEFAULT 'text'
        CHECK (message_type IN ('text', 'image', 'shared_post', 'system')),
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX idx_messages_conv ON public.messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON public.messages(sender_id);
