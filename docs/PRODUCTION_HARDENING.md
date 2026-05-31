# Production Hardening

Phase 7 adds the first production deployment foundation for BharatFit AI.

## What is included

### Backend config

Environment-based settings live in:

```text
backend/app/core/config.py
```

Supported env vars:

```text
BHARATFIT_ENV
BHARATFIT_APP_NAME
BHARATFIT_API_KEY
BHARATFIT_CORS_ORIGINS
BHARATFIT_LOG_REQUESTS
DATABASE_URL / BHARATFIT_DATABASE_URL
```

### Optional API key guard

If `BHARATFIT_API_KEY` is set, protected endpoints require:

```text
X-API-Key: your-key
```

If `BHARATFIT_API_KEY` is unset, the backend remains open for local development.

Protected endpoints:

```text
POST /users/profile
GET  /users/{user_id}/profile
POST /wardrobe/items
GET  /wardrobe/items/{user_id}
DELETE /wardrobe/items/{user_id}/{item_id}
POST /outfits/generate
POST /chat/stylist
```

Public endpoints:

```text
GET /health
GET /taxonomy
GET /llm/status
```

### CORS

Configure origins with:

```text
BHARATFIT_CORS_ORIGINS=https://your-app.example.com,https://admin.example.com
```

Use exact origins in production. Avoid `*` for authenticated deployments.

### Persistence

The backend can now use:

- in-memory store when no `DATABASE_URL` is set
- SQLite/Postgres-compatible SQLAlchemy store when `DATABASE_URL` is set

SQLite example:

```bash
export DATABASE_URL=sqlite:///./bharatfit.db
```

Postgres example:

```bash
export DATABASE_URL=postgresql+psycopg://bharatfit:bharatfit@localhost:5432/bharatfit
```

Persistence implementation:

```text
backend/app/db/persistent_store.py
backend/app/storage_factory.py
```

### Docker

Backend Dockerfile:

```text
backend/Dockerfile
```

Compose stack with Postgres:

```text
docker-compose.yml
```

Run:

```bash
docker compose up --build
```

API:

```text
http://localhost:8000
```

Health:

```text
http://localhost:8000/health
```

## Health response

`GET /health` now includes:

```json
{
  "status": "ok",
  "environment": "production",
  "store_backend": "database",
  "auth_mode": "api_key"
}
```

## User auth and isolation

See [`AUTH_USER_ISOLATION.md`](AUTH_USER_ISOLATION.md) for Phase 8 user isolation modes.

## Security notes

This is a production foundation, not full enterprise auth.

Still needed for real launch:

- Firebase/Auth0/Supabase auth
- per-user authorization checks
- Row-level security if using Supabase/Postgres directly
- HTTPS-only deployment
- secrets manager
- request rate limiting
- audit logs
- encrypted backups

## Privacy rule remains unchanged

Even with persistence enabled, the backend stores structured wardrobe/profile features only.

Raw photos should stay on-device.
