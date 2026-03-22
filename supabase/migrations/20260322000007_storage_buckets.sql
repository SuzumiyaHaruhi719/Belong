-- Migration 7: Storage buckets for images
-- Buckets: avatars, post-images, gathering-images, profile-backgrounds

-- ============================================================
-- CREATE STORAGE BUCKETS
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES
    ('avatars', 'avatars', true, 5242880,  -- 5MB
     ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
    ('post-images', 'post-images', true, 10485760,  -- 10MB
     ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
    ('gathering-images', 'gathering-images', true, 10485760,  -- 10MB
     ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']),
    ('profile-backgrounds', 'profile-backgrounds', true, 10485760,  -- 10MB
     ARRAY['image/jpeg', 'image/png', 'image/webp', 'image/heic']);

-- ============================================================
-- STORAGE POLICIES: Avatars
-- ============================================================
-- Anyone can view avatars (public bucket)
CREATE POLICY "Avatars are publicly viewable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'avatars');

-- Users can upload their own avatar: path = avatars/{user_id}/{filename}
CREATE POLICY "Users can upload own avatar"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Users can update/replace their own avatar
CREATE POLICY "Users can update own avatar"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- Users can delete their own avatar
CREATE POLICY "Users can delete own avatar"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'avatars'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- ============================================================
-- STORAGE POLICIES: Post Images
-- ============================================================
CREATE POLICY "Post images are publicly viewable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'post-images');

CREATE POLICY "Users can upload post images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'post-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete own post images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'post-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- ============================================================
-- STORAGE POLICIES: Gathering Images
-- ============================================================
CREATE POLICY "Gathering images are publicly viewable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'gathering-images');

CREATE POLICY "Users can upload gathering images"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'gathering-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update own gathering images"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'gathering-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete own gathering images"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'gathering-images'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

-- ============================================================
-- STORAGE POLICIES: Profile Backgrounds
-- ============================================================
CREATE POLICY "Profile backgrounds are publicly viewable"
    ON storage.objects FOR SELECT
    USING (bucket_id = 'profile-backgrounds');

CREATE POLICY "Users can upload own background"
    ON storage.objects FOR INSERT
    WITH CHECK (
        bucket_id = 'profile-backgrounds'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can update own background"
    ON storage.objects FOR UPDATE
    USING (
        bucket_id = 'profile-backgrounds'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );

CREATE POLICY "Users can delete own background"
    ON storage.objects FOR DELETE
    USING (
        bucket_id = 'profile-backgrounds'
        AND (storage.foldername(name))[1] = auth.uid()::text
    );
