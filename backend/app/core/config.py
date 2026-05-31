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


@dataclass(frozen=True)
class Settings:
    app_name: str = "BharatFit AI Backend"
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
        return cls(
            app_name=os.getenv("BHARATFIT_APP_NAME", "BharatFit AI Backend"),
            app_env=os.getenv("BHARATFIT_ENV", "development"),
            database_url=os.getenv("DATABASE_URL") or os.getenv("BHARATFIT_DATABASE_URL"),
            api_key=os.getenv("BHARATFIT_API_KEY"),
            auth_mode=os.getenv("BHARATFIT_AUTH_MODE", "open_dev").strip().lower(),
            user_tokens=_token_map(os.getenv("BHARATFIT_USER_TOKENS")),
            firebase_project_id=os.getenv("FIREBASE_PROJECT_ID") or os.getenv("BHARATFIT_FIREBASE_PROJECT_ID"),
            firebase_credentials_path=os.getenv("GOOGLE_APPLICATION_CREDENTIALS") or os.getenv("BHARATFIT_FIREBASE_CREDENTIALS_PATH"),
            cors_origins=_csv(os.getenv("BHARATFIT_CORS_ORIGINS"), ["*"]),
            log_requests=os.getenv("BHARATFIT_LOG_REQUESTS", "true").lower() in {"1", "true", "yes"},
            rate_limit_per_minute=int(os.getenv("BHARATFIT_RATE_LIMIT_PER_MINUTE", "120")),
            security_headers_enabled=os.getenv("BHARATFIT_SECURITY_HEADERS", "true").lower() in {"1", "true", "yes"},
        )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings.from_env()
