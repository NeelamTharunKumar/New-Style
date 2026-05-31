# Local Storage and Privacy Layer

Phase 3 makes the Flutter MVP local-first.

## What is stored locally

The app now persists these values on-device using `shared_preferences`:

- user style profile
- structured wardrobe items
- local image reference strings
- generated outfit results
- backend API base URL

The implementation lives in:

```text
flutter_app/lib/data/local_store.dart
flutter_app/lib/data/local_image_service.dart
```

## What is not stored/uploaded

Phase 3 still does not upload raw image bytes.

The app may store or display local references such as:

```text
local://wardrobe/shirt_office_blue.jpg
```

These are pointers only. The backend cannot use them to retrieve an image.

## Local-first outfit generation

Before Phase 3, outfit generation relied on backend-persisted wardrobe items.

Now the Flutter app sends the current local wardrobe as structured `wardrobe_items` inside the `/outfits/generate` request. This means:

- local wardrobe remains the source of truth
- backend restart does not erase the app's wardrobe
- outfit generation still works after backend memory resets
- images still do not leave the app

The request also sends a structured `user_profile` object so skin-tone/preferences can be used without requiring backend profile persistence.

## Privacy settings screen

Added screen:

```text
flutter_app/lib/presentation/screens/privacy_settings_screen.dart
```

It supports:

- local data summary
- structured data sync to backend
- local JSON export
- clear saved outfit results
- clear all local profile/wardrobe/outfit data

## Export format

The local export contains:

- timestamp
- privacy note
- profile JSON
- wardrobe item feature JSON
- outfit result JSON

It does not include image bytes.

## Remaining limitations

- `shared_preferences` is fine for MVP but not ideal for large wardrobes.
- Actual image picking/copying is not implemented yet.
- For production, move wardrobe storage to Hive/Isar/Drift and store images in app documents directory.
- No encryption-at-rest yet.
