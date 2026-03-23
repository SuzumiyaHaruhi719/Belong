-- Fix publish_gathering to accept latitude/longitude parameters
-- The Swift client sends these but the original function didn't accept them

DROP FUNCTION IF EXISTS public.publish_gathering(TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TEXT, TIMESTAMPTZ, TIMESTAMPTZ, INT, TEXT, TEXT, TEXT[], BOOLEAN);

CREATE OR REPLACE FUNCTION public.publish_gathering(
    p_title TEXT,
    p_description TEXT,
    p_template_type TEXT,
    p_emoji TEXT,
    p_image_url TEXT DEFAULT NULL,
    p_city TEXT DEFAULT NULL,
    p_school TEXT DEFAULT NULL,
    p_location_name TEXT DEFAULT NULL,
    p_latitude FLOAT DEFAULT NULL,
    p_longitude FLOAT DEFAULT NULL,
    p_starts_at TIMESTAMPTZ DEFAULT now(),
    p_ends_at TIMESTAMPTZ DEFAULT NULL,
    p_max_attendees INT DEFAULT 10,
    p_visibility TEXT DEFAULT 'open',
    p_vibe TEXT DEFAULT 'welcoming',
    p_tags TEXT[] DEFAULT '{}',
    p_is_draft BOOLEAN DEFAULT false
)
RETURNS JSON AS $$
DECLARE
    v_user_id UUID := auth.uid();
    v_gathering_id UUID;
    v_tag TEXT;
    v_conv_id UUID;
BEGIN
    -- Create gathering
    INSERT INTO public.gatherings (
        host_id, title, description, template_type, emoji, image_url,
        city, school, location_name, latitude, longitude,
        starts_at, ends_at, max_attendees, visibility, vibe, status, is_draft
    ) VALUES (
        v_user_id, p_title, p_description, p_template_type, p_emoji, p_image_url,
        p_city, p_school, p_location_name, p_latitude, p_longitude,
        p_starts_at, p_ends_at, p_max_attendees, p_visibility, p_vibe,
        CASE WHEN p_is_draft THEN 'upcoming' ELSE 'upcoming' END,
        p_is_draft
    ) RETURNING id INTO v_gathering_id;

    -- Insert tags
    FOREACH v_tag IN ARRAY p_tags LOOP
        INSERT INTO public.gathering_tags (gathering_id, tag_value)
        VALUES (v_gathering_id, v_tag)
        ON CONFLICT DO NOTHING;
    END LOOP;

    -- Add host as member
    INSERT INTO public.gathering_members (gathering_id, user_id, status)
    VALUES (v_gathering_id, v_user_id, 'joined');

    -- Create group chat conversation (only for published gatherings)
    IF NOT p_is_draft THEN
        INSERT INTO public.conversations (type, gathering_id)
        VALUES ('gathering_group', v_gathering_id)
        RETURNING id INTO v_conv_id;

        INSERT INTO public.conversation_members (conversation_id, user_id)
        VALUES (v_conv_id, v_user_id);
    END IF;

    RETURN json_build_object('gathering_id', v_gathering_id);
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
