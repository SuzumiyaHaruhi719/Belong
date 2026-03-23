-- Fix overly permissive conversations INSERT policy.
--
-- Previous: WITH CHECK (true) — any authenticated user could create
-- arbitrary conversations directly, bypassing validation.
--
-- Fix: Deny all direct INSERTs via RLS. All conversation creation
-- goes through SECURITY DEFINER RPCs (create_or_get_dm, publish_gathering)
-- which bypass RLS and include proper validation (block checks, etc).

DROP POLICY IF EXISTS "Users can create conversations" ON public.conversations;

CREATE POLICY "Conversations created via RPC only"
    ON public.conversations FOR INSERT
    WITH CHECK (false);
