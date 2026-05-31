from fastapi.testclient import TestClient

from app.core.config import get_settings
from app.db.persistent_store import PersistentStore
from app.main import app, store
from app.models import UserProfile, WardrobeItem

client = TestClient(app)


def test_optional_api_key_guard(monkeypatch):
    store.clear()
    monkeypatch.setenv("BHARATFIT_API_KEY", "secret")
    get_settings.cache_clear()
    try:
        missing = client.post("/users/profile", json={"user_id": "secure_user", "style_mode": "mixed"})
        assert missing.status_code == 401

        ok = client.post(
            "/users/profile",
            headers={"X-API-Key": "secret"},
            json={"user_id": "secure_user", "style_mode": "mixed"},
        )
        assert ok.status_code == 200
    finally:
        monkeypatch.delenv("BHARATFIT_API_KEY", raising=False)
        get_settings.cache_clear()


def test_persistent_store_roundtrip(tmp_path):
    db_path = tmp_path / "bharatfit_test.db"
    persistent = PersistentStore(f"sqlite:///{db_path}")

    profile = UserProfile(user_id="u1", style_mode="menswear", skin_tone="medium warm")
    persistent.upsert_profile(profile)
    assert persistent.get_profile("u1") == profile

    item = WardrobeItem(
        user_id="u1",
        item_id="shirt_001",
        style_mode="menswear",
        category="shirt",
        color="light blue",
        occasion_tags=["office"],
        local_image_ref="local://wardrobe/shirt_001.jpg",
    )
    persistent.add_item(item)
    assert persistent.list_items("u1") == [item]
    assert persistent.delete_item("u1", "shirt_001") is True
    assert persistent.list_items("u1") == []


def test_dev_bearer_user_isolation(monkeypatch):
    store.clear()
    monkeypatch.setenv("BHARATFIT_AUTH_MODE", "dev_bearer")
    get_settings.cache_clear()
    try:
        missing = client.post("/users/profile", json={"user_id": "alice", "style_mode": "mixed"})
        assert missing.status_code == 401

        alice_ok = client.post(
            "/users/profile",
            headers={"Authorization": "Bearer dev:alice"},
            json={"user_id": "alice", "style_mode": "mixed"},
        )
        assert alice_ok.status_code == 200

        cross_user = client.post(
            "/users/profile",
            headers={"Authorization": "Bearer dev:alice"},
            json={"user_id": "bob", "style_mode": "mixed"},
        )
        assert cross_user.status_code == 403
    finally:
        monkeypatch.delenv("BHARATFIT_AUTH_MODE", raising=False)
        get_settings.cache_clear()


def test_static_bearer_token_mapping(monkeypatch):
    store.clear()
    monkeypatch.setenv("BHARATFIT_AUTH_MODE", "static_bearer")
    monkeypatch.setenv("BHARATFIT_USER_TOKENS", "token-alice:alice")
    get_settings.cache_clear()
    try:
        ok = client.post(
            "/users/profile",
            headers={"Authorization": "Bearer token-alice"},
            json={"user_id": "alice", "style_mode": "mixed"},
        )
        assert ok.status_code == 200

        forbidden = client.get("/wardrobe/items/bob", headers={"Authorization": "Bearer token-alice"})
        assert forbidden.status_code == 403
    finally:
        monkeypatch.delenv("BHARATFIT_AUTH_MODE", raising=False)
        monkeypatch.delenv("BHARATFIT_USER_TOKENS", raising=False)
        get_settings.cache_clear()
