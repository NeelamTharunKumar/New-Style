# Native Kotlin/Swift ML Bridge

Phase 6 adds the native bridge path while keeping Flutter as the shared UI.

## Goal

When built, the product should produce both:

- Android APK / App Bundle from the Flutter app with Kotlin native ML bridge
- iOS app/archive from the Flutter app with Swift native ML bridge

The Flutter UI stays shared. Device-specific ML/image work can run in native code.

## Architecture

```text
Flutter UI
  ↓ MethodChannel("drape/native_ml")
Native platform layer
  ├─ Android: Kotlin MainActivity
  └─ iOS: Swift AppDelegate
```

## Implemented methods

### `isAvailable`

Returns whether the native bridge is available.

### `analyzeGarmentImage`

Input:

```json
{
  "imagePath": "/local/device/path.jpg",
  "localImageRef": "file:///local/device/path.jpg",
  "itemIdHint": "shirt_001"
}
```

Output:

```json
{
  "localImageRef": "file:///local/device/path.jpg",
  "hexColor": "#A8C7E8",
  "colorName": "light blue",
  "patternHint": "solid",
  "brightness": 184.2,
  "confidence": 0.83,
  "width": 1200,
  "height": 1600,
  "nativeEngine": "android_kotlin_bitmap",
  "privacy": "computed on-device; raw image not uploaded"
}
```

## Files

Flutter bridge:

```text
flutter_app/lib/services/native_ml_bridge.dart
```

Native templates:

```text
native_bridge/android/MainActivity.kt
native_bridge/ios/AppDelegate.swift
```

Preparation/build scripts:

```text
scripts/prepare_flutter_platforms.sh
scripts/build_android_apk.sh
scripts/build_ios_release.sh
```

## How the bridge is installed

The current repo does not commit generated Flutter `android/` and `ios/` platform directories. Generate them locally with:

```bash
./scripts/prepare_flutter_platforms.sh
```

This runs:

```bash
cd flutter_app
flutter create --platforms=android,ios .
flutter pub get
```

Then copies native bridge templates into the generated platform folders.

## Privacy contract

The native bridge analyzes a local image path on the device and returns structured features. It does not upload the image.

The backend still receives only structured data and local reference strings.

## Fallback behavior

If the native bridge is unavailable, Flutter falls back to the Dart-based local extractor from Phase 5.

So the app still works on platforms or development builds where the native method channel has not been installed.

## Future native ML upgrades

The current native bridge performs simple local bitmap analysis. Future upgrades can replace or extend it with:

### Android

- TensorFlow Lite garment classifier
- MediaPipe pose/body landmarks
- ML Kit segmentation
- GPU/NNAPI acceleration

### iOS

- CoreML garment classifier
- Vision person/pose segmentation
- Core Image color extraction
- Metal acceleration

The Flutter method channel contract can remain stable while native implementations improve.
