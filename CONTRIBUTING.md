# Contributing to StyleDNA AI

Thank you for your interest in contributing!

## Development Setup
1. Clone the repo
2. Run Flutter app: `cd flutter_app && flutter pub get`
3. Run Backend: `cd backend && uvicorn app.main:app --reload`

## Code Guidelines
- Follow clean architecture + DIP
- All ML processing must stay on-device first
- Never send raw images to LLMs
- Write tests for new features

## Pull Request Process
1. Create feature branch from `main`
2. Ensure all screens follow the existing UI pattern
3. Update the main specification document if architecture changes

We welcome contributions especially around:
- Additional on-device ML models
- New outfit occasion types
- UI/UX improvements