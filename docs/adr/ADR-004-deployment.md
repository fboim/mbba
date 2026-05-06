# ADR-004: Deployment Strategy

**Tanggal:** 2026-05-05
**Status:** Accepted

## Keputusan

| Komponen | Pilihan | Alasan |
|---|---|---|
| Frontend Hosting | Vercel atau Netlify | Auto deploy dari Git, CDN global, custom domain gratis, gratis tier cukup MVP |
| Backend / Database | Supabase Cloud (free tier) | Managed database, auth, storage — tanpa manage server sendiri |
| Audio Storage | Supabase Storage (1GB gratis) | Satu platform, signed URL untuk keamanan |
| CI/CD | GitHub Actions + Vercel/Netlify deploy hook | Otomatis deploy setiap push ke branch `main` |

## Struktur Deploy

```
GitHub Repository (private)
    │
    ├── push to main
    │
    ▼
GitHub Actions (optional — lint/validate)
    │
    ▼
Vercel / Netlify
    ├── Build: (kosong — pure HTML)
    ├── Output: src/frontend/
    └── Domain: mbba.vercel.app / mbba.netlify.app
```

## Konfigurasi Vercel

`vercel.json` (dibuat di root):
```json
{
  "buildCommand": "",
  "outputDirectory": "src/frontend",
  "cleanUrls": true,
  "trailingSlash": false
}
```

## Konfigurasi Netlify

`_redirects` (di `src/frontend/`):
```
/*    /index.html   200
```

`netlify.toml` (di root):
```toml
[build]
  command = ""
  publish = "src/frontend"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

## Konsekuensi Desain

- Tidak ada server-side rendering (SSR) — semua client-side
- Supabase credentials harus di-set sebagai environment variables di Vercel/Netlify
- Untuk production scale: upgrade Supabase tier, migrate storage ke Cloudflare R2

## Langkah Deployment

1. Push kode ke GitHub repository
2. Hubungkan repo ke Vercel/Netlify
3. Set environment variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`
4. Deploy — URL aktif dalam hitungan menit

## Alternatif: GitHub Pages (Ditolak)

GitHub Pages ditolak karena:
- Tidak support SPA routing redirects
- Bandwidth limit 100GB/bulan
- Tidak ada auto-deploy preview
