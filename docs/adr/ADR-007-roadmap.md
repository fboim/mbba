# ADR-007: Future Roadmap

**Tanggal:** 2026-05-05
**Status:** Planning

## Scale-Up Path

### Fase 1 — MVP (SAAT INI ✅)
- HTML5 + Tailwind CDN
- Supabase (DB + Auth + Storage)
- Dummy data lokal (JSON)
- Linear progression (lock/unlock)
- Quiz instant result

### Fase 2 — Integrasi Supabase (Next Step)
```
TODO:
[x] ADR + Schema         — done
[x] HTML Template        — done
[x] Seed Data JSON       — done
[ ] api.js               — Supabase JS SDK integration
[ ] Auth flow            — Login/Register UI
[ ] Real progress save   — user_progress table write
[ ] Real kurikulum fetch — replace DUMMY_KURIKULUM
```

### Fase 3 — Android App
```
TODO:
[ ] WebView wrapper (Kotlin/Java)
[ ] Offline cache   — Service Worker
[ ] Push notification — FCM
[ ] Deep link ke fasal tertentu
[ ] Biometric login
```

### Fase 4 — Fitur Lanjutan
```
TODO:
[ ] Streak / habit tracker
[ ] Leaderboard
[ ] Premium subscription (Stripe)
[ ] Analytics dashboard (Teacher)
[ ] AI tutor / chatbot (future)
[ ] Multi-language UI (ID/EN/AR)
```

## Migration Triggers

| Kondisi | Tindakan |
|---|---|
| Storage > 1GB | Migrate ke Cloudflare R2 |
| Concurrent user > 50 | Upgrade Supabase tier / self-host |
| Audio streaming lambat | Pakai Supabase signed URL + CDN |
| Butuh custom auth logic | Migrate ke NextAuth.js / Clerk |
