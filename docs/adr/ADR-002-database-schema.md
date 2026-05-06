# ADR-002: Database Schema Design

**Tanggal:** 2026-05-05
**Status:** Accepted

## Keputusan Desain

### Prinsip
1. **Linear Hierarchy** — Data mengikuti hierarki ketat: Bagian → Bab → Fasal → Quiz
2. **User Progress sebagai single source of truth** — Lock/unlock ditentukan oleh status di tabel ini
3. **Soft relationships via UUID** — Tidak pakai foreign key constraints di Supabase (RLS policy yang fleksibel lebih penting)
4. **JSONB untuk options kuis** — Fleksibel untuk format soal yang mungkin berubah di masa depan

### Tabel: `users`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
email           text UNIQUE NOT NULL
full_name       text
role            text CHECK (role IN ('student', 'teacher', 'admin'))
created_at     timestamptz DEFAULT now()
updated_at     timestamptz DEFAULT now()
```

### Tabel: `bagian`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
order_index    integer UNIQUE NOT NULL
title           text NOT NULL
description     text
is_active       boolean DEFAULT true
created_at     timestamptz DEFAULT now()
```

### Tabel: `bab`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
bagian_id       uuid REFERENCES bagian(id) ON DELETE CASCADE
order_index    integer NOT NULL
title           text NOT NULL
is_muqoddimah  boolean DEFAULT false
is_locked      boolean DEFAULT true
created_at     timestamptz DEFAULT now()
```

### Tabel: `fasal`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
bab_id          uuid REFERENCES bab(id) ON DELETE CASCADE
order_index    integer NOT NULL
title           text NOT NULL
content_arab    text NOT NULL
content_id      text NOT NULL
audio_url       text
is_locked      boolean DEFAULT true
created_at     timestamptz DEFAULT now()
```

### Tabel: `quiz`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
fasal_id        uuid REFERENCES fasal(id) ON DELETE CASCADE
type            text DEFAULT 'mc' CHECK (type IN ('mc','fill-arab','fill-latin'))
order_index    integer NOT NULL
question        text NOT NULL
options         jsonb              -- hanya untuk type='mc'
correct_answer  text NOT NULL       -- "A"/"B"/"C"/"D" untuk mc, teks Arab/Latin untuk fill-*
placeholder     text               -- untuk fill-arab / fill-latin
passing_threshold integer DEFAULT 100
```

### Tabel: `user_progress`
```
id              uuid PRIMARY KEY DEFAULT gen_random_uuid()
user_id         uuid REFERENCES users(id) ON DELETE CASCADE
fasal_id        uuid REFERENCES fasal(id) ON DELETE CASCADE
status          text DEFAULT 'locked'
                CHECK (status IN ('locked','unlocked','in_progress','completed'))
quiz_score      integer
quiz_attempts   integer DEFAULT 0
started_at     timestamptz
completed_at   timestamptz
created_at     timestamptz DEFAULT now()
updated_at     timestamptz DEFAULT now()

UNIQUE (user_id, fasal_id)
```

## Row Level Security (RLS)

- **Student** → hanya bisa baca & update progress miliknya sendiri
- **Teacher** → bisa baca semua progress, bisa insert/update materi
- **Admin** → full access

## Konsekuensi Desain

- Tidak ada hard delete (CASCADE) untuk konten — history tetap terjaga jika perlu undo
- `order_index` sebagai primary sort key — bukan `created_at` (karena urutan kurikulum tidak selalu kronologis)
- `is_locked` di tabel `bab` dan `fasal` sebagai fallback flag — lock real-time ditentukan oleh `user_progress`
