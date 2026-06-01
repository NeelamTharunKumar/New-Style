# Data Lifecycle and Migrations

Phase 9 adds database migration scaffolding and user data lifecycle endpoints.

## Alembic migrations

Added:

```text
backend/alembic.ini
backend/alembic/env.py
backend/alembic/versions/0001_initial_schema.py
```

Run migrations from the backend directory:

```bash
cd backend
alembic upgrade head
```

The migration creates:

```text
user_profiles
wardrobe_items
```

The current app still stores profile/item payloads as JSON text for flexibility while the product schema stabilizes.

## Data export endpoint

```text
GET /users/{user_id}/export
```

Returns structured user data:

```json
{
  "user_id": "u1",
  "privacy": "No raw wardrobe/selfie images...",
  "profile": {},
  "wardrobe_items": [],
  "outfit_history": []
}
```

No image bytes are included.

## Data deletion endpoint

```text
DELETE /users/{user_id}
```

Deletes:

- user profile
- structured wardrobe items

Response:

```json
{
  "user_id": "u1",
  "deleted": true,
  "profile_deleted": true,
  "wardrobe_items_deleted": 12,
  "privacy": "No raw wardrobe/selfie images..."
}
```

## Auth behavior

Both export and delete endpoints use the Phase 8 user-isolation guard.

If auth mode resolves the current user as `alice`, then:

```text
GET /users/bob/export
DELETE /users/bob
```

return `403`.

## Remaining database work

Still recommended before real production:

- normalize key wardrobe fields into indexed columns
- add `created_at` / `updated_at` timestamps
- add Alembic migration tests in CI
- add encrypted backups
- add soft-delete / retention window if required by policy
- add outfit history persistence table
- add audit log table for deletion/export events
