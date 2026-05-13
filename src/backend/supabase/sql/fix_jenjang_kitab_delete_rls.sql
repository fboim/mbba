-- ============================================================
-- MBBA — Fix RLS Policies for DELETE on jenjang & kitab
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- 1. Hapus policy lama
-- ============================================================

DROP POLICY IF EXISTS "anon_read_jenjang" ON public.jenjang;
DROP POLICY IF EXISTS "anon_read_kitab" ON public.kitab;
DROP POLICY IF EXISTS "admin_write_jenjang" ON public.jenjang;
DROP POLICY IF EXISTS "admin_write_kitab" ON public.kitab;
DROP POLICY IF EXISTS "admin_update_jenjang" ON public.jenjang;
DROP POLICY IF EXISTS "admin_update_kitab" ON public.kitab;
DROP POLICY IF EXISTS "jenjang_select" ON public.jenjang;
DROP POLICY IF EXISTS "jenjang_insert" ON public.jenjang;
DROP POLICY IF EXISTS "jenjang_update" ON public.jenjang;
DROP POLICY IF EXISTS "jenjang_delete" ON public.jenjang;
DROP POLICY IF EXISTS "kitab_select" ON public.kitab;
DROP POLICY IF EXISTS "kitab_insert" ON public.kitab;
DROP POLICY IF EXISTS "kitab_update" ON public.kitab;
DROP POLICY IF EXISTS "kitab_delete" ON public.kitab;

-- ============================================================
-- 2. Buat policy baru - allow authenticated users (for debug)
-- ============================================================

-- Jenjang policies - allow all authenticated users
CREATE POLICY "jenjang_all_auth" ON public.jenjang FOR ALL USING (auth.role() = 'authenticated');

-- Kitab policies - allow all authenticated users
CREATE POLICY "kitab_all_auth" ON public.kitab FOR ALL USING (auth.role() = 'authenticated');

-- ============================================================
-- DONE
-- ============================================================
SELECT 'RLS Policies for jenjang & kitab updated!' as status;