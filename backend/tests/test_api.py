from fastapi.testclient import TestClient

from app.main import app, store

client = TestClient(app)


def setup_function():
    store.clear()


def test_health_privacy_contract():
    resp = client.get("/health")
    assert resp.status_code == 200
    body = resp.json()
    assert body["status"] == "ok"
    assert "No raw" in body["privacy"]


def test_add_items_and_generate_menswear_office_outfit():
    client.post(
        "/users/profile",
        json={
            "user_id": "u1",
            "style_mode": "menswear",
            "skin_tone": "medium warm",
            "preferences": ["smart casual", "minimal", "budget-conscious"],
        },
    )
    items = [
        {"user_id": "u1", "item_id": "shirt_001", "style_mode": "menswear", "category": "shirt", "color": "light blue", "fabric": "cotton", "formality": 8, "style_tags": ["formal", "minimal"], "occasion_tags": ["office"]},
        {"user_id": "u1", "item_id": "trouser_001", "style_mode": "menswear", "category": "trousers", "color": "charcoal", "fabric": "cotton", "formality": 8, "style_tags": ["formal"], "occasion_tags": ["office"]},
        {"user_id": "u1", "item_id": "shoe_001", "style_mode": "menswear", "category": "loafers", "color": "brown", "formality": 7, "style_tags": ["smart casual"], "occasion_tags": ["office", "date"]},
    ]
    for item in items:
        assert client.post("/wardrobe/items", json=item).status_code == 201

    resp = client.post(
        "/outfits/generate",
        json={"user_id": "u1", "occasion": "office", "weather": {"temperature_c": 34, "condition": "hot_humid"}},
    )
    assert resp.status_code == 200
    body = resp.json()
    assert body["outfits"]
    top = body["outfits"][0]
    assert "shirt_001" in top["item_ids"]
    assert "trouser_001" in top["item_ids"]
    assert top["score"] > 60


def test_stateless_womenswear_haldi_outfit_uses_structured_data_only():
    resp = client.post(
        "/outfits/generate",
        json={
            "user_id": "u2",
            "occasion": "haldi",
            "style_mode": "womenswear",
            "user_profile": {
                "user_id": "u2",
                "style_mode": "womenswear",
                "skin_tone": "medium warm",
                "preferences": ["ethnic", "festive", "budget-conscious"],
                "climate_preference": "hot_humid"
            },
            "wardrobe_items": [
                {"user_id": "u2", "item_id": "kurti_001", "style_mode": "womenswear", "category": "kurti", "color": "mustard yellow", "fabric": "cotton", "formality": 7, "style_tags": ["ethnic", "festive"], "occasion_tags": ["haldi"]},
                {"user_id": "u2", "item_id": "palazzo_001", "style_mode": "womenswear", "category": "palazzo", "color": "white", "fabric": "cotton", "formality": 5, "style_tags": ["ethnic"], "occasion_tags": ["haldi", "festival"]},
                {"user_id": "u2", "item_id": "juttis_001", "style_mode": "womenswear", "category": "juttis", "color": "gold", "formality": 7, "style_tags": ["ethnic", "festive"], "occasion_tags": ["haldi", "wedding guest"]},
            ],
            "weather": {"temperature_c": 33, "condition": "hot_humid"},
        },
    )
    assert resp.status_code == 200
    body = resp.json()
    assert "No raw" in body["privacy"]
    assert body["outfits"]
    assert any("kurti_001" in outfit["item_ids"] for outfit in body["outfits"])


def test_outfit_feedback_history_flow():
    store.clear()
    payload = {
        "user_id": "u_feedback",
        "outfit_id": "outfit_001",
        "item_ids": ["shirt_001", "trouser_001"],
        "occasion": "office",
        "rating": 5,
        "worn": True,
        "favorite": True,
        "notes": "Worked well",
    }
    created = client.post("/outfits/feedback", json=payload)
    assert created.status_code == 200
    body = created.json()
    assert body["feedback_id"].startswith("feedback_")
    assert body["rating"] == 5

    history = client.get("/outfits/history/u_feedback")
    assert history.status_code == 200
    assert len(history.json()) == 1
    assert history.json()[0]["item_ids"] == ["shirt_001", "trouser_001"]
