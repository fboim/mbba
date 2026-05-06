-- ============================================================
-- MBBA — Full Seed Data SQL (gen_random_uuid + composite FK)
-- Generated: 2026-05-05
-- Target: Supabase PostgreSQL
-- ============================================================
-- PRASYARAT:
-- 1. Tabel sudah dibuat (bagian, bab, fasal, quiz)
-- 2. Tabel memiliki UNIQUE constraint: bagian(order_index),
--    bab(bagian_id, order_index), fasal(bab_id, order_index),
--    quiz(fasal_id, order_index)
-- CARA PAKAI:
-- 1. Buka Supabase Dashboard → SQL Editor
-- 2. Copy seluruh isi file ini
-- 3. Paste ke SQL Editor
-- 4. Klik Run
-- ============================================================

-- ============================================================
-- BAGIAN (3 records)
-- ============================================================
INSERT INTO public.bagian (id, order_index, title, description, is_active) VALUES
(gen_random_uuid(), 1, 'Al-Qawa''id al-Muta''alliqah bi al-Jumlah', 'Qaidah-qaidah nahwu yang berkaitan dengan kalimat.', true),
(gen_random_uuid(), 2, 'Ash-Sharf al-Mukhtasar', 'Shorof dasar yang berkaitan dengan fi''il.', true),
(gen_random_uuid(), 3, 'Al-I''rab al-Musharrar', 'Penjabaran i''rab secara terperinci.', true)
ON CONFLICT (order_index) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  is_active = EXCLUDED.is_active;

-- ============================================================
-- BAB (3 records)
-- ============================================================
INSERT INTO public.bab (id, bagian_id, order_index, title, is_muqoddimah, is_locked) VALUES
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 1, 'Muqoddimah', true, false),
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 2, 'Ad-Dafridu wa Ats-Tsauliy', false, true),
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 3, 'Al-Ismu wal-Kalimatu wal-''Alfadhu', false, true)
ON CONFLICT (bagian_id, order_index) DO UPDATE SET
  title = EXCLUDED.title,
  is_muqoddimah = EXCLUDED.is_muqoddimah,
  is_locked = EXCLUDED.is_locked;

-- ============================================================
-- FASAL (3 records)
-- ============================================================
INSERT INTO public.fasal (id, bab_id, order_index, title, content_arab, content_id, audio_url, is_locked) VALUES
(gen_random_uuid(), (SELECT id FROM public.bab WHERE order_index = 1), 1, 'Ad-Dafridu fi al-Jumlah',
 'هَذَا الضَّبْعُ مُسْتَقِيمٌ. هَذِهِ الْبَقَرَةُ مُسْتَقِيمَةٌ. هَذَا الْجِلْدُ وَاسِعٌ. هَذِهِ النَّخْلَةُ طَوِيلَةٌ.',
 'Ini (binatang buas) singa berjalan tegak. Ini (binatang) sapi berjalan tegak. Kulit ini luas. Pohon kurma itu tinggi.',
 NULL, false),
(gen_random_uuid(), (SELECT id FROM public.bab WHERE order_index = 1), 2, 'Al-Ismu wal-Kalimatu',
 'الْجِلْدُ وَاسِعٌ. الْبَقَرَةُ مُسْتَقِيمَةٌ. النَّخْلَةُ طَوِيلَةٌ. الضَّبْعُ مُسْتَقِيمٌ.',
 'Kulit itu luas. Sapi itu berjalan tegak. Pohon kurma itu tinggi. Singa itu berjalan tegak.',
 NULL, true),
(gen_random_uuid(), (SELECT id FROM public.bab WHERE order_index = 2), 1, 'Al-Ismu wal-Fa''lu',
 'الْغُرْبَالُ نَظِيفٌ. الْبَقَرَةُ كَبِيرَةٌ. الْكَلْبُ صَغِيرٌ. الْعِلْجُ قَوِيٌّ.',
 'Pengayak itu bersih. Sapi itu besar. Anjing itu kecil. Orang itu kuat.',
 NULL, true)
ON CONFLICT (bab_id, order_index) DO UPDATE SET
  title = EXCLUDED.title,
  content_arab = EXCLUDED.content_arab,
  content_id = EXCLUDED.content_id,
  audio_url = EXCLUDED.audio_url,
  is_locked = EXCLUDED.is_locked;

-- ============================================================
-- QUIZ (50 records — mc, fill-arab, fill-latin)
-- ============================================================
INSERT INTO public.quiz (id, fasal_id, type, order_index, question, options, correct_answer, placeholder, passing_threshold) VALUES

-- === SOAL 1-10: Multiple Choice ===
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 1, 'Apa arti مُسْتَقِيمٌ?', '[{"key":"A","value":"Luas"},{"key":"B","value":"Berjalan tegak"},{"key":"C","value":"Tinggi"},{"key":"D","value":"Baik"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 2, 'Manakah kata yang menunjukkan kata benda feminin (muannats)?', '[{"key":"A","value":"الْبَقَرَةُ"},{"key":"B","value":"الْجِلْدُ"},{"key":"C","value":"الضَّبْعُ"},{"key":"D","value":"النَّخْلَةُ"}]', 'D', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 3, 'Kalimat "هَذَا الْجِلْدُ وَاسِعٌ" terdiri dari berapa kata?', '[{"key":"A","value":"3 kata"},{"key":"B","value":"4 kata"},{"key":"C","value":"5 kata"},{"key":"D","value":"2 kata"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 4, 'Apa fungsi isim isyaroh "هَذَا"?', '[{"key":"A","value":"Menunjuk kata kerja"},{"key":"B","value":"Menunjuk kata benda mudzakkar"},{"key":"C","value":"Menunjuk kata sifat"},{"key":"D","value":"Menunjuk huruf"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 5, '"طَوِيلَةٌ" adalah kata sifat (shifah) untuk kata...', '[{"key":"A","value":"الْجِلْدُ"},{"key":"B","value":"النَّخْلَةُ"},{"key":"C","value":"الْبَقَرَةُ"},{"key":"D","value":"الضَّبْعُ"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 6, 'Bentuk feminin dari "وَاسِعٌ" adalah...', '[{"key":"A","value":"وَاسِعَةٌ"},{"key":"B","value":"مُوسِعٌ"},{"key":"C","value":"إِسْعَةٌ"},{"key":"D","value":"وَسِيعٌ"}]', 'A', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 7, 'Mengapa "الْجِلْدُ" mendapat tanwin?', '[{"key":"A","value":"Karena الْجِلْدُ adalah mubtada"},{"key":"B","value":"Karena الْجِلْدُ adalah khobar yang di-nashab-kan"},{"key":"C","value":"Karena الْجِلْدُ adalah isim isyaroh"},{"key":"D","value":"Karena الْجِلْدُ adalah na''t"}]', 'A', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 8, 'Isim Isyaroh untuk mudzakkar terdekat adalah...', '[{"key":"A","value":"هَذِهِ"},{"key":"B","value":"ذَلِكَ"},{"key":"C","value":"هَذَا"},{"key":"D","value":"أُولَئِكَ"}]', 'C', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 9, 'Isim Isyaroh untuk muannats jauh adalah...', '[{"key":"A","value":"هَذَا"},{"key":"B","value":"تِلْكَ"},{"key":"C","value":"ذَاكَ"},{"key":"D","value":"هَذِهِ"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 10, 'Apa perbedaan antara الضَّبْعُ dan الضَّبْعَةُ?', '[{"key":"A","value":"Tidak ada perbedaan"},{"key":"B","value":"ضبع adalah mudzakkar, ضبعة adalah muannats"},{"key":"C","value":"ضبع adalah muannats, ضبعة adalah mudzakkar"},{"key":"D","value":"Keduanya adalah اسم yang berbeda"}]', 'B', NULL, 100),

-- === SOAL 11-20: Multiple Choice ===
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 11, 'Dalam kalimat "الْبَقَرَةُ مُسْتَقِيمَةٌ", apa fungsi الْبَقَرَةُ?', '[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Maf''ul bih"},{"key":"D","value":"Na''t"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 12, 'Kata "هَذَا" termasuk dalam kategori...', '[{"key":"A","value":"Isim Ma''rifat"},{"key":"B","value":"Isim Isyaroh"},{"key":"C","value":"Isim Nakirah"},{"key":"D","value":"Isim Alam"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 13, 'Huruf apa yang membuat "النَّخْلَةُ" menjadi muannats?', '[{"key":"A","value":"Alif"},{"key":"B","value":"Ta marbuthah (ة)"},{"key":"C","value":"Ya"},{"key":"D","value":"Waw"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 14, 'Apa arti وَاسِعٌ?', '[{"key":"A","value":"Tinggi"},{"key":"B","value":"Luas"},{"key":"C","value":"Baik"},{"key":"D","value":"Berjalan tegak"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 15, 'Dalam kalimat nominal (jumlah ismiyah), yang berfungsi sebagai subjek disebut...', '[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Fa''il"},{"key":"D","value":"Na''ib Fa''il"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 16, 'مُسْتَقِيمٌ adalah...', '[{"key":"A","value":"Isim (kata benda)"},{"key":"B","value":"Khobar (predicate)"},{"key":"C","value":"Fi''il (kata kerja)"},{"key":"D","value":"Harf (huruf)"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 17, 'Isim Isyaroh untuk mudzakkar jauh adalah...', '[{"key":"A","value":"هَذَا"},{"key":"B","value":"ذَاكَ"},{"key":"C","value":"تِلْكَ"},{"key":"D","value":"أُولَئِكَ"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 18, 'Dalam kalimat "الْبَقَرَةُ مُسْتَقِيمَةٌ", الْبَقَرَةُ adalah...', '[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Maf''ul bih"},{"key":"D","value":"Na''t"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 19, 'Kata "هَذَا" termasuk kategori...', '[{"key":"A","value":"Isim Ma''rifat"},{"key":"B","value":"Isim Isyaroh"},{"key":"C","value":"Isim Nakirah"},{"key":"D","value":"Isim Alam"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 20, 'Huruf apa yang membuat "النَّخْلَةُ" menjadi muannats?', '[{"key":"A","value":"Alif (ا)"},{"key":"B","value":"Ta Marbuthah (ة)"},{"key":"C","value":"Ya (ي)"},{"key":"D","value":"Waw (و)"}]', 'B', NULL, 100),

-- === SOAL 21-26: Multiple Choice ===
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 21, 'Dalam kalimat nominal, yang berfungsi sebagai subjek disebut...', '[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Fa''il"},{"key":"D","value":"Na''ib Fa''il"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 22, 'مُسْتَقِيمٌ adalah khobar. Khobar berfungsi sebagai...', '[{"key":"A","value":"Kata benda (Isim)"},{"key":"B","value":"Kata sifat (Shifah)"},{"key":"C","value":"Predicate / pengenai"},{"key":"D","value":"Kata keterangan (Zarf)"}]', 'C', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 23, 'Isim Isyaroh untuk mudzakkar jauh adalah...', '[{"key":"A","value":"هَذَا"},{"key":"B","value":"ذَاكَ"},{"key":"C","value":"تِلْكَ"},{"key":"D","value":"أُولَئِكَ"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 24, 'Apa arti طَوِيلَةٌ?', '[{"key":"A","value":"Luas (feminin)"},{"key":"B","value":"Tinggi (feminin)"},{"key":"C","value":"Baik (feminin)"},{"key":"D","value":"Berjalan tegak (feminin)"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 25, 'Kata "النَّخْلَةُ" mendapat tanwin karena berfungsi sebagai...', '[{"key":"A","value":"Khobar"},{"key":"B","value":"Mubtada"},{"key":"C","value":"Isim isyaroh"},{"key":"D","value":"Na''t"}]', 'A', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 26, 'Dalam jumlah ismiyah, mubtada dan khobar membentuk kalimat yang bernilai...', '[{"key":"A","value":"Perintah (Amr)"},{"key":"B","value":"Pertanyaan (Istifham)"},{"key":"C","value":"Keterangan (Khabariyah)"},{"key":"D","value":"Penafian (Nafi)"}]', 'C', NULL, 100),

-- === SOAL 27-35: Isian Arab ===
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 27, 'Lengkapkan: هَذَا الضَّبْعُ مُسْتَقِيمٌ (هَذَا=Ini, الضَّبْعُ=singa, مُسْتَقِيمٌ=berjalan tegak)', NULL, 'مُسْتَقِيمٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 28, 'Lengkapkan: هَذِهِ الْبَقَرَةُ مُسْتَقِيمَةٌ (هَذِهِ=ini, الْبَقَرَةُ=sapi, مُسْتَقِيمَةٌ=berjalan tegak)', NULL, 'مُسْتَقِيمَةٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 29, 'Lengkapkan: هَذَا الْجِلْدُ ____ (هَذَا=ini, الْجِلْدُ=kulit)', NULL, 'وَاسِعٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 30, 'Lengkapkan: هَذِهِ النَّخْلَةُ ____ (هَذِهِ=ini, النَّخْلَةُ=pohon kurma)', NULL, 'طَوِيلَةٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 31, 'Lengkapkan: ____ الْبَقَرَةُ مُسْتَقِيمَةٌ (kata penunjuk untuk muannats dekat)', NULL, 'هَذِهِ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 32, 'Lengkapkan kalimat ke-3: هَذَا الضَّبْعُ مُسْتَقِيمٌ. هَذِهِ الْبَقَرَةُ مُسْتَقِيمَةٌ. هَذَا الْجِلْدُ ____. هَذِهِ النَّخْلَةُ طَوِيلَةٌ.', NULL, 'وَاسِعٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 33, 'Bentuk feminin dari مُسْتَقِيمٌ adalah...', NULL, 'مُسْتَقِيمَةٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 34, 'Lengkapkan dengan isim isyaroh mudzakkar dekat: ____ الضَّبْعُ مُسْتَقِيمٌ', NULL, 'هَذَا', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 35, 'Lengkapkan: هَذَا الضَّبْعُ مُسْتَقِيمٌ (ketik kata yang berarti "berjalan tegak")', NULL, 'مُسْتَقِيمٌ', 'ketik jawaban Arab...', 100),

-- === SOAL 36-50: Isian Latin ===
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 36, 'Terjemahkan ke huruf Latin: النَّخْلَةُ', NULL, 'an-nakhatu', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 37, 'Terjemahkan ke huruf Latin: وَاسِعٌ', NULL, 'wasion', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 38, 'Terjemahkan ke huruf Latin: مُسْتَقِيمٌ', NULL, 'mustaqimun', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 39, 'Terjemahkan ke huruf Latin: طَوِيلَةٌ', NULL, 'thawilatum', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 40, 'Terjemahkan ke huruf Latin: الْبَقَرَةُ', NULL, 'al-baqaratu', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 41, 'Terjemahkan ke huruf Latin: الضَّبْعُ', NULL, 'adh-dhabu', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 42, 'Terjemahkan ke huruf Latin: مُسْتَقِيمٌ', NULL, 'mustaqimun', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 43, 'Terjemahkan ke huruf Latin: وَاسِعٌ', NULL, 'wasion', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 44, 'Terjemahkan ke huruf Latin: النَّخْلَةُ طَوِيلَةٌ', NULL, 'an-nakhatu thawilatum', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 45, 'Terjemahkan ke huruf Latin: هَذَا الْجِلْدُ وَاسِعٌ', NULL, 'hadza al-jildu wasiun', 'ketik latin...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 46, 'Bentuk feminin dari "وَاسِعٌ" adalah...', '[{"key":"A","value":"وَاسِعَةٌ"},{"key":"B","value":"مُوسِعٌ"},{"key":"C","value":"إِسْعَةٌ"},{"key":"D","value":"وَسِيعٌ"}]', 'A', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 47, 'Isim Isyaroh untuk muannats jauh adalah...', '[{"key":"A","value":"هَذَا"},{"key":"B","value":"تِلْكَ"},{"key":"C","value":"ذَاكَ"},{"key":"D","value":"هَذِهِ"}]', 'B', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'mc', 48, 'مُسْتَقِيمٌ adalah khobar. Khobar berfungsi sebagai...', '[{"key":"A","value":"Kata benda (Isim)"},{"key":"B","value":"Kata sifat (Shifah)"},{"key":"C","value":"Predicate / pengenai"},{"key":"D","value":"Kata keterangan (Zarf)"}]', 'C', NULL, 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-arab', 49, 'Lengkapkan: هَذَا الضَّبْعُ مُسْتَقِيمٌ (ketik kata Arab yang berarti "berjalan tegak")', NULL, 'مُسْتَقِيمٌ', 'ketik jawaban Arab...', 100),
(gen_random_uuid(), (SELECT id FROM public.fasal WHERE order_index = 1 AND bab_id = (SELECT id FROM public.bab WHERE order_index = 1 AND bagian_id = (SELECT id FROM public.bagian WHERE order_index = 1))), 'fill-latin', 50, 'Terjemahkan ke huruf Latin: الْجِلْدُ وَاسِعٌ', NULL, 'al-jildu wasiun', 'ketik latin...', 100);

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'bagian' as table_name, count(*) as total FROM public.bagian
UNION ALL SELECT 'bab', count(*) FROM public.bab
UNION ALL SELECT 'fasal', count(*) FROM public.fasal
UNION ALL SELECT 'quiz', count(*) FROM public.quiz;