# ADR-003: Quiz Logic

**Tanggal:** 2026-05-05
**Status:** Accepted

## Keputusan: Hybrid + Random Bank Quiz

```
Bank Soal (30-50 soal per Fasal)
         │
         ▼
  Ambil 10 soal random (acak)
         │
         ▼
┌──────────────────────────────────┐
│ Student mengerjakan + submit       │
│                                    │
│ Jika 100% benar → unlock next      │
│ Jika < 100%       → ulangi (acak)  │
└──────────────────────────────────┘
       │
       ▼
Teacher bisa override via Supabase Dashboard
```

## Aturan Quiz (MVP)

| Parameter | Nilai |
|---|---|
| Bank soal per Fasal | 30-50 soal |
| Soal diujikan per sesi | 10 soal (acak dari bank) |
| Jenis soal | **Pilihan ganda** + **Isian Huruf Arab/Latin** |
| Passing threshold | **100%** (harus semua benar) |
| Max retry | Unlimited (soal diacak ulang setiap kali) |
| Display hasil | Instant (langsung setelah submit) |
| Teacher override | Ya (manual via Supabase Dashboard) |

## Jenis Soal

### 1. Pilihan Ganda (Multiple Choice)
```
Tipe: "mc"
Opsi: A, B, C, D (text)
Correct: "A" / "B" / "C" / "D"
```

### 2. Isian Arab (Arabic Fill-in)
```
Tipe: "fill-arab"
Placeholder: "____"
Correct: "مُسْتَقِيمٌ"
Student ketik harakat Arabic pakai keyboard/virtual
```

### 3. Isian Latin (Latin Fill-in)
```
Tipe: "fill-latin"
Placeholder: "____"
Correct: "mustaqim"
Student ketik huruf Latin biasa
```

## Struktur Data Soal (JSONB di Supabase)

```json
{
  "id": "quiz-001",
  "fasal_id": "fasal-001",
  "order_index": 1,
  "question": "Apa arti مُسْتَقِيمٌ?",
  "type": "mc",
  "options": [
    { "key": "A", "value": "Luas" },
    { "key": "B", "value": "Berjalan tegak" },
    { "key": "C", "value": "Tinggi" },
    { "key": "D", "value": "Baik" }
  ],
  "correct_answer": "B",
  "passing_threshold": 100
}
```

```json
{
  "id": "quiz-010",
  "fasal_id": "fasal-001",
  "order_index": 10,
  "question": "Lengkapkan: هَذَا الضَّبْعُ ____",
  "type": "fill-arab",
  "placeholder": "____",
  "correct_answer": "مُسْتَقِيمٌ",
  "passing_threshold": 100
}
```

## Alasan Pembagian Soal

| Pertimbangan | Keputusan |
|---|---|
| Pemahaman mendalam | Bank besar → setiap retry dapat soal berbeda → tidak hafal jawaban |
| Validasi pemahaman | Campuran MC + isian → student harus benar-benar paham, tidak sekadar memilih |
| Fairsi & variasi | Random 10 dari 30-50 → setiap attempt unik, mengurangi cheat |
| Effort fair | 10 soal tidak terlalu banyak untuk dijawab, tapi cukup untuk evaluasi |

## Konsekuensi Desain

- Frontend harus bisa render 3 tipe soal yang berbeda
- Input isian Arab butuh virtual keyboard Arabic atau input field khusus
- Scoring: per-soal, bukan per-total-score
- Retry: fetch 10 soal baru secara random dari bank
- Teacher input soal: cukup ketik di Supabase Dashboard (sudah JSONB)
