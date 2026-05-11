-- ============================================================
-- MBBA — Safe RLS Policies Setup
-- Drop existing policies first, then create new ones
-- Run this in Supabase SQL Editor
-- ============================================================

-- ============================================================
-- DROP EXISTING POLICIES (safe - won't error if not exists)
-- ============================================================

-- Drop bagian policies
DROP POLICY IF EXISTS "Bagian: Public read access" ON public.bagian;
DROP POLICY IF EXISTS "Bagian: Admin only write" ON public.bagian;
DROP POLICY IF EXISTS "Bagian: Admin only update" ON public.bagian;
DROP POLICY IF EXISTS "Bagian: Admin only delete" ON public.bagian;

-- Drop bab policies
DROP POLICY IF EXISTS "Bab: Public read access" ON public.bab;
DROP POLICY IF EXISTS "Bab: Admin only write" ON public.bab;
DROP POLICY IF EXISTS "Bab: Admin only update" ON public.bab;
DROP POLICY IF EXISTS "Bab: Admin only delete" ON public.bab;

-- Drop fasal policies
DROP POLICY IF EXISTS "Fasal: Public read access" ON public.fasal;
DROP POLICY IF EXISTS "Fasal: Admin only write" ON public.fasal;
DROP POLICY IF EXISTS "Fasal: Admin only update" ON public.fasal;
DROP POLICY IF EXISTS "Fasal: Admin only delete" ON public.fasal;

-- Drop quiz policies
DROP POLICY IF EXISTS "Quiz: Public read access" ON public.quiz;
DROP POLICY IF EXISTS "Quiz: Admin/Teacher write" ON public.quiz;
DROP POLICY IF EXISTS "Quiz: Admin/Teacher update" ON public.quiz;
DROP POLICY IF EXISTS "Quiz: Admin/Teacher delete" ON public.quiz;

-- Drop user_progress policies
DROP POLICY IF EXISTS "User Progress: Owner read access" ON public.user_progress;
DROP POLICY IF EXISTS "User Progress: Owner insert" ON public.user_progress;
DROP POLICY IF EXISTS "User Progress: Owner update" ON public.user_progress;
DROP POLICY IF EXISTS "User Progress: Admin delete" ON public.user_progress;

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================

ALTER TABLE public.bagian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bab ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fasal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- HELPER FUNCTIONS
-- ============================================================

-- Drop existing functions first
DROP FUNCTION IF EXISTS get_user_role();
DROP FUNCTION IF EXISTS get_user_id();

-- Create function to get user role from JWT
CREATE OR REPLACE FUNCTION get_user_role()
RETURNS TEXT AS $$
BEGIN
  RETURN COALESCE(
    current_setting('request.jwt.claims', true)::json->>'user_metadata'->>'role',
    current_setting('request.jwt.claims', true)::json->>'role',
    'guest'
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create function to get current user ID
CREATE OR REPLACE FUNCTION get_user_id()
RETURNS UUID AS $$
BEGIN
  RETURN COALESCE(
    current_setting('request.jwt.claims', true)::json->>'sub',
    NULL
  );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================
-- BAGIAN POLICIES
-- ============================================================

CREATE POLICY "Bagian: Public read access"
ON public.bagian FOR SELECT
USING (true);

CREATE POLICY "Bagian: Admin only write"
ON public.bagian FOR INSERT
WITH CHECK (
  get_user_role() = 'admin'
);

CREATE POLICY "Bagian: Admin only update"
ON public.bagian FOR UPDATE
USING (
  get_user_role() = 'admin'
);

CREATE POLICY "Bagian: Admin only delete"
ON public.bagian FOR DELETE
USING (
  get_user_role() = 'admin'
);

-- ============================================================
-- BAB POLICIES
-- ============================================================

CREATE POLICY "Bab: Public read access"
ON public.bab FOR SELECT
USING (true);

CREATE POLICY "Bab: Admin only write"
ON public.bab FOR INSERT
WITH CHECK (
  get_user_role() = 'admin'
);

CREATE POLICY "Bab: Admin only update"
ON public.bab FOR UPDATE
USING (
  get_user_role() = 'admin'
);

CREATE POLICY "Bab: Admin only delete"
ON public.bab FOR DELETE
USING (
  get_user_role() = 'admin'
);

-- ============================================================
-- FASAL POLICIES
-- ============================================================

CREATE POLICY "Fasal: Public read access"
ON public.fasal FOR SELECT
USING (true);

CREATE POLICY "Fasal: Admin only write"
ON public.fasal FOR INSERT
WITH CHECK (
  get_user_role() = 'admin'
);

CREATE POLICY "Fasal: Admin only update"
ON public.fasal FOR UPDATE
USING (
  get_user_role() = 'admin'
);

CREATE POLICY "Fasal: Admin only delete"
ON public.fasal FOR DELETE
USING (
  get_user_role() = 'admin'
);

-- ============================================================
-- QUIZ POLICIES
-- ============================================================

CREATE POLICY "Quiz: Public read access"
ON public.quiz FOR SELECT
USING (true);

CREATE POLICY "Quiz: Admin/Teacher write"
ON public.quiz FOR INSERT
WITH CHECK (
  get_user_role() IN ('admin', 'teacher')
);

CREATE POLICY "Quiz: Admin/Teacher update"
ON public.quiz FOR UPDATE
USING (
  get_user_role() IN ('admin', 'teacher')
);

CREATE POLICY "Quiz: Admin/Teacher delete"
ON public.quiz FOR DELETE
USING (
  get_user_role() IN ('admin', 'teacher')
);

-- ============================================================
-- USER_PROGRESS POLICIES
-- ============================================================

CREATE POLICY "User Progress: Owner read access"
ON public.user_progress FOR SELECT
USING (
  auth.uid() = user_id OR
  get_user_role() IN ('admin', 'teacher')
);

CREATE POLICY "User Progress: Owner insert"
ON public.user_progress FOR INSERT
WITH CHECK (
  auth.uid() = user_id
);

CREATE POLICY "User Progress: Owner update"
ON public.user_progress FOR UPDATE
USING (
  auth.uid() = user_id OR
  get_user_role() IN ('admin', 'teacher')
);

CREATE POLICY "User Progress: Admin delete"
ON public.user_progress FOR DELETE
USING (
  get_user_role() = 'admin'
);

-- ============================================================
-- INPUT VALIDATION TRIGGERS
-- ============================================================

-- Drop existing triggers
DROP TRIGGER IF EXISTS trg_validate_bagian ON public.bagian;
DROP TRIGGER IF EXISTS trg_validate_bab ON public.bab;
DROP TRIGGER IF EXISTS trg_validate_fasal ON public.fasal;
DROP TRIGGER IF EXISTS trg_validate_quiz ON public.quiz;
DROP TRIGGER IF EXISTS trg_validate_progress ON public.user_progress;

-- Drop existing functions
DROP FUNCTION IF EXISTS validate_bagian_input();
DROP FUNCTION IF EXISTS validate_bab_input();
DROP FUNCTION IF EXISTS validate_fasal_input();
DROP FUNCTION IF EXISTS validate_quiz_input();
DROP FUNCTION IF EXISTS validate_progress_input();

-- Validate bagian input
CREATE OR REPLACE FUNCTION validate_bagian_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
    RAISE EXCEPTION 'Judul bagian tidak boleh kosong';
  END IF;
  IF LENGTH(NEW.title) > 200 THEN
    RAISE EXCEPTION 'Judul bagian maksimal 200 karakter';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_bagian
BEFORE INSERT OR UPDATE ON public.bagian
FOR EACH ROW EXECUTE FUNCTION validate_bagian_input();

-- Validate bab input
CREATE OR REPLACE FUNCTION validate_bab_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
    RAISE EXCEPTION 'Judul bab tidak boleh kosong';
  END IF;
  IF LENGTH(NEW.title) > 200 THEN
    RAISE EXCEPTION 'Judul bab maksimal 200 karakter';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_bab
BEFORE INSERT OR UPDATE ON public.bab
FOR EACH ROW EXECUTE FUNCTION validate_bab_input();

-- Validate fasal input
CREATE OR REPLACE FUNCTION validate_fasal_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
    RAISE EXCEPTION 'Judul fasal tidak boleh kosong';
  END IF;
  IF LENGTH(NEW.title) > 300 THEN
    RAISE EXCEPTION 'Judul fasal maksimal 300 karakter';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_fasal
BEFORE INSERT OR UPDATE ON public.fasal
FOR EACH ROW EXECUTE FUNCTION validate_fasal_input();

-- Validate quiz input
CREATE OR REPLACE FUNCTION validate_quiz_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.question IS NULL OR TRIM(NEW.question) = '' THEN
    RAISE EXCEPTION 'Pertanyaan quiz tidak boleh kosong';
  END IF;
  IF LENGTH(NEW.question) > 2000 THEN
    RAISE EXCEPTION 'Pertanyaan quiz maksimal 2000 karakter';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_quiz
BEFORE INSERT OR UPDATE ON public.quiz
FOR EACH ROW EXECUTE FUNCTION validate_quiz_input();

-- Validate progress input
CREATE OR REPLACE FUNCTION validate_progress_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.user_id IS NULL THEN
    RAISE EXCEPTION 'User ID tidak boleh kosong';
  END IF;
  IF NEW.fasal_id IS NULL OR TRIM(NEW.fasal_id) = '' THEN
    RAISE EXCEPTION 'Fasal ID tidak boleh kosong';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_progress
BEFORE INSERT OR UPDATE ON public.user_progress
FOR EACH ROW EXECUTE FUNCTION validate_progress_input();

-- ============================================================
-- DONE
-- ============================================================
SELECT 'RLS Policies applied successfully!' as status;