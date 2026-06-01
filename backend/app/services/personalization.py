from __future__ import annotations

from typing import Iterable, List, Sequence

from app.models import OutfitFeedback, OutfitRecommendation


def apply_feedback_personalization(
    outfits: Sequence[OutfitRecommendation],
    feedback_history: Iterable[OutfitFeedback],
) -> List[OutfitRecommendation]:
    """Adjust outfit scores using privacy-safe explicit feedback.

    This never changes item IDs. It only reranks/annotates generated outfits based on
    ratings, favorites, rejections and worn history for the same user.
    """
    history = list(feedback_history)
    if not history:
        return list(outfits)

    personalized: List[OutfitRecommendation] = []
    for outfit in outfits:
        item_set = set(outfit.item_ids)
        exact_matches = [fb for fb in history if set(fb.item_ids) == item_set or fb.outfit_id == outfit.outfit_id]
        overlap_matches = [fb for fb in history if item_set and set(fb.item_ids).intersection(item_set)]

        delta = 0.0
        reasons: list[str] = []

        for fb in exact_matches:
            if fb.rejected:
                delta -= 28
                reasons.append("You previously rejected this exact combination, so it is ranked lower.")
            if fb.favorite:
                delta += 14
                reasons.append("You previously favorited this combination, so it is ranked higher.")
            if fb.rating:
                delta += (fb.rating - 3) * 5
            if fb.worn:
                delta -= 6
                reasons.append("This exact look was worn before, so repeat frequency is controlled.")

        if not exact_matches:
            for fb in overlap_matches:
                overlap = len(set(fb.item_ids).intersection(item_set)) / max(len(item_set), 1)
                if fb.rejected:
                    delta -= 8 * overlap
                if fb.favorite:
                    delta += 5 * overlap
                if fb.rating:
                    delta += (fb.rating - 3) * 1.5 * overlap

        updated_score = round(max(0.0, min(100.0, outfit.score + delta)), 2)
        tips = list(outfit.styling_tips)
        if reasons:
            tips = (tips + reasons)[:5]

        source = outfit.source
        if delta != 0:
            source = f"{source}+feedback_personalization"

        personalized.append(outfit.model_copy(update={"score": updated_score, "styling_tips": tips, "source": source}))

    personalized.sort(key=lambda item: item.score, reverse=True)
    return personalized
