#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE_URL="${BHARATFIT_API_BASE_URL:-https://api.example.com}"

"$ROOT_DIR/scripts/prepare_flutter_platforms.sh"
"$ROOT_DIR/scripts/configure_android_signing.sh"

cd "$ROOT_DIR/flutter_app"
flutter build appbundle --release --dart-define=BHARATFIT_API_BASE_URL="$API_BASE_URL" "$@"

echo "Signed AAB output usually appears at: flutter_app/build/app/outputs/bundle/release/app-release.aab"
