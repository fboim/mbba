# ADR-001: Tech Stack Decision

**Tanggal:** 2026-05-05
**Status:** Accepted

## Keputusan

| Layer | Pilihan | Alasan |
|---|---|---|
| Frontend | HTML5 + Tailwind CSS (CDN) | Ringan, cocok untuk Android WebView, tanpa build tool |
| Backend + CMS | Supabase (PostgreSQL + Auth + Storage + REST API) | Free tier cukup MVP, Admin Dashboard built-in, Auth bawaan |
| Admin Panel | Supabase Dashboard | Teacher/Admin input materi tanpa skill teknis |
| Font Arab | Amiri + Noto Naskh Arabic fallback | Kompatibilitas browser luas |
| Penyimpanan Audio | Supabase Storage (1GB gratis) | Satu platform dengan DB, simplifikasi |

## Alternatif yang Dippertimbangkan

- **Directus (Self-hosted):** Lebih fleksibel tapi perlu manage server sendiri — ditolak untuk MVP karena menambah kompleksitas operasi.
- **Strapi:** Powerful tapi berat untuk VPS kecil — ditolak, Supabase lebih lightweight untuk fase ini.

## Konsekuensi

- **Terikat vendor Supabase** — jika Supabase mengubah pricing, migration akan butuh effort.
- **Batas free tier** — 1GB storage dan 50 concurrent user cukup untuk MVP; perlu di-upgrade jika scaling melewati itu.

## Roadmap Upgrade

Ketika proyek mature dan kebutuhan meningkat, target migrasi:
- Storage → Cloudflare R2 atau AWS S3
- Hosting → Self-hosted Supabase atau Railway
