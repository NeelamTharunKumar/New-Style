#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/flutter_app"
ANDROID_PACKAGE_DIR="$APP_DIR/android/app/src/main/kotlin/com/example/bharatfit_ai"
IOS_RUNNER_DIR="$APP_DIR/ios/Runner"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found in PATH. Install Flutter before preparing platforms." >&2
  exit 1
fi

cd "$APP_DIR"
flutter create --platforms=android,ios .
flutter pub get

mkdir -p "$ANDROID_PACKAGE_DIR"
cp "$ROOT_DIR/native_bridge/android/MainActivity.kt" "$ANDROID_PACKAGE_DIR/MainActivity.kt"

if [ -d "$IOS_RUNNER_DIR" ]; then
  cp "$ROOT_DIR/native_bridge/ios/AppDelegate.swift" "$IOS_RUNNER_DIR/AppDelegate.swift"
fi

echo "Flutter Android/iOS platform folders prepared with BharatFit native ML bridge."
