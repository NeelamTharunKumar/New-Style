from __future__ import annotations

from collections import defaultdict
from datetime import datetime, timezone
from typing import Dict, List, Optional
from uuid import uuid4

from app.models import AuditEvent, OutfitFeedback, OutfitFeedbackRequest, UserProfile, WardrobeItem


class InMemoryStore:
    """Prototype store. Replace with Postgres in production hardening phase."""

    def __init__(self) -> None:
        self._profiles: Dict[str, UserProfile] = {}
        self._wardrobe: Dict[str, Dict[str, WardrobeItem]] = defaultdict(dict)
        self._feedback: Dict[str, Dict[str, OutfitFeedback]] = defaultdict(dict)
        self._audit: Dict[str, Dict[str, AuditEvent]] = defaultdict(dict)

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


    def add_feedback(self, payload: OutfitFeedbackRequest) -> OutfitFeedback:
        feedback = OutfitFeedback(
            feedback_id=f"feedback_{uuid4().hex[:10]}",
            created_at=datetime.now(timezone.utc).isoformat(),
            **payload.model_dump(),
        )
        self._feedback[payload.user_id][feedback.feedback_id] = feedback
        return feedback

    def list_feedback(self, user_id: str) -> List[OutfitFeedback]:
        return list(self._feedback[user_id].values())


    def add_audit_event(self, user_id: str, event_type: str, metadata: Optional[Dict] = None) -> AuditEvent:
        event = AuditEvent(
            event_id=f"audit_{uuid4().hex[:10]}",
            user_id=user_id,
            event_type=event_type,
            created_at=datetime.now(timezone.utc).isoformat(),
            metadata=metadata or {},
        )
        self._audit[user_id][event.event_id] = event
        return event

    def list_audit_events(self, user_id: str) -> List[AuditEvent]:
        return list(self._audit[user_id].values())

    def export_user(self, user_id: str) -> dict:
        return {
            "profile": self.get_profile(user_id),
            "wardrobe_items": self.list_items(user_id),
            "outfit_history": [item.model_dump() for item in self.list_feedback(user_id)],
            "audit_events": [item.model_dump() for item in self.list_audit_events(user_id)],
        }

    def delete_user(self, user_id: str) -> dict:
        profile_deleted = self._profiles.pop(user_id, None) is not None
        item_count = len(self._wardrobe[user_id])
        self._wardrobe.pop(user_id, None)
        self._feedback.pop(user_id, None)
        self._audit.pop(user_id, None)
        return {
            "profile_deleted": profile_deleted,
            "wardrobe_items_deleted": item_count,
        }

    def clear(self) -> None:
        self._profiles.clear()
        self._wardrobe.clear()
        self._feedback.clear()
        self._audit.clear()
