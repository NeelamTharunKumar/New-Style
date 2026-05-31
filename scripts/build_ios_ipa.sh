#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS IPA builds require macOS with Xcode installed." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
API_BASE_URL="${BHARATFIT_API_BASE_URL:-https://api.example.com}"
EXPORT_OPTIONS="$ROOT_DIR/flutter_app/ios/ExportOptions.plist"

"$ROOT_DIR/scripts/prepare_flutter_platforms.sh"
"$ROOT_DIR/scripts/create_ios_export_options.sh" "$EXPORT_OPTIONS"

cd "$ROOT_DIR/flutter_app"
flutter build ipa --release \
  --export-options-plist="$EXPORT_OPTIONS" \
  --dart-define=BHARATFIT_API_BASE_URL="$API_BASE_URL" \
  "$@"

echo "IPA output usually appears under: flutter_app/build/ios/ipa/"
