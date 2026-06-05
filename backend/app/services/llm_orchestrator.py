from __future__ import annotations

import hashlib
import json
import os
from collections import defaultdict
from datetime import date
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
        enabled_value = os.getenv("DRAPE_LLM_ENABLED", "false")
        self.enabled = enabled_value.lower() in {"1", "true", "yes"}
        self.api_key = os.getenv("OPENAI_API_KEY") or os.getenv("DRAPE_LLM_API_KEY")
        self.base_url = os.getenv("DRAPE_LLM_BASE_URL", "https://api.openai.com/v1/chat/completions")
        self.model = os.getenv("DRAPE_LLM_MODEL", "gpt-4o-mini")
        self.timeout = float(os.getenv("DRAPE_LLM_TIMEOUT_SECONDS", "20"))
        self.daily_limit_per_user = int(os.getenv("DRAPE_LLM_DAILY_LIMIT_PER_USER", "50"))
        self._cache: dict[str, Mapping[str, Any]] = {}
        self._calls_by_user_day: dict[tuple[str, str], int] = defaultdict(int)

    def status(self) -> Dict[str, Any]:
        return {
            "enabled": self.enabled,
            "configured": bool(self.api_key),
            "model": self.model,
            "purpose": "explanation_only",
            "daily_limit_per_user": self.daily_limit_per_user,
            "cache_entries": len(self._cache),
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
            cache_key = self._cache_key(payload)
            if cache_key in self._cache:
                return apply_llm_explanations(outfits, self._cache[cache_key])
            if not self._reserve_call(profile.user_id):
                return list(outfits)
            raw = await self._call_llm(payload)
            self._trim_cache()
            self._cache[cache_key] = raw
            return apply_llm_explanations(outfits, raw)
        except Exception as exc:
            logger = __import__("logging").getLogger("drape.llm")
            logger.warning("LLM explanation failed: %s", exc, exc_info=True)
            return list(outfits)

    def _cache_key(self, payload: Mapping[str, Any]) -> str:
        text = json.dumps(payload, sort_keys=True, ensure_ascii=False)
        return hashlib.sha256(text.encode("utf-8")).hexdigest()

    def _trim_cache(self) -> None:
        if len(self._cache) > 500:
            self._cache.clear()

    def _reserve_call(self, user_id: str) -> bool:
        if self.daily_limit_per_user <= 0:
            return True
        key = (user_id, date.today().isoformat())
        if self._calls_by_user_day[key] >= self.daily_limit_per_user:
            return False
        self._calls_by_user_day[key] += 1
        return True

    async def _call_llm(self, payload: Mapping[str, Any]) -> Mapping[str, Any]:
        prompt = USER_PROMPT_TEMPLATE.replace("{payload}", json.dumps(payload, ensure_ascii=False))
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
