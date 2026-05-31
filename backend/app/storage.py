from __future__ import annotations

from collections import defaultdict
from typing import Dict, List, Optional

from app.models import UserProfile, WardrobeItem


class InMemoryStore:
    """Prototype store. Replace with Postgres in production hardening phase."""

    def __init__(self) -> None:
        self._profiles: Dict[str, UserProfile] = {}
        self._wardrobe: Dict[str, Dict[str, WardrobeItem]] = defaultdict(dict)

    def upsert_profile(self, profile: UserProfile) -> UserProfile:
        self._profiles[profile.user_id] = profile
        return profile

    def get_profile(self, user_id: str) -> Optional[UserProfile]:
        return self._profiles.get(user_id)

    def add_item(self, item: WardrobeItem) -> WardrobeItem:
        self._wardrobe[item.user_id][item.item_id] = item
        return item

    def list_items(self, user_id: str) -> List[WardrobeItem]:
        return list(self._wardrobe[user_id].values())

    def delete_item(self, user_id: str, item_id: str) -> bool:
        if item_id in self._wardrobe[user_id]:
            del self._wardrobe[user_id][item_id]
            return True
        return False

    def clear(self) -> None:
        self._profiles.clear()
        self._wardrobe.clear()
