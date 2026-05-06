-- ============================================================
-- MBBA — STEP 2: Insert bagian + bab + fasal
-- (Jalankan SETELAH step1_delete_reset.sql)
-- ============================================================

INSERT INTO public.bagian (id, order_index, title, description, is_active) VALUES
(gen_random_uuid(), 1, 'Al-Qawa''id al-Muta''alliqah bi al-Jumlah', 'Qaidah-qaidah nahwu yang berkaitan dengan kalimat.', true),
(gen_random_uuid(), 2, 'Ash-Sharf al-Mukhtasar', 'Shorof dasar yang berkaitan dengan fi''il.', true),
(gen_random_uuid(), 3, 'Al-I''rab al-Musharrar', 'Penjabaran i''rab secara terperinci.', true);

INSERT INTO public.bab (id, bagian_id, order_index, title, is_muqoddimah, is_locked) VALUES
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 1, 'Muqoddimah', true, false),
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 2, 'Ad-Dafridu wa Ats-Tsauliy', false, true),
(gen_random_uuid(), (SELECT id FROM public.bagian WHERE order_index = 1), 3, 'Al-Ismu wal-Kalimatu wal-''Alfadhu', false, true);

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
 NULL, true);

SELECT 'STEP 2 DONE: bagian=' || count(*) FROM public.bagian
UNION ALL SELECT 'bab=' FROM public.bab
UNION ALL SELECT 'fasal=' FROM public.fasal;
