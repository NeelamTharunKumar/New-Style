from app.models import OutfitRecommendation, ScoreBreakdown, UserProfile, WardrobeItem
from app.services.llm_orchestrator import apply_llm_explanations
from app.services.prompt_templates import build_llm_payload, contains_sensitive_keys


def test_llm_payload_excludes_photo_refs_and_vectors():
    profile = UserProfile(user_id="u1", style_mode="menswear", skin_tone="medium warm")
    item = WardrobeItem(
        user_id="u1",
        item_id="shirt_001",
        category="shirt",
        color="light blue",
        local_image_ref="local://wardrobe/private-shirt-photo.jpg",
        feature_vector_summary={"dominant_color": "light blue", "privacy": "local_only"},
        style_tags=["formal"],
        occasion_tags=["office"],
    )
    outfit = OutfitRecommendation(
        outfit_id="outfit_001",
        title="Rule title",
        item_ids=["shirt_001"],
        score=88,
        score_breakdown=ScoreBreakdown(category_fit=10),
        why="Rule why",
    )

    payload = build_llm_payload(profile=profile, wardrobe=[item], occasion="office", weather=None, outfits=[outfit])
    payload_text = str(payload)

    assert "local_image_ref" not in payload_text
    assert "private-shirt-photo" not in payload_text
    assert "feature_vector_summary" not in payload_text
    assert "embedding" not in payload_text
    assert contains_sensitive_keys(payload) == []


def test_apply_llm_explanations_preserves_item_ids_and_scores():
    original = OutfitRecommendation(
        outfit_id="outfit_001",
        title="Rule title",
        item_ids=["shirt_001", "trouser_001"],
        score=92,
        score_breakdown=ScoreBreakdown(category_fit=25),
        why="Rule explanation",
        styling_tips=["Rule tip"],
        avoid=["Rule avoid"],
    )
    response = {
        "outfits": [
            {
                "outfit_id": "outfit_001",
                "title": "Polished Office Look",
                "item_ids": ["malicious_change"],
                "score": 1,
                "why": "The blue shirt and charcoal trousers are office-appropriate for Indian workwear.",
                "styling_tips": ["Keep the belt and shoes coordinated."],
                "avoid": ["Avoid loud accessories."],
            }
        ]
    }

    enhanced = apply_llm_explanations([original], response)[0]

    assert enhanced.title == "Polished Office Look"
    assert enhanced.item_ids == ["shirt_001", "trouser_001"]
    assert enhanced.score == 92
    assert enhanced.source == "rule_engine+llm_explanation"
    assert "blue shirt" in enhanced.why


def test_wardrobe_item_rejects_sensitive_feature_payloads():
    from pydantic import ValidationError

    try:
        WardrobeItem(
            user_id="u1",
            item_id="bad",
            category="shirt",
            color="blue",
            feature_vector_summary={"raw_image": "base64data"},
        )
    except ValidationError as exc:
        assert "feature_vector_summary" in str(exc)
    else:
        raise AssertionError("sensitive feature payload should be rejected")
