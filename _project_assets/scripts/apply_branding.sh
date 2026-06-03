#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$ROOT_DIR/flutter_app"
ANDROID_APP_ID="${ANDROID_APP_ID:-com.drape.ai}"
IOS_BUNDLE_ID="${IOS_BUNDLE_ID:-com.drape.ai}"
APP_DISPLAY_NAME="${APP_DISPLAY_NAME:-Drape AI}"
ANDROID_PACKAGE_PATH="${ANDROID_APP_ID//./\/}"
ANDROID_PACKAGE_DIR="$APP_DIR/android/app/src/main/kotlin/$ANDROID_PACKAGE_PATH"

if [ ! -d "$APP_DIR/android" ] && [ ! -d "$APP_DIR/ios" ]; then
  echo "No generated platform folders found. Run ./scripts/prepare_flutter_platforms.sh first." >&2
  exit 1
fi

if [ -d "$APP_DIR/android" ]; then
  mkdir -p "$ANDROID_PACKAGE_DIR"
  sed "s/^package .*/package $ANDROID_APP_ID/" "$ROOT_DIR/native_bridge/android/MainActivity.kt" > "$ANDROID_PACKAGE_DIR/MainActivity.kt"

  GRADLE_GROOVY="$APP_DIR/android/app/build.gradle"
  GRADLE_KTS="$APP_DIR/android/app/build.gradle.kts"
  if [ -f "$GRADLE_GROOVY" ]; then
    python3 - <<'PY' "$GRADLE_GROOVY" "$ANDROID_APP_ID"
from pathlib import Path
import re, sys
path=Path(sys.argv[1]); app_id=sys.argv[2]
s=path.read_text()
s=re.sub(r'namespace\s+["\'][^"\']+["\']', f'namespace "{app_id}"', s)
s=re.sub(r'applicationId\s+["\'][^"\']+["\']', f'applicationId "{app_id}"', s)
path.write_text(s)
PY
  elif [ -f "$GRADLE_KTS" ]; then
    python3 - <<'PY' "$GRADLE_KTS" "$ANDROID_APP_ID"
from pathlib import Path
import re, sys
path=Path(sys.argv[1]); app_id=sys.argv[2]
s=path.read_text()
s=re.sub(r'namespace\s*=\s*["\'][^"\']+["\']', f'namespace = "{app_id}"', s)
s=re.sub(r'applicationId\s*=\s*["\'][^"\']+["\']', f'applicationId = "{app_id}"', s)
path.write_text(s)
PY
  fi

  MANIFEST="$APP_DIR/android/app/src/main/AndroidManifest.xml"
  if [ -f "$MANIFEST" ]; then
    python3 - <<'PY' "$MANIFEST" "$APP_DISPLAY_NAME"
from pathlib import Path
import re, sys
path=Path(sys.argv[1]); name=sys.argv[2]
s=path.read_text()
s=re.sub(r'android:label="[^"]*"', f'android:label="{name}"', s, count=1)
path.write_text(s)
PY
  fi
fi

if [ -d "$APP_DIR/ios" ]; then
  PLIST="$APP_DIR/ios/Runner/Info.plist"
  if [ -f "$PLIST" ]; then
    python3 - <<'PY' "$PLIST" "$APP_DISPLAY_NAME"
from pathlib import Path
import sys
path=Path(sys.argv[1]); name=sys.argv[2]
s=path.read_text()
if '<key>CFBundleDisplayName</key>' in s:
    import re
    s=re.sub(r'(<key>CFBundleDisplayName</key>\s*<string>)[^<]*(</string>)', rf'\1{name}\2', s)
else:
    s=s.replace('<dict>', f'<dict>\n\t<key>CFBundleDisplayName</key>\n\t<string>{name}</string>', 1)
path.write_text(s)
PY
  fi
  PBX="$APP_DIR/ios/Runner.xcodeproj/project.pbxproj"
  if [ -f "$PBX" ]; then
    python3 - <<'PY' "$PBX" "$IOS_BUNDLE_ID"
from pathlib import Path
import re, sys
path=Path(sys.argv[1]); bundle=sys.argv[2]
s=path.read_text()
s=re.sub(r'PRODUCT_BUNDLE_IDENTIFIER = [^;]+;', f'PRODUCT_BUNDLE_IDENTIFIER = {bundle};', s)
path.write_text(s)
PY
  fi
fi

echo "Applied branding: app='$APP_DISPLAY_NAME' android='$ANDROID_APP_ID' ios='$IOS_BUNDLE_ID'"
