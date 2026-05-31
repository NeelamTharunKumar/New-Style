from __future__ import annotations

from typing import List, Optional

from sqlalchemy import Column, String, Text, create_engine
from sqlalchemy.orm import Session, declarative_base, sessionmaker

from app.models import UserProfile, WardrobeItem

Base = declarative_base()


class UserProfileRecord(Base):
    __tablename__ = "user_profiles"

    user_id = Column(String(128), primary_key=True)
    profile_json = Column(Text, nullable=False)


class WardrobeItemRecord(Base):
    __tablename__ = "wardrobe_items"

    user_id = Column(String(128), primary_key=True)
    item_id = Column(String(128), primary_key=True)
    item_json = Column(Text, nullable=False)


class PersistentStore:
    """SQLAlchemy-backed store for SQLite/Postgres-compatible persistence."""

    def __init__(self, database_url: str) -> None:
        connect_args = {"check_same_thread": False} if database_url.startswith("sqlite") else {}
        self.engine = create_engine(database_url, pool_pre_ping=True, connect_args=connect_args)
        self.SessionLocal = sessionmaker(bind=self.engine, autocommit=False, autoflush=False)
        Base.metadata.create_all(bind=self.engine)

    def upsert_profile(self, profile: UserProfile) -> UserProfile:
        with self._session() as session:
            existing = session.get(UserProfileRecord, profile.user_id)
            payload = profile.model_dump_json()
            if existing:
                existing.profile_json = payload
            else:
                session.add(UserProfileRecord(user_id=profile.user_id, profile_json=payload))
            session.commit()
        return profile

    def get_profile(self, user_id: str) -> Optional[UserProfile]:
        with self._session() as session:
            record = session.get(UserProfileRecord, user_id)
            if not record:
                return None
            return UserProfile.model_validate_json(record.profile_json)

    def add_item(self, item: WardrobeItem) -> WardrobeItem:
        with self._session() as session:
            existing = session.get(WardrobeItemRecord, {"user_id": item.user_id, "item_id": item.item_id})
            payload = item.model_dump_json()
            if existing:
                existing.item_json = payload
            else:
                session.add(WardrobeItemRecord(user_id=item.user_id, item_id=item.item_id, item_json=payload))
            session.commit()
        return item

    def list_items(self, user_id: str) -> List[WardrobeItem]:
        with self._session() as session:
            records = session.query(WardrobeItemRecord).filter(WardrobeItemRecord.user_id == user_id).all()
            return [WardrobeItem.model_validate_json(record.item_json) for record in records]

    def delete_item(self, user_id: str, item_id: str) -> bool:
        with self._session() as session:
            record = session.get(WardrobeItemRecord, {"user_id": user_id, "item_id": item_id})
            if not record:
                return False
            session.delete(record)
            session.commit()
            return True


    def export_user(self, user_id: str) -> dict:
        return {
            "profile": self.get_profile(user_id),
            "wardrobe_items": self.list_items(user_id),
        }

    def delete_user(self, user_id: str) -> dict:
        with self._session() as session:
            item_count = session.query(WardrobeItemRecord).filter(WardrobeItemRecord.user_id == user_id).delete()
            profile_count = session.query(UserProfileRecord).filter(UserProfileRecord.user_id == user_id).delete()
            session.commit()
            return {
                "profile_deleted": profile_count > 0,
                "wardrobe_items_deleted": item_count,
            }

    def clear(self) -> None:
        with self._session() as session:
            session.query(WardrobeItemRecord).delete()
            session.query(UserProfileRecord).delete()
            session.commit()

    def _session(self) -> Session:
        return self.SessionLocal()
