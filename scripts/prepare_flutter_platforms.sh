#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
APP_DIR="$ROOT_DIR/flutter_app"
IOS_RUNNER_DIR="$APP_DIR/ios/Runner"

if ! command -v flutter >/dev/null 2>&1; then
  echo "Flutter SDK not found in PATH. Install Flutter before preparing platforms." >&2
  exit 1
fi

cd "$APP_DIR"
flutter create --platforms=android,ios .
flutter pub get

# Cleanup legacy Groovy gradle files if Kotlin DSL versions exist
if [ -f "android/app/build.gradle.kts" ] && [ -f "android/app/build.gradle" ]; then
  rm "android/app/build.gradle"
fi
if [ -f "android/build.gradle.kts" ] && [ -f "android/build.gradle" ]; then
  rm "android/build.gradle"
fi


bash "$ROOT_DIR/scripts/apply_branding.sh"

if [ -d "$IOS_RUNNER_DIR" ]; then
  cp "$ROOT_DIR/native_bridge/ios/AppDelegate.swift" "$IOS_RUNNER_DIR/AppDelegate.swift"
fi

echo "Flutter Android/iOS platform folders prepared with Drape branding and native ML bridge."

# Enforce Flutter 3.29+ AGP, KGP and Gradle versions to fix CI build errors
python3 - <<'PY'
import os, re
app_dir = os.path.join(os.path.dirname(__file__), '../../flutter_app')

# Update settings.gradle / settings.gradle.kts
for sf in ['android/settings.gradle', 'android/settings.gradle.kts']:
    p = os.path.join(app_dir, sf)
    if os.path.exists(p):
        s = open(p).read()
        s = re.sub(r'(id\s*["\']com\.android\.application["\']\s*version\s*["\'])[^"\']+(["\'])', r'\g<1>8.11.1\g<2>', s)
        s = re.sub(r'(id\s*["\']org\.jetbrains\.kotlin\.android["\']\s*version\s*["\'])[^"\']+(["\'])', r'\g<1>2.2.20\g<2>', s)
        open(p, 'w').write(s)

# Update gradle wrapper
wp = os.path.join(app_dir, 'android/gradle/wrapper/gradle-wrapper.properties')
if os.path.exists(wp):
    s = open(wp).read()
    s = re.sub(r'gradle-[^"-]+-(all|bin)\.zip', r'gradle-8.14-\1.zip', s)
    open(wp, 'w').write(s)
PY
