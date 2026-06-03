# Branding and App Assets

Phase 13 finalizes the current working brand package and adds source assets.

## Working brand

```text
App name: Drape AI
Short name: Drape
Tagline: Outfits from your own wardrobe
Positioning: India-first wardrobe assistant
Android application ID: com.drape.ai
Default iOS bundle ID: com.drape.ai
```

> Before public launch, confirm that the app name, domain and package IDs are legally available.

## Brand constants

Flutter constants live in:

```text
flutter_app/lib/core/branding.dart
```

Use `AppBranding.appName`, `AppBranding.androidApplicationId`, etc. instead of hardcoding strings in UI.

## Source assets

Added:

```text
flutter_app/assets/branding/app_icon.svg
flutter_app/assets/branding/splash_logo.svg
flutter_app/assets/branding/README.md
```

These are source SVGs. For production, export PNGs at platform-required sizes.

## In-app brand mark

Added:

```text
flutter_app/lib/presentation/widgets/brand_mark.dart
```

This creates a Flutter-rendered brand mark used in onboarding and dashboard.

## Applying package/bundle IDs

Generated Flutter platform folders are not committed. After generating them, apply branding with:

```bash
./scripts/prepare_flutter_platforms.sh
```

or directly:

```bash
ANDROID_APP_ID=com.drape.ai \
IOS_BUNDLE_ID=com.drape.ai \
APP_DISPLAY_NAME="Drape AI" \
./scripts/apply_branding.sh
```

The script patches:

- Android namespace/applicationId
- Android app label
- Android native Kotlin package path
- iOS bundle identifier
- iOS display name

## Store assets still needed

- Final PNG app icon exports
- Android adaptive icon foreground/background
- iOS AppIcon asset catalog
- splash screen integration
- App Store screenshots
- Google Play screenshots
