# Flutter MVP

Phase 2 turns the Flutter prototype into a functional backend-connected MVP.

## Implemented screens

- Home dashboard
- Style Profile setup
- Wardrobe list
- Manual wardrobe item form
- Outfit generation screen
- AI stylist chat screen connected to backend stub

## Backend connection

The app uses `DrapeApiClient` in:

```text
flutter_app/lib/data/drape_api_client.dart
```

Default API base URL:

```text
http://10.0.2.2:8000
```

This works for Android emulator when the backend runs on the host machine. For iOS simulator, use:

```text
http://localhost:8000
```

The Home screen lets the user edit the backend base URL.

You can also compile with:

```bash
flutter run --dart-define=DRAPE_API_BASE_URL=http://localhost:8000
```

## Run full MVP locally

Terminal 1:

```bash
cd backend
pip install -r requirements.txt
uvicorn app.main:app --reload
```

Terminal 2:

```bash
cd flutter_app
flutter pub get
flutter run
```

## MVP user flow

1. Open Home.
2. Check backend health.
3. Open Style Profile and save a profile.
4. Open Wardrobe.
5. Add a demo set or manually add structured clothing items.
6. Open Your Outfits.
7. Select occasion/weather.
8. Generate outfits.
9. App displays returned item IDs mapped to local wardrobe references.

## Privacy behavior in Phase 2

Phase 2 does not upload image bytes.

The manual item form sends only structured fields such as:

- item ID
- category
- color
- fabric
- fit
- tags
- local image reference string

The `local_image_ref` is only a pointer such as:

```text
local://wardrobe/shirt_001.jpg
```

The backend cannot use it to access a photo. Later phases will connect this to actual local image storage.
