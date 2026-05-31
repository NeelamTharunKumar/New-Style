# Signed Release Automation

Phase 11 adds signed Android/iOS release automation and app-store readiness docs.

## Android signed release

### Required GitHub secrets

```text
ANDROID_KEYSTORE_BASE64
ANDROID_KEYSTORE_PASSWORD
ANDROID_KEY_ALIAS
ANDROID_KEY_PASSWORD
ANDROID_PACKAGE_NAME
GOOGLE_PLAY_SERVICE_ACCOUNT_JSON   optional for Play upload
```

Create base64 keystore value:

```bash
base64 -w 0 upload-keystore.jks
```

### Local signed AAB build

```bash
export BHARATFIT_API_BASE_URL=https://api.yourdomain.com
export ANDROID_KEYSTORE_BASE64=...
export ANDROID_KEYSTORE_PASSWORD=...
export ANDROID_KEY_ALIAS=...
export ANDROID_KEY_PASSWORD=...
./scripts/build_android_aab_signed.sh
```

Output:

```text
flutter_app/build/app/outputs/bundle/release/app-release.aab
```

### GitHub Actions

Manual workflow:

```text
Android Signed Release
```

It builds a signed AAB, uploads it as an artifact, and can upload a draft to Google Play if Play secrets are configured.

## iOS TestFlight release

### Required GitHub secrets

```text
IOS_CERTIFICATE_P12_BASE64
IOS_CERTIFICATE_PASSWORD
IOS_PROVISIONING_PROFILE_BASE64
IOS_PROVISIONING_PROFILE_NAME
IOS_BUNDLE_ID
APPLE_TEAM_ID
KEYCHAIN_PASSWORD
APP_STORE_CONNECT_API_KEY_ID           optional for TestFlight upload
APP_STORE_CONNECT_ISSUER_ID            optional for TestFlight upload
APP_STORE_CONNECT_API_KEY_BASE64       optional for TestFlight upload
```

### Local IPA build

Requires macOS + Xcode.

```bash
export BHARATFIT_API_BASE_URL=https://api.yourdomain.com
export APPLE_TEAM_ID=...
export IOS_BUNDLE_ID=com.yourcompany.bharatfit
export IOS_PROVISIONING_PROFILE_NAME="Your Profile Name"
./scripts/build_ios_ipa.sh
```

Output:

```text
flutter_app/build/ios/ipa/*.ipa
```

### GitHub Actions

Manual workflow:

```text
iOS TestFlight Release
```

It imports certificate/profile, builds an IPA, uploads it as an artifact, and can upload to TestFlight if App Store Connect API secrets are set.

## Backend deployment

Manual workflow:

```text
Backend Deploy to Cloud Run
```

Required secrets:

```text
GCP_SERVICE_ACCOUNT_KEY
GCP_PROJECT_ID
DATABASE_URL
BHARATFIT_API_KEY
FIREBASE_PROJECT_ID
```

This workflow builds the backend Docker image, pushes it to Artifact Registry, and deploys to Cloud Run.

## Important warnings

- Never commit keystores, certificates, provisioning profiles, or service account JSON.
- Use GitHub Actions secrets or your CI provider's secret store.
- Rotate secrets if accidentally exposed.
- For iOS, ensure bundle ID and provisioning profile match.
- For Android, keep the upload keystore backed up securely.
