-- Fix infinite recursion in conversation_members RLS policy
-- The old policy queried conversation_members to check if user is a member,
-- which triggered the same policy again → infinite loop.

DROP POLICY IF EXISTS "Members can view conversation members" ON public.conversation_members;

-- Fixed: simply allow users to see rows where they are a member of the same conversation
-- by directly checking user_id = auth.uid() OR the conversation_id is one the user belongs to
CREATE POLICY "Members can view conversation members"
    ON public.conversation_members FOR SELECT
    USING (
        conversation_id IN (
            SELECT cm.conversation_id FROM public.conversation_members cm
            WHERE cm.user_id = auth.uid()
        )
    );

-- The above still has recursion. The correct fix is to use a security definer function.
-- Drop the policy we just created and use a simpler approach.
DROP POLICY IF EXISTS "Members can view conversation members" ON public.conversation_members;

-- Simple approach: users can see all conversation_members rows for conversations they belong to.
-- We use a function with SECURITY DEFINER to bypass RLS.
CREATE OR REPLACE FUNCTION public.user_conversation_ids(p_user_id uuid)
RETURNS SETOF uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
    SELECT conversation_id FROM public.conversation_members WHERE user_id = p_user_id;
$$;

CREATE POLICY "Members can view conversation members"
    ON public.conversation_members FOR SELECT
    USING (
        conversation_id IN (SELECT public.user_conversation_ids(auth.uid()))
    );
