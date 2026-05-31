from app.models import OutfitFeedback, OutfitRecommendation, ScoreBreakdown
from app.services.personalization import apply_feedback_personalization


def _outfit(outfit_id: str, item_ids: list[str], score: float) -> OutfitRecommendation:
    return OutfitRecommendation(
        outfit_id=outfit_id,
        title=outfit_id,
        item_ids=item_ids,
        score=score,
        score_breakdown=ScoreBreakdown(),
        why="why",
    )


def test_feedback_personalization_reranks_favorites_over_rejections():
    outfits = [
        _outfit("a", ["shirt_1", "trouser_1"], 80),
        _outfit("b", ["shirt_2", "trouser_2"], 82),
    ]
    feedback = [
        OutfitFeedback(
            feedback_id="f1",
            user_id="u1",
            outfit_id="a",
            item_ids=["shirt_1", "trouser_1"],
            favorite=True,
            rating=5,
            created_at="2026-01-01T00:00:00Z",
        ),
        OutfitFeedback(
            feedback_id="f2",
            user_id="u1",
            outfit_id="b",
            item_ids=["shirt_2", "trouser_2"],
            rejected=True,
            rating=1,
            created_at="2026-01-02T00:00:00Z",
        ),
    ]

    personalized = apply_feedback_personalization(outfits, feedback)

    assert personalized[0].outfit_id == "a"
    assert personalized[0].score > outfits[0].score
    assert personalized[-1].outfit_id == "b"
    assert personalized[-1].score < outfits[1].score
