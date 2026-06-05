# Architecture

## High-level design

```text
Flutter app
  ├─ stores photos locally
  ├─ extracts local wardrobe/profile features
  ├─ sends structured features only
  └─ renders outfit cards with local images

FastAPI backend
  ├─ stores user profile + structured wardrobe features
  ├─ generates and scores outfits
  ├─ returns item IDs + explanation
  └─ never requires raw photos

Future LLM adapter
  ├─ receives only structured candidate outfits
  ├─ returns JSON explanation/tips
  └─ no image input
```

## Current repo structure

```text
backend/
  app/
    main.py                 FastAPI routes
    models.py               Pydantic request/response models
    storage.py              In-memory prototype store
    storage_factory.py      Store selection (memory/database)
    core/
      auth.py               Firebase/dev user authentication
      config.py             Environment-variable settings
      firebase_auth.py      Firebase token verification
      rate_limit.py         Per-IP rate limiter
      security.py           API key guard
    db/
      persistent_store.py   Postgres/SQLAlchemy store
    services/
      outfit_engine.py      India-first outfit generation/scoring
      color_rules.py        Color and skin-tone helper rules
      llm_orchestrator.py   Optional LLM explanation layer
      personalization.py    Feedback-based personalization
      prompt_templates.py   LLM prompt templates
      taxonomy.py           Occasions/categories/style tags
  tests/
    test_api.py             Backend API tests
  alembic/
    versions/               Database migrations
  requirements.txt          Pinned Python dependencies

flutter_app/
  lib/
    main.dart               App entry point + theme
    core/
      branding.dart         Branding constants (bundle IDs, app name)
      design_tokens.dart    Theme colors, shadows, spacing
    data/
      app_models.dart       Shared Dart models
      drape_api_client.dart Backend API client
      firebase_login_service.dart  Firebase auth wrapper
      local_feature_extractor.dart On-device color analysis
      local_store.dart      SharedPreferences persistence
      secure_auth_store.dart Keychain credential store
      weather_service.dart  Open-Meteo + backend proxy weather
    state/
      app_state.dart        Central ChangeNotifier state
    presentation/
      screens/              App screens (wardrobe, outfits, etc.)
      widgets/              Shared widgets (shimmer, etc.)

scripts/
  prepare_flutter_platforms.sh   Generate android/ios folders
  build_android_apk.sh           Build debug APK
  build_android_aab_signed.sh    Build signed AAB
  build_ios_release.sh           Build iOS (no codesign)
  build_ios_ipa.sh               Build signed IPA
  verify_flutter_local.sh        Run Flutter QA locally
  verify_all_local.sh            Run backend + Flutter QA
  apply_branding.sh              Apply app name/bundle ID
  configure_android_signing.sh   Set up keystore signing
  create_ios_export_options.sh   Generate ExportOptions.plist

native_bridge/
  android/MainActivity.kt        Kotlin Bitmap color analysis
  ios/AppDelegate.swift           Swift CoreGraphics color analysis

_project_assets/
  docs/                          All project documentation
    ARCHITECTURE.md
    PRODUCT_SPEC.md
    PRODUCT_POSITIONING.md
    PRIVACY_ARCHITECTURE.md
    API_EXAMPLES.md
    ...
  legal/                         Privacy policy templates
  store_metadata/                App store descriptions
```

## Backend responsibility

The backend should handle:

- structured wardrobe item validation
- user profile validation
- outfit candidate generation
- scoring
- deterministic explanations
- future auth/database/LLM orchestration

The backend should not handle:

- raw image upload in the default flow
- selfie storage
- reconstructing images from features
- direct photo processing for the privacy-first path

## Flutter responsibility

The Flutter app should handle:

- local wardrobe photo storage
- local image references
- local feature extraction
- mapping returned item IDs to local images
- visual outfit card rendering
- user corrections to extracted features

## Native ML bridge responsibility

Future Kotlin/Swift modules should handle:

- garment detection
- local segmentation/background cleanup
- dominant color extraction
- skin-tone estimation
- body/proportion features
- local embeddings/classification

## Data flow

```text
User photo/wardrobe photo
      ↓ local only
Local extraction
      ↓ structured features
FastAPI outfit engine
      ↓ item IDs + explanation
Flutter visual card
      ↓ maps IDs to local photos
User sees outfit
```
