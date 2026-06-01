from __future__ import annotations

from itertools import product
from typing import Dict, Iterable, List, Optional, Sequence
from uuid import uuid4

from app.models import OutfitRecommendation, ScoreBreakdown, StyleMode, UserProfile, WardrobeItem, WeatherContext
from app.services.color_rules import color_harmony_score, is_festive, skin_tone_score

TOPS = {"shirt", "t-shirt", "tee", "polo", "top", "kurti", "kurta", "blouse", "dress", "anarkali", "kurta set"}
BOTTOMS = {"jeans", "chinos", "trousers", "trouser", "palazzo", "leggings", "skirt", "salwar", "churidar", "dhoti"}
FOOTWEAR = {"sneakers", "sneaker", "loafers", "formal shoes", "shoes", "sandals", "heels", "juttis", "jooti", "flats"}
LAYERING = {"blazer", "nehru jacket", "ethnic jacket", "jacket", "dupatta"}
ACCESSORIES = {"watch", "belt", "jewelry", "handbag", "bag", "earrings", "necklace", "grooming"}
ETHNIC_ONE_PIECE = {"saree", "lehenga", "sherwani", "anarkali", "kurta set", "dress"}

OCCASION_ALIASES = {
    "work": "office",
    "meeting": "office",
    "business meeting": "office",
    "job interview": "interview",
    "wedding": "wedding guest",
    "marriage": "wedding guest",
    "function": "family function",
    "party": "date",
    "daily": "daily casual",
}

OCCASION_RULES: Dict[str, Dict[str, object]] = {
    "college": {"formality": (2, 6), "preferred": {"t-shirt", "shirt", "kurti", "jeans", "palazzo", "sneakers", "juttis", "sandals"}, "style": {"casual", "smart casual", "budget-conscious"}},
    "office": {"formality": (6, 9), "preferred": {"shirt", "polo", "trousers", "chinos", "kurti", "palazzo", "blazer", "loafers", "formal shoes"}, "style": {"formal", "smart casual", "minimal"}},
    "interview": {"formality": (7, 10), "preferred": {"shirt", "blazer", "trousers", "formal shoes", "kurti", "saree", "loafers"}, "style": {"formal", "minimal"}},
    "date": {"formality": (4, 8), "preferred": {"shirt", "polo", "top", "dress", "jeans", "chinos", "skirt", "loafers", "sneakers", "heels"}, "style": {"smart casual", "elegant", "minimal"}},
    "daily casual": {"formality": (1, 6), "preferred": {"t-shirt", "shirt", "kurti", "jeans", "leggings", "sandals", "sneakers"}, "style": {"casual", "comfortable", "budget-conscious"}},
    "travel": {"formality": (1, 6), "preferred": {"t-shirt", "shirt", "kurti", "jeans", "palazzo", "sneakers", "sandals"}, "style": {"comfortable", "casual"}},
    "wedding guest": {"formality": (7, 10), "preferred": {"saree", "lehenga", "blouse", "kurta", "sherwani", "nehru jacket", "anarkali", "jewelry", "juttis", "heels"}, "style": {"ethnic", "traditional", "festive", "elegant"}},
    "haldi": {"formality": (5, 9), "preferred": {"kurta", "kurti", "lehenga", "dupatta", "palazzo", "churidar", "juttis", "sandals", "jewelry"}, "style": {"ethnic", "traditional", "festive"}, "colors": {"yellow", "mustard", "white", "cream", "green"}},
    "sangeet": {"formality": (6, 10), "preferred": {"lehenga", "saree", "anarkali", "kurta", "sherwani", "nehru jacket", "heels", "juttis", "jewelry"}, "style": {"ethnic", "festive", "elegant"}},
    "mehendi": {"formality": (5, 9), "preferred": {"kurta", "kurti", "lehenga", "palazzo", "dupatta", "juttis", "jewelry"}, "style": {"ethnic", "festive"}, "colors": {"green", "yellow", "mustard", "pink", "orange"}},
    "reception": {"formality": (8, 10), "preferred": {"saree", "lehenga", "blazer", "sherwani", "anarkali", "formal shoes", "heels", "jewelry"}, "style": {"formal", "elegant", "festive"}},
    "pooja": {"formality": (4, 8), "preferred": {"kurta", "kurti", "saree", "dupatta", "churidar", "palazzo", "juttis", "sandals"}, "style": {"traditional", "modest", "ethnic"}},
    "festival": {"formality": (5, 9), "preferred": {"kurta", "kurti", "saree", "lehenga", "dupatta", "juttis", "jewelry", "nehru jacket"}, "style": {"traditional", "ethnic", "festive"}},
    "family function": {"formality": (5, 8), "preferred": {"kurta", "kurti", "saree", "shirt", "chinos", "dupatta", "juttis", "loafers"}, "style": {"traditional", "smart casual", "modest"}},
    "monsoon day": {"formality": (1, 7), "preferred": {"shirt", "t-shirt", "kurti", "jeans", "trousers", "sandals", "sneakers"}, "style": {"comfortable", "casual"}},
    "summer day": {"formality": (1, 7), "preferred": {"shirt", "t-shirt", "kurti", "palazzo", "chinos", "sandals", "sneakers"}, "style": {"comfortable", "casual"}},
}


def normalize_occasion(occasion: str) -> str:
    normalized = occasion.strip().lower()
    return OCCASION_ALIASES.get(normalized, normalized)


class OutfitEngine:
    def generate(
        self,
        *,
        user_id: str,
        profile: UserProfile,
        wardrobe: Sequence[WardrobeItem],
        occasion: str,
        weather: Optional[WeatherContext] = None,
        style_mode: Optional[StyleMode] = None,
        max_results: int = 5,
    ) -> List[OutfitRecommendation]:
        occasion = normalize_occasion(occasion)
        mode = style_mode or profile.style_mode
        user_items = [item for item in wardrobe if item.user_id == user_id]
        if mode != StyleMode.mixed:
            mode_items = [item for item in user_items if item.style_mode in {mode, StyleMode.mixed}]
            if mode_items:
                user_items = mode_items

        candidates = self._candidate_combinations(user_items, occasion, mode)
        scored = [self._score_candidate(c, profile, occasion, weather) for c in candidates]
        scored = [s for s in scored if s.score > 0]
        scored.sort(key=lambda rec: rec.score, reverse=True)
        return scored[:max_results]

    def _candidate_combinations(self, items: Sequence[WardrobeItem], occasion: str, mode: StyleMode) -> List[List[WardrobeItem]]:
        if not items:
            return []

        tops = self._filter(items, TOPS)
        bottoms = self._filter(items, BOTTOMS)
        footwear = self._filter(items, FOOTWEAR)
        layers = self._filter(items, LAYERING)
        accessories = self._filter(items, ACCESSORIES)
        one_piece = self._filter(items, ETHNIC_ONE_PIECE)

        candidates: List[List[WardrobeItem]] = []

        # Western / smart-casual formula: top + bottom + footwear + optional accessory/layer.
        for top, bottom in product(tops, bottoms):
            if top.item_id == bottom.item_id:
                continue
            shoes = footwear or [None]
            for shoe in shoes[:10]:
                combo = [top, bottom] + ([shoe] if shoe else [])
                self._append_optional(combo, layers, occasion)
                self._append_optional(combo, accessories, occasion)
                candidates.append(self._unique(combo))

        # Indian / one-piece formulas: saree+blouse, lehenga+dupatta, kurta/kurti+bottom, sherwani+footwear.
        sarees = [i for i in items if self._cat(i) == "saree"]
        blouses = [i for i in items if self._cat(i) == "blouse"]
        for saree, blouse in product(sarees, blouses or [None]):
            combo = [saree] + ([blouse] if blouse else [])
            self._append_optional(combo, footwear, occasion)
            self._append_optional(combo, accessories, occasion)
            candidates.append(self._unique(combo))

        lehengas = [i for i in items if self._cat(i) == "lehenga"]
        dupattas = [i for i in items if self._cat(i) == "dupatta"]
        for lehenga in lehengas:
            combo = [lehenga]
            self._append_optional(combo, dupattas, occasion)
            self._append_optional(combo, footwear, occasion)
            self._append_optional(combo, accessories, occasion)
            candidates.append(self._unique(combo))

        ethnic_tops = [i for i in items if self._cat(i) in {"kurta", "kurti", "anarkali", "sherwani", "kurta set"}]
        ethnic_bottoms = [i for i in items if self._cat(i) in {"palazzo", "leggings", "churidar", "salwar", "dhoti", "trousers"}]
        for top in ethnic_tops:
            if self._cat(top) in {"anarkali", "sherwani", "kurta set"}:
                combo = [top]
                self._append_optional(combo, layers, occasion)
                self._append_optional(combo, footwear, occasion)
                self._append_optional(combo, accessories, occasion)
                candidates.append(self._unique(combo))
            for bottom in ethnic_bottoms:
                if top.item_id == bottom.item_id:
                    continue
                combo = [top, bottom]
                self._append_optional(combo, dupattas, occasion)
                self._append_optional(combo, footwear, occasion)
                self._append_optional(combo, accessories, occasion)
                candidates.append(self._unique(combo))

        # Fallback: if wardrobe is tiny, return useful 2-item pairings.
        if not candidates:
            for i, first in enumerate(items):
                for second in items[i + 1 :]:
                    candidates.append([first, second])

        # Limit combinatorial explosion but keep deterministic ordering.
        dedup: Dict[str, List[WardrobeItem]] = {}
        for combo in candidates:
            key = ":".join(sorted(item.item_id for item in combo))
            if len(combo) >= 2:
                dedup[key] = combo
        return list(dedup.values())[:500]

    def _score_candidate(
        self,
        combo: Sequence[WardrobeItem],
        profile: UserProfile,
        occasion: str,
        weather: Optional[WeatherContext],
    ) -> OutfitRecommendation:
        rules = OCCASION_RULES.get(occasion, OCCASION_RULES["daily casual"])
        categories = {self._cat(i) for i in combo}
        colors = [i.color for i in combo]
        hex_colors = [i.hex_color for i in combo if i.hex_color]
        all_tags = self._tags(combo)

        category_fit = self._category_fit(categories, occasion)
        occasion_fit = self._occasion_fit(combo, occasion, rules)
        formality_fit = self._formality_fit(combo, rules)
        color_score = color_harmony_score(colors, hex_colors)
        skin_score = skin_tone_score(colors, profile.skin_tone)
        climate_score = self._climate_fit(combo, weather, profile)
        preference_score = self._preference_fit(all_tags, profile.preferences)
        india_score = self._india_context_fit(combo, occasion, rules)

        breakdown = ScoreBreakdown(
            category_fit=category_fit,
            occasion_fit=occasion_fit,
            formality_fit=formality_fit,
            color_harmony=color_score,
            skin_tone_fit=skin_score,
            climate_fit=climate_score,
            style_preference_fit=preference_score,
            india_context_fit=india_score,
        )
        total = round(
            category_fit
            + occasion_fit
            + formality_fit
            + color_score
            + skin_score
            + climate_score
            + preference_score
            + india_score,
            2,
        )

        return OutfitRecommendation(
            outfit_id=f"outfit_{uuid4().hex[:10]}",
            title=self._title(combo, occasion),
            item_ids=[i.item_id for i in combo],
            score=min(total, 100.0),
            score_breakdown=breakdown,
            why=self._why(combo, occasion, profile, weather),
            styling_tips=self._styling_tips(combo, occasion, weather),
            avoid=self._avoid(combo, occasion, weather),
        )

    def _category_fit(self, categories: set[str], occasion: str) -> float:
        has_top_or_one_piece = bool(categories.intersection(TOPS | ETHNIC_ONE_PIECE))
        has_bottom_or_one_piece = bool(categories.intersection(BOTTOMS | ETHNIC_ONE_PIECE))
        has_footwear = bool(categories.intersection(FOOTWEAR))
        score = 0.0
        if has_top_or_one_piece:
            score += 8
        if has_bottom_or_one_piece:
            score += 8
        if has_footwear:
            score += 5
        if occasion in {"wedding guest", "haldi", "sangeet", "mehendi", "reception", "festival"} and categories.intersection(ACCESSORIES | LAYERING):
            score += 4
        return min(score, 25.0)

    def _occasion_fit(self, combo: Sequence[WardrobeItem], occasion: str, rules: Dict[str, object]) -> float:
        preferred = set(rules.get("preferred", set()))
        style = set(rules.get("style", set()))
        score = 0.0
        for item in combo:
            cat = self._cat(item)
            if occasion in item.occasion_tags or occasion in item.india_tags:
                score += 5
            if cat in preferred:
                score += 2.5
            if set(item.style_tags).intersection(style):
                score += 2
        colors = set(rules.get("colors", set()))
        if colors and any(any(c in item.color.lower() for c in colors) for item in combo):
            score += 5
        return min(score, 20.0)

    def _formality_fit(self, combo: Sequence[WardrobeItem], rules: Dict[str, object]) -> float:
        low, high = rules.get("formality", (1, 10))  # type: ignore[assignment]
        avg = sum(item.formality for item in combo) / max(len(combo), 1)
        if low <= avg <= high:
            return 15.0
        distance = min(abs(avg - low), abs(avg - high))
        return max(0.0, round(15.0 - distance * 3.0, 2))

    def _climate_fit(self, combo: Sequence[WardrobeItem], weather: Optional[WeatherContext], profile: UserProfile) -> float:
        condition = (weather.condition if weather else None) or profile.climate_preference or ""
        temp = weather.temperature_c if weather else None
        joined = " ".join([condition] + [" ".join(i.climate_tags + i.season_tags + [i.fabric or ""]) for i in combo]).lower()
        score = 6.0
        if condition and any(condition.lower() in i.climate_tags for i in combo):
            score += 3.0
        if temp and temp >= 30:
            if any(f in joined for f in ["cotton", "linen", "breathable", "summer"]):
                score += 3.0
            if any(f in joined for f in ["heavy", "wool", "velvet"]):
                score -= 3.0
        if "monsoon" in condition.lower():
            if any(self._cat(i) in {"sandals", "trousers", "kurti"} for i in combo):
                score += 2.0
            if "white" in " ".join(i.color for i in combo).lower():
                score -= 1.0
        return round(max(0.0, min(score, 10.0)), 2)

    def _preference_fit(self, tags: set[str], preferences: Iterable[str]) -> float:
        prefs = {p.strip().lower() for p in preferences if p.strip()}
        if not prefs:
            return 5.0
        matches = len(tags.intersection(prefs))
        return min(10.0, 4.0 + matches * 2.0)

    def _india_context_fit(self, combo: Sequence[WardrobeItem], occasion: str, rules: Dict[str, object]) -> float:
        score = 3.0
        cats = {self._cat(i) for i in combo}
        if occasion in {"haldi", "sangeet", "mehendi", "wedding guest", "reception", "pooja", "festival"}:
            if cats.intersection({"kurta", "kurti", "saree", "lehenga", "sherwani", "anarkali", "juttis", "dupatta", "jewelry", "nehru jacket"}):
                score += 5.0
            if any(is_festive(i.color) for i in combo):
                score += 2.0
        elif occasion in {"office", "interview"}:
            if cats.intersection({"shirt", "trousers", "chinos", "kurti", "palazzo", "loafers", "formal shoes"}):
                score += 5.0
        elif occasion in {"college", "daily casual"}:
            if cats.intersection({"t-shirt", "shirt", "jeans", "kurti", "sneakers", "sandals"}):
                score += 4.0
        return min(score, 10.0)

    def _why(self, combo: Sequence[WardrobeItem], occasion: str, profile: UserProfile, weather: Optional[WeatherContext]) -> str:
        names = [item.name or f"{item.color} {item.category}" for item in combo]
        colors = ", ".join(item.color for item in combo[:3])
        fabric_note = ""
        fabrics = {item.fabric for item in combo if item.fabric}
        if fabrics:
            fabric_note = f" The fabric mix ({', '.join(sorted(fabrics))}) keeps the outfit practical for Indian conditions."
        skin_note = ""
        if profile.skin_tone:
            skin_note = f" The {colors} palette is checked against your {profile.skin_tone} skin-tone profile."
        weather_note = ""
        if weather and (weather.temperature_c or weather.condition):
            weather_note = f" It also considers today's context: {weather.temperature_c or 'unknown'}°C, {weather.condition or 'general weather'}."
        return f"Wear {' + '.join(names)} for {occasion}. The combination balances occasion fit, color harmony, formality and India-specific styling rules.{skin_note}{fabric_note}{weather_note}"

    def _styling_tips(self, combo: Sequence[WardrobeItem], occasion: str, weather: Optional[WeatherContext]) -> List[str]:
        tips: List[str] = []
        cats = {self._cat(i) for i in combo}
        if occasion in {"office", "interview"}:
            tips.append("Keep accessories clean and minimal; match belt and shoes when possible.")
        if occasion in {"date"}:
            tips.append("Add one polished detail like a watch, simple earrings, or a clean fragrance.")
        if occasion in {"haldi", "mehendi", "sangeet", "wedding guest", "reception"}:
            tips.append("Use festive accessories, but keep them proportional to the outfit so it does not look overdone.")
        if cats.intersection({"sneakers", "sandals", "juttis"}):
            tips.append("Choose clean, comfortable footwear because Indian events often involve standing or walking.")
        if weather and weather.temperature_c and weather.temperature_c >= 32:
            tips.append("Prefer breathable innerwear and avoid heavy layering in hot weather.")
        return tips[:4]

    def _avoid(self, combo: Sequence[WardrobeItem], occasion: str, weather: Optional[WeatherContext]) -> List[str]:
        avoid: List[str] = []
        if occasion == "haldi":
            avoid.append("Avoid very heavy or delicate pieces that may stain easily during Haldi.")
        if weather and weather.condition and "monsoon" in weather.condition.lower():
            avoid.append("Avoid white shoes or floor-length hems on rainy/monsoon days.")
        if occasion in {"office", "interview"}:
            avoid.append("Avoid overly loud accessories unless your workplace dress code allows it.")
        return avoid[:3]

    def _append_optional(self, combo: List[WardrobeItem], options: Sequence[WardrobeItem], occasion: str) -> None:
        if not options:
            return
        preferred = set(OCCASION_RULES.get(occasion, {}).get("preferred", set()))
        sorted_options = sorted(
            options,
            key=lambda i: (
                0 if self._cat(i) in preferred or occasion in i.occasion_tags else 1,
                -i.formality,
                i.item_id,
            ),
        )
        for item in sorted_options:
            if item.item_id not in {existing.item_id for existing in combo}:
                combo.append(item)
                return

    def _filter(self, items: Sequence[WardrobeItem], categories: set[str]) -> List[WardrobeItem]:
        return [i for i in items if self._cat(i) in categories or (i.subcategory and i.subcategory.lower() in categories)]

    def _cat(self, item: WardrobeItem) -> str:
        return item.category.strip().lower()

    def _tags(self, combo: Sequence[WardrobeItem]) -> set[str]:
        tags: set[str] = set()
        for item in combo:
            tags.update(item.style_tags)
            tags.update(item.occasion_tags)
            tags.update(item.india_tags)
            tags.add(self._cat(item))
        return tags

    def _unique(self, combo: Sequence[Optional[WardrobeItem]]) -> List[WardrobeItem]:
        seen = set()
        result: List[WardrobeItem] = []
        for item in combo:
            if item and item.item_id not in seen:
                seen.add(item.item_id)
                result.append(item)
        return result

    def _title(self, combo: Sequence[WardrobeItem], occasion: str) -> str:
        occasion_title = occasion.replace("_", " ").title()
        if occasion in {"haldi", "mehendi", "sangeet", "wedding guest", "reception"}:
            prefix = "India-Ready Festive"
        elif occasion in {"office", "interview"}:
            prefix = "Polished"
        elif occasion in {"college", "daily casual"}:
            prefix = "Comfortable"
        else:
            prefix = "Personalized"
        anchor = combo[0].name or f"{combo[0].color} {combo[0].category}"
        return f"{prefix} {occasion_title}: {anchor} Look"
