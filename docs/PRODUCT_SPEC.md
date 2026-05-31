# BharatFit AI Product Specification

Version: 0.2 | Phase: Product repositioning and backend MVP | Date: 2026-05-31

## One-line positioning

**BharatFit AI is a privacy-first, India-first wardrobe assistant that creates occasion-ready outfits from clothes users already own.**

## Why this positioning

Generic AI stylist apps already exist. BharatFit AI focuses on a sharper gap:

- Indian climate and occasions
- ethnic + western mix-and-match
- men's practical styling, where many fashion apps are weaker
- budget-conscious styling from the user's existing wardrobe
- privacy-first architecture where raw photos stay on-device

## Primary users

1. **Indian college students** who want daily outfit help without buying more clothes.
2. **Indian working professionals** who need office/date/travel outfit decisions.
3. **Wedding/function attendees** who need Haldi, Sangeet, Mehendi, reception and wedding guest combinations.
4. **Men seeking practical styling** for shirts, pants, shoes, sneakers, grooming and capsule wardrobes.
5. **Women mixing ethnic and western wardrobes** such as saree/blouse, kurti/palazzo, dupatta, jeans/tops and festive outfits.

## Core promise

The app should answer:

> “What should I wear for this occasion from my own wardrobe?”

And return:

- exact item IDs
- local visual outfit card using on-device images
- explanation of why it works
- climate/occasion/style reasoning
- avoid notes
- styling tips

## Privacy contract

Raw images should not be uploaded to the backend or LLM.

### Stays on-device

- wardrobe photos
- selfies/full-body photos
- local thumbnails
- raw face/body/camera data

### Can leave device

- item IDs
- semantic clothing features
- local image reference strings
- color/category/style tags
- occasion/weather/profile context

## MVP feature set

### Backend MVP

- User profile endpoint
- Wardrobe structured item CRUD
- India-first taxonomy endpoint
- Outfit generation endpoint
- Menswear and womenswear rules
- Climate-aware scoring
- Deterministic explanations

### Flutter MVP

Implemented in Phase 2:

- Style profile setup with style mode
- Manual wardrobe item entry
- Local-only photo path reference
- Wardrobe list
- Occasion selector
- Weather/context input
- Outfit result cards
- Backend API integration
- Backend health check
- Privacy-safe chat stub
- Local-first persistence for profile, wardrobe features and generated outfits
- Privacy settings screen with structured JSON export and local data deletion
- Optional LLM explanation adapter that cannot change item IDs/scores
- Basic local image picking, local copy and dominant color extraction
- Native Kotlin/Swift method-channel bridge for platform ML
- Scripts to prepare Android/iOS platform folders and build APK/iOS release
- Optional API key guard, CORS config, SQLAlchemy persistence and Docker deployment
- User auth modes and per-user data isolation checks
- Flutter login screen and secure token storage for bearer/API credentials
- Firebase auth verification plumbing and CI/CD release workflows
- Signed Android/iOS release automation, backend Cloud Run deploy workflow and app-store metadata templates
- UI/UX Pro Max-inspired Exaggerated Minimalism fashion/lifestyle visual system
- First-run onboarding, premium UI components and polished wardrobe/outfit UX
- Centralized branding, source app icon/splash assets and package/bundle ID patching
- Flutter QA scripts, model/component tests and CI test step
- Feedback-based outfit personalization, privacy hardening, SQLite scaffold and detail-page UX
- Alembic migration scaffold and privacy-safe user data export/delete endpoints

## India-first styling domains

### Occasions

- college
- office
- interview
- date
- daily casual
- travel
- wedding guest
- Haldi
- Sangeet
- Mehendi
- reception
- pooja
- festival
- family function
- monsoon day
- summer day

### Womenswear

- saree + blouse
- lehenga + dupatta
- kurti + palazzo/leggings/churidar
- kurta set
- anarkali
- ethnic jacket
- top + jeans/skirt
- dresses
- juttis/sandals/heels
- jewelry/handbag

### Menswear

- shirt + trouser/chinos/jeans
- t-shirt/polo + jeans/chinos
- kurta + churidar/dhoti/chinos
- sherwani/Nehru jacket
- sneakers/loafers/formal shoes/juttis
- watch/belt/grooming

## Recommendation engine principles

The system should not let the LLM randomly choose from the full wardrobe.

Recommended flow:

1. Deterministic engine creates candidate outfits.
2. Engine scores candidates by fit, color, occasion, climate and user preferences.
3. Top candidates are sent to LLM only as structured JSON.
4. LLM returns explanation and conversational styling tips.
5. App maps item IDs to local photos.

## Scoring dimensions

- category completeness
- occasion suitability
- formality
- color harmony
- skin-tone compatibility
- climate suitability
- style preference match
- India-context fit
- wardrobe utilization / repeat control

## Production roadmap summary

1. Phase 0: repo cleanup, naming, docs, positioning.
2. Phase 1: functional structured-data backend MVP.
3. Phase 2: Flutter functional MVP connected to backend.
4. Phase 3: local storage and privacy layer.
5. Phase 4: LLM explanation adapter with strict JSON/no-photo contract.
6. Phase 5: local feature extraction.
7. Phase 6: native Kotlin/Swift ML bridges.
8. Phase 7: Postgres/auth/deployment hardening.
