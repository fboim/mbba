-- ============================================================
-- MBBA — Setup Supabase Storage for Kitab Covers
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. Create storage bucket for kitab covers
-- ============================================================
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'kitab-covers',
  'kitab-covers',
  true,
  2097152, -- 2MB limit
  ARRAY['image/jpeg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- ============================================================
-- 2. Create storage policies (public read, authenticated write)
-- ============================================================

-- Allow public read access to kitab covers
DROP POLICY IF EXISTS "Public Read Access" ON storage.objects;
CREATE POLICY "Public Read Access"
ON storage.objects FOR SELECT
USING (bucket_id = 'kitab-covers');

-- Allow authenticated users to upload files
DROP POLICY IF EXISTS "Authenticated Upload" ON storage.objects;
CREATE POLICY "Authenticated Upload"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id = 'kitab-covers' AND
  auth.role() = 'authenticated'
);

-- Allow authenticated users to update files
DROP POLICY IF EXISTS "Authenticated Update" ON storage.objects;
CREATE POLICY "Authenticated Update"
ON storage.objects FOR UPDATE
USING (
  bucket_id = 'kitab-covers' AND
  auth.role() = 'authenticated'
);

-- Allow authenticated users to delete files
DROP POLICY IF EXISTS "Authenticated Delete" ON storage.objects;
CREATE POLICY "Authenticated Delete"
ON storage.objects FOR DELETE
USING (
  bucket_id = 'kitab-covers' AND
  auth.role() = 'authenticated'
);

-- ============================================================
-- DONE
-- ============================================================
SELECT 'Storage bucket "kitab-covers" created successfully!' as status;