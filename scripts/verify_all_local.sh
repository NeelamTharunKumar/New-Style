#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

cd "$ROOT_DIR"
python3 -m pip install -r backend/requirements.txt
python3 -m py_compile backend/app/*.py backend/app/core/*.py backend/app/db/*.py backend/app/services/*.py
(cd backend && pytest -q)

if command -v flutter >/dev/null 2>&1; then
  "$ROOT_DIR/scripts/verify_flutter_local.sh"
else
  echo "Flutter SDK not found; backend checks passed, Flutter checks skipped." >&2
fi
