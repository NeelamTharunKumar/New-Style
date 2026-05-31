# Upgrade Batch: Privacy, ML, Personalization, Local DB and UX Details

This batch implements practical upgrades across the areas requested after Phase 14.

## Privacy hardening

Added:

```text
backend/app/core/rate_limit.py
```

Backend now supports:

```text
DRAPE_RATE_LIMIT_PER_MINUTE=120
DRAPE_SECURITY_HEADERS=true
```

Security headers are added by middleware:

- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `Referrer-Policy: no-referrer`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`

Flutter local image deletion was also improved:

```text
flutter_app/lib/data/local_image_service.dart
flutter_app/lib/state/app_state.dart
```

Deleting a wardrobe item now attempts to delete the copied local image file too.

## Local ML upgrades

Added:

```text
flutter_app/lib/data/ml_feature_schema.dart
```

Local extraction metadata now includes:

- schema version
- category hint
- occasion hints
- privacy metadata

The native bridge remains ready for future TFLite/CoreML upgrades.

## Outfit engine personalization

Added:

```text
backend/app/services/personalization.py
backend/tests/test_personalization.py
```

The backend now uses outfit feedback to rerank generated outfits before optional LLM explanation.

Signals used:

- favorites boost
- rejections penalize
- high/low ratings adjust score
- worn looks receive repeat-control penalty
- partial item overlap affects related recommendations

## Feedback/history API

Added:

```text
POST /outfits/feedback
GET  /outfits/history/{user_id}
```

This is the foundation for personalized recommendation learning.

## SQLite local DB migration scaffold

Added:

```text
flutter_app/lib/data/local_database_store.dart
```

It defines SQLite tables for:

- wardrobe items
- outfit history

The app still uses the stable shared-preferences store until Flutter QA is run locally.

## Wardrobe/outfit UX detail pages

Added:

```text
flutter_app/lib/presentation/screens/outfit_detail_screen.dart
flutter_app/lib/presentation/screens/wardrobe_item_detail_screen.dart
```

Outfit detail supports:

- full item grid
- explanation
- score
- tips/avoid notes
- rating
- favorite
- mark worn
- reject/not-my-style feedback

Wardrobe detail supports:

- larger local image preview
- structured item attributes
- local feature summary
- delete item and local image action

## App store assets

Added placeholder generated assets:

```text
flutter_app/assets/app_icons/generated/
flutter_app/assets/screenshots/placeholders/
```

These are not final art; they exist to unblock release-pipeline and metadata work.

## Validation

Backend tests pass:

```text
15 passed, 1 warning
```

Flutter must still be validated locally:

```bash
./scripts/verify_flutter_local.sh
```
