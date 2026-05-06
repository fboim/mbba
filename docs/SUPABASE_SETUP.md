# MBBA — Panduan Setup Supabase

**Tanggal:** 2026-05-05
**Status:** Ready for Setup

## Langkah 1: Buat Project Supabase

1. Buka [supabase.com](https://supabase.com) → buat akun / login
2. Klik **New Project**
3. Isi:
   - **Name:** MBBA
   - **Database Password:** simpan di tempat aman
   - **Region:** Singapore (terdekat)
   - **Pricing:** Free Tier
4. Tunggu provisioning selesai (~2 menit)
5. Buka **Project Settings → API**
6. Catat:
   - `Project URL` → `SUPABASE_URL`
   - `anon public` key → `SUPABASE_ANON_KEY`
   - `service_role` key → **JANGAN di-expose ke frontend**

---

## Langkah 2: Buat Tabel (SQL Editor)

Buka **SQL Editor** → jalankan query berikut:

```sql
-- =============================================
-- USERS (leverages Supabase Auth)
-- =============================================
CREATE TABLE IF NOT EXISTS public.users (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  full_name   TEXT,
  role        TEXT DEFAULT 'student' CHECK (role IN ('student','teacher','admin')),
  created_at   TIMESTAMPTZ DEFAULT NOW(),
  updated_at   TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- BAGIAN
-- =============================================
CREATE TABLE IF NOT EXISTS public.bagian (
  id           UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_index INTEGER UNIQUE NOT NULL,
  title        TEXT NOT NULL,
  description  TEXT,
  is_active    BOOLEAN DEFAULT TRUE,
  created_at   TIMESTAMPTZ DEFAULT NOW()
);

-- =============================================
-- BAB
-- =============================================
CREATE TABLE IF NOT EXISTS public.bab (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bagian_id     UUID REFERENCES public.bagian(id) ON DELETE CASCADE,
  order_index   INTEGER NOT NULL,
  title         TEXT NOT NULL,
  is_muqoddimah BOOLEAN DEFAULT FALSE,
  is_locked     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (bagian_id, order_index)
);

-- =============================================
-- FASAL
-- =============================================
CREATE TABLE IF NOT EXISTS public.fasal (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  bab_id        UUID REFERENCES public.bab(id) ON DELETE CASCADE,
  order_index   INTEGER NOT NULL,
  title         TEXT NOT NULL,
  content_arab  TEXT NOT NULL,
  content_id    TEXT NOT NULL,
  audio_url     TEXT,
  is_locked     BOOLEAN DEFAULT TRUE,
  created_at    TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (bab_id, order_index)
);

-- =============================================
-- QUIZ
-- =============================================
CREATE TABLE IF NOT EXISTS public.quiz (
  id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  fasal_id            UUID REFERENCES public.fasal(id) ON DELETE CASCADE,
  order_index         INTEGER NOT NULL,
  type                TEXT DEFAULT 'mc' CHECK (type IN ('mc','fill-arab','fill-latin')),
  question            TEXT NOT NULL,
  options             JSONB,          -- untuk type='mc' saja
  correct_answer      TEXT NOT NULL,
  placeholder         TEXT,
  passing_threshold   INTEGER DEFAULT 100,
  UNIQUE (fasal_id, order_index)
);

-- =============================================
-- USER PROGRESS
-- =============================================
CREATE TABLE IF NOT EXISTS public.user_progress (
  id             UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id        UUID REFERENCES public.users(id) ON DELETE CASCADE,
  fasal_id       UUID REFERENCES public.fasal(id) ON DELETE CASCADE,
  status         TEXT DEFAULT 'locked' CHECK (status IN ('locked','unlocked','in_progress','completed')),
  quiz_score     INTEGER,
  quiz_attempts  INTEGER DEFAULT 0,
  started_at     TIMESTAMPTZ,
  completed_at   TIMESTAMPTZ,
  created_at     TIMESTAMPTZ DEFAULT NOW(),
  updated_at     TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE (user_id, fasal_id)
);

-- =============================================
-- INDEXING
-- =============================================
CREATE INDEX IF NOT EXISTS idx_bab_bagian ON public.bab(bagian_id);
CREATE INDEX IF NOT EXISTS idx_fasal_bab ON public.fasal(bab_id);
CREATE INDEX IF NOT EXISTS idx_quiz_fasal ON public.quiz(fasal_id);
CREATE INDEX IF NOT EXISTS idx_progress_user ON public.user_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_progress_fasal ON public.user_progress(fasal_id);
```

---

## Langkah 3: Aktifkan Row Level Security (RLS)

Jalankan di SQL Editor:

```sql
-- Enable RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bagian ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.bab ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.fasal ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.quiz ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_progress ENABLE ROW LEVEL SECURITY;

-- POLICY: semua bisa baca kurikulum
CREATE POLICY "public_read" ON public.bagian FOR SELECT USING (true);
CREATE POLICY "public_read" ON public.bab FOR SELECT USING (true);
CREATE POLICY "public_read" ON public.fasal FOR SELECT USING (true);
CREATE POLICY "public_read" ON public.quiz FOR SELECT USING (true);

-- POLICY: student hanya bisa akses progress sendiri
CREATE POLICY "student_progress" ON public.user_progress
  FOR ALL USING (auth.uid() = user_id);

-- POLICY: teacher bisa insert/update materi
-- (dari service_role key — tidak di frontend)
```

---

## Langkah 4: Buat Storage Bucket (Audio)

1. Buka **Storage** → **New Bucket**
2. **Name:** `audio`
3. **Public:** ✅ (centang)
4. Buka folder `audio` → upload file MP3
5. Copy **Public URL** → tempelkan ke kolom `audio_url` di tabel `fasal`

---

## Langkah 5: Import Seed Data (SQL)

> **Catatan:** Supabase Table Editor tidak mendukung import JSON secara langsung.
> Gunakan cara berikut:

1. Buka **SQL Editor** (sidebar kiri)
2. Klik **New Query**
3. Copy seluruh isi file [`src/backend/supabase/seed/seed_data.sql`](src/backend/supabase/seed/seed_data.sql)
4. Paste ke SQL Editor
5. Klik **Run** (▶️)
6. Verifikasi: cek hasil di **Table Editor** — harusnya ada:
   - `bagian`: 3 records
   - `bab`: 3 records
   - `fasal`: 3 records
   - `quiz`: 50 records

---

## Langkah 6: Konfigurasi Environment Variables

Buat file `.env` di root project:

```env
SUPABASE_URL=https://[PROJECT-REF].supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

Buat file `.env.example` untuk repo (tanpa nilai asli):

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

---

## Checklist Setup

- [ ] Supabase project dibuat
- [ ] SQL schema dijalankan
- [ ] RLS + policies diterapkan
- [ ] Storage bucket `audio` dibuat (public)
- [ ] Seed data di-import (SQL insert via SQL Editor — 50 soal quiz)
- [ ] `.env` dikonfigurasi
- [ ] Test: buka `fasal.html` → cek data muncul

---

## Troubleshooting

**Error: row-level security denied**
→ RLS policy belum diterapkan atau user belum login. Login dulu via Supabase Auth.

**Audio tidak playing**
→ Pastikan Supabase Storage bucket sudah di-set public.

**CORS error**
→ Buka **API Settings → CORS** → tambahkan domain frontend Anda.
