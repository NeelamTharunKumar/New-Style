# Drape AI

> **Privacy-first, India-first wardrobe assistant that creates visual outfits from clothes users already own.**

Drape AI helps users answer:

```text
What should I wear today?
```

The product is designed for Indian wardrobes and occasions: college, office, dates, travel, festivals, pooja, Haldi, Sangeet, Mehendi, reception and wedding guest looks.

---

## Core privacy promise

```text
Photos stay on the phone.
Local ML extracts structured clothing features.
Only item IDs, categories, colors, tags and context go to the backend.
Backend returns outfit item IDs + explanations.
The phone displays local wardrobe images and local previews.
```

Raw wardrobe photos, selfies, face images and body images are not required by the backend or LLM.

---

## Market-launch loop

The app is now organized around the consumer loop that matters:

```text
Add photo
→ local color extraction
→ 1-tap category/color/occasion correction chips
→ save wardrobe item
→ pick occasion
→ get visual outfits
→ preview look locally
→ wear/save/swap/reject
```

### Occasion-first home

Home asks:

```text
What are you dressing for?
[College] [Office] [Date] [Haldi] [Sangeet] [Wedding] [Casual] [Travel]
```

### Outfit result format

```text
Office-ready look

[Blue shirt] [Charcoal trousers] [Brown loafers]

Why it works:
Clean blue-charcoal contrast, breathable cotton for warm weather, brown loafers make it polished.

Actions:
[Preview Look] [Wear today] [Save] [Swap item] [Not my style]
```

### Local Level 2 try-on preview

Drape includes a privacy-safe **Preview Look** feature:

- mannequin-style local preview
- board/lookbook preview
- category-to-body-slot placement
- local item photos only
- no image upload
- no LLM image generation

This is intentionally positioned as a local outfit preview, not a body-accurate virtual try-on.

---

## Why this product exists

Generic fashion apps and AI stylist apps already exist. Drape focuses on Indian wardrobe realities:

- ethnic + western wardrobe mixing
- college and office dressing
- dates and daily casual looks
- Haldi / Sangeet / Mehendi / Reception / wedding guest outfits
- saree + blouse combinations
- kurti + palazzo / leggings / dupatta combinations
- kurta + chinos / churidar / Nehru jacket combinations
- hot, humid, monsoon and indoor-AC dressing
- budget-conscious styling using clothes users already own
- practical men’s styling: shirts, trousers, sneakers, loafers, belts, watches, grooming and capsule wardrobes

---

## Current implementation status

This repo contains a backend MVP, a backend-connected Flutter MVP, local-first privacy scaffolding, release automation, and market-launch UX loops.

### Backend implemented

- FastAPI backend
- India-first taxonomy
- user profile endpoints
- wardrobe CRUD endpoints
- outfit generation endpoint
- outfit feedback/history endpoints
- user data export/delete endpoints
- optional API key guard
- user auth/isolation modes
- Firebase token verification plumbing
- SQLAlchemy persistence with SQLite/Postgres support
- Alembic migrations
- rate limiting and security headers
- privacy-safe audit events
- optional LLM explanation layer with no-photo contract
- LLM cache and per-user daily limit
- feedback-based outfit personalization
- Docker and Cloud Run deployment scaffolding
- backend test suite

### Flutter implemented

- UI/UX Pro Max-inspired fashion/lifestyle visual system
- **Full Dark Mode and Theme support** (`DrapeColors` system)
- **AppShell with Bottom Navigation** for intuitive core flows
- **Branded animated Splash Screen** with hydrating state
- first-run onboarding
- occasion-first home
- photo-first wardrobe add flow
- local photo copy and dominant color extraction
- 1-tap category/color/occasion correction chips
- local-first profile/wardrobe/outfit persistence
- secure token storage
- login screen for dev/static/Firebase auth flows
- style profile setup
- wardrobe grid with **safety deletion dialogs**
- wardrobe item detail page
- outfit generation screen
- outfit detail page
- local mannequin/board outfit preview
- wear/save/swap/reject feedback actions
- privacy and local data screen
- local structured data export
- **Upgraded AI Stylist Chat UI** with avatars and animated typing indicators
- native Kotlin/Swift ML bridge templates
- Android/iOS build scripts
- signed release automation scaffolding
- app branding constants and source assets
- Flutter widget/model tests and verification scripts

---

## Important limitations

This is not fully market-launched yet. Remaining work before public release:

- run Flutter locally and fix analyzer/build issues
- run real device QA
- replace placeholder Firebase config with `flutterfire configure`
- add real Google/Apple/email sign-in if needed
- move local app state fully from SharedPreferences to SQLite/encrypted storage
- add true garment segmentation/classification models
- improve recommendation rules with beta feedback
- generate final app icon, adaptive icon, splash and screenshots
- configure real Android/iOS signing secrets
- deploy backend with real Postgres/Firebase credentials
- legal review of privacy policy and terms

---

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

Run backend tests:

```bash
cd backend
pytest
```

Run migrations:

```bash
cd backend
alembic upgrade head
```

---

## Flutter quickstart

```bash
cd flutter_app
flutter pub get
flutter run
```

Full local Flutter verification:

```bash
./scripts/verify_flutter_local.sh
```

Full backend + Flutter verification:

```bash
./scripts/verify_all_local.sh
```

> Flutter SDK is not available in the agent sandbox, so Flutter analyze/build must be run locally or in CI.

---

## Build Android and iOS versions

Prepare generated platform folders and native bridge:

```bash
./scripts/prepare_flutter_platforms.sh
```

Build Android APK:

```bash
./scripts/build_android_apk.sh
```

Build signed Android AAB:

```bash
./scripts/build_android_aab_signed.sh
```

Build iOS release without codesign:

```bash
./scripts/build_ios_release.sh
```

Build signed/exported iOS IPA on macOS:

```bash
./scripts/build_ios_ipa.sh
```

---

## Key documentation

### Product and architecture

- [`_project_assets/docs/PRODUCT_SPEC.md`](_project_assets/docs/PRODUCT_SPEC.md)
- [`_project_assets/docs/PRODUCT_POSITIONING.md`](_project_assets/docs/PRODUCT_POSITIONING.md)
- [`_project_assets/docs/ARCHITECTURE.md`](_project_assets/docs/ARCHITECTURE.md)
- [`_project_assets/docs/IMPLEMENTATION_PHASES.md`](_project_assets/docs/IMPLEMENTATION_PHASES.md)
- [`_project_assets/docs/MARKET_LAUNCH_LOOP.md`](_project_assets/docs/MARKET_LAUNCH_LOOP.md)

### Privacy and AI

- [`_project_assets/docs/PRIVACY_ARCHITECTURE.md`](_project_assets/docs/PRIVACY_ARCHITECTURE.md)
- [`_project_assets/docs/LOCAL_STORAGE_PRIVACY.md`](_project_assets/docs/LOCAL_STORAGE_PRIVACY.md)
- [`_project_assets/docs/LOCAL_FEATURE_EXTRACTION.md`](_project_assets/docs/LOCAL_FEATURE_EXTRACTION.md)
- [`_project_assets/docs/LOCAL_TRY_ON_PREVIEW.md`](_project_assets/docs/LOCAL_TRY_ON_PREVIEW.md)
- [`_project_assets/docs/LLM_EXPLANATION_LAYER.md`](_project_assets/docs/LLM_EXPLANATION_LAYER.md)

### Backend, auth and deployment

- [`_project_assets/docs/API_EXAMPLES.md`](_project_assets/docs/API_EXAMPLES.md)
- [`_project_assets/docs/PRODUCTION_HARDENING.md`](_project_assets/docs/PRODUCTION_HARDENING.md)
- [`_project_assets/docs/AUTH_USER_ISOLATION.md`](_project_assets/docs/AUTH_USER_ISOLATION.md)
- [`_project_assets/docs/LOGIN_SECURE_STORAGE.md`](_project_assets/docs/LOGIN_SECURE_STORAGE.md)
- [`_project_assets/docs/DATA_LIFECYCLE_AND_MIGRATIONS.md`](_project_assets/docs/DATA_LIFECYCLE_AND_MIGRATIONS.md)
- [`_project_assets/docs/FIREBASE_AND_CICD.md`](_project_assets/docs/FIREBASE_AND_CICD.md)
- [`_project_assets/docs/BUILD_RELEASES.md`](_project_assets/docs/BUILD_RELEASES.md)
- [`_project_assets/docs/SIGNED_RELEASE_AUTOMATION.md`](_project_assets/docs/SIGNED_RELEASE_AUTOMATION.md)

### UI/UX, release and assets

- [`_project_assets/docs/UI_UX_PRO_MAX_APP_DESIGN.md`](_project_assets/docs/UI_UX_PRO_MAX_APP_DESIGN.md)
- [`_project_assets/docs/PRODUCT_POLISH_UX.md`](_project_assets/docs/PRODUCT_POLISH_UX.md)
- [`_project_assets/docs/BRANDING_AND_ASSETS.md`](_project_assets/docs/BRANDING_AND_ASSETS.md)
- [`_project_assets/docs/FLUTTER_QA_AND_BUILD_VERIFICATION.md`](_project_assets/docs/FLUTTER_QA_AND_BUILD_VERIFICATION.md)
- [`_project_assets/docs/APP_STORE_READINESS.md`](_project_assets/docs/APP_STORE_READINESS.md)

### Upgrade notes

- [`_project_assets/docs/UPGRADE_BATCH_PRIVACY_ML_PERSONALIZATION.md`](_project_assets/docs/UPGRADE_BATCH_PRIVACY_ML_PERSONALIZATION.md)
- [`_project_assets/docs/UPGRADE_BATCH_2_SECURITY_PERSONALIZATION.md`](_project_assets/docs/UPGRADE_BATCH_2_SECURITY_PERSONALIZATION.md)
- [`_project_assets/docs/PHASE_15_21_COMPLETION.md`](_project_assets/docs/PHASE_15_21_COMPLETION.md)

> `_project_assets/docs/PROJECT_LOG.md` is intentionally ignored by git and kept as a local running implementation log.

---

## Roadmap status

Completed foundation phases:

```text
Phase 0–14: completed
Phase 15–21 batch: partially implemented/scaffolded
Market-launch loop: implemented
Local Level 2 outfit preview: implemented
```

Next highest-priority work:

```text
1. Configure real Firebase with FlutterFire.
2. Complete SQLite/encrypted local storage migration.
3. Add real garment classifier/segmentation model.
4. Beta test with 10–20 Indian users.
5. Improve recommendation quality from feedback.
6. Finalize store assets and deployment credentials.
```
