# Phases 15–21 Completion Notes

This batch implements practical scaffolding and improvements for the requested phases.

## Phase 15 — Flutter analyzer/build fix pass

Added:

- Flutter component/model tests
- local verification scripts
- CI `flutter test` step
- removed stale unused wardrobe widgets

Still needs local execution with Flutter SDK:

```bash
./scripts/verify_flutter_local.sh
```

## Phase 16 — Real Firebase provider setup

Added earlier and extended:

- Firebase backend token verification
- Flutter Firebase anonymous sign-in plumbing
- secure token storage

Still needed:

- run `flutterfire configure`
- configure real Firebase Android/iOS apps
- add Google/Apple/email providers if desired

## Phase 17 — Real local ML upgrade

Added:

```text
flutter_app/lib/data/ml_feature_schema.dart
```

Improved local feature metadata with:

- schema version
- category hints
- occasion hints
- privacy metadata

Native bridge remains ready for TFLite/CoreML upgrades.

## Phase 18 — Outfit engine v2

Added outfit feedback/history APIs:

```text
POST /outfits/feedback
GET  /outfits/history/{user_id}
```

This enables future learning from:

- worn outfits
- favorite outfits
- rejected outfits
- ratings
- notes

## Phase 19 — Local database upgrade

Added SQLite store scaffold:

```text
flutter_app/lib/data/local_database_store.dart
```

The current app still uses the stable SharedPreferences store. The SQLite store is prepared for the next migration after Flutter QA.

## Phase 20 — Privacy/security hardening

Added backend:

- simple IP-based rate limiting
- security headers
- additional privacy-safe lifecycle coverage

Config:

```text
BHARATFIT_RATE_LIMIT_PER_MINUTE=120
BHARATFIT_SECURITY_HEADERS=true
```

## Phase 21 — App store production assets

Added generated placeholder PNG assets:

```text
flutter_app/assets/app_icons/generated/
flutter_app/assets/screenshots/placeholders/
```

These are placeholders and should be replaced by final professional exports before store submission.
