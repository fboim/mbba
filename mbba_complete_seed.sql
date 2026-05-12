-- ============================================================
-- MBBA — Complete Fix & Seed SQL
-- Jalankan di Supabase SQL Editor (SECARA BERURUTAN)
-- ============================================================

-- ============================================================
-- BAGIAN 1: FIX SCHEMA
-- Tambahkan kolom yang missing
-- ============================================================

-- 1a. Tambah kolom image_url ke kitab (untuk cover kitab)
ALTER TABLE public.kitab ADD COLUMN IF NOT EXISTS image_url text;

-- 1b. Tambah kolom bab_id ke quiz (diperlukan oleh fetchQuizBankBab di frontend)
ALTER TABLE public.quiz ADD COLUMN IF NOT EXISTS bab_id uuid REFERENCES public.bab(id) ON DELETE SET NULL;

-- 1c. Tambah kolom created_at ke quiz jika belum ada
ALTER TABLE public.quiz ADD COLUMN IF NOT EXISTS created_at timestamptz DEFAULT now();

-- ============================================================
-- BAGIAN 2: TAMBAH UNIQUE CONSTRAINTS
-- (Diperlukan agar ON CONFLICT tidak error)
-- ============================================================

-- 2a. Unique constraint untuk bagian (berdasarkan order_index)
DO $$ BEGIN
  ALTER TABLE public.bagian ADD CONSTRAINT bagian_order_index_key UNIQUE (order_index);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 2b. Unique constraint untuk bab (bagian_id + order_index)
DO $$ BEGIN
  ALTER TABLE public.bab ADD CONSTRAINT bab_bagian_order_idx UNIQUE (bagian_id, order_index);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 2c. Unique constraint untuk fasal (bab_id + order_index)
DO $$ BEGIN
  ALTER TABLE public.fasal ADD CONSTRAINT fasal_bab_order_idx UNIQUE (bab_id, order_index);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- 2d. Unique constraint untuk quiz (fasal_id + order_index)
DO $$ BEGIN
  ALTER TABLE public.quiz ADD CONSTRAINT quiz_fasal_order_idx UNIQUE (fasal_id, order_index);
EXCEPTION WHEN duplicate_object THEN null;
END $$;

-- ============================================================
-- BAGIAN 3: RESET DATA LAMA
-- ============================================================

DELETE FROM public.quiz;
DELETE FROM public.fasal;
DELETE FROM public.bab;
DELETE FROM public.bagian;
DELETE FROM public.kitab;
DELETE FROM public.jenjang;

-- ============================================================
-- BAGIAN 4: INSERT DATA
-- ============================================================

-- 4a. JENJANG
INSERT INTO public.jenjang (id, nama, deskripsi, order_index) VALUES
  ('jj-001-tngkt-1', 'Tingkat 1', 'Dasar-dasar Nahwu dan Sharaf', 1),
  ('jj-002-tngkt-2', 'Tingkat 2', 'Nahwu Menengah - Am Maudhu''at', 2),
  ('jj-003-tngkt-3', 'Tingkat 3', 'Nahwu Lanjutan - Alfiyah Ibnu Malik', 3);

-- 4b. KITAB
INSERT INTO public.kitab (id, jenjang_id, nama, penulis, image_url, order_index) VALUES
  ('kb-001-muqoddimah', 'jj-001-tngkt-1', 'Muqoddimah', 'Syeikh Muhammad Ali al-Shabuniy', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Banana-Cross-Section.jpg/220px-Banana-Cross-Section.jpg', 1),
  ('kb-002-alfiyah', 'jj-001-tngkt-1', 'Alfiyah Ibnu Malik', 'Ibnu Malik', NULL, 2),
  ('kb-003-am-maudhu', 'jj-002-tngkt-2', 'Am Maudhu''at al-Kubra', 'Syeikh Hasan al-Mishri', NULL, 1);

-- 4c. BAGIAN
INSERT INTO public.bagian (id, kitab_id, order_index, title, description, is_active) VALUES
  ('bg-001-qawaid', 'kb-001-muqoddimah', 1, 'Al-Qawa''id al-Muta''alliqah bi al-Jumlah', 'Qaidah-qaidah nahwu yang berkaitan dengan kalimat.', true),
  ('bg-002-sharf', 'kb-001-muqoddimah', 2, 'Ash-Sharf al-Mukhtasar', 'Shorof dasar yang berkaitan dengan fi''il.', true),
  ('bg-003-irab', 'kb-001-muqoddimah', 3, 'Al-I''rab al-Musharrar', 'Penjabaran i''rab secara terperinci.', true);

-- 4d. BAB
INSERT INTO public.bab (id, bagian_id, order_index, title, is_muqoddimah, is_locked) VALUES
  ('bb-001-muqod', 'bg-001-qawaid', 1, 'Muqoddimah', true, false),
  ('bb-002-dafrid', 'bg-001-qawaid', 2, 'Ad-Dafridu wa Ats-Tsauliy', false, true),
  ('bb-003-kalimat', 'bg-001-qawaid', 3, 'Al-Ismu wal-Kalimatu wal-''Alfadhu', false, true);

-- 4e. FASAL
INSERT INTO public.fasal (id, bab_id, order_index, title, content_arab, content_id, audio_url, is_locked) VALUES

  -- Fasal 1: Ad-Dafridu fi al-Jumlah (bagian 1)
  ('fs-001-dfrd-jumlah', 'bb-001-muqod', 1, 'Ad-Dafridu fi al-Jumlah',
'هَذَا الضَّبْعُ مُسْتَقِيمٌ. هَذِهِ الْبَقَرَةُ مُسْتَقِيمَةٌ. هَذَا الْجِلْدُ وَاسِعٌ. هَذِهِ النَّخْلَةُ طَوِيلَةٌ.',
'Ini (binatang buas) singa berjalan tegak. Ini (binatang) sapi berjalan tegak. Kulit ini luas. Pohon kurma itu tinggi.',
NULL, false),

  -- Fasal 2: Al-Ismu wal-Kalimatu (bagian 1)
  ('fs-002-isym-klimat', 'bb-001-muqod', 2, 'Al-Ismu wal-Kalimatu',
'الْجِلْدُ وَاسِعٌ. الْبَقَرَةُ مُسْتَقِيمَةٌ. النَّخْلَةُ طَوِيلَةٌ. الضَّبْعُ مُسْتَقِيمٌ.',
'Kulit itu luas. Sapi itu berjalan tegak. Pohon kurma itu tinggi. Singa itu berjalan tegak.',
NULL, true),

  -- Fasal 3: Al-Ismu wal-Fa''lu (bab 2)
  ('fs-003-isym-fal', 'bb-002-dafrid', 1, 'Al-Ismu wal-Fa''lu',
'الْغُرْبَالُ نَظِيفٌ. الْبَقَرَةُ كَبِيرَةٌ. الْكَلْبُ صَغِيرٌ. الْعِلْجُ قَوِيٌّ.',
'Pengayak itu bersih. Sapi itu besar. Anjing itu kecil. Orang itu kuat.',
NULL, true),

  -- Fasal 4: Al-Fa''luwal (bab 3)
  ('fs-004-falwal', 'bb-003-kalimat', 1, 'Al-Fa''luwal',
'الضَّرْبُ قَوِيٌّ. الْكِتَابَةُ نَافِعَةٌ. الدَّرْسُ مُهِّمٌ.',
'Memukul itu kuat. Menulis itu bermanfaat. Belajar itu penting.',
NULL, true);

-- 4f. Backfill: Update bab_id di quiz berdasarkan fasal_id (untuk quiz yang sudah ada sebelumnya)
UPDATE public.quiz q
SET bab_id = f.bab_id
FROM public.fasal f
WHERE q.fasal_id = f.id AND q.bab_id IS NULL;

-- 4g. QUIZ (ISI BAB MUQODDIMAH — 20 SOAL)
INSERT INTO public.quiz (id, fasal_id, bab_id, type, order_index, question, options, correct_answer, passing_threshold) VALUES

-- Soal 1-5 (Fasal 1: Ad-Dafridu fi al-Jumlah)
(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 1,
'Apa arti مُسْتَقِيمٌ?',
'[{"key":"A","value":"Luas"},{"key":"B","value":"Berjalan tegak"},{"key":"C","value":"Tinggi"},{"key":"D","value":"Baik"}]',
'B', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 2,
'Manakah kata yang menunjukkan kata benda feminin (muannats)?',
'[{"key":"A","value":"الْبَقَرَةُ"},{"key":"B","value":"الْجِلْدُ"},{"key":"C","value":"الضَّبْعُ"},{"key":"D","value":"النَّخْلَةُ"}]',
'D', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 3,
'Kalimat "هَذَا الْجِلْدُ وَاسِعٌ" terdiri dari berapa kata?',
'[{"key":"A","value":"3 kata"},{"key":"B","value":"4 kata"},{"key":"C","value":"5 kata"},{"key":"D","value":"2 kata"}]',
'B', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 4,
'Apa fungsi isim isyaroh "هَذَا"?',
'[{"key":"A","value":"Menunjuk kata kerja"},{"key":"B","value":"Menunjuk kata benda mudzakkar"},{"key":"C","value":"Menunjuk kata sifat"},{"key":"D","value":"Menunjuk huruf"}]',
'B', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 5,
'"طَوِيلَةٌ" adalah kata sifat (shifah) untuk kata...',
'[{"key":"A","value":"الْجِلْدُ"},{"key":"B","value":"النَّخْلَةُ"},{"key":"C","value":"الْبَقَرَةُ"},{"key":"D","value":"الضَّبْعُ"}]',
'B', 100),

-- Soal 6-10 (Fasal 1: Lanjutan)
(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 6,
'Bentuk feminin dari "وَاسِعٌ" adalah...',
'[{"key":"A","value":"وَاسِعَةٌ"},{"key":"B","value":"مُوسِعٌ"},{"key":"C","value":"إِسْعَةٌ"},{"key":"D","value":"وَسِيعٌ"}]',
'A', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 7,
'Mengapa "الْجِلْدُ" mendapat tanwin?',
'[{"key":"A","value":"Karena الْجِلْدُ adalah mubtada"},{"key":"B","value":"Karena الْجِلْدُ adalah khobar"},{"key":"C","value":"Karena الْجِلْدُ adalah isim isyaroh"},{"key":"D","value":"Karena الْجِلْدُ adalah na''t"}]',
'A', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 8,
'Isim Isyaroh untuk mudzakkar terdekat adalah...',
'[{"key":"A","value":"هَذِهِ"},{"key":"B","value":"ذَلِكَ"},{"key":"C","value":"هَذَا"},{"key":"D","value":"أُولَئِكَ"}]',
'C', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 9,
'Isim Isyaroh untuk muannats jauh adalah...',
'[{"key":"A","value":"هَذَا"},{"key":"B","value":"تِلْكَ"},{"key":"C","value":"ذَاكَ"},{"key":"D","value":"هَذِهِ"}]',
'B', 100),

(gen_random_uuid(), 'fs-001-dfrd-jumlah', 'bb-001-muqod', 'mc', 10,
'Apa perbedaan antara الضَّبْعُ dan الضَّبْعَةُ?',
'[{"key":"A","value":"Tidak ada perbedaan"},{"key":"B","value":"ضبع adalah mudzakkar, ضبعة adalah muannats"},{"key":"C","value":"ضبع adalah muannats, ضبعة adalah mudzakkar"},{"key":"D","value":"Keduanya adalah اسم yang berbeda"}]',
'B', 100),

-- Soal 11-20 (Fasal 2: Al-Ismu wal-Kalimatu)
(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 1,
'Dalam kalimat "الْبَقَرَةُ مُسْتَقِيمَةٌ", apa fungsi الْبَقَرَةُ?',
'[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Maf''ul bih"},{"key":"D","value":"Na''t"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 2,
'Kata "هَذَا" termasuk dalam kategori...',
'[{"key":"A","value":"Isim Ma''rifat"},{"key":"B","value":"Isim Isyaroh"},{"key":"C","value":"Isim Nakirah"},{"key":"D","value":"Isim Alam"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 3,
'Huruf apa yang membuat "النَّخْلَةُ" menjadi muannats?',
'[{"key":"A","value":"Alif"},{"key":"B","value":"Ta marbuthah (ة)"},{"key":"C","value":"Ya"},{"key":"D","value":"Waw"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 4,
'Apa arti وَاسِعٌ?',
'[{"key":"A","value":"Tinggi"},{"key":"B","value":"Luas"},{"key":"C","value":"Baik"},{"key":"D","value":"Berjalan tegak"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 5,
'Dalam kalimat nominal (jumlah ismiyah), yang berfungsi sebagai subjek disebut...',
'[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Fa''il"},{"key":"D","value":"Na''ib Fa''il"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 6,
'مُسْتَقِيمٌ adalah...',
'[{"key":"A","value":"Isim (kata benda)"},{"key":"B","value":"Khobar (predicate)"},{"key":"C","value":"Fi''il (kata kerja)"},{"key":"D","value":"Harf (huruf)"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 7,
'Isim Isyaroh untuk mudzakkar jauh adalah...',
'[{"key":"A","value":"هَذَا"},{"key":"B","value":"ذَاكَ"},{"key":"C","value":"تِلْكَ"},{"key":"D","value":"أُولَئِكَ"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 8,
'Dalam kalimat "الْبَقَرَةُ مُسْتَقِيمَةٌ", الْبَقَرَةُ adalah...',
'[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Maf''ul bih"},{"key":"D","value":"Na''t"}]',
'B', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 9,
'Kata "النَّخْلَةُ" mendapat tanwin karena berfungsi sebagai...',
'[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Isim isyaroh"},{"key":"D","value":"Na''t"}]',
'A', 100),

(gen_random_uuid(), 'fs-002-isym-klimat', 'bb-001-muqod', 'mc', 10,
'Dalam jumlah ismiyah, mubtada dan khobar membentuk kalimat yang bernilai...',
'[{"key":"A","value":"Perintah (Amr)"},{"key":"B","value":"Pertanyaan (Istifham)"},{"key":"C","value":"Keterangan (Khabariyah)"},{"key":"D","value":"Penafian (Nafi)"}]',
'C', 100);

-- ============================================================
-- BAGIAN 5: VERIFIKASI
-- ============================================================
SELECT 'Jenjang:' AS info, COUNT(*) AS jumlah FROM public.jenjang
UNION ALL SELECT 'Kitab:', COUNT(*) FROM public.kitab
UNION ALL SELECT 'Bagian:', COUNT(*) FROM public.bagian
UNION ALL SELECT 'Bab:', COUNT(*) FROM public.bab
UNION ALL SELECT 'Fasal:', COUNT(*) FROM public.fasal
UNION ALL SELECT 'Quiz:', COUNT(*) FROM public.quiz
UNION ALL SELECT 'Bab dengan quiz:', COUNT(DISTINCT bab_id) FROM public.quiz WHERE bab_id IS NOT NULL;
