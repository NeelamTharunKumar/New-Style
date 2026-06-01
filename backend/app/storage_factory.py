from __future__ import annotations

from app.core.config import Settings
from app.db.persistent_store import PersistentStore
from app.storage import InMemoryStore


def create_store(settings: Settings):
    if settings.database_url:
        return PersistentStore(settings.database_url)
    return InMemoryStore()
