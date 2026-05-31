# Firebase Auth and CI/CD Release Automation

This phase adds Firebase auth plumbing plus CI/CD workflows.

## Backend Firebase auth

Set:

```bash
export DRAPE_AUTH_MODE=firebase
export FIREBASE_PROJECT_ID=your-firebase-project-id
export GOOGLE_APPLICATION_CREDENTIALS=/secure/path/service-account.json
```

Then protected requests must send:

```text
Authorization: Bearer <firebase-id-token>
```

The backend verifies the token with Firebase Admin SDK and uses the Firebase `uid` for user isolation.

## Flutter Firebase login

Added:

```text
flutter_app/lib/firebase_options.dart
flutter_app/lib/data/firebase_login_service.dart
```

`firebase_options.dart` is a placeholder. Replace it using FlutterFire CLI:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

The current login screen supports Firebase anonymous sign-in as the first provider path. Future work can add Google/Apple/email providers.

## Secure storage

Firebase ID tokens are stored through the existing secure token store:

```text
flutter_app/lib/data/secure_auth_store.dart
```

Requests include:

```text
Authorization: Bearer <firebase-id-token>
```

## CI workflows

Added:

```text
.github/workflows/backend-ci.yml
.github/workflows/docker-ci.yml
.github/workflows/flutter-ci.yml
.github/workflows/android-release.yml
.github/workflows/ios-release.yml
```

### Backend CI

Runs:

- dependency install
- Python compile check
- pytest
- Alembic migration smoke test

### Docker CI

Builds backend Docker image.

### Flutter CI

Runs:

- platform preparation
- flutter analyze
- debug Android APK build smoke test

### Android release artifact

Manual workflow:

```text
Android Release Artifact
```

Builds release APK and uploads it as a GitHub artifact.

### iOS release build

Manual workflow:

```text
iOS Release Build
```

Runs on macOS and builds iOS without codesigning. Real TestFlight/App Store release still requires Apple signing setup.

## Remaining work

- Add Google Sign-In and Apple Sign-In providers.
- Add email/password or passwordless login if desired.
- Add Firebase config secrets to CI if building real signed apps.
- Add Android keystore signing in GitHub Actions.
- Add iOS certificate/provisioning profile automation.
- Add backend deployment workflow to Render/Fly.io/Cloud Run.
