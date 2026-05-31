# Flutter QA and Local Build Verification

Phase 14 adds Flutter test coverage and local verification scripts.

## Local verification command

Run from repo root:

```bash
./scripts/verify_flutter_local.sh
```

This runs:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter test
flutter build apk --debug
```

You can set the backend URL:

```bash
DRAPE_API_BASE_URL=https://api.yourdomain.com ./scripts/verify_flutter_local.sh
```

## Full local verification

```bash
./scripts/verify_all_local.sh
```

This runs backend checks first, then Flutter checks if Flutter SDK is installed.

## Flutter tests added

```text
flutter_app/test/app_models_test.dart
flutter_app/test/branding_test.dart
flutter_app/test/components_test.dart
```

Coverage includes:

- wardrobe model JSON roundtrip
- tag normalization
- brand constants
- privacy badge rendering
- brand mark smoke render
- empty state rendering

## Manual app QA checklist

After `flutter run`, verify:

- [ ] onboarding appears on first launch
- [ ] onboarding can be skipped/completed
- [ ] dashboard loads after onboarding
- [ ] backend URL can be saved
- [ ] health check works
- [ ] login screen saves dev bearer token
- [ ] style profile can be saved
- [ ] demo wardrobe can be added
- [ ] local photo picker opens from Add Item
- [ ] extracted color populates the item form
- [ ] outfit generation returns cards
- [ ] local images appear in wardrobe/outfit cards
- [ ] privacy screen exports structured JSON
- [ ] logout clears secure token

## Device size QA

Test at minimum:

- Android emulator: Pixel 5/6 dimensions
- small width: 360-375px
- tablet-ish width: 768px
- iPhone simulator if on macOS

## Known limitation

Flutter SDK is not available in this agent environment, so Flutter tests/analyze/build must be run locally or in CI.
