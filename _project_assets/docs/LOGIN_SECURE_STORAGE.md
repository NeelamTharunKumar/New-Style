# Login and Secure Token Storage

This phase adds a Flutter login/token-storage layer on top of the backend auth modes from Phase 8.

## What was added

### Secure token storage

Added:

```text
flutter_app/lib/data/secure_auth_store.dart
```

Uses:

```yaml
flutter_secure_storage
```

Stored securely on-device:

- API key
- bearer auth token
- auth mode
- user ID

### Login screen

Added:

```text
flutter_app/lib/presentation/screens/login_screen.dart
```

The screen supports:

- dev bearer login: generates `dev:<user_id>`
- static bearer login: user pastes a token
- optional API key storage
- logout / clear secure tokens

### Backend session endpoint

Added:

```text
GET /auth/session
```

Returns:

```json
{
  "authenticated": true,
  "auth_mode": "dev_bearer",
  "user_id": "demo_user",
  "api_key_required": false
}
```

The Flutter app calls this after saving credentials to validate the session.

## Local dev flow

Backend:

```bash
export DRAPE_AUTH_MODE=dev_bearer
cd backend
uvicorn app.main:app --reload
```

Flutter:

1. Open app.
2. Open `Login & Secure Tokens`.
3. Choose `Dev bearer`.
4. Enter user ID, e.g. `demo_user`.
5. Save login securely.

Requests now include:

```text
Authorization: Bearer dev:demo_user
```

## Static bearer staging flow

Backend:

```bash
export DRAPE_AUTH_MODE=static_bearer
export DRAPE_USER_TOKENS=token-demo:demo_user
```

Flutter:

1. Open login screen.
2. Choose `Static bearer token`.
3. User ID: `demo_user`.
4. Token: `token-demo`.
5. Save.

## API key flow

If backend also has:

```bash
export DRAPE_API_KEY=service-secret
```

Enter `service-secret` in the API key field.

Requests include both:

```text
X-API-Key: service-secret
Authorization: Bearer dev:demo_user
```

## Production note

This is not yet real consumer identity like Google/Apple/email login. It is the secure-token storage and session plumbing needed before adding a provider.

For production, replace dev/static tokens with:

- Firebase Auth
- Auth0
- Supabase Auth
- custom OIDC

The Flutter secure storage layer can still be reused to store provider tokens/session info.
