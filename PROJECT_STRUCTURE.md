# MBBA — Struktur Proyek

```
mbba/
├── docs/
│   ├── adr/
│   │   ├── ADR-001-tech-stack.md       ✅ Tech stack + alternatif + roadmap
│   │   ├── ADR-002-database-schema.md  ✅ 6 tabel + relasi + RLS
│   │   ├── ADR-003-quiz-logic.md      ✅ Hybrid quiz + 100% threshold + 3 tipe soal
│   │   ├── ADR-004-deployment.md      ✅ Vercel/Netlify + konfigurasi
│   │   ├── ADR-005-seed-data.md       ✅ JSON import via Dashboard
│   │   ├── ADR-006-api-contract.md    ✅ 17 endpoint REST API
│   │   └── ADR-007-roadmap.md         ✅ Scale-up path + migration trigger
│   │
│   └── SUPABASE_SETUP.md              ✅ Panduan lengkap setup Supabase
│
├── src/
│   └── frontend/
│       ├── pages/
│       │   ├── index.html             ✅ Landing page
│       │   ├── auth.html             ✅ Login + Register (Supabase Auth)
│       │   └── fasal.html             ✅ Halaman belajar lengkap
│       └── js/
│           ├── api.js               ✅ Supabase REST API integration
│           └── quiz.js             ✅ Modular quiz logic (3 tipe soal)
│
└── src/backend/
    └── supabase/seed/
        ├── bagian.json              ✅ 3 Bagian (Mukhtarat)
        ├── bab.json                 ✅ 3 Bab (Bagian 1)
        ├── fasal.json               ✅ 3 Fasal (Bagian 1)
        └── quiz.json                ✅ 30+ soal (mc + fill-arab + fill-latin)
```

## Status MVP — SELESAI ✅

| Komponen | Status | Lokasi |
|---|---|---|
| Landing Page | ✅ Selesai | `src/frontend/pages/index.html` |
| Auth Page | ✅ Selesai | `src/frontend/pages/auth.html` |
| Fasal Page | ✅ Selesai | `src/frontend/pages/fasal.html` |
| API Integration | ✅ Selesai | `src/frontend/js/api.js` |
| Quiz Logic | ✅ Selesai | `src/frontend/js/quiz.js` |
| Seed Data | ✅ Selesai | `src/backend/supabase/seed/` |
| SQL Schema | ✅ Selesai | `docs/SUPABASE_SETUP.md` |
| ADR Documentation | ✅ 7/7 | `docs/adr/` |

## Langkah Selanjutnya (Setup Supabase)

1. Buat project Supabase → ikuti `docs/SUPABASE_SETUP.md`
2. Jalankan SQL schema di SQL Editor
3. Import seed data JSON (urutan: bagian → bab → fasal → quiz)
4. Buat `.env` dari `.env.example`
5. Deploy `src/frontend/` ke Vercel/Netlify
