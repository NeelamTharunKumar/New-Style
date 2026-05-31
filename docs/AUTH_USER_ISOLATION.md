# Auth and User Isolation

Phase 8 adds the first real user-isolation layer.

## Why this matters

Before Phase 8, the backend trusted `user_id` from the request. That is acceptable for a local prototype but not safe for production.

Phase 8 introduces a user identity dependency and checks that authenticated users can only access their own data.

## Auth layers

Drape now has two separate protection layers:

### 1. Optional API key

Configured by:

```bash
export DRAPE_API_KEY=your-service-key
```

Clients send:

```text
X-API-Key: your-service-key
```

This is useful for environment/service protection, but it is not user identity.

### 2. User auth mode

Configured by:

```bash
export DRAPE_AUTH_MODE=...
```

Supported values:

```text
open_dev       default, no user isolation enforcement
api_key        not a user identity mode; use API key plus another user auth mode later
dev_bearer     Authorization: Bearer dev:<user_id>
static_bearer  Authorization: Bearer <token> mapped via env
firebase       reserved placeholder, not implemented yet
```

## Dev bearer mode

Useful for local testing:

```bash
export DRAPE_AUTH_MODE=dev_bearer
```

Request:

```text
Authorization: Bearer dev:alice
```

Then `alice` can access only `user_id=alice` resources.

## Static bearer mode

Useful for staging demos:

```bash
export DRAPE_AUTH_MODE=static_bearer
export DRAPE_USER_TOKENS=token-alice:alice,token-bob:bob
```

Request:

```text
Authorization: Bearer token-alice
```

This resolves to user `alice`.

## Protected resources

The backend now checks user access for:

```text
POST /users/profile
GET  /users/{user_id}/profile
POST /wardrobe/items
GET  /wardrobe/items/{user_id}
DELETE /wardrobe/items/{user_id}/{item_id}
POST /outfits/generate
POST /chat/stylist
```

For `/outfits/generate`, the backend checks:

- request `user_id`
- optional `user_profile.user_id`
- every structured `wardrobe_items[].user_id`

## Flutter build-time auth config

Flutter API client supports:

```bash
--dart-define=DRAPE_API_KEY=your-service-key
--dart-define=DRAPE_AUTH_TOKEN=dev:demo_user
```

Example:

```bash
flutter run \
  --dart-define=DRAPE_API_BASE_URL=http://localhost:8000 \
  --dart-define=DRAPE_AUTH_TOKEN=dev:demo_user
```

## Production recommendation

For a real launch, replace `dev_bearer` / `static_bearer` with one of:

- Firebase Auth token verification via Firebase Admin SDK
- Auth0 JWT verification
- Supabase Auth JWT verification
- custom OAuth/OIDC provider

`firebase` mode is currently reserved as a placeholder and returns `501 Not Implemented`.
