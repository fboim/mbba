# ADR-005: Seed Data Strategy

**Tanggal:** 2026-05-05
**Status:** Accepted

## Keputusan: JSON Manual Import via Supabase Dashboard

Teacher/Admin menginput data via Supabase Dashboard dengan format JSON:

```
Supabase Dashboard
    │
    ├── Table Editor → Import via JSON
    │   ├── bagian.json   (3 records)
    │   ├── bab.json      (3 records)
    │   ├── fasal.json    (3 records)
    │   └── quiz.json     (6 records)
    │
    └── Storage          → Upload file audio MP3
                            (max 2MB per file)
```

## Alasan

| Pertimbangan | Keputusan |
|---|---|
| Skill Teacher/Admin | Tidak perlu tahu SQL — cukup copy-paste JSON |
| Repeatability | File JSON reusable, bisa di-commit ke git |
| Flexibility | Admin bisa edit langsung di Dashboard setelah import |
| Dev workflow | Dev bisa pakai JSON seed tanpa akses Supabase project |

## Langkah Import (untuk Teacher/Admin)

1. Buka **Supabase Dashboard → Table Editor**
2. Pilih tabel `bagian` → klik **Import** → upload `bagian.json`
3. Ulangi untuk `bab`, `fasal`, `quiz` (urutan harus respeta: bagian → bab → fasal → quiz)
4. Buka **Storage** → buat bucket `audio` → upload file MP3
5. Copy public URL audio → paste ke field `audio_url` di tabel `fasal`

## Urutan Import (Wajib)

```
1. bagian.json   (parent)
2. bab.json      (reference: bagian_id)
3. fasal.json    (reference: bab_id)
4. quiz.json     (reference: fasal_id)
```

## Catatan Penting

- Pastikan UUID di `bab.bagian_id` konsisten dengan UUID di `bagian`
- Pastikan `bab.order_index` dimulai dari 1 per Bagian
- Semua `is_locked` di-set `true` KECUALI `bab-001` dan `fasal-001`
