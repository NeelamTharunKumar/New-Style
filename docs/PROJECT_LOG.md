# BharatFit AI Project Log

This document is the running implementation log for the repository. It should be updated after every phase or meaningful change.

## Current status summary

| Area | Status |
|---|---|
| Product positioning | Repositioned to India-first, privacy-first wardrobe assistant |
| Backend MVP | Functional FastAPI structured-data outfit engine |
| Flutter MVP | Backend-connected functional prototype |
| Local photo storage | Local reference persistence implemented; actual image picker/file copy not yet |
| Real on-device ML | Not implemented yet; interfaces/placeholders only |
| LLM integration | Not implemented yet; backend chat is deterministic stub |
| Database/auth/deployment | Not implemented yet; backend uses in-memory store, but Flutter can now send local wardrobe statelessly |

## Core product direction

BharatFit AI is a privacy-first, India-first wardrobe assistant.

Core promise:

```text
Photos stay on phone.
Structured wardrobe/profile features go to backend.
Backend returns exact item IDs + explanations.
Phone maps item IDs to local wardrobe images.
```

Focus areas:

- Indian ethnic + western outfit mixing
- college, office, date, travel and daily casual outfits
- wedding guest, Haldi, Sangeet, Mehendi, reception, pooja and festival outfits
- saree/blouse, kurti/palazzo/dupatta, kurta/chinos/Nehru jacket combinations
- practical men’s styling: shirt-pant, sneaker/shoe, belt, grooming, capsule wardrobe
- hot/humid/monsoon/indoor-AC climate-aware styling
- budget-conscious styling from clothes the user already owns

---

# Completed work

## Initial repo review

### What was found

The original repository had a strong product idea and a useful specification, but the implementation was an early prototype rather than production-ready.

Major issues found:

- Backend import was broken.
- `main.py` imported `app.ml.graph_engine`, but actual file was `backend/app/graph_engine.py`.
- Graph engine used `networkx.all_simple_paths()` incorrectly without a target node.
- Backend had no wardrobe item add/list/delete flow.
- Backend generated outfits from an empty in-memory graph.
- Flutter app was mostly hardcoded demo UI.
- No backend API integration in Flutter.
- No local storage.
- No real ML.
- No LLM adapter.
- README overclaimed production readiness.

---

## Phase 1 — Privacy-first India wardrobe backend MVP

Commit:

```text
dcefaf7 Phase 1: privacy-first India wardrobe backend MVP
```

### What was fixed/added

#### Backend structure

Added:

```text
backend/app/__init__.py
backend/app/models.py
backend/app/storage.py
backend/app/services/color_rules.py
backend/app/services/outfit_engine.py
backend/app/services/taxonomy.py
backend/tests/conftest.py
backend/tests/test_api.py
```

Updated:

```text
backend/app/main.py
backend/app/graph_engine.py
backend/requirements.txt
readme.md
```

#### Fixed backend run failure

Original broken import:

```python
from app.ml.graph_engine import WardrobeGraphEngine
```

The backend was restructured so FastAPI now imports and runs correctly.

#### Fixed old graph engine bug

Original issue:

```python
nx.all_simple_paths(self.G, node, cutoff=3)
```

This failed because `all_simple_paths()` requires a target.

Kept a backward-compatible `WardrobeGraphEngine`, but changed generation to use graph cliques/pairs instead of broken path logic.

#### Added working API endpoints

Implemented:

```text
GET  /health
GET  /taxonomy
POST /users/profile
GET  /users/{user_id}/profile
POST /wardrobe/items
GET  /wardrobe/items/{user_id}
DELETE /wardrobe/items/{user_id}/{item_id}
POST /outfits/generate
POST /chat/stylist
```

#### Added structured data models

Added Pydantic models for:

- `UserProfile`
- `WardrobeItemCreate`
- `WardrobeItem`
- `OutfitGenerateRequest`
- `OutfitRecommendation`
- `ScoreBreakdown`
- `StylistChatRequest`
- `StylistChatResponse`

#### Added privacy-first contract

Backend now explicitly says:

```text
No raw wardrobe/selfie images are required or processed by this API; use item IDs and structured features only.
```

#### Added India-first taxonomy

Added Indian occasions:

```text
college, office, interview, date, daily casual, travel,
wedding guest, haldi, sangeet, mehendi, reception,
pooja, festival, family function, monsoon day, summer day
```

Added menswear categories:

```text
shirt, t-shirt, polo, kurta, nehru jacket, blazer,
jeans, chinos, trousers, dhoti, sherwani,
sneakers, loafers, formal shoes, sandals, juttis,
watch, belt, grooming
```

Added womenswear categories:

```text
kurti, kurta, kurta set, dupatta, palazzo, leggings,
saree, blouse, lehenga, salwar, churidar, anarkali,
ethnic jacket, top, shirt, t-shirt, jeans, skirt,
dress, heels, juttis, sandals, sneakers, handbag, jewelry
```

#### Added outfit engine

The backend can now generate and score outfits using:

- category completeness
- occasion fit
- formality fit
- color harmony
- skin-tone fit
- climate fit
- style preference fit
- India-context fit

The engine returns:

- exact `item_ids`
- title
- score
- score breakdown
- explanation
- styling tips
- avoid notes

#### Added tests

Added tests for:

- health/privacy contract
- menswear office outfit generation
- womenswear Haldi outfit generation with structured data only

Validation result:

```text
3 passed, 1 warning
```

### Phase 1 limitations

- Backend storage is in-memory only.
- No database persistence.
- No authentication.
- No real LLM integration.
- No real image/ML processing.
- Outfit rules are useful but still heuristic.

---

## Phase 0 — Product repositioning and repo cleanup

Commit:

```text
ca62bd1 Phase 0: reposition product and clean repo
```

### What was fixed/added

#### Repositioned product

Changed working product name to:

```text
BharatFit AI
```

Reason:

- Avoid overlap with existing `Style DNA` products.
- Better fit for India-first positioning.
- Clearer focus on Indian wardrobes and practical outfits.

#### Updated docs

Added:

```text
docs/PRODUCT_SPEC.md
docs/PRODUCT_POSITIONING.md
docs/ARCHITECTURE.md
docs/IMPLEMENTATION_PHASES.md
```

Updated:

```text
readme.md
CONTRIBUTING.md
License.txt
```

#### Removed/renamed legacy files

Removed:

```text
# Flutter.txt
StyleDNA_AI_Complete_Specification.md
```

Created updated spec:

```text
docs/PRODUCT_SPEC.md
```

Renamed Flutter screen:

```text
flutter_app/lib/presentation/screens/style_dna_screen.dart
```

to:

```text
flutter_app/lib/presentation/screens/style_profile_screen.dart
```

#### Updated Flutter naming

Updated visible labels from old StyleDNA wording to BharatFit/Style Profile wording.

#### Updated `.gitignore`

Added ignores for:

- Flutter build files
- Python cache files
- `.pytest_cache`
- virtual envs
- env files
- IDE files
- OS files

### Validation

Backend tests still passed:

```text
3 passed, 1 warning
```

### Phase 0 limitations

- Product name is still working name and can be changed later.
- Flutter was not yet functional at this point.

---

## Phase 2 — Flutter backend-connected MVP

Commit:

```text
c80f013 Phase 2: connect Flutter MVP to backend
```

### What was fixed/added

#### Added Flutter data models

Added:

```text
flutter_app/lib/data/app_models.dart
```

Models:

- `UserProfile`
- `WardrobeItem`
- `OutfitRecommendation`
- `ScoreBreakdown`

These mirror the backend API schema.

#### Added Flutter API client

Added:

```text
flutter_app/lib/data/bharatfit_api_client.dart
```

Supports:

```text
GET  /health
POST /users/profile
GET  /wardrobe/items/{user_id}
POST /wardrobe/items
DELETE /wardrobe/items/{user_id}/{item_id}
POST /outfits/generate
POST /chat/stylist
```

Default backend URL:

```text
http://10.0.2.2:8000
```

Useful for Android emulator.

For iOS simulator:

```text
http://localhost:8000
```

#### Added app state

Added:

```text
flutter_app/lib/state/app_state.dart
```

Manages:

- current profile
- backend base URL
- wardrobe items
- generated outfits
- loading state
- error state
- backend health
- chat calls
- demo wardrobe seed data

#### Added reusable status banner

Added:

```text
flutter_app/lib/presentation/widgets/status_banner.dart
```

Used to show:

- loading
- errors
- backend status
- success messages

#### Updated Home screen

Updated:

```text
flutter_app/lib/presentation/screens/home_dashboard.dart
```

Now includes:

- product positioning
- privacy contract card
- backend URL field
- backend health check
- navigation to profile/wardrobe/outfits/chat
- live status banner

#### Updated Style Profile screen

Updated:

```text
flutter_app/lib/presentation/screens/style_profile_screen.dart
```

Now supports saving:

- user ID
- style mode: menswear/womenswear/mixed
- skin tone
- body shape
- climate
- region
- preferences
- budget-conscious preference

Sends to:

```text
POST /users/profile
```

#### Updated Wardrobe screen

Updated:

```text
flutter_app/lib/presentation/screens/wardrobe_screen.dart
```

Now supports:

- load wardrobe from backend
- add manual structured wardrobe item
- delete wardrobe item
- add demo set
- show local image reference

Manual item fields:

- item ID
- name
- style mode
- category
- subcategory
- color
- hex color
- pattern
- fabric
- fit
- formality
- style tags
- occasion tags
- climate tags
- local image reference

Important privacy behavior:

```text
Only local image reference strings are sent.
Actual image bytes are not sent.
```

#### Updated Outfit screen

Updated:

```text
flutter_app/lib/presentation/screens/your_outfits_screen.dart
```

Now supports:

- occasion selection
- weather/context input
- backend outfit generation
- result cards
- exact item ID mapping
- score display
- score breakdown chips
- explanation
- styling tips
- avoid notes

#### Updated Chat screen

Updated:

```text
flutter_app/lib/presentation/screens/ai_stylist_chat.dart
```

Now calls backend chat stub:

```text
POST /chat/stylist
```

Real LLM comes later.

#### Added Flutter MVP docs

Added:

```text
docs/FLUTTER_MVP.md
```

Covers:

- run instructions
- backend URL setup
- MVP user flow
- privacy behavior

#### Updated Flutter dependency

Added:

```yaml
http: ^1.2.2
```

### Validation

Backend tests still passed:

```text
3 passed, 1 warning
```

Flutter SDK was not available in the environment, so these still need to be run locally:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter run
```

### Phase 2 limitations

- Backend storage is still in-memory.
- No real image picker.
- No local image database for actual image files yet.
- No real on-device ML extraction.
- Outfit visual card uses color swatches/local refs, not actual local photos yet.
- Chat is backend stub, not LLM.

---

## Phase 3 — Local storage and privacy layer

Commit:

```text
84873e9 Phase 3: add local-first privacy storage
```

### What was fixed/added

#### Added local persistence

Added:

```text
flutter_app/lib/data/local_store.dart
```

The Flutter app now persists locally using `shared_preferences`:

- user style profile
- structured wardrobe items
- generated outfit results
- backend API base URL

This means the app no longer loses the user's wardrobe/profile when restarted.

#### Added local image reference helper

Added:

```text
flutter_app/lib/data/local_image_service.dart
```

It standardizes local-only references such as:

```text
local://wardrobe/shirt_001.jpg
```

Actual image picking/copying is still future work.

#### Made Flutter local-first

Updated:

```text
flutter_app/lib/state/app_state.dart
```

The app now:

- hydrates profile/wardrobe/outfits from local storage on startup
- saves profile locally before trying backend sync
- saves wardrobe locally before trying backend sync
- deletes wardrobe locally even if backend is unavailable
- saves generated outfits locally
- exports local structured data as JSON
- clears saved outfits or all local data
- syncs structured data to backend on demand

#### Made outfit generation stateless/local-wardrobe aware

Updated backend request model:

```text
backend/app/models.py
backend/app/main.py
```

`POST /outfits/generate` now accepts optional `user_profile` in the request.

The Flutter app now sends:

- local structured `user_profile`
- local structured `wardrobe_items`
- occasion/weather context

This avoids relying on backend in-memory wardrobe/profile state. Backend restart no longer destroys the app's ability to generate outfits, as long as the app has local data.

#### Added privacy settings screen

Added:

```text
flutter_app/lib/presentation/screens/privacy_settings_screen.dart
```

It supports:

- local data summary
- sync structured data to backend
- export local structured data JSON
- clear saved outfit results
- clear all local profile/wardrobe/outfit data

#### Updated Home screen

Updated:

```text
flutter_app/lib/presentation/screens/home_dashboard.dart
```

Home now hydrates local data on startup and includes navigation to Privacy & Local Data.

#### Updated API client

Updated:

```text
flutter_app/lib/data/bharatfit_api_client.dart
```

`generateOutfits()` now sends local structured wardrobe/profile data in the request.

#### Added docs

Added:

```text
docs/LOCAL_STORAGE_PRIVACY.md
```

Updated:

```text
readme.md
docs/PRODUCT_SPEC.md
docs/IMPLEMENTATION_PHASES.md
```

#### Added dependency

Added:

```yaml
shared_preferences: ^2.3.2
```

### Validation

Backend validation passed:

```text
python3 -m py_compile backend/app/*.py backend/app/services/*.py
cd backend && pytest -q
3 passed, 1 warning
```

Flutter SDK is not installed in this environment, so local validation is still needed:

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter run
```

### Phase 3 limitations

- Uses `shared_preferences`, which is acceptable for MVP but not ideal for large wardrobes.
- Actual image picker/file-copy flow is not implemented yet.
- Local data is not encrypted at rest yet.
- No conflict resolution between local data and backend data.
- Backend still uses in-memory storage.
- No Flutter automated tests yet.

---

# Known issues / technical debt

## Backend

1. **In-memory storage only**
   - Data disappears when backend restarts.
   - Need Postgres/SQLite depending next phase.

2. **No auth/user isolation**
   - Current `user_id` is trusted from request.
   - Need Firebase/JWT or other auth.

3. **Rules are heuristic**
   - Good for MVP, but need refinement with real user feedback.

4. **No LLM adapter yet**
   - Explanations are deterministic templates.
   - Need strict JSON LLM adapter later.

5. **No weather API integration**
   - Weather is manually sent by app.

6. **No production deployment config**
   - Need Dockerfile, env config, logging, CORS policy, rate limiting.

## Flutter

1. **MVP local persistence only**
   - `shared_preferences` stores structured data locally.
   - Need Hive/Isar/Drift/SQLite for large wardrobes.

2. **No real local image storage yet**
   - `local_image_ref` is a string only.
   - Need image picker and local file storage.

3. **No actual local feature extraction**
   - Current phase uses manual structured fields.
   - Need dominant color extraction, category classifier, etc.

4. **No Flutter local tests yet**
   - Need widget/model/API tests.

5. **Need local Flutter validation**
   - Environment here does not have Flutter SDK.
   - Run `flutter analyze` locally.

## Product

1. **Working name may change**
   - `BharatFit AI` is a working name, not final branding.

2. **Need user testing**
   - Test if users understand manual wardrobe entry.
   - Test whether India-first occasions feel accurate.

3. **Need stronger gender/style inclusivity choices**
   - Current modes: menswear, womenswear, mixed.
   - Later should support style expression without forcing gender identity.

---

# Next recommended work

## Phase 4 — LLM explanation adapter

Goal:

Add LLM support only for explanations, not raw outfit generation.

### Rules

- No raw photos to LLM.
- LLM receives top candidate outfits as structured JSON.
- LLM returns strict JSON.
- Rule-based explanation remains fallback.

### Files likely to add

```text
backend/app/services/llm_orchestrator.py
backend/app/services/prompt_templates.py
backend/app/models.py
backend/tests/test_llm_contract.py
```

---

## Phase 5 — Basic local feature extraction

Goal:

Reduce manual wardrobe entry.

### Start simple

- dominant color extraction
- manual correction UI
- basic category suggestions
- basic skin-tone field from local profile flow

### Later

- TFLite/CoreML classifier
- MediaPipe/Pose/Vision
- segmentation/background removal

---

# Run commands

## Backend

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

API docs:

```text
http://localhost:8000/docs
```

Tests:

```bash
cd backend
pytest
```

## Flutter

```bash
cd flutter_app
flutter pub get
flutter analyze
flutter run
```

Android emulator backend URL:

```text
http://10.0.2.2:8000
```

iOS simulator backend URL:

```text
http://localhost:8000
```

---

# Update policy for this file

After every meaningful change, update this document with:

1. commit hash/title
2. what was fixed
3. what was added
4. validation performed
5. limitations remaining
6. next recommended work
