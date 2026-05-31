from __future__ import annotations

from enum import Enum
from typing import Any, Dict, List, Optional
from uuid import uuid4

from pydantic import BaseModel, Field, field_validator


SENSITIVE_FEATURE_KEYS = {
    "raw_image",
    "image_bytes",
    "base64",
    "base64_image",
    "face_image",
    "selfie",
    "body_image",
    "embedding",
    "clip_embedding",
}


def _contains_sensitive_feature_key(value: Any) -> bool:
    if isinstance(value, dict):
        for key, child in value.items():
            if str(key).lower() in SENSITIVE_FEATURE_KEYS:
                return True
            if _contains_sensitive_feature_key(child):
                return True
    if isinstance(value, list):
        return any(_contains_sensitive_feature_key(item) for item in value)
    return False


class StyleMode(str, Enum):
    menswear = "menswear"
    womenswear = "womenswear"
    mixed = "mixed"


class WeatherContext(BaseModel):
    temperature_c: Optional[float] = Field(default=None, ge=-10, le=60)
    condition: Optional[str] = Field(default=None, examples=["hot_humid", "monsoon", "winter", "indoor_ac"])
    city: Optional[str] = None


class UserProfile(BaseModel):
    user_id: str
    style_mode: StyleMode = StyleMode.mixed
    region: str = "India"
    climate_preference: Optional[str] = Field(default=None, examples=["hot_humid", "hot_dry", "monsoon"])
    skin_tone: Optional[str] = Field(default=None, examples=["medium warm", "dusky warm", "fair cool", "neutral"])
    body_shape: Optional[str] = None
    preferences: List[str] = Field(default_factory=list, examples=[["smart casual", "minimal", "budget-conscious"]])
    modesty_preference: Optional[str] = Field(default=None, examples=["modest", "balanced", "bold"])
    budget_conscious: bool = True
    metadata: Dict[str, Any] = Field(default_factory=dict)


class WardrobeItemCreate(BaseModel):
    user_id: str
    item_id: Optional[str] = None
    style_mode: StyleMode = StyleMode.mixed
    name: Optional[str] = None
    category: str = Field(..., examples=["shirt", "kurti", "saree", "chinos", "sneakers"])
    subcategory: Optional[str] = None
    color: str = Field(..., examples=["light blue", "mustard yellow", "charcoal"])
    hex_color: Optional[str] = Field(default=None, pattern=r"^#[0-9A-Fa-f]{6}$")
    secondary_colors: List[str] = Field(default_factory=list)
    pattern: Optional[str] = Field(default="solid")
    fabric: Optional[str] = Field(default=None, examples=["cotton", "linen", "silk", "denim"])
    fit: Optional[str] = Field(default=None, examples=["regular", "slim", "relaxed", "flowy"])
    sleeve: Optional[str] = None
    neckline: Optional[str] = None
    length: Optional[str] = None
    formality: int = Field(default=5, ge=1, le=10)
    style_tags: List[str] = Field(default_factory=list)
    occasion_tags: List[str] = Field(default_factory=list)
    season_tags: List[str] = Field(default_factory=list)
    climate_tags: List[str] = Field(default_factory=list)
    india_tags: List[str] = Field(default_factory=list)
    local_image_ref: Optional[str] = Field(
        default=None,
        description="Local-only image reference. The backend stores the string but never receives image bytes.",
        examples=["local://wardrobe/shirt_001.jpg"],
    )
    feature_vector_summary: Dict[str, Any] = Field(
        default_factory=dict,
        description="Optional structured/local ML features. Do not include raw image data.",
    )

    @field_validator("category", "color")
    @classmethod
    def normalize_required_text(cls, value: str) -> str:
        value = value.strip().lower()
        if not value:
            raise ValueError("must not be empty")
        return value

    @field_validator("style_tags", "occasion_tags", "season_tags", "climate_tags", "india_tags", "secondary_colors")
    @classmethod
    def normalize_lists(cls, values: List[str]) -> List[str]:
        return sorted({v.strip().lower() for v in values if v and v.strip()})

    @field_validator("feature_vector_summary")
    @classmethod
    def reject_sensitive_feature_payloads(cls, value: Dict[str, Any]) -> Dict[str, Any]:
        if _contains_sensitive_feature_key(value):
            raise ValueError("feature_vector_summary must not contain raw images, base64 payloads, face/selfie data, or embeddings")
        return value


class WardrobeItem(WardrobeItemCreate):
    item_id: str

    @classmethod
    def from_create(cls, payload: WardrobeItemCreate) -> "WardrobeItem":
        data = payload.model_dump()
        data["item_id"] = payload.item_id or f"item_{uuid4().hex[:10]}"
        if not data.get("name"):
            sub = f" {data['subcategory']}" if data.get("subcategory") else ""
            data["name"] = f"{data['color']} {sub} {data['category']}".strip()
        return cls(**data)


class OutfitGenerateRequest(BaseModel):
    user_id: str
    occasion: str = Field(..., examples=["office", "college", "haldi", "wedding guest", "date"])
    style_mode: Optional[StyleMode] = None
    user_profile: Optional[UserProfile] = Field(
        default=None,
        description="Optional stateless profile features supplied by the app. No photos.",
    )
    weather: Optional[WeatherContext] = None
    max_results: int = Field(default=5, ge=1, le=20)
    prompt: Optional[str] = Field(default=None, description="User's natural language request; treated as context only.")
    wardrobe_items: Optional[List[WardrobeItemCreate]] = Field(
        default=None,
        description="Optional stateless mode: send structured item features for this request only. No photos.",
    )

    @field_validator("occasion")
    @classmethod
    def normalize_occasion(cls, value: str) -> str:
        value = value.strip().lower()
        if not value:
            raise ValueError("occasion must not be empty")
        return value


class ScoreBreakdown(BaseModel):
    category_fit: float = 0
    occasion_fit: float = 0
    formality_fit: float = 0
    color_harmony: float = 0
    skin_tone_fit: float = 0
    climate_fit: float = 0
    style_preference_fit: float = 0
    india_context_fit: float = 0


class OutfitRecommendation(BaseModel):
    outfit_id: str
    title: str
    item_ids: List[str]
    score: float
    score_breakdown: ScoreBreakdown
    why: str
    styling_tips: List[str] = Field(default_factory=list)
    avoid: List[str] = Field(default_factory=list)
    source: str = "rule_engine"


class OutfitGenerateResponse(BaseModel):
    user_id: str
    occasion: str
    privacy: str
    outfits: List[OutfitRecommendation]








class OutfitFeedbackRequest(BaseModel):
    user_id: str
    outfit_id: str
    item_ids: List[str] = Field(default_factory=list)
    occasion: Optional[str] = None
    rating: Optional[int] = Field(default=None, ge=1, le=5)
    worn: bool = False
    favorite: bool = False
    rejected: bool = False
    notes: Optional[str] = None


class OutfitFeedback(BaseModel):
    feedback_id: str
    user_id: str
    outfit_id: str
    item_ids: List[str] = Field(default_factory=list)
    occasion: Optional[str] = None
    rating: Optional[int] = None
    worn: bool = False
    favorite: bool = False
    rejected: bool = False
    notes: Optional[str] = None
    created_at: str


class AuditEvent(BaseModel):
    event_id: str
    user_id: str
    event_type: str
    created_at: str
    metadata: Dict[str, Any] = Field(default_factory=dict)


class AuthSessionResponse(BaseModel):
    authenticated: bool
    auth_mode: str
    user_id: Optional[str] = None
    api_key_required: bool = False


class UserDataExport(BaseModel):
    user_id: str
    privacy: str
    profile: Optional[UserProfile] = None
    wardrobe_items: List[WardrobeItem] = Field(default_factory=list)
    outfit_history: List[Dict[str, Any]] = Field(default_factory=list)


class UserDeleteResponse(BaseModel):
    user_id: str
    deleted: bool
    profile_deleted: bool
    wardrobe_items_deleted: int
    privacy: str


class StylistChatRequest(BaseModel):
    user_id: str
    message: str
    context: Dict[str, Any] = Field(default_factory=dict)


class StylistChatResponse(BaseModel):
    reply: str
    privacy: str
