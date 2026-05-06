-- ============================================================
-- MBBA — Tambah UNIQUE Constraints (sebelum seed data)
-- Jalankan ini TERLEBIH DAHULU sebelum seed_data.sql
-- ============================================================

-- 1. Pastikan bagian.order_index UNIQUE (seharusnya sudah ada)
ALTER TABLE public.bagian ADD CONSTRAINT bagian_order_index_key UNIQUE (order_index);

-- 2. Tambah UNIQUE composite constraint untuk bab
ALTER TABLE public.bab ADD CONSTRAINT bab_bagian_order_idx UNIQUE (bagian_id, order_index);

-- 3. Tambah UNIQUE composite constraint untuk fasal
ALTER TABLE public.fasal ADD CONSTRAINT fasal_bab_order_idx UNIQUE (bab_id, order_index);

-- 4. Tambah UNIQUE composite constraint untuk quiz
ALTER TABLE public.quiz ADD CONSTRAINT quiz_fasal_order_idx UNIQUE (fasal_id, order_index);
