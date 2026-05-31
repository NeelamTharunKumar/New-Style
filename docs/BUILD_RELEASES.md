# Building Android and iOS Versions

Phase 6 prepares the app so one Flutter codebase can build two platform versions:

- Android APK
- iOS app/archive

## Prerequisites

### Android

- Flutter SDK
- Android Studio or Android SDK
- Java/JDK compatible with your Flutter version

### iOS

- macOS
- Xcode
- CocoaPods
- Apple Developer account for signing/distribution

## Prepare platform folders

The repo keeps generated platform folders out of git. Generate them locally:

```bash
./scripts/prepare_flutter_platforms.sh
```

This creates:

```text
flutter_app/android/
flutter_app/ios/
```

and installs the Kotlin/Swift native ML bridge templates.

## Build Android APK

```bash
./scripts/build_android_apk.sh
```

Output is usually:

```text
flutter_app/build/app/outputs/flutter-apk/app-release.apk
```

You can pass Flutter build flags:

```bash
./scripts/build_android_apk.sh --dart-define=BHARATFIT_API_BASE_URL=https://your-api.example.com
```

For Play Store, build an app bundle:

```bash
cd flutter_app
flutter build appbundle --release
```

Output:

```text
flutter_app/build/app/outputs/bundle/release/app-release.aab
```

## Build iOS

On macOS:

```bash
./scripts/build_ios_release.sh
```

This runs:

```bash
flutter build ios --release --no-codesign
```

For App Store/TestFlight distribution:

1. Open:

```text
flutter_app/ios/Runner.xcworkspace
```

2. Configure bundle ID, signing team, capabilities and provisioning profile in Xcode.
3. Archive from Xcode.
4. Upload to TestFlight/App Store Connect.

## Backend URL per build

Set production API base URL at build time:

```bash
flutter build apk --release --dart-define=BHARATFIT_API_BASE_URL=https://api.yourdomain.com
flutter build ios --release --dart-define=BHARATFIT_API_BASE_URL=https://api.yourdomain.com
```

## Important note

This environment does not have Flutter/Xcode installed, so release artifacts cannot be generated here. The scripts are committed so you can run them locally or in CI.
