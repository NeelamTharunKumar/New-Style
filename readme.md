# BharatFit AI

> Privacy-first outfit intelligence for Indian wardrobes — ethnic, western, college, office, dates, weddings, Haldi, Sangeet, and daily dressing.

BharatFit AI is an India-first wardrobe assistant that recommends outfits from clothes users already own.

The core privacy principle is simple:

```text
Photos stay on the phone.
Structured features go to the backend.
Backend returns outfit item IDs + explanation.
Phone displays local wardrobe images.
```

## Why this product exists

Generic fashion apps and AI stylist apps already exist. BharatFit AI is focused on Indian wardrobe realities:

- ethnic + western wardrobe mixing
- college outfits
- Indian office outfits
- dates and daily casual looks
- wedding guest outfits
- Haldi / Sangeet / Mehendi / Reception looks
- saree + blouse combinations
- kurti + palazzo / leggings / dupatta combinations
- kurta + chinos / churidar / Nehru jacket combinations
- hot, humid, monsoon and indoor-AC dressing
- budget-conscious styling using clothes users already own
- practical men’s styling: shirts, trousers, sneakers, shoes, belts, grooming and capsule wardrobes

## Current implementation status

This repo now contains a functional backend MVP and a backend-connected Flutter MVP.

### Backend implemented

- FastAPI app that runs
- privacy-first health endpoint
- India-first taxonomy endpoint
- user style profile endpoint
- wardrobe add/list/delete endpoints
- structured-data-only outfit generation endpoint
- India/menswear/womenswear rule engine
- deterministic explanations and styling tips
- tests for core API flows

### Flutter implemented

- Backend API client
- Home dashboard with backend health check
- Style profile setup
- Manual structured wardrobe item entry
- Wardrobe list/delete flow
- Demo wardrobe seed flow
- Occasion/weather outfit generation
- Outfit cards that map returned item IDs to local image references
- Privacy-safe AI stylist chat stub
- Local-first profile/wardrobe/outfit persistence
- Privacy settings screen with export/sync/clear actions
- Optional LLM explanation adapter with strict JSON/no-photo contract
- Basic on-device wardrobe photo color extraction
- Local file image previews for wardrobe/outfit cards
- Native Kotlin/Swift ML bridge templates
- Android APK and iOS build preparation scripts
- Optional API-key auth, CORS config, SQL persistence and Docker deployment foundation
- User-auth modes and per-user backend access checks
- Flutter login screen and secure token storage
- Firebase auth verification plumbing and CI/CD workflows
- Signed Android AAB/iOS IPA release automation and app store readiness templates
- UI/UX Pro Max-inspired fashion/lifestyle visual system
- First-run onboarding, premium UI components, polished home/wardrobe/outfit UX
- Centralized branding constants, source app icon/splash assets and package/bundle patching script
- Flutter QA scripts and widget/model tests
- Privacy hardening, outfit feedback personalization, SQLite scaffold, item/outfit detail UX
- Market-launch loop: Add photo → correction chips → occasion-first outfits → feedback actions
- Local Level 2 outfit preview with mannequin/board modes before swapping
- Alembic migration scaffold and user export/delete lifecycle endpoints

- [`docs/MARKET_LAUNCH_LOOP.md`](docs/MARKET_LAUNCH_LOOP.md)
- [`docs/LOCAL_TRY_ON_PREVIEW.md`](docs/LOCAL_TRY_ON_PREVIEW.md)

## Backend quickstart

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Open API docs:

```text
http://localhost:8000/docs
```

Run tests:

```bash
cd backend
pytest
```

## Flutter quickstart

```bash
cd flutter_app
flutter pub get
flutter run
```

## Documentation

- [`docs/PROJECT_LOG.md`](docs/PROJECT_LOG.md) — running implementation log and TODO tracker
- [`docs/PRODUCT_SPEC.md`](docs/PRODUCT_SPEC.md)
- [`docs/PRODUCT_POSITIONING.md`](docs/PRODUCT_POSITIONING.md)
- [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md)
- [`docs/PRIVACY_ARCHITECTURE.md`](docs/PRIVACY_ARCHITECTURE.md)
- [`docs/API_EXAMPLES.md`](docs/API_EXAMPLES.md)
- [`docs/IMPLEMENTATION_PHASES.md`](docs/IMPLEMENTATION_PHASES.md)
- [`docs/FLUTTER_MVP.md`](docs/FLUTTER_MVP.md)
- [`docs/LOCAL_STORAGE_PRIVACY.md`](docs/LOCAL_STORAGE_PRIVACY.md)
- [`docs/LLM_EXPLANATION_LAYER.md`](docs/LLM_EXPLANATION_LAYER.md)
- [`docs/LOCAL_FEATURE_EXTRACTION.md`](docs/LOCAL_FEATURE_EXTRACTION.md)
- [`docs/NATIVE_ML_BRIDGE.md`](docs/NATIVE_ML_BRIDGE.md)
- [`docs/BUILD_RELEASES.md`](docs/BUILD_RELEASES.md)
- [`docs/PRODUCTION_HARDENING.md`](docs/PRODUCTION_HARDENING.md)
- [`docs/AUTH_USER_ISOLATION.md`](docs/AUTH_USER_ISOLATION.md)
- [`docs/LOGIN_SECURE_STORAGE.md`](docs/LOGIN_SECURE_STORAGE.md)
- [`docs/FIREBASE_AND_CICD.md`](docs/FIREBASE_AND_CICD.md)
- [`docs/SIGNED_RELEASE_AUTOMATION.md`](docs/SIGNED_RELEASE_AUTOMATION.md)
- [`docs/APP_STORE_READINESS.md`](docs/APP_STORE_READINESS.md)
- [`docs/PRODUCT_POLISH_UX.md`](docs/PRODUCT_POLISH_UX.md)
- [`docs/UI_UX_PRO_MAX_APP_DESIGN.md`](docs/UI_UX_PRO_MAX_APP_DESIGN.md)
- [`docs/FLUTTER_QA_AND_BUILD_VERIFICATION.md`](docs/FLUTTER_QA_AND_BUILD_VERIFICATION.md)
- [`docs/UPGRADE_BATCH_PRIVACY_ML_PERSONALIZATION.md`](docs/UPGRADE_BATCH_PRIVACY_ML_PERSONALIZATION.md)
- [`docs/BRANDING_AND_ASSETS.md`](docs/BRANDING_AND_ASSETS.md)
- [`docs/DATA_LIFECYCLE_AND_MIGRATIONS.md`](docs/DATA_LIFECYCLE_AND_MIGRATIONS.md)

## Example backend flow

1. Create profile.
2. Add structured wardrobe items.
3. Generate outfits for an occasion.
4. Use returned `item_ids` to display local wardrobe photos in the app.

The backend never needs the actual wardrobe photos.

## Roadmap

1. Phase 0: repo cleanup, naming, docs, positioning — completed.
2. Phase 1: functional structured-data backend MVP — completed.
3. Phase 2: Flutter functional MVP connected to backend — completed.
4. Phase 3: local storage and privacy layer — completed.
5. Phase 4: LLM explanation adapter with strict JSON/no-photo contract — completed.
6. Phase 5: basic local feature extraction — completed.
7. Phase 6: native Kotlin/Swift ML bridges and Android/iOS build scripts — completed.
8. Phase 7: Postgres/auth/deployment hardening — completed.
9. Phase 8: user auth and isolation — completed.
10. Phase 9: data lifecycle and migrations — completed.
11. Phase 10: Firebase auth and CI/CD release automation — completed.
12. Phase 11: signed Android/iOS release automation and app-store readiness — completed.
13. Phase 12: product polish and real app UX — completed.
14. Phase 13: final branding/package cleanup and app assets — completed.
15. Phase 14: Flutter QA, tests and local build verification — completed.
