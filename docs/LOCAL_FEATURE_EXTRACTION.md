# Basic Local Feature Extraction

Phase 5 starts reducing manual wardrobe entry while keeping the same privacy rule:

> Raw photos stay on-device. Only structured features leave the app.

## Implemented in Phase 5

### Local image selection and copy

The wardrobe item form now has:

```text
Pick local photo & extract color
```

When a user selects a wardrobe photo:

1. The photo is copied into the app's local documents directory.
2. A `file://...` local reference is stored in the wardrobe item.
3. The raw image is not uploaded to the backend.
4. Extracted structured features are used to prefill the item form.

### Dominant color extraction

Added:

```text
flutter_app/lib/data/local_feature_extractor.dart
```

The extractor:

- decodes the selected image locally
- samples pixels on-device
- ignores near-white background and near-black shadow pixels
- computes dominant RGB color
- converts it to hex
- maps it to a human-readable color name
- estimates a simple pattern hint based on luminance variance
- records confidence and image dimensions in structured metadata

Example extracted result:

```json
{
  "local_extraction": true,
  "dominant_hex_color": "#A8C7E8",
  "dominant_color_name": "light blue",
  "pattern_hint": "solid",
  "brightness": 184.2,
  "confidence": 0.82,
  "image_width": 1200,
  "image_height": 1600,
  "privacy": "computed on-device; raw image not uploaded"
}
```

### Local visual cards

Added:

```text
flutter_app/lib/presentation/widgets/local_wardrobe_image.dart
```

Wardrobe and outfit cards now display the local file image when available. If the image file is missing or the item only has a `local://` placeholder, the UI falls back to a color swatch.

## Files added/updated

```text
flutter_app/lib/data/local_feature_extractor.dart
flutter_app/lib/data/local_image_service.dart
flutter_app/lib/presentation/widgets/local_wardrobe_image.dart
flutter_app/lib/presentation/screens/wardrobe_screen.dart
flutter_app/lib/presentation/screens/your_outfits_screen.dart
flutter_app/lib/data/app_models.dart
flutter_app/pubspec.yaml
```

## Dependencies added

```yaml
image_picker: ^1.1.2
path_provider: ^2.1.4
image: ^4.2.0
```

## Privacy behavior

The app may store a local reference like:

```text
file:///.../ApplicationDocuments/wardrobe_images/shirt_001_123456.jpg
```

The backend receives this as a string reference only. It cannot access the user's local file.

The backend/LLM should still never receive image bytes.

## Current limitations

This is intentionally basic and not a real fashion vision model yet.

Limitations:

- dominant color can be affected by backgrounds or lighting
- no garment segmentation yet
- no category classifier yet
- no fabric classifier yet
- no sleeve/neckline detection yet
- no skin-tone extraction yet
- no camera capture flow yet, only gallery picking
- no encryption-at-rest yet

## Next improvements

Recommended next steps:

1. Add manual correction UI chips for extracted color/pattern.
2. Add background removal or person/garment segmentation.
3. Add simple category suggestion from an on-device classifier.
4. Add camera capture in addition to gallery selection.
5. Move from `shared_preferences` to a local DB for larger wardrobes.
6. Add optional local encryption for stored profile/wardrobe metadata.
