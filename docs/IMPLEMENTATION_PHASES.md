# Implementation Phases

## Phase 0 — Repo stabilization and product repositioning

Status: completed in this commit.

Scope:

- remove legacy/confusing artifacts
- reposition product as India-first and privacy-first
- avoid `StyleDNA` branding overlap
- document architecture and privacy contract
- align README with actual implementation status
- keep backend and Flutter naming consistent

## Phase 1 — Functional backend MVP

Status: completed in previous commit.

Scope:

- FastAPI backend runs
- profile endpoint
- wardrobe structured item endpoints
- outfit generation endpoint
- India/menswear/womenswear rule engine
- tests

## Phase 2 — Flutter functional MVP

Status: completed in this commit.

Scope:

- API client
- wardrobe item form
- local item ID/image reference model
- occasion selector
- outfit result cards
- privacy copy in UI

## Phase 3 — Local storage/privacy layer

Status: completed in this commit.

Scope:

- local DB
- local photo paths
- delete/export data
- optional cloud sync design

## Phase 4 — LLM explanation layer

Status: completed in this commit.

Scope:

- strict JSON prompt templates
- no-photo LLM adapter
- fallback explanations

## Phase 5 — Local feature extraction

Status: completed in this commit.

Scope:

- dominant color extraction
- manual correction UI
- skin-tone prototype

## Phase 6 — Native Kotlin/Swift ML bridge

Status: completed in this commit.

Scope:

- Flutter platform channel
- Android Kotlin TFLite/MediaPipe module
- iOS Swift CoreML/Vision module

## Phase 7 — Production hardening

Status: completed in this commit.

Scope:

- Postgres
- auth
- migrations
- deployment
- CI
- logging
- rate limiting


## Phase 8 — User auth and isolation

Status: completed in this commit.

Scope:

- user identity dependency
- dev bearer mode for local testing
- static bearer mode for staging/demo
- per-user access checks for profile, wardrobe, outfits and chat
- Flutter API client support for API key and bearer token dart-defines
- auth/user-isolation tests


## Phase 9 — Data lifecycle and migrations

Status: completed in this commit.

Scope:

- Alembic migration scaffold
- initial SQL schema migration
- user data export endpoint
- user data deletion endpoint
- store-level export/delete methods
- auth-protected lifecycle tests


## Phase 9B — Login and secure token storage

Status: completed in this commit.

Scope:

- Flutter secure token storage
- login/logout screen
- backend auth session endpoint
- API client secure credential hydration
- dev/static bearer login flows


## Phase 10 — Firebase auth and CI/CD release automation

Status: completed in this commit.

Scope:

- backend Firebase ID token verification
- Flutter Firebase anonymous login plumbing
- secure token reuse for Firebase ID tokens
- backend/session validation
- GitHub Actions backend CI
- Docker build CI
- Flutter analyze/build CI
- manual Android release artifact workflow
- manual iOS no-codesign release workflow


## Phase 11 — Signed release automation and app-store readiness

Status: completed in this commit.

Scope:

- signed Android AAB build script
- iOS IPA export script
- Android signed release GitHub workflow
- iOS TestFlight GitHub workflow
- backend Cloud Run deploy workflow
- privacy policy template
- app store metadata drafts
- release readiness checklist


## Phase 12 — Product polish and real app UX

Status: completed in this commit.

Scope:

- first-run onboarding gate
- premium shared UI components
- polished home dashboard
- wardrobe grid cards and empty state
- outfit card/empty state polish
- local onboarding completion persistence


## Phase 13 — Final branding/package cleanup and app assets

Status: completed in this commit.

Scope:

- centralized brand constants
- in-app brand mark widget
- source SVG icon/splash assets
- Android/iOS package/bundle patching script
- docs for final branding and asset export
