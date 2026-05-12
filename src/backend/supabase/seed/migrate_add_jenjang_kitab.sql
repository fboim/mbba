-- ============================================================
-- MBBA — Migration: Tambah Jenjang & Kitab
-- Jalankan di Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. Buat tabel JENJANG
-- ============================================================
CREATE TABLE IF NOT EXISTS public.jenjang (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  nama text NOT NULL,
  deskripsi text,
  order_index integer DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.jenjang ENABLE ROW LEVEL SECURITY;

INSERT INTO auth.users (id, email, created_at) VALUES
  ('00000000-0000-0000-0000-000000000000', 'system@mbba.local', now())
ON CONFLICT (id) DO NOTHING;

-- Policy: semua role yang login bisa read
CREATE POLICY "jenjang_select" ON public.jenjang FOR SELECT USING (true);
-- Policy: hanya admin/teacher bisa insert/update/delete
CREATE POLICY "jenjang_admin_all" ON public.jenjang FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid()
    AND (u.raw_user_meta_data->>'role' IN ('admin', 'teacher'))
  )
);

-- ============================================================
-- 2. Buat tabel KITAB (FK → jenjang)
-- ============================================================
CREATE TABLE IF NOT EXISTS public.kitab (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  jenjang_id uuid NOT NULL REFERENCES public.jenjang(id) ON DELETE CASCADE,
  nama text NOT NULL,
  penulis text,
  order_index integer DEFAULT 1,
  created_at timestamptz DEFAULT now()
);

ALTER TABLE public.kitab ENABLE ROW LEVEL SECURITY;

CREATE POLICY "kitab_select" ON public.kitab FOR SELECT USING (true);
CREATE POLICY "kitab_admin_all" ON public.kitab FOR ALL USING (
  EXISTS (
    SELECT 1 FROM auth.users u
    WHERE u.id = auth.uid()
    AND (u.raw_user_meta_data->>'role' IN ('admin', 'teacher'))
  )
);

-- ============================================================
-- 3. Tambah kolom KITAB_ID ke tabel BAGIAN
--    (kolom bagian_id lama tetap dipertahankan sementara untuk backward compat)
-- ============================================================
ALTER TABLE public.bagian ADD COLUMN IF NOT EXISTS kitab_id uuid REFERENCES public.kitab(id) ON DELETE SET NULL;

-- ============================================================
-- 4. Backfill: buat 1 Jenjang + 1 Kitab default, lalu update semua bagian
-- ============================================================
-- Buat jenjang default
INSERT INTO public.jenjang (id, nama, deskripsi, order_index)
VALUES ('11111111-1111-1111-1111-111111111111', 'Tingkat 1', 'Dasar Nahwu dan Shorof', 1)
ON CONFLICT DO NOTHING;

-- Buat kitab default
INSERT INTO public.kitab (id, jenjang_id, nama, penulis, order_index)
VALUES ('22222222-2222-2222-2222-222222222222', '11111111-1111-1111-1111-111111111111', 'Al-Mukhtarat', 'Syeikh Ali Mahdi', 1)
ON CONFLICT DO NOTHING;

-- Update semua bagian yang ada agar punya kitab_id default
UPDATE public.bagian
SET kitab_id = '22222222-2222-2222-2222-222222222222'
WHERE kitab_id IS NULL;

-- ============================================================
-- 5. Opsional: drop kolom bagian_id lama (FK self-ref yang tidak berguna)
--    Aktifkan baris di bawah HANYA jika Anda yakin tidak ada kode yang pakai kolom itu
-- ALTER TABLE public.bagian DROP COLUMN IF EXISTS bagian_id;
-- ============================================================
