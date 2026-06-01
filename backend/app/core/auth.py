from __future__ import annotations

from dataclasses import dataclass
from typing import Annotated, Optional

from fastapi import Header, HTTPException, status

from app.core.config import get_settings
from app.core.firebase_auth import verify_firebase_token


@dataclass(frozen=True)
class CurrentUser:
    user_id: Optional[str]
    auth_mode: str


async def get_current_user(
    authorization: Annotated[str | None, Header(alias="Authorization")] = None,
) -> CurrentUser:
    """Resolve user identity for per-user data isolation.

    Modes:
    - open_dev: no user identity enforced; useful for local dev.
    - dev_bearer: Authorization: Bearer dev:<user_id>
    - static_bearer: Authorization: Bearer <token>, with token:user_id mapping in env.
    - firebase: reserved placeholder for future Firebase Admin token verification.
    """
    settings = get_settings()
    mode = settings.auth_mode

    if mode == "open_dev":
        return CurrentUser(user_id=None, auth_mode=mode)

    scheme, token = _parse_bearer(authorization)
    if scheme != "bearer" or not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="missing bearer token",
        )

    if mode == "dev_bearer":
        if not token.startswith("dev:"):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="dev bearer tokens must use format dev:<user_id>",
            )
        user_id = token.removeprefix("dev:").strip()
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="empty user id in token")
        return CurrentUser(user_id=user_id, auth_mode=mode)

    if mode == "static_bearer":
        user_id = settings.user_tokens.get(token)
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="invalid bearer token")
        return CurrentUser(user_id=user_id, auth_mode=mode)

    if mode == "firebase":
        decoded = verify_firebase_token(token)
        user_id = decoded.get("uid") or decoded.get("user_id") or decoded.get("sub")
        if not user_id:
            raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="firebase token missing uid")
        return CurrentUser(user_id=str(user_id), auth_mode=mode)

    raise HTTPException(status_code=status.HTTP_500_INTERNAL_SERVER_ERROR, detail=f"unsupported auth mode: {mode}")


def ensure_user_access(current_user: CurrentUser, target_user_id: str) -> None:
    """Enforce that authenticated users can only access their own resources."""
    if not current_user.user_id:
        return
    if current_user.user_id != target_user_id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="authenticated user cannot access another user's data",
        )


def _parse_bearer(authorization: str | None) -> tuple[str | None, str | None]:
    if not authorization:
        return None, None
    parts = authorization.strip().split(" ", 1)
    if len(parts) != 2:
        return None, None
    return parts[0].lower(), parts[1].strip()
