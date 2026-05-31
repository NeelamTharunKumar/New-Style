from __future__ import annotations

import os
from dataclasses import dataclass, field
from functools import lru_cache
from typing import List, Optional


def _csv(value: str | None, default: List[str]) -> List[str]:
    if not value:
        return default
    return [item.strip() for item in value.split(",") if item.strip()]


@dataclass(frozen=True)
class Settings:
    app_name: str = "BharatFit AI Backend"
    app_env: str = "development"
    database_url: Optional[str] = None
    api_key: Optional[str] = None
    cors_origins: List[str] = field(default_factory=lambda: ["*"])
    log_requests: bool = True

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
            cors_origins=_csv(os.getenv("BHARATFIT_CORS_ORIGINS"), ["*"]),
            log_requests=os.getenv("BHARATFIT_LOG_REQUESTS", "true").lower() in {"1", "true", "yes"},
        )


@lru_cache(maxsize=1)
def get_settings() -> Settings:
    return Settings.from_env()
