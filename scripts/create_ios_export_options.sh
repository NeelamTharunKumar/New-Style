#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_FILE="${1:-$ROOT_DIR/flutter_app/ios/ExportOptions.plist}"
METHOD="${IOS_EXPORT_METHOD:-app-store}"
TEAM_ID="${APPLE_TEAM_ID:-}"
BUNDLE_ID="${IOS_BUNDLE_ID:-com.example.drapeAi}"
PROFILE_NAME="${IOS_PROVISIONING_PROFILE_NAME:-}"

mkdir -p "$(dirname "$OUT_FILE")"

cat > "$OUT_FILE" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>method</key>
  <string>$METHOD</string>
  <key>signingStyle</key>
  <string>manual</string>
  <key>stripSwiftSymbols</key>
  <true/>
  <key>uploadBitcode</key>
  <false/>
  <key>uploadSymbols</key>
  <true/>
PLIST

if [ -n "$TEAM_ID" ]; then
  cat >> "$OUT_FILE" <<PLIST
  <key>teamID</key>
  <string>$TEAM_ID</string>
PLIST
fi

if [ -n "$PROFILE_NAME" ]; then
  cat >> "$OUT_FILE" <<PLIST
  <key>provisioningProfiles</key>
  <dict>
    <key>$BUNDLE_ID</key>
    <string>$PROFILE_NAME</string>
  </dict>
PLIST
fi

cat >> "$OUT_FILE" <<PLIST
</dict>
</plist>
PLIST

echo "Created iOS export options at $OUT_FILE"
