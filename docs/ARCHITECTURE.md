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
    services/
      outfit_engine.py      India-first outfit generation/scoring
      color_rules.py        Color and skin-tone helper rules
      taxonomy.py           Occasions/categories/style tags
  tests/
    test_api.py             Backend API tests

flutter_app/
  lib/
    main.dart
    core/di.dart            Local ML interface placeholder
    presentation/screens/   Prototype screens

docs/
  PRODUCT_SPEC.md
  PRODUCT_POSITIONING.md
  PRIVACY_ARCHITECTURE.md
  API_EXAMPLES.md
  ARCHITECTURE.md
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
