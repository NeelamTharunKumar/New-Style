# Market Launch Loop

This document defines the consumer-facing loop needed to move Drape from technical foundation to market-testable MVP.

## Core promise

```text
Add clothing photos → pick an occasion → get visual outfits from clothes you own.
```

## Launch UX flow

### Add clothing

```text
Add photo
→ auto color extraction
→ category suggestion
→ 1-tap correction chips
→ occasion chips
→ save
```

Implemented in:

```text
flutter_app/lib/presentation/screens/wardrobe_screen.dart
```

The simplified add-item flow now appears before advanced fields. Advanced structured inputs are still available under an expansion section.

### Occasion-first home

Home now asks:

```text
What are you dressing for?
[College] [Office] [Date] [Haldi] [Sangeet] [Wedding] [Casual] [Travel]
```

Implemented in:

```text
flutter_app/lib/presentation/screens/home_dashboard.dart
```

Selecting an occasion opens outfit generation with that occasion preselected.

### Outfit output structure

Outfit cards now follow the target market format:

```text
Office-ready look

[Blue shirt] [Charcoal trousers] [Brown loafers]

Why it works:
Clean blue-charcoal contrast, breathable cotton for warm weather, brown loafers make it polished.

Actions:
[Wear today] [Save] [Swap item] [Not my style]
```

Implemented in:

```text
flutter_app/lib/presentation/screens/your_outfits_screen.dart
flutter_app/lib/presentation/screens/outfit_detail_screen.dart
```

## Feedback loop

Actions connect to backend feedback endpoints:

```text
Wear today → worn=true
Save → favorite=true
Not my style → rejected=true
Swap item → regenerate outfits
```

Backend personalization uses feedback to rerank future recommendations.

## What is hidden from normal users

The main consumer flow should avoid exposing:

- backend URLs
- API keys
- structured feature terminology
- complex manual tags
- score breakdowns as primary content

Developer/advanced controls can remain, but should be secondary.

## Next market-readiness steps

- run Flutter locally and fix analyzer/build issues
- make Add Photo the default CTA from onboarding/home
- add category classifier beyond color extraction
- improve outfit quality for 8 core occasions
- test with 10–20 Indian users
