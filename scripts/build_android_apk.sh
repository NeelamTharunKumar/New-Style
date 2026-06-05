#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
bash "$ROOT_DIR/scripts/prepare_flutter_platforms.sh"
cd "$ROOT_DIR/flutter_app"
flutter build apk --release "$@"

echo "APK output usually appears at: flutter_app/build/app/outputs/flutter-apk/app-release.apk"
