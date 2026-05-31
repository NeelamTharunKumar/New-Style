StyleDNA AI - Production-Ready Startup Specification
Version: 1.0 | Date: 2026-05-31 | Team: Senior PM, Principal UI/UX, Staff Flutter, Senior AI/ML, Staff Backend, Solutions Architect

1. Complete Product Requirements Document (PRD)
Vision
StyleDNA AI is the definitive AI fashion OS for personal style. Unlike Essembl/Whering/Acloset (which rely on catalog matching or basic tagging), StyleDNA delivers hyper-personalized, wardrobe-native outfit generation using on-device feature extraction (MediaPipe/YOLO/CLIP) + minimal LLM orchestration (features only, never raw images) for privacy, speed, and cost-efficiency.

Target Users
18-45 urban professionals/students who own 30-200 clothing items and want daily outfit intelligence.
Core Differentiator: "Your Outfits"
100% wardrobe-constrained generation with explainability.
On-device CLIP embeddings + local graph algorithm → LLM only receives JSON feature vectors for final narrative.
Functional Requirements (Detailed)
Style DNA Analysis

On-device: MediaPipe FaceMesh + Pose + Selfie segmentation.
Extract: skin tone (LAB values), face shape (landmarks), body type (ratios), hair (segmentation).
Local inference → send 128-dim vector + metadata to backend for LLM report (no image upload).
Color Analysis

Local: Dominant color extraction (k-means on segmented garment) + seasonal mapping rules.
Generate palettes, avoid lists, combinations (pre-computed rules + LLM narrative only).
Your Wardrobe

Upload → on-device YOLOv8n + SAM for item detection/crop.
Local feature vector (CLIP 512-dim) + attributes → store in Postgres + S3 metadata only.
No raw images sent to LLM ever.
Your Outfits (USP)

Local graph: items as nodes, compatibility edges (color harmony, occasion rules, style vectors).
Generate combinations via DFS + scoring (no LLM for combos).
LLM receives only top-5 scored JSON feature sets for "why it works" explanation.
5-11. All other features follow same principle: local ML first, feature JSON to LLM.

Non-Functional
<2s outfit generation (local graph).
Privacy: 95% processing on-device.
Offline capable for core wardrobe/outfits.
2. User Journey
Splash → Onboarding (selfie + 5 wardrobe items) → StyleDNA report (instant local).
Daily: Home dashboard shows 3 recommended outfits (local engine).
Your Outfits: Select occasion → instant local combos + LLM why.
AI Chat: Text only, context = user feature profile.
Calendar/Insights: Usage tracking.
3. Detailed UI/UX Design
Design Language: Premium minimalism (Apple + Linear + Notion).

Glassmorphism cards with subtle blur.
Dark mode primary (#0A0A0A bg, #FFFFFF text), Light mode secondary.
Typography: SF Pro / Inter 400/600, 17-34pt.
Animations: 200-300ms spring (Hero-like).
Screens (detailed):
Home Dashboard: Top nav glass, 3 outfit cards (hero image local render), quick actions.
Your Outfits: Horizontal scroll occasions, grid of generated outfits (local thumbnails).
AI Chat: Clean chat with pill suggestions, context chips (StyleDNA summary).
All screens use bottom nav + floating AI button.
4. Design System
Colors: Primary #6366F1, Accent #22C55E, Neutral #111113.
Components: GlassCard, OutfitTile, DNAReportSection, AnimatedFAB.
Icons: Tabler (outline + filled).
Motion: Shared element transitions for outfit views.
5. Database Schema (PostgreSQL)
SQL

users (id, firebase_uid, style_dna_vector JSONB, color_profile JSONB, created_at)
wardrobe_items (id, user_id, clip_embedding VECTOR(512), category, color, pattern, material, style, season, occasion, s3_key, local_features JSONB)
outfit_combinations (id, user_id, item_ids INT[], score FLOAT, occasion, generated_at)
outfit_history (id, user_id, outfit_id, worn_date, rating)
Use pgvector for embeddings.
6. API Documentation (FastAPI)
Endpoints (feature-only):

POST /analyze/style-dna (receive local MediaPipe vector)
POST /wardrobe/add (receive local YOLO+CLIP vector)
POST /outfits/generate (receive occasion + user_id → local graph → LLM narrative)
GET /recommend/daily
POST /chat (text + context features)
All return JSON; images via presigned S3.
7. AI Architecture (Minimal LLM)
On-Device Layer: MediaPipe (face/body), YOLOv8n-seg (garments), CLIP (embeddings), local k-means color.
Backend Orchestration: FastAPI + Redis cache.
LLM Calls (minimal): Only for narrative (GPT-4o-mini or Gemini Flash). Input = structured JSON features + rules. Never raw images.
Fallback: Pure rule-based scoring.
8. Recommendation Engine Design
Hybrid: Local graph (NetworkX-like in Python) + cosine similarity on embeddings.
Scoring: color_harmony (ΔE), style_match, occasion_rules, recency_penalty.
Daily: Weather API + user history filter.
9. Wardrobe Combination Algorithm
Build compatibility graph (local): edges if color ΔE < 40, style overlap, season match.
DFS/BFS with pruning for occasion constraints.
Score top-N.
Send top-5 feature JSONs to LLM for explanation.
Generates 1000+ combos in <500ms.
10. Flutter Folder Structure
text

lib/
  core/ (DI, constants)
  data/ (repositories, local_ml_service.dart using tflite/mediapipe)
  domain/ (entities, usecases)
  presentation/ (screens/, widgets/, blocs)
  services/ (firebase, s3)
Feature-first + clean architecture.
11. FastAPI Folder Structure
text

app/
  api/ (routers)
  core/ (config, security)
  db/ (models, vector)
  ml/ (local_feature_processor.py, graph_engine.py)
  services/ (llm_orchestrator.py - thin)
12. Cloud Architecture
Frontend: Flutter (iOS/Android)
Backend: FastAPI on Fly.io / Render
DB: Supabase Postgres + pgvector
Storage: AWS S3 (presigned)
Cache: Upstash Redis
Auth: Firebase
AI: On-device + Vertex AI / OpenAI (feature-only)
13. Security Architecture
On-device encryption for embeddings.
JWT + Firebase.
No PII/images to LLM.
Row-level security Postgres.
14. Scalability Plan
Local ML reduces backend load 90%.
Horizontal FastAPI replicas.
Embedding cache in Redis.
Target: 100k users with < $0.01/user/month LLM cost.
15. Development Roadmap
Phase 1 (MVP - 8 weeks): Onboarding, Wardrobe, Your Outfits (local graph), StyleDNA local.
Phase 2 (12 weeks): Color, Chat, Calendar, Insights.
Phase 3: Virtual Try-On (local SAM), Packing.

16. Complete Implementation Strategy
Week 1-2: Design system + Flutter skeleton + local ML integration (MediaPipe Flutter plugin).
Week 3-4: Backend + Postgres schema + graph engine.
Week 5-6: Wardrobe + Your Outfits end-to-end (feature pipeline).
Week 7-8: Polish + testing.
Use DIP: All ML services abstracted behind interfaces; LLM is a thin adapter.
Testing: Unit (graph), Integration (feature flow), E2E (Flutter).
Next Step: Begin implementation in workspace with core local ML service prototype.