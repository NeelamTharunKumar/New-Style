from __future__ import annotations

from functools import lru_cache
from typing import Any, Dict

from fastapi import HTTPException, status

try:
    import firebase_admin
    from firebase_admin import auth as firebase_auth
    from firebase_admin import credentials
except Exception:  # pragma: no cover - optional dependency import guard
    firebase_admin = None
    firebase_auth = None
    credentials = None

from app.core.config import get_settings


@lru_cache(maxsize=1)
def _ensure_firebase_app() -> None:
    if firebase_admin is None:
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="firebase-admin dependency is not installed",
        )
    if firebase_admin._apps:  # type: ignore[attr-defined]
        return

    settings = get_settings()
    if settings.firebase_credentials_path:
        cred = credentials.Certificate(settings.firebase_credentials_path)
        firebase_admin.initialize_app(cred, {"projectId": settings.firebase_project_id} if settings.firebase_project_id else None)
    else:
        # Uses Google Application Default Credentials when deployed on Firebase/GCP or when
        # GOOGLE_APPLICATION_CREDENTIALS is configured.
        firebase_admin.initialize_app(options={"projectId": settings.firebase_project_id} if settings.firebase_project_id else None)


def verify_firebase_token(id_token: str) -> Dict[str, Any]:
    _ensure_firebase_app()
    if firebase_auth is None:
        raise HTTPException(
            status_code=status.HTTP_501_NOT_IMPLEMENTED,
            detail="firebase-admin dependency is not installed",
        )
    try:
        return firebase_auth.verify_id_token(id_token, check_revoked=True)
    except Exception as exc:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail=f"invalid firebase token: {exc}",
        ) from exc
