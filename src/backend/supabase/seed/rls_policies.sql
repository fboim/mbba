-- ============================================================
-- MBBA — Row Level Security (RLS) Policies
-- Mengamankan data berdasarkan role user
-- ============================================================

-- ============================================================
-- ENABLE RLS ON ALL TABLES
-- ============================================================
ALTER TABLE public.bagian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bab ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fasal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- ============================================================
-- HELPER FUNCTION: Get user role from JWT
-- ============================================================
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

-- ============================================================
-- HELPER FUNCTION: Get current user ID
-- ============================================================
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
-- Everyone can read bagian
CREATE POLICY "Bagian: Public read access"
ON public.bagian FOR SELECT
USING (true);

-- Only admin can insert/update/delete bagian
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
-- Everyone can read bab
CREATE POLICY "Bab: Public read access"
ON public.bab FOR SELECT
USING (true);

-- Admin can insert/update/delete bab
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
-- Everyone can read fasal
CREATE POLICY "Fasal: Public read access"
ON public.fasal FOR SELECT
USING (true);

-- Admin can insert/update/delete fasal
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
-- Everyone can read quiz
CREATE POLICY "Quiz: Public read access"
ON public.quiz FOR SELECT
USING (true);

-- Admin and teacher can insert/update/delete quiz
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
-- Users can read their own progress
CREATE POLICY "User Progress: Owner read access"
ON public.user_progress FOR SELECT
USING (
  auth.uid() = user_id OR
  get_user_role() IN ('admin', 'teacher')
);

-- Users can only insert their own progress
CREATE POLICY "User Progress: Owner insert"
ON public.user_progress FOR INSERT
WITH CHECK (
  auth.uid() = user_id
);

-- Users can only update their own progress (admins can update anyone)
CREATE POLICY "User Progress: Owner update"
ON public.user_progress FOR UPDATE
USING (
  auth.uid() = user_id OR
  get_user_role() IN ('admin', 'teacher')
);

-- Only admins can delete progress
CREATE POLICY "User Progress: Admin delete"
ON public.user_progress FOR DELETE
USING (
  get_user_role() = 'admin'
);

-- ============================================================
-- VALIDASI INPUT (Triggers)
-- ============================================================

-- Trigger untuk validasi judul bagian
CREATE OR REPLACE FUNCTION validate_bagian_input()
RETURNS TRIGGER AS $$
BEGIN
  -- Validasi title tidak kosong
  IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
    RAISE EXCEPTION 'Judul bagian tidak boleh kosong';
  END IF;

  -- Batasi panjang title
  IF LENGTH(NEW.title) > 200 THEN
    RAISE EXCEPTION 'Judul bagian maksimal 200 karakter';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_bagian
BEFORE INSERT OR UPDATE ON public.bagian
FOR EACH ROW EXECUTE FUNCTION validate_bagian_input();

-- Trigger untuk validasi judul bab
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

-- Trigger untuk validasi judul fasal
CREATE OR REPLACE FUNCTION validate_fasal_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.title IS NULL OR TRIM(NEW.title) = '' THEN
    RAISE EXCEPTION 'Judul fasal tidak boleh kosong';
  END IF;

  IF LENGTH(NEW.title) > 300 THEN
    RAISE EXCEPTION 'Judul fasal maksimal 300 karakter';
  END IF;

  -- Validasi content_arab jika ada
  IF NEW.content_arab IS NOT NULL AND LENGTH(NEW.content_arab) > 10000 THEN
    RAISE EXCEPTION 'Konten Arab maksimal 10000 karakter';
  END IF;

  -- Validasi content_id jika ada
  IF NEW.content_id IS NOT NULL AND LENGTH(NEW.content_id) > 10000 THEN
    RAISE EXCEPTION 'Konten Indonesia maksimal 10000 karakter';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_fasal
BEFORE INSERT OR UPDATE ON public.fasal
FOR EACH ROW EXECUTE FUNCTION validate_fasal_input();

-- Trigger untuk validasi quiz
CREATE OR REPLACE FUNCTION validate_quiz_input()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.question IS NULL OR TRIM(NEW.question) = '' THEN
    RAISE EXCEPTION 'Pertanyaan quiz tidak boleh kosong';
  END IF;

  IF LENGTH(NEW.question) > 2000 THEN
    RAISE EXCEPTION 'Pertanyaan quiz maksimal 2000 karakter';
  END IF;

  -- Validasi correct_answer tidak kosong untuk multiple choice
  IF NEW.type = 'mc' AND (NEW.correct_answer IS NULL OR TRIM(NEW.correct_answer) = '') THEN
    RAISE EXCEPTION 'Jawaban benar harus diisi untuk soal multiple choice';
  END IF;

  -- Validasi options format (JSON)
  IF NEW.options IS NOT NULL THEN
    -- Basic JSON validation - could enhance with jsonb validation
    IF NEW.options::text !~ '^\\[.*\\]$' THEN
      RAISE EXCEPTION 'Format options harus JSON array';
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_quiz
BEFORE INSERT OR UPDATE ON public.quiz
FOR EACH ROW EXECUTE FUNCTION validate_quiz_input();

-- Trigger untuk validasi user_progress
CREATE OR REPLACE FUNCTION validate_progress_input()
RETURNS TRIGGER AS $$
BEGIN
  -- Validasi user_id tidak kosong
  IF NEW.user_id IS NULL THEN
    RAISE EXCEPTION 'User ID tidak boleh kosong';
  END IF;

  -- Validasi fasal_id tidak kosong
  IF NEW.fasal_id IS NULL OR TRIM(NEW.fasal_id) = '' THEN
    RAISE EXCEPTION 'Fasal ID tidak boleh kosong';
  END IF;

  -- Validasi quiz_score range
  IF NEW.quiz_score IS NOT NULL THEN
    IF NEW.quiz_score < 0 OR NEW.quiz_score > 100 THEN
      RAISE EXCEPTION 'Skor quiz harus antara 0-100';
    END IF;
  END IF;

  -- Validasi status
  IF NEW.status IS NOT NULL AND NEW.status NOT IN ('locked', 'unlocked', 'in_progress', 'completed') THEN
    RAISE EXCEPTION 'Status tidak valid';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_progress
BEFORE INSERT OR UPDATE ON public.user_progress
FOR EACH ROW EXECUTE FUNCTION validate_progress_input();