#!/usr/bin/env bash
set -euo pipefail

if [[ "$(uname -s)" != "Darwin" ]]; then
  echo "iOS builds require macOS with Xcode installed." >&2
  exit 1
fi

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
bash "$ROOT_DIR/_project_assets/scripts/prepare_flutter_platforms.sh"
cd "$ROOT_DIR/flutter_app"
flutter build ios --release --no-codesign "$@"

echo "iOS build created without code signing. Open ios/Runner.xcworkspace in Xcode to archive/sign for App Store/TestFlight."
