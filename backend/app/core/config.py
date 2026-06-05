from __future__ import annotations

import os
from dataclasses import dataclass, field
from functools import lru_cache
from typing import Dict, List, Optional


def _csv(value: str | None, default: List[str]) -> List[str]:
    if not value:
        return default
    return [item.strip() for item in value.split(",") if item.strip()]


def _token_map(value: str | None) -> Dict[str, str]:
    if not value:
        return {}
    result: Dict[str, str] = {}
    for pair in value.split(","):
        if not pair.strip() or ":" not in pair:
            continue
        token, user_id = pair.split(":", 1)
        token = token.strip()
        user_id = user_id.strip()
        if token and user_id:
            result[token] = user_id
    return result


def _flag(value: str | None, default: str = "true") -> bool:
    return (value if value is not None else default).lower() in {"1", "true", "yes"}


@dataclass(frozen=True)
class Settings:
    app_name: str = "Drape AI Backend"
    app_env: str = "development"
    database_url: Optional[str] = None
    api_key: Optional[str] = None
    auth_mode: str = "open_dev"
    user_tokens: Dict[str, str] = field(default_factory=dict)
    firebase_project_id: Optional[str] = None
    firebase_credentials_path: Optional[str] = None
    cors_origins: List[str] = field(default_factory=lambda: ["*"])
    log_requests: bool = True
    rate_limit_per_minute: int = 120
    security_headers_enabled: bool = True

    @property
    def store_backend(self) -> str:
        return "database" if self.database_url else "memory"

    @classmethod
    def from_env(cls) -> "Settings":
        def _int_env(key: str, fallback: int) -> int:
            val = os.getenv(key)
            if val is not None:
                try:
                    return int(val)
                except ValueError:
                    raise ValueError(f"{key} must be an integer, got: {val!r}")
            return fallback

        auth_mode = os.getenv("DRAPE_AUTH_MODE", "open_dev")
        log_requests = os.getenv("DRAPE_LOG_REQUESTS", "true")
        security_headers = os.getenv("DRAPE_SECURITY_HEADERS", "true")
        return cls(
            app_name=os.getenv("DRAPE_APP_NAME", "Drape AI Backend"),
            app_env=os.getenv("DRAPE_ENV", "development"),
            database_url=os.getenv("DATABASE_URL") or os.getenv("DRAPE_DATABASE_URL"),
            api_key=os.getenv("DRAPE_API_KEY"),
            auth_mode=auth_mode.strip().lower(),
            user_tokens=_token_map(os.getenv("DRAPE_USER_TOKENS")),
            firebase_project_id=os.getenv("FIREBASE_PROJECT_ID") or os.getenv("DRAPE_FIREBASE_PROJECT_ID"),
            firebase_credentials_path=os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or os.getenv("DRAPE_FIREBASE_CREDENTIALS_PATH"),
            cors_origins=_csv(os.getenv("DRAPE_CORS_ORIGINS"), ["*"]),
            log_requests=_flag(log_requests),
            rate_limit_per_minute=_int_env("DRAPE_RATE_LIMIT_PER_MINUTE", 120),
            security_headers_enabled=_flag(security_headers),
        )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings.from_env()
