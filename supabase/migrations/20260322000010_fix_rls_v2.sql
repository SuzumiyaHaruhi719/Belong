-- Fix infinite recursion in conversation_members, conversations, and messages RLS policies
-- Root cause: policies on conversation_members queried conversation_members itself

-- Step 1: Drop all policies that cause recursion
DROP POLICY IF EXISTS "Members can view conversation members" ON public.conversation_members;
DROP POLICY IF EXISTS "Members can view conversations" ON public.conversations;
DROP POLICY IF EXISTS "Members can view messages" ON public.messages;
DROP POLICY IF EXISTS "Members can send messages" ON public.messages;

-- Step 2: Create SECURITY DEFINER function (bypasses RLS, breaks the recursion)
CREATE OR REPLACE FUNCTION public.is_conversation_member(p_conversation_id uuid, p_user_id uuid)
RETURNS boolean
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT EXISTS (
        SELECT 1 FROM public.conversation_members 
        WHERE conversation_id = p_conversation_id AND user_id = p_user_id
    );
$$;

-- Step 3: Recreate policies using the function
CREATE POLICY "Members can view conversation members"
    ON public.conversation_members FOR SELECT
    USING (public.is_conversation_member(conversation_id, auth.uid()));

CREATE POLICY "Members can view conversations"
    ON public.conversations FOR SELECT
    USING (public.is_conversation_member(id, auth.uid()));

CREATE POLICY "Members can view messages"
    ON public.messages FOR SELECT
    USING (public.is_conversation_member(conversation_id, auth.uid()));

CREATE POLICY "Members can send messages"
    ON public.messages FOR INSERT
    WITH CHECK (
        auth.uid() = sender_id
        AND public.is_conversation_member(conversation_id, auth.uid())
    );
