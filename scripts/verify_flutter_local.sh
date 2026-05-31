#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/flutter_app"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found in PATH. Install Flutter before running Flutter QA." >&2
  exit 1
fi

cd "$APP_DIR"
flutter --version
flutter pub get
flutter analyze
flutter test
flutter build apk --debug --dart-define=BHARATFIT_API_BASE_URL="${BHARATFIT_API_BASE_URL:-http://10.0.2.2:8000}"

echo "Flutter local QA passed: pub get, analyze, tests, debug APK build."
