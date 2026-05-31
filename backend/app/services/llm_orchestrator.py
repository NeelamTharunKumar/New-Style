from __future__ import annotations

import json
import os
from typing import Any, Dict, List, Mapping, Sequence

import httpx

from app.models import OutfitRecommendation, UserProfile, WardrobeItem, WeatherContext
from app.services.prompt_templates import (
    SYSTEM_PROMPT,
    USER_PROMPT_TEMPLATE,
    build_llm_payload,
    contains_sensitive_keys,
)


class LLMOrchestrator:
    """Thin, optional LLM adapter for explanations only.

    It never sends raw photos, local image refs, or embeddings. The deterministic
    outfit engine remains the source of truth for selected item IDs and scores.
    """

    def __init__(self) -> None:
        self.enabled = os.getenv("BHARATFIT_LLM_ENABLED", "false").lower() in {"1", "true", "yes"}
        self.api_key = os.getenv("OPENAI_API_KEY") or os.getenv("BHARATFIT_LLM_API_KEY")
        self.base_url = os.getenv("BHARATFIT_LLM_BASE_URL", "https://api.openai.com/v1/chat/completions")
        self.model = os.getenv("BHARATFIT_LLM_MODEL", "gpt-4o-mini")
        self.timeout = float(os.getenv("BHARATFIT_LLM_TIMEOUT_SECONDS", "20"))

    def status(self) -> Dict[str, Any]:
        return {
            "enabled": self.enabled,
            "configured": bool(self.api_key),
            "model": self.model,
            "purpose": "explanation_only",
            "privacy": "LLM receives structured features only; no photos, local image refs, or embeddings.",
        }

    async def explain_outfits(
        self,
        *,
        profile: UserProfile,
        wardrobe: Sequence[WardrobeItem],
        occasion: str,
        weather: WeatherContext | None,
        outfits: Sequence[OutfitRecommendation],
    ) -> List[OutfitRecommendation]:
        if not outfits:
            return []
        if not self.enabled or not self.api_key:
            return list(outfits)

        payload = build_llm_payload(
            profile=profile,
            wardrobe=wardrobe,
            occasion=occasion,
            weather=weather,
            outfits=outfits,
        )
        sensitive_hits = contains_sensitive_keys(payload)
        if sensitive_hits:
            # Hard fail closed: never call LLM with sensitive payload keys.
            return list(outfits)

        try:
            raw = await self._call_llm(payload)
            return apply_llm_explanations(outfits, raw)
        except Exception:
            # Fallback must be silent and deterministic for user experience.
            return list(outfits)

    async def _call_llm(self, payload: Mapping[str, Any]) -> Mapping[str, Any]:
        prompt = USER_PROMPT_TEMPLATE.format(payload=json.dumps(payload, ensure_ascii=False))
        request_body = {
            "model": self.model,
            "response_format": {"type": "json_object"},
            "messages": [
                {"role": "system", "content": SYSTEM_PROMPT},
                {"role": "user", "content": prompt},
            ],
            "temperature": 0.2,
        }
        headers = {
            "Authorization": f"Bearer {self.api_key}",
            "Content-Type": "application/json",
        }
        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(self.base_url, headers=headers, json=request_body)
            response.raise_for_status()
            data = response.json()

        content = data["choices"][0]["message"]["content"]
        parsed = json.loads(content)
        if not isinstance(parsed, dict):
            raise ValueError("LLM response must be a JSON object")
        return parsed


def apply_llm_explanations(
    outfits: Sequence[OutfitRecommendation],
    llm_response: Mapping[str, Any],
) -> List[OutfitRecommendation]:
    """Apply strict explanation fields while preserving item IDs and scores."""
    raw_outfits = llm_response.get("outfits")
    if not isinstance(raw_outfits, list):
        return list(outfits)

    by_id: Dict[str, Mapping[str, Any]] = {}
    for item in raw_outfits:
        if isinstance(item, Mapping) and isinstance(item.get("outfit_id"), str):
            by_id[item["outfit_id"]] = item

    enhanced: List[OutfitRecommendation] = []
    for outfit in outfits:
        patch = by_id.get(outfit.outfit_id)
        if not patch:
            enhanced.append(outfit)
            continue

        title = _safe_text(patch.get("title"), outfit.title, max_len=90)
        why = _safe_text(patch.get("why"), outfit.why, max_len=700)
        styling_tips = _safe_string_list(patch.get("styling_tips"), outfit.styling_tips, max_items=5, max_len=180)
        avoid = _safe_string_list(patch.get("avoid"), outfit.avoid, max_items=4, max_len=180)

        enhanced.append(
            outfit.model_copy(
                update={
                    "title": title,
                    "why": why,
                    "styling_tips": styling_tips,
                    "avoid": avoid,
                    "source": "rule_engine+llm_explanation",
                }
            )
        )
    return enhanced


def _safe_text(value: Any, fallback: str, max_len: int) -> str:
    if not isinstance(value, str):
        return fallback
    value = value.strip()
    if not value:
        return fallback
    return value[:max_len]


def _safe_string_list(value: Any, fallback: Sequence[str], *, max_items: int, max_len: int) -> List[str]:
    if not isinstance(value, list):
        return list(fallback)
    result = []
    for item in value:
        if isinstance(item, str) and item.strip():
            result.append(item.strip()[:max_len])
        if len(result) >= max_items:
            break
    return result or list(fallback)
