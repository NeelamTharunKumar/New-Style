#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="$ROOT_DIR/flutter_app"
ANDROID_DIR="$APP_DIR/android"
APP_ANDROID_DIR="$ANDROID_DIR/app"
KEYSTORE_PATH="$APP_ANDROID_DIR/upload-keystore.jks"
KEY_PROPERTIES="$ANDROID_DIR/key.properties"

if [ ! -d "$ANDROID_DIR" ]; then
  echo "Android platform folder missing. Run ./scripts/prepare_flutter_platforms.sh first." >&2
  exit 1
fi

: "${ANDROID_KEYSTORE_BASE64:?ANDROID_KEYSTORE_BASE64 is required}"
: "${ANDROID_KEYSTORE_PASSWORD:?ANDROID_KEYSTORE_PASSWORD is required}"
: "${ANDROID_KEY_ALIAS:?ANDROID_KEY_ALIAS is required}"
: "${ANDROID_KEY_PASSWORD:?ANDROID_KEY_PASSWORD is required}"

mkdir -p "$APP_ANDROID_DIR"
printf '%s' "$ANDROID_KEYSTORE_BASE64" | base64 --decode > "$KEYSTORE_PATH"

cat > "$KEY_PROPERTIES" <<PROPS
storePassword=$ANDROID_KEYSTORE_PASSWORD
keyPassword=$ANDROID_KEY_PASSWORD
keyAlias=$ANDROID_KEY_ALIAS
storeFile=upload-keystore.jks
PROPS

GRADLE_GROOVY="$APP_ANDROID_DIR/build.gradle"
GRADLE_KTS="$APP_ANDROID_DIR/build.gradle.kts"

if [ -f "$GRADLE_GROOVY" ]; then
  if ! grep -q "keystoreProperties" "$GRADLE_GROOVY"; then
    python3 - <<'PY' "$GRADLE_GROOVY"
from pathlib import Path
import sys
path = Path(sys.argv[1])
s = path.read_text()
prefix = """def keystoreProperties = new Properties()\ndef keystorePropertiesFile = rootProject.file('key.properties')\nif (keystorePropertiesFile.exists()) {\n    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))\n}\n\n"""
s = prefix + s
marker = "    defaultConfig {"
signing = """    signingConfigs {\n        release {\n            keyAlias keystoreProperties['keyAlias']\n            keyPassword keystoreProperties['keyPassword']\n            storeFile keystoreProperties['storeFile'] ? file(keystoreProperties['storeFile']) : null\n            storePassword keystoreProperties['storePassword']\n        }\n    }\n\n"""
s = s.replace(marker, signing + marker)
s = s.replace("signingConfig signingConfigs.debug", "signingConfig signingConfigs.release")
path.write_text(s)
PY
  fi
elif [ -f "$GRADLE_KTS" ]; then
  if ! grep -q "keystoreProperties" "$GRADLE_KTS"; then
    python3 - <<'PY' "$GRADLE_KTS"
from pathlib import Path
import sys
path = Path(sys.argv[1])
s = path.read_text()
prefix = """import java.util.Properties\nimport java.io.FileInputStream\n\nval keystoreProperties = Properties()\nval keystorePropertiesFile = rootProject.file(\"key.properties\")\nif (keystorePropertiesFile.exists()) {\n    keystoreProperties.load(FileInputStream(keystorePropertiesFile))\n}\n\n"""
s = prefix + s
marker = "    defaultConfig {"
signing = """    signingConfigs {\n        create(\"release\") {\n            keyAlias = keystoreProperties[\"keyAlias\"] as String\n            keyPassword = keystoreProperties[\"keyPassword\"] as String\n            storeFile = keystoreProperties[\"storeFile\"]?.let { file(it) }\n            storePassword = keystoreProperties[\"storePassword\"] as String\n        }\n    }\n\n"""
s = s.replace(marker, signing + marker)
s = s.replace("signingConfig = signingConfigs.getByName(\"debug\")", "signingConfig = signingConfigs.getByName(\"release\")")
s = s.replace("signingConfig = signingConfigs.debug", "signingConfig = signingConfigs.getByName(\"release\")")
path.write_text(s)
PY
  fi
else
  echo "Could not find Android app Gradle file." >&2
  exit 1
fi

echo "Android signing configured with key.properties and release signing config."
