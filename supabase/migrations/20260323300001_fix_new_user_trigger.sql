-- Fix handle_new_user trigger to generate unique usernames.
--
-- Problem: signInWithOTP creates auth.users without username metadata,
-- so the trigger falls back to split_part(email, '@', 1). Two users with
-- the same email prefix (e.g. alice@uni1.edu, alice@uni2.edu) would
-- collide on the unique username constraint, blocking sign-up entirely.
--
-- Fix: fall back to 'user_' || first 8 hex chars of UUID, which is
-- practically unique (4 billion possibilities).

CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO public.users (id, email, username, display_name)
    VALUES (
        NEW.id,
        NEW.email,
        COALESCE(
            NULLIF(NEW.raw_user_meta_data->>'username', ''),
            'user_' || left(replace(NEW.id::text, '-', ''), 8)
        ),
        COALESCE(
            NULLIF(NEW.raw_user_meta_data->>'display_name', ''),
            split_part(NEW.email, '@', 1)
        )
    );
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
