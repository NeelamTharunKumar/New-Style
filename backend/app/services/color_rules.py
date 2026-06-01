from __future__ import annotations

import math
from typing import Iterable, Optional, Tuple

NEUTRALS = {"white", "black", "grey", "gray", "charcoal", "cream", "beige", "navy", "denim", "brown", "tan"}
WARM_COLORS = {"yellow", "mustard", "orange", "coral", "peach", "rust", "maroon", "olive", "gold", "brown", "cream", "beige"}
COOL_COLORS = {"blue", "navy", "teal", "green", "emerald", "purple", "lavender", "silver", "grey", "gray"}
FESTIVE_COLORS = {"yellow", "mustard", "orange", "pink", "red", "maroon", "green", "emerald", "gold", "purple"}

COLOR_FAMILIES = {
    "blue": {"blue", "navy", "sky", "royal", "teal", "denim"},
    "green": {"green", "olive", "emerald", "mint", "teal"},
    "red": {"red", "maroon", "burgundy", "wine", "pink", "coral"},
    "yellow": {"yellow", "mustard", "gold"},
    "neutral": NEUTRALS,
    "earth": {"brown", "tan", "beige", "khaki", "cream", "olive", "rust"},
}

HARMONY_PAIRS = {
    ("navy", "beige"),
    ("blue", "beige"),
    ("blue", "white"),
    ("white", "black"),
    ("black", "grey"),
    ("black", "charcoal"),
    ("cream", "maroon"),
    ("mustard", "white"),
    ("yellow", "white"),
    ("green", "gold"),
    ("emerald", "gold"),
    ("pink", "white"),
    ("olive", "cream"),
    ("brown", "cream"),
}


def normalize_color(color: Optional[str]) -> str:
    return (color or "").strip().lower().replace("-", " ")


def color_tokens(color: Optional[str]) -> set[str]:
    normalized = normalize_color(color)
    return {token for token in normalized.split() if token}


def hex_to_rgb(hex_color: str) -> Tuple[int, int, int]:
    value = hex_color.strip().lstrip("#")
    return int(value[0:2], 16), int(value[2:4], 16), int(value[4:6], 16)


def rgb_distance(hex_a: str, hex_b: str) -> float:
    ra, ga, ba = hex_to_rgb(hex_a)
    rb, gb, bb = hex_to_rgb(hex_b)
    return math.sqrt((ra - rb) ** 2 + (ga - gb) ** 2 + (ba - bb) ** 2)


def _contains_any(color: str, options: Iterable[str]) -> bool:
    tokens = color_tokens(color)
    return bool(tokens.intersection(options))


def is_neutral(color: str) -> bool:
    return _contains_any(color, NEUTRALS)


def is_festive(color: str) -> bool:
    return _contains_any(color, FESTIVE_COLORS)


def color_harmony_score(colors: list[str], hex_colors: Optional[list[str]] = None) -> float:
    colors = [normalize_color(c) for c in colors if c]
    if len(colors) <= 1:
        return 14.0

    score = 10.0
    neutral_count = sum(1 for c in colors if is_neutral(c))
    if neutral_count:
        score += min(6.0, neutral_count * 2.0)

    for i, c1 in enumerate(colors):
        for c2 in colors[i + 1 :]:
            t1, t2 = color_tokens(c1), color_tokens(c2)
            if t1.intersection(t2):
                score += 1.5
            for a in t1:
                for b in t2:
                    if (a, b) in HARMONY_PAIRS or (b, a) in HARMONY_PAIRS:
                        score += 4.0

    if hex_colors and len(hex_colors) >= 2:
        distances = []
        for i, h1 in enumerate(hex_colors):
            for h2 in hex_colors[i + 1 :]:
                try:
                    distances.append(rgb_distance(h1, h2))
                except Exception:
                    pass
        if distances:
            avg = sum(distances) / len(distances)
            if 60 <= avg <= 230:
                score += 3.0
            elif avg < 30:
                score += 1.0

    return round(max(0.0, min(score, 20.0)), 2)


def skin_tone_score(colors: list[str], skin_tone: Optional[str]) -> float:
    if not skin_tone:
        return 5.0
    tone = skin_tone.lower()
    score = 5.0
    joined = " ".join(colors).lower()
    if "warm" in tone:
        if _contains_any(joined, WARM_COLORS):
            score += 3.0
        if _contains_any(joined, {"emerald", "teal", "navy"}):
            score += 1.5
    if "cool" in tone:
        if _contains_any(joined, COOL_COLORS):
            score += 3.0
        if _contains_any(joined, {"pink", "lavender", "silver"}):
            score += 1.5
    if "dusky" in tone or "deep" in tone:
        if _contains_any(joined, {"mustard", "emerald", "maroon", "cream", "royal", "teal", "gold"}):
            score += 2.0
    if "neutral" in tone:
        score += 1.0
    return round(max(0.0, min(score, 10.0)), 2)
