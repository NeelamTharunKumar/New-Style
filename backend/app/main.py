from __future__ import annotations

from typing import List

from fastapi import FastAPI, HTTPException, status

from app.models import (
    OutfitGenerateRequest,
    OutfitGenerateResponse,
    StylistChatRequest,
    StylistChatResponse,
    UserProfile,
    WardrobeItem,
    WardrobeItemCreate,
)
from app.services.outfit_engine import OutfitEngine
from app.services.taxonomy import TAXONOMY
from app.storage import InMemoryStore

app = FastAPI(
    title="India-First Wardrobe AI Backend",
    description=(
        "Privacy-preserving outfit recommendation API. The backend accepts structured wardrobe/profile "
        "features only; raw photos are expected to stay on-device."
    ),
    version="0.1.0",
)

store = InMemoryStore()
outfit_engine = OutfitEngine()

PRIVACY_MESSAGE = "No raw wardrobe/selfie images are required or processed by this API; use item IDs and structured features only."


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "product": "India-first wardrobe assistant",
        "ml_mode": "on_device_feature_extraction_first",
        "privacy": PRIVACY_MESSAGE,
    }


@app.get("/taxonomy")
async def taxonomy():
    return TAXONOMY


@app.post("/users/profile", response_model=UserProfile)
async def upsert_profile(profile: UserProfile):
    return store.upsert_profile(profile)


@app.get("/users/{user_id}/profile", response_model=UserProfile)
async def get_profile(user_id: str):
    profile = store.get_profile(user_id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="profile not found")
    return profile


@app.post("/wardrobe/items", response_model=WardrobeItem, status_code=status.HTTP_201_CREATED)
async def add_wardrobe_item(payload: WardrobeItemCreate):
    item = WardrobeItem.from_create(payload)
    return store.add_item(item)


@app.get("/wardrobe/items/{user_id}", response_model=List[WardrobeItem])
async def list_wardrobe_items(user_id: str):
    return store.list_items(user_id)


@app.delete("/wardrobe/items/{user_id}/{item_id}")
async def delete_wardrobe_item(user_id: str, item_id: str):
    if not store.delete_item(user_id, item_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="wardrobe item not found")
    return {"deleted": True, "item_id": item_id}


@app.post("/outfits/generate", response_model=OutfitGenerateResponse)
async def generate_outfits(req: OutfitGenerateRequest):
    profile = store.get_profile(req.user_id) or UserProfile(user_id=req.user_id, style_mode=req.style_mode or "mixed")

    if req.wardrobe_items is not None:
        # Stateless privacy-first mode: frontend can send structured features without persisting them server-side.
        wardrobe = [WardrobeItem.from_create(item) for item in req.wardrobe_items]
    else:
        wardrobe = store.list_items(req.user_id)

    if not wardrobe:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="no wardrobe items available; add structured wardrobe items first or pass wardrobe_items in the request",
        )

    outfits = outfit_engine.generate(
        user_id=req.user_id,
        profile=profile,
        wardrobe=wardrobe,
        occasion=req.occasion,
        weather=req.weather,
        style_mode=req.style_mode,
        max_results=req.max_results,
    )
    return OutfitGenerateResponse(
        user_id=req.user_id,
        occasion=req.occasion,
        privacy=PRIVACY_MESSAGE,
        outfits=outfits,
    )


@app.post("/chat/stylist", response_model=StylistChatResponse)
async def stylist_chat(req: StylistChatRequest):
    # Phase 1 uses a deterministic privacy-safe response. Phase 5 will add an LLM adapter with strict JSON I/O.
    msg = req.message.strip()
    if not msg:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="message cannot be empty")
    return StylistChatResponse(
        reply=(
            "I can help choose outfits from your wardrobe using structured item features only. "
            "Try POST /outfits/generate with an occasion like college, office, date, haldi, sangeet, or wedding guest."
        ),
        privacy=PRIVACY_MESSAGE,
    )
