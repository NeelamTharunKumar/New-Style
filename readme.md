# India-First Wardrobe AI

> Privacy-first outfit intelligence for Indian wardrobes — ethnic, western, college, office, dates, weddings, Haldi, Sangeet, and daily dressing.

This repository is being converted from an early prototype into a functional foundation for an India-first AI wardrobe assistant.

## Core product promise

Users upload their wardrobe photos locally. The app extracts structured features on-device and sends only those features to the backend.

The backend recommends exact outfit item IDs and explains why the combination works. The app displays the real clothing photos locally.

```text
Photos stay on phone.
Structured features go to backend.
Backend returns outfit item IDs + explanation.
Phone displays local images.
```

## India-first focus

The product is optimized for Indian dressing contexts:

- ethnic + western wardrobe mixing
- college outfits
- office outfits
- dates
- wedding guest looks
- Haldi / Sangeet / Mehendi / Reception
- saree + blouse matching
- kurti + palazzo / leggings / dupatta combinations
- kurta + chinos / churidar / Nehru jacket combinations
- hot, humid, monsoon and indoor-AC dressing
- budget-conscious styling using clothes users already own
- skin-tone/color recommendations for Indian complexions

## Men’s styling focus

The engine includes practical menswear rules:

- shirt + trouser combinations
- shirt + pant contrast
- sneakers/shoes matching
- belt/shoe matching guidance
- college, office, date and wedding looks
- kurta / sherwani / Nehru jacket styling
- grooming tips
- capsule wardrobe direction

## Current implementation status

### Backend

Implemented in this phase:

- FastAPI app that runs
- privacy-first health endpoint
- India-first taxonomy endpoint
- user style profile endpoint
- wardrobe add/list/delete endpoints
- structured-data-only outfit generation endpoint
- rule-based India/menswear/womenswear outfit engine
- deterministic explanations and styling tips
- tests for core API flows

### Flutter app

The Flutter app is still an early UI prototype. Next phases will connect it to the backend and add local storage/privacy-preserving image handling.

## Run backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Docs:

```text
http://localhost:8000/docs
```

## Run tests

```bash
cd backend
pytest
```

## Privacy architecture

See [`docs/PRIVACY_ARCHITECTURE.md`](docs/PRIVACY_ARCHITECTURE.md).

## API examples

See [`docs/API_EXAMPLES.md`](docs/API_EXAMPLES.md).

## Flutter app

```bash
cd flutter_app
flutter pub get
flutter run
```

## Roadmap

1. Backend functional MVP — in progress/completed for structured data.
2. Flutter functional MVP with local wardrobe storage.
3. LLM explanation layer with strict JSON and no-photo contract.
4. Basic local feature extraction.
5. Native Kotlin/Swift ML bridge for on-device garment/body feature extraction.
6. Postgres/auth/deployment production hardening.
