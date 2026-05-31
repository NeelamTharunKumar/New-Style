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

Next recommended phase.

Scope:

- Flutter platform channel
- Android Kotlin TFLite/MediaPipe module
- iOS Swift CoreML/Vision module

## Phase 7 — Production hardening

Scope:

- Postgres
- auth
- migrations
- deployment
- CI
- logging
- rate limiting
