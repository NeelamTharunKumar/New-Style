from __future__ import annotations

from typing import Any, Dict, List, Sequence

from app.models import OutfitRecommendation, UserProfile, WardrobeItem, WeatherContext

SYSTEM_PROMPT = """You are Drape AI's explanation layer.

You explain outfit recommendations for Indian users using structured data only.
You must never ask for or infer from raw photos. You must not claim to see images.
You cannot change outfit item IDs, scores, or selected items.
You can only improve title, why, styling_tips, and avoid notes.

Return strict JSON only. No markdown. No commentary.
"""

USER_PROMPT_TEMPLATE = """Create concise India-first outfit explanations from the structured JSON below.

Rules:
- Do not change outfit_id or item choices.
- Do not mention that you saw photos/images.
- Use Indian context: weather, comfort, occasion, modesty when relevant, ethnic/western balance.
- Keep tips practical and budget-conscious.
- If local image refs or photos are missing, do not mention it.
- Output JSON schema exactly:
{
  "outfits": [
    {
      "outfit_id": "string",
      "title": "string",
      "why": "string",
      "styling_tips": ["string", "string"],
      "avoid": ["string"]
    }
  ]
}

Structured data:
{payload}
"""

SENSITIVE_KEYS = {
    "local_image_ref",
    "feature_vector_summary",
    "clip_embedding",
    "embedding",
    "image",
    "image_bytes",
    "photo",
    "selfie",
    "raw_image",
    "face_image",
    "body_image",
}


def sanitize_item_for_llm(item: WardrobeItem) -> Dict[str, Any]:
    """Return semantic item features only. No photo refs or raw vectors."""
    data = item.model_dump()
    sanitized: Dict[str, Any] = {}
    allowed = {
        "item_id",
        "style_mode",
        "name",
        "category",
        "subcategory",
        "color",
        "hex_color",
        "secondary_colors",
        "pattern",
        "fabric",
        "fit",
        "sleeve",
        "neckline",
        "length",
        "formality",
        "style_tags",
        "occasion_tags",
        "season_tags",
        "climate_tags",
        "india_tags",
    }
    for key in allowed:
        value = data.get(key)
        if value is None or value == [] or value == {}:
            continue
        sanitized[key] = value
    return sanitized




def occasion_guidance(occasion: str) -> Dict[str, Any]:
    normalized = occasion.strip().lower()
    guidance = {
        "haldi": {
            "color_mood": ["yellow", "white", "green"],
            "advice": ["prefer washable fabrics", "choose comfortable footwear", "avoid delicate pieces if staining is likely"],
        },
        "sangeet": {
            "color_mood": ["festive", "bold", "jewel tones"],
            "advice": ["dance-friendly fit", "avoid restrictive silhouettes", "statement accessory is acceptable"],
        },
        "wedding guest": {
            "color_mood": ["elevated", "ethnic", "fusion"],
            "advice": ["avoid underdressed combinations", "consider jewelry intensity", "balance festive with comfort"],
        },
        "office": {
            "color_mood": ["polished", "neutral", "smart contrast"],
            "advice": ["breathable fabrics", "AC-friendly layer if available", "avoid overly flashy combinations"],
        },
        "date": {
            "color_mood": ["smart casual", "clean", "warm accents"],
            "advice": ["clean shoes", "one polished accessory", "avoid gymwear unless context is explicitly casual"],
        },
        "college": {
            "color_mood": ["comfortable", "repeat-friendly", "casual"],
            "advice": ["comfortable footwear", "weather-safe fabrics", "budget-conscious remixing"],
        },
    }
    return guidance.get(normalized, {"advice": ["keep the explanation practical, respectful and occasion-aware"]})


def build_llm_payload(
    *,
    profile: UserProfile,
    wardrobe: Sequence[WardrobeItem],
    occasion: str,
    weather: WeatherContext | None,
    outfits: Sequence[OutfitRecommendation],
) -> Dict[str, Any]:
    items_by_id = {item.item_id: sanitize_item_for_llm(item) for item in wardrobe}
    return {
        "privacy_contract": "Structured features only. No raw photos, local image refs, vectors, or image bytes are included.",
        "occasion": occasion,
        "occasion_guidance": occasion_guidance(occasion),
        "weather": weather.model_dump(exclude_none=True) if weather else None,
        "user_profile": {
            "user_id": profile.user_id,
            "style_mode": profile.style_mode.value if hasattr(profile.style_mode, "value") else profile.style_mode,
            "region": profile.region,
            "climate_preference": profile.climate_preference,
            "skin_tone": profile.skin_tone,
            "body_shape": profile.body_shape,
            "preferences": profile.preferences,
            "modesty_preference": profile.modesty_preference,
            "budget_conscious": profile.budget_conscious,
        },
        "candidate_outfits": [
            {
                "outfit_id": outfit.outfit_id,
                "item_ids": outfit.item_ids,
                "score": outfit.score,
                "score_breakdown": outfit.score_breakdown.model_dump(),
                "rule_title": outfit.title,
                "rule_why": outfit.why,
                "items": [items_by_id[item_id] for item_id in outfit.item_ids if item_id in items_by_id],
            }
            for outfit in outfits
        ],
    }


def contains_sensitive_keys(value: Any) -> List[str]:
    """Return sensitive key paths found in a nested payload."""
    hits: List[str] = []

    def walk(node: Any, path: str) -> None:
        if isinstance(node, dict):
            for key, child in node.items():
                next_path = f"{path}.{key}" if path else str(key)
                if key in SENSITIVE_KEYS:
                    hits.append(next_path)
                walk(child, next_path)
        elif isinstance(node, list):
            for index, child in enumerate(node):
                walk(child, f"{path}[{index}]")

    walk(value, "")
    return hits
