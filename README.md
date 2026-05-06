# MBBA — Madrasah Belajar Bahasa Arab

```
Belajar nahwu dan shorof menggunakan Kitab Mukhtarat
```

## Struktur Proyek

```
mbba/
├── docs/
│   ├── adr/                              # Architecture Decision Records
│   │   ├── ADR-001-tech-stack.md          ✅ Tech stack
│   │   ├── ADR-002-database-schema.md     ✅ Skema 6 tabel
│   │   ├── ADR-003-quiz-logic.md          ✅ Hybrid quiz + 100% threshold
│   │   ├── ADR-004-deployment.md          ✅ Vercel/Netlify
│   │   ├── ADR-005-seed-data.md           ✅ JSON import
│   │   ├── ADR-006-api-contract.md         ✅ 17 endpoint
│   │   └── ADR-007-roadmap.md             ✅ Scale-up path
│   │
│   └── SUPABASE_SETUP.md                  ✅ Panduan setup lengkap
│
├── src/
│   └── frontend/
│       ├── pages/
│       │   ├── index.html                 ✅ Landing page
│       │   ├── auth.html                  ✅ Login + Register
│       │   └── fasal.html                 ✅ Halaman belajar
│       └── js/
│           ├── api.js                     ✅ Supabase REST API integration
│           └── quiz.js                    ✅ Modular quiz logic
│
├── src/backend/supabase/seed/
│   ├── bagian.json                       ✅ 3 Bagian
│   ├── bab.json                          ✅ 3 Bab
│   ├── fasal.json                        ✅ 3 Fasal
│   └── quiz.json                         ✅ 30+ soal (3 tipe)
│
├── .env.example
└── docs/adr/ADR-007-roadmap.md
```

## Status MVP — SELESAI ✅

| Komponen | Status | Catatan |
|---|---|---|
| ADR Documentation | ✅ 7/7 | |
| Landing Page | ✅ Selesai | `index.html` |
| Auth Page | ✅ Selesai | Login + Register |
| Fasal Page | ✅ Selesai | Materi + kuis + audio |
| API Integration | ✅ Selesai | `api.js` — Supabase REST |
| Quiz Logic | ✅ Selesai | Random 10/30, 3 tipe soal, 100% threshold |
| Seed Data | ✅ Selesai | 3 Bagian, 3 Bab, 3 Fasal, 30+ soal |
| SQL Schema | ✅ Selesai | Ada di `SUPABASE_SETUP.md` |

## Cara Menjalankan (Local)

Tanpa Supabase (dummy data):
```
Buka: src/frontend/pages/fasal.html
```

Dengan Supabase:
1. Buat project di [supabase.com](https://supabase.com)
2. Ikuti `docs/SUPABASE_SETUP.md`
3. Buat `.env` dari `.env.example`
4. Import seed data JSON
5. Deploy: `src/frontend/` ke Vercel/Netlify

## Tech Stack

| Layer | Teknologi |
|---|---|
| Frontend | HTML5 + Tailwind CSS (CDN) |
| Backend + Auth | Supabase (PostgreSQL + Auth + Storage) |
| Hosting | Vercel / Netlify |
| Docs | ADR |

## Fitur MVP

- Teks Arab berharakat (Amiri font, RTL)
- Audio player HTML5 native
- Kuis 3 tipe: Pilihan Ganda + Isian Arab + Isian Latin
- Bank 30 soal → 10 acak per sesi
- Threshold 100% (harus semua benar)
- Linear progression (lock/unlock)
- Sidebar navigasi kurikulum
- Progress bar
- Login + Register via Supabase Auth
