# Local Outfit Preview / Level 2 Try-On

This feature implements the current realistic version of virtual try-on for Drape.

## Scope

This is **not** a body-accurate generative virtual try-on.

It is a client-side mannequin/board preview that lets users visually inspect a selected outfit before asking for swaps.

## User-facing promise

```text
Preview the outfit combination locally before wearing it.
Photos stay on-device.
```

Avoid saying:

```text
See exactly how this looks on your body.
```

## Implemented

Added:

```text
flutter_app/lib/presentation/screens/outfit_preview_screen.dart
```

The preview screen supports two modes:

1. **Mannequin** — approximate clothing placement by category.
2. **Board** — clean vertical lookbook of selected items.

## Slot mapping

Examples:

```text
shirt / t-shirt / blouse → torso
top / kurti / kurta → long torso
saree / lehenga → full body area
jeans / chinos / trousers / palazzo → legs
sneakers / juttis / heels / shoes → feet
dupatta / blazer / jacket → shoulder overlay
watch / jewelry / handbag → accessory zone
```

## Entry points

Added `Preview Look` action to:

```text
flutter_app/lib/presentation/screens/your_outfits_screen.dart
flutter_app/lib/presentation/screens/outfit_detail_screen.dart
```

Actions available from preview:

```text
Wear today
Save
Swap item
Not my style
```

These connect to the existing feedback/personalization flow.

## Privacy behavior

The preview uses:

- local wardrobe item photos
- local image refs
- category slot mapping
- Flutter rendering

It does not send images to the backend or LLM.

## Future upgrades

- background removal / transparent garment crops
- better garment segmentation
- pose-guided local overlay
- user-photo preview with explicit opt-in
- true on-device virtual try-on model if feasible
