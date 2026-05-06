# ADR-006: API Contract

**Tanggal:** 2026-05-05
**Status:** Accepted

## Base URL

```
https://[PROJECT-REF].supabase.co/rest/v1/
```

## Authentication

Semua request memerlukan header:
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [JWT_TOKEN]
```

## Endpoints

### Auth

| Method | Endpoint | Body | Response |
|---|---|---|---|
| POST | `/auth/v1/signup` | `{ email, password, options }` | `{ user, session }` |
| POST | `/auth/v1/token?grant_type=password` | `{ email, password }` | `{ access_token, refresh_token }` |
| POST | `/auth/v1/logout` | — | `204 No Content` |
| GET | `/auth/v1/user` | — | `{ id, email, user_metadata }` |

### Kurikulum (READ)

| Method | Endpoint | Query Params | Response |
|---|---|---|---|
| GET | `/bagian` | `select=*,bab(*,fasal(*,quiz(*)))` | Array Bagian + nested |
| GET | `/bab` | `bagian_id=uuid` | Array Bab |
| GET | `/fasal` | `bab_id=uuid` | Array Fasal |
| GET | `/fasal?id=uuid` | — | Single Fasal |
| GET | `/quiz` | `fasal_id=uuid` | Array Quiz |

### Progress

| Method | Endpoint | Body | Response |
|---|---|---|---|
| GET | `/progress_view?user_id=eq.uuid` | — | Array Progress |
| POST | `/user_progress` | `{ user_id, fasal_id, status }` | Created record |
| PATCH | `/user_progress?id=eq.uuid` | `{ quiz_score, status }` | Updated record |

### Admin (Teacher)

| Method | Endpoint | Body | Response |
|---|---|---|---|
| POST | `/fasal` | Fasal object | Created |
| PUT | `/fasal?id=eq.uuid` | Fasal object | Updated |
| POST | `/quiz` | Quiz object | Created |

## Row Level Security (RLS)

```sql
-- student: hanya bisa baca/modif progress sendiri
CREATE POLICY "student_progress" ON user_progress
  FOR ALL USING (auth.uid() = user_id);

-- teacher/admin: full access via service_role key
-- (service_role key tidak boleh di-expose ke frontend)
```

## Error Format

```json
{
  "message": "Not found",
  "details": null,
  "hint": null,
  "code": "PGRST116"
}
```

## Rate Limiting

Supabase free tier: ~60 req/min. MVP aman.
