-- RPC: delete_own_account
-- Allows an authenticated user to delete their own account from auth.users,
-- which cascades to delete their public.users row and all related data.
-- This must be SECURITY DEFINER to access auth.users.

CREATE OR REPLACE FUNCTION delete_own_account()
RETURNS void AS $$
DECLARE
    v_user_id UUID;
BEGIN
    v_user_id := auth.uid();
    IF v_user_id IS NULL THEN
        RAISE EXCEPTION 'Not authenticated';
    END IF;

    -- Delete from auth.users — this cascades to public.users and all FK-referencing tables
    DELETE FROM auth.users WHERE id = v_user_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
