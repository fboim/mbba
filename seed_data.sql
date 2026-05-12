-- ============================================================
-- MBBA Database Seed Data
-- Kitab: Muqoddimah al-Mulhid (Muqoddimah untuk Pelajar)
-- ============================================================

-- 1. JENJANG (Level)
INSERT INTO public.jenjang (id, nama, deskripsi, order_index, created_at)
VALUES
  ('11111111-1111-1111-1111-111111111101', 'Tingkat 1', 'Dasar-dasar Nahwu dan Sharaf', 1, NOW()),
  ('11111111-1111-1111-1111-111111111102', 'Tingkat 2', 'Nahwu Menengah - Am Maudhu''', 2, NOW()),
  ('11111111-1111-1111-1111-111111111103', 'Tingkat 3', 'Nahwu Lanjutan - Alfiyah Ibnu Malik', 3, NOW());

-- 2. KITAB (Book)
INSERT INTO public.kitab (id, jenjang_id, nama, penulis, image_url, order_index, created_at)
VALUES
  ('22222222-2222-2222-2222-222222222201', '11111111-1111-1111-1111-111111111101', 'Muqoddimah', 'Syeikh Muhammad Ali al-Shabuniy', 'https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Banana-Cross-Section.jpg/220px-Banana-Cross-Section.jpg', 1, NOW()),
  ('22222222-2222-2222-2222-222222222202', '11111111-1111-1111-1111-111111111101', 'Alfiyah Ibnu Malik', 'Ibnu Malik', NULL, 2, NOW()),
  ('22222222-2222-2222-2222-222222222203', '11111111-1111-1111-1111-111111111102', 'Am Maudhu''at al-Kubra', 'Syeikh Hasan al-Mishri', NULL, 1, NOW());

-- 3. BAGIAN (Section)
INSERT INTO public.bagian (id, kitab_id, title, order_index, created_at)
VALUES
  ('33333333-3333-3333-3333-333333333301', '22222222-2222-2222-2222-222222222201', 'Muqoddimah Kitab', 1, NOW()),
  ('33333333-3333-3333-3333-333333333302', '22222222-2222-2222-2222-222222222201', 'Fasal Pertama', 2, NOW()),
  ('33333333-3333-3333-3333-333333333303', '22222222-2222-2222-2222-222222222201', 'Fasal Kedua', 3, NOW());

-- 4. BAB (Chapter) - termasuk Muqoddimah (is_muqoddimah=true)
INSERT INTO public.bab (id, bagian_id, title, order_index, is_muqoddimah, content_arab, content_id, created_at)
VALUES
  ('44444444-4444-4444-4444-444444444401', '33333333-3333-3333-3333-333333333301', 'Muqoddimah', 1, true,
'الحمدُ للهِ ربِّ العالَمينَ، والصلاةُ والسلامُ على أشرفِ الأنبياءِ والمرسَلينَ، سيدِنا محمَّدٍ وعلى آلِهِ وصَحْبِهِ أجمعينَ.

أمَّا بعدُ، فيقولُ العبدُ الضَّعيفُ محمَّدُ بنُ أبي الوَفَاءِ: إنَّ هذا الكتابَ جُعِلَ للمبتدئينَ في صناعةِ العربيَّةِ، ليَعرِفوا أحوالَ结构的 الإعرابِ التي تردُ في القرآنِ الكريمِ والسنَّةِ النبويَّةِ.',
'Segala puji bagi Allah Tuhan seru sekalian alam. Shalawat dan salam semoga tercurah kepada Nabi Muhammad SAW, keluarganya, dan sahabatnya.

Sedang开后, ini adalah kitab yang dibuat untuk pemula dalam ilmu bahasa Arab, agar mereka mengetahui berbagai hukum ihwal ta''shif (morfologi) dan i''rab (analisis gramatikal) yang terdapat dalam Al-Quran dan Sunnah Nabi.',
NOW()),

  ('44444444-4444-4444-4444-444444444402', '33333333-3333-3333-3333-333333333302', 'Fasal 1: Af''al al-Qulub', 1, false,
'اعلَمْ أنَّ الكلِمَ ثلاثةُ: اسمٌ، وفِعلٌ، وحرفٌ.
والفعلُ ثلاثةٌ: ماضٍ، ومُضارِعٌ، وأمرٌ.
وأمَّا الفعلُ الماضي فهو ما دلَّ على حدثٍ حصلَ في الزمنِ الماضي.
مثالُهُ: كتبَ، قرَأَ، ذهبَ.',
'Ketahuilah bahwa kata dalam bahasa Arab terbagi menjadi tiga: ism (kata benda), fi''l (kata kerja), dan huruf (partikel).

Fi''l (kata kerja) terbagi menjadi tiga: madhi (lampau), mudhari'' (kini/masa depan), dan amr (perintah).

Al-fi''l al-madhi adalah kata kerja yang menunjukkan kejadian yang telah berlalu.
Contohnya: كتبَ (kataba - menulis), قرَأَ (qara''a - membaca), ذهبَ (dzahaba - pergi).',
NOW()),

  ('44444444-4444-4444-4444-444444444403', '33333333-3333-3333-3333-333333333303', 'Fasal 2: Af''al al-Qulub (lanjutan)', 1, false,
'والفعلُ المُضارِعُ هو ما دلَّ على حدثٍ يحصلُ الآنَ أو في الزمنِ المستقبلِ.
مثالُهُ: يكتُبُ، يقرَأُ، يذهَبُ.

والفعلُ الأمرِ هو ما دلَّ على طلبِ فعلِ الشيءِ.
مثالُهُ: اُكتُبْ، اِقرَأْ، اِذهَبْ.',
'Fi''l al-mudhari'' adalah kata kerja yang menunjukkan kejadian yang terjadi sekarang atau akan terjadi di masa depan.
Contohnya: يكتُبُ (yaktubu - sedang menulis / akan menulis), يقرَأُ (yaqra''u - sedang membaca), يذهَبُ (yadzhabu - sedang pergi / akan pergi).

Fi''l al-amr adalah kata kerja yang menunjukkan permintaan untuk melakukan sesuatu.
Contohnya: اُكتُبْ (uktub - tulislah!), اِقرَأْ (iqra'' - bacalah!), اِذهَبْ (idzhab - pergilah!).',
NOW());

-- 5. FASAL (Lesson)
INSERT INTO public.fasal (id, bab_id, title, order_index, content_arab, content_id, created_at)
VALUES
  ('55555555-5555-5555-5555-555555555501', '44444444-4444-4444-4444-444444444401', 'Pendahuluan', 1,
'قالَ الشَّيخُ محمَّدُ بنُ أبي الوَفَاءِ: هذا الكتابُ جُعِلَ للمبتدئينَ في صناعةِ العربيَّةِ.',
'Berkata as-Syaikh Muhammad bin Abi al-Wafa: "Kitab ini dibuat untuk pemula dalam ilmu bahasa Arab."',

'66666666-6666-6666-6666-666666666601', '44444444-4444-4444-4444-444444444402', 'Pengertian Af''al al-Qulub', 1,
'القلبُ يكونُ في موضعِ النِّحْوِ الذي هو محلُّ إعرابِ الاسمِ والفعلِ والحرفِ.',
'Hati (al-qalb) berada pada posisi Nahwu yang merupakan tempat i''rab (analisis gramatikal) kata benda, kata kerja, dan partikel.',

'66666666-6666-6666-6666-666666666602', '44444444-4444-4444-4444-444444444402', 'Hukum I''rab Af''al al-Qulub', 2,
'اعلمْ أنَّ هذه الأفعالَ التي تبدَأُ بالعينِ وتكونُ مضمومةَ العينِ في الماضي ومفتوحةَ العينِ في المضارعِ.',
'Ketahuilah bahwa kata kerja ini yang dimulai dengan huruf ''ain, dimana ''ain-nya berharakat dhammah pada fi''l madhi dan berharakat fathah pada fi''l mudhari''.',

'66666666-6666-6666-6666-666666666603', '44444444-4444-4444-4444-444444444403', 'Amalan Af''al al-Qulub', 1,
'أَمَرَنيْ زَيْدٌ بِالْقِرَاءَةِ.
زيدٌ: فاعلٌ مرفوعٌ وعلامةُ رفعِهِ الضَّمَّةُ الظَّاهرةُ.',
'َAmaraniy zaidun bil qiraa''ati.
Zaidun: fa''il (subjek), marfu'' (subjek), tandanya marfu'' adalah dhammah yang tampak.',
NOW());

-- 6. QUIZ untuk BAB Muqoddimah (bab_id = 44444444-4444-4444-4444-444444444401)
INSERT INTO public.quiz (id, bab_id, fasal_id, question, type, options, correct_answer, order_index, created_at)
VALUES
  ('77777777-7777-7777-7777-777777777701', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Apa bahasa Arab dari kata "menulis"?',
'mc',
'{"a": "قرَأَ", "b": "كتبَ", "c": "ذهبَ", "d": "جلسَ"}',
'b',
1, NOW()),

  ('77777777-7777-7777-7777-777777777702', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Berapa banyak pembagian kata dalam bahasa Arab?',
'mc',
'{"a": "Dua", "b": "Tiga", "c": "Empat", "d": "Lima"}',
'b',
2, NOW()),

  ('77777777-7777-7777-7777-777777777703', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Ketik阿拉伯文 untuk "membaca":',
'fill-arab',
NULL,
'قرَأَ',
3, NOW()),

  ('77777777-7777-7777-7777-777777777704', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'"ذهبَ" termasuk kata kerja apa?',
'mc',
'{"a": "Perintah", "b": "Sekarang", "c": "Lampau", "d": "Sedang"}',
'c',
4, NOW()),

  ('77777777-7777-7777-7777-777777777705', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Apa bahasa Arab dari "pergilah!"?',
'fill-arab',
NULL,
'اِذهَبْ',
5, NOW()),

  ('77777777-7777-7777-7777-777777777706', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Fi''l mudhari'' adalah kata kerja yang menunjukkan kejadian...',
'mc',
'{"a": "Lampau saja", "b": "Sekarang atau akan datang", "c": "Hanya perintah", "d": "Hanya kebiasaan"}',
'b',
6, NOW()),

  ('77777777-7777-7777-7777-777777777707', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Ketik bahasa Arab untuk "saya menulis":',
'fill-arab',
NULL,
'أَكْتُبُ',
7, NOW()),

  ('77777777-7777-7777-7777-777777777708', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'"اِقرَأْ" adalah contoh fi''l...',
'mc',
'{"a": "Madhi", "b": "Mudhari''", "c": "Amr", "d": "Masdar"}',
'c',
8, NOW()),

  ('77777777-7777-7777-7777-777777777709', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Apa bahasa Arab dari "sedang pergi"?',
'mc',
'{"a": "ذهبَ", "b": "يذهَبُ", "c": "اِذهَبْ", "d": "سَيَذْهَبُ"}',
'b',
9, NOW()),

  ('77777777-7777-7777-7777-777777777710', '44444444-4444-4444-4444-444444444401', '55555555-5555-5555-5555-555555555501',
'Ketik bahasa Arab untuk "duduk":',
'fill-arab',
NULL,
'جَلَسَ',
10, NOW());

-- 7. QUIZ untuk FASAL PERTAMA (bab_id = 44444444-4444-4444-4444-444444444402)
INSERT INTO public.quiz (id, bab_id, fasal_id, question, type, options, correct_answer, order_index, created_at)
VALUES
  ('77777777-7777-7777-7777-777777777711', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666601',
'"كتبَ" artinya...',
'mc',
'{"a": "Membaca", "b": "Pergi", "c": "Menulis", "d": "Duduk"}',
'c',
1, NOW()),

  ('77777777-7777-7777-7777-777777777712', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666601',
'Fi''l madhi menunjukkan kejadian yang...',
'mc',
'{"a": "Sedang terjadi", "b": "Akan terjadi", "c": "Sudah terjadi", "d": "Harus terjadi"}',
'c',
2, NOW()),

  ('77777777-7777-7777-7777-777777777713', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666602',
'Hukum i''rab fi''l madhi yang hurufnya limudhadza (dhammah قبل lam) adalah...',
'mc',
'{"a": "Fathah", "b": "Kasrah", "c": "Dhammah", "d": "Sukun"}',
'c',
3, NOW()),

  ('77777777-7777-7777-7777-777777777714', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666602',
'Ketik bentuk mudhari'' dari "kataba":',
'fill-arab',
NULL,
'يَكْتُبُ',
4, NOW()),

  ('77777777-7777-7777-7777-777777777715', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'Berapa jenis fi''l menurut zaman?',
'mc',
'{"a": "Dua", "b": "Tiga", "c": "Empat", "d": "Lima"}',
'b',
5, NOW()),

  ('77777777-7777-7777-7777-777777777716', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'" duduklah!" dalam bahasa Arab adalah...',
'fill-arab',
NULL,
'اِجْلِسْ',
6, NOW()),

  ('77777777-7777-7777-7777-777777777717', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'"يقرَأُ" adalah fi''l...',
'mc',
'{"a": "Madhi", "b": "Amr", "c": "Mudhari''", "d": "Masdar"}',
'c',
7, NOW()),

  ('77777777-7777-7777-7777-777777777718', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'Ketik fi''l amr dari "dzahaba":',
'fill-arab',
NULL,
'اِذْهَبْ',
8, NOW()),

  ('77777777-7777-7777-7777-777777777719', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'Mana yang termasuk fi''l madhi?',
'mc',
'{"a": "يكتُبُ", "b": "اُكتُبْ", "c": "كتبَ", "d": "يَكْتُبُ"}',
'c',
9, NOW()),

  ('77777777-7777-7777-7777-777777777720', '44444444-4444-4444-4444-444444444402', '66666666-6666-6666-6666-666666666603',
'Fi''l amr selalu berharakat... pada huruf pertamanya.',
'mc',
'{"a": "Fathah", "b": "Kasrah", "c": "Dhammah", "d": "Sukun"}',
'b',
10, NOW());

-- 8. QUIZ untuk FASAL KEDUA
INSERT INTO public.quiz (id, bab_id, fasal_id, question, type, options, correct_answer, order_index, created_at)
VALUES
  ('77777777-7777-7777-7777-777777777721', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'"狮" (yaskunu) artinya...',
'mc',
'{"a": "Berdiri", "b": "Tidur", "c": "Bermukim/diam", "d": "Berjalan"}',
'c',
1, NOW()),

  ('77777777-7777-7777-7777-777777777722', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Apa fi''l madhi dari "yajlisu"?',
'fill-arab',
NULL,
'جَلَسَ',
2, NOW()),

  ('77777777-7777-7777-7777-777777777723', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Af''al al-Qulub adalah kata kerja yang huruf akhirnya...',
'mc',
'{"a": "Ta ta''butsalah", "b": "Ta marbutsah", "c": "Ta marfu''ah", "d": "Nun tabi''iyah"}',
'b',
3, NOW()),

  ('77777777-7777-7777-7777-777777777724', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Ketik bentuk madhi dari "yanzuru":',
'fill-arab',
NULL,
'نَظَرَ',
4, NOW()),

  ('77777777-7777-7777-7777-777777777725', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'"Fahira" (فَهِلَ) artinya...',
'mc',
'{"a": "Mengerti", "b": "Bodoh", "c": "Bekerja", "d": "Membantu"}',
'a',
5, NOW()),

  ('77777777-7777-7777-7777-777777777726', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Dalam "اعلمْ"، huruf "اع" adalah...',
'mc',
'{"a": "Fa''il", "b": "Mudhari'' dengan alif qabd", "c": "Amr", "d": "Masdar"}',
'b',
6, NOW()),

  ('77777777-7777-7777-7777-777777777727', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Ketik fi''l madhi dari "yasmi''u" (mendengar):',
'fill-arab',
NULL,
'سَمِعَ',
7, NOW()),

  ('77777777-7777-7777-7777-777777777728', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Dhammah sebelum lam mudhara''ah menunjukkan...',
'mc',
'{"a": "Jarang terjadi", "b": "Pasti terjadi", "c": "Sedang terjadi sekarang", "d": "Akan terjadi"}',
'b',
8, NOW()),

  ('77777777-7777-7777-7777-777777777729', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'"狮" dibaca...',
'fill-arab',
NULL,
'يَسْكُنُ',
9, NOW()),

  ('77777777-7777-7777-7777-777777777730', '44444444-4444-4444-4444-444444444403', '66666666-6666-6666-6666-666666666603',
'Fi''l mudhari'' yang dhimmahnya dipindahkan ke wazan disebut...',
'mc',
'{"a": "Mu''tal", "b": "Maqbul", "c": "Mahmuz", "d": "Mujarrad"}',
'c',
10, NOW());

-- ============================================================
-- VERIFIKASI
-- ============================================================
SELECT 'Jenjang:' AS info, COUNT(*) AS jumlah FROM public.jenjang
UNION ALL
SELECT 'Kitab:', COUNT(*) FROM public.kitab
UNION ALL
SELECT 'Bagian:', COUNT(*) FROM public.bagian
UNION ALL
SELECT 'Bab:', COUNT(*) FROM public.bab
UNION ALL
SELECT 'Fasal:', COUNT(*) FROM public.fasal
UNION ALL
SELECT 'Quiz:', COUNT(*) FROM public.quiz;
