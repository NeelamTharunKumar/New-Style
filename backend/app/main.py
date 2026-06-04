from __future__ import annotations

import logging
import time
from typing import List

from fastapi import Depends, FastAPI, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware

from app.core.auth import CurrentUser, ensure_user_access, get_current_user
from app.core.config import get_settings
from app.core.rate_limit import enforce_rate_limit
from app.core.security import require_api_key
from app.models import (
    AuthSessionResponse,
    OutfitFeedback,
    OutfitFeedbackRequest,
    OutfitGenerateRequest,
    OutfitGenerateResponse,
    StylistChatRequest,
    StylistChatResponse,
    UserDataExport,
    UserDeleteResponse,
    UserProfile,
    WardrobeItem,
    WardrobeItemCreate,
)
from app.services.llm_orchestrator import LLMOrchestrator
from app.services.outfit_engine import OutfitEngine
from app.services.personalization import apply_feedback_personalization
from app.services.taxonomy import TAXONOMY
from app.storage_factory import create_store

settings = get_settings()
logger = logging.getLogger("drape.api")
logging.basicConfig(level=logging.INFO)

app = FastAPI(
    title=settings.app_name,
    description=(
        "Privacy-preserving outfit recommendation API. The backend accepts structured wardrobe/profile "
        "features only; raw photos are expected to stay on-device."
    ),
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

store = create_store(settings)
outfit_engine = OutfitEngine()
llm_orchestrator = LLMOrchestrator()

PRIVACY_MESSAGE = "No raw wardrobe/selfie images are required or processed by this API; use item IDs and structured features only."


@app.middleware("http")
async def request_security_middleware(request: Request, call_next):
    start = time.perf_counter()
    await enforce_rate_limit(request)
    response = await call_next(request)
    if settings.security_headers_enabled:
        response.headers["X-Content-Type-Options"] = "nosniff"
        response.headers["X-Frame-Options"] = "DENY"
        response.headers["Referrer-Policy"] = "no-referrer"
        response.headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()"
    if settings.log_requests:
        elapsed_ms = round((time.perf_counter() - start) * 1000, 2)
        logger.info("%s %s -> %s in %sms", request.method, request.url.path, response.status_code, elapsed_ms)
    return response


@app.get("/health")
async def health():
    return {
        "status": "ok",
        "product": "Drape AI",
        "environment": settings.app_env,
        "store_backend": settings.store_backend,
        "api_key_mode": "enabled" if settings.api_key else "open_dev",
        "user_auth_mode": get_settings().auth_mode,
        "ml_mode": "on_device_feature_extraction_first",
        "privacy": PRIVACY_MESSAGE,
    }


@app.get("/taxonomy")
async def taxonomy():
    return TAXONOMY


@app.get("/llm/status")
async def llm_status():
    return llm_orchestrator.status()


@app.get("/auth/session", response_model=AuthSessionResponse)
async def auth_session(
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    return AuthSessionResponse(
        authenticated=current_user.user_id is not None or settings.auth_mode == "open_dev",
        auth_mode=current_user.auth_mode,
        user_id=current_user.user_id,
        api_key_required=bool(settings.api_key),
    )


@app.post("/users/profile", response_model=UserProfile)
async def upsert_profile(
    profile: UserProfile,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, profile.user_id)
    return store.upsert_profile(profile)


@app.get("/users/{user_id}/profile", response_model=UserProfile)
async def get_profile(
    user_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    profile = store.get_profile(user_id)
    if not profile:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="profile not found")
    return profile


@app.get("/users/{user_id}/export", response_model=UserDataExport)
async def export_user_data(
    user_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    exported = store.export_user(user_id)
    store.add_audit_event(user_id, "user_data_export", {"endpoint": "/users/{user_id}/export"})
    return UserDataExport(
        user_id=user_id,
        privacy=PRIVACY_MESSAGE,
        profile=exported.get("profile"),
        wardrobe_items=exported.get("wardrobe_items", []),
        outfit_history=exported.get("outfit_history", []),
        audit_events=exported.get("audit_events", []),
    )


@app.delete("/users/{user_id}", response_model=UserDeleteResponse)
async def delete_user_data(
    user_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    store.add_audit_event(user_id, "user_data_delete_requested", {"endpoint": "DELETE /users/{user_id}"})
    result = store.delete_user(user_id)
    return UserDeleteResponse(
        user_id=user_id,
        deleted=bool(result.get("profile_deleted") or result.get("wardrobe_items_deleted", 0)),
        profile_deleted=bool(result.get("profile_deleted")),
        wardrobe_items_deleted=int(result.get("wardrobe_items_deleted", 0)),
        privacy=PRIVACY_MESSAGE,
    )


@app.post("/wardrobe/items", response_model=WardrobeItem, status_code=status.HTTP_201_CREATED)
async def add_wardrobe_item(
    payload: WardrobeItemCreate,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, payload.user_id)
    item = WardrobeItem.from_create(payload)
    saved = store.add_item(item)
    store.add_audit_event(payload.user_id, "wardrobe_item_upsert", {"item_id": saved.item_id, "category": saved.category})
    return saved


@app.get("/wardrobe/items/{user_id}", response_model=List[WardrobeItem])
async def list_wardrobe_items(
    user_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    return store.list_items(user_id)


@app.delete("/wardrobe/items/{user_id}/{item_id}")
async def delete_wardrobe_item(
    user_id: str,
    item_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    if not store.delete_item(user_id, item_id):
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="wardrobe item not found")
    store.add_audit_event(user_id, "wardrobe_item_delete", {"item_id": item_id})
    return {"deleted": True, "item_id": item_id}


@app.post("/outfits/generate", response_model=OutfitGenerateResponse)
async def generate_outfits(
    req: OutfitGenerateRequest,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, req.user_id)
    if req.user_profile is not None:
        ensure_user_access(current_user, req.user_profile.user_id)
    if req.wardrobe_items is not None:
        for structured_item in req.wardrobe_items:
            ensure_user_access(current_user, structured_item.user_id)
    profile = req.user_profile or store.get_profile(req.user_id) or UserProfile(user_id=req.user_id, style_mode=req.style_mode or "mixed")

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
    outfits = apply_feedback_personalization(outfits, store.list_feedback(req.user_id))
    store.add_audit_event(req.user_id, "outfit_generate", {"occasion": req.occasion, "candidate_count": len(outfits)})
    outfits = await llm_orchestrator.explain_outfits(
        profile=profile,
        wardrobe=wardrobe,
        occasion=req.occasion,
        weather=req.weather,
        outfits=outfits,
    )
    return OutfitGenerateResponse(
        user_id=req.user_id,
        occasion=req.occasion,
        privacy=PRIVACY_MESSAGE,
        outfits=outfits,
    )


@app.post("/outfits/feedback", response_model=OutfitFeedback)
async def record_outfit_feedback(
    req: OutfitFeedbackRequest,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, req.user_id)
    feedback = store.add_feedback(req)
    store.add_audit_event(req.user_id, "outfit_feedback", {"outfit_id": req.outfit_id, "rating": req.rating, "favorite": req.favorite, "rejected": req.rejected})
    return feedback


@app.get("/outfits/history/{user_id}", response_model=List[OutfitFeedback])
async def list_outfit_history(
    user_id: str,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, user_id)
    return store.list_feedback(user_id)


@app.post("/chat/stylist", response_model=StylistChatResponse)
async def stylist_chat(
    req: StylistChatRequest,
    _auth: None = Depends(require_api_key),
    current_user: CurrentUser = Depends(get_current_user),
):
    ensure_user_access(current_user, req.user_id)
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


# ── Weather proxy (avoids CORS issues on web) ────────────────────────────────

import httpx  # noqa: E402


@app.get("/weather/current")
async def weather_current(lat: float | None = None, lon: float | None = None):
    """Proxy weather data via wttr.in. If no lat/lon provided, uses IP-based geolocation."""
    try:
        async with httpx.AsyncClient(timeout=httpx.Timeout(15.0), follow_redirects=True) as client:
            # If no coordinates, try IP geolocation
            if lat is None or lon is None:
                ip_resp = await client.get("http://ip-api.com/json/?fields=status,city,lat,lon")
                if ip_resp.status_code == 200:
                    ip_data = ip_resp.json()
                    if ip_data.get("status") == "success":
                        lat = ip_data.get("lat")
                        lon = ip_data.get("lon")
                        city = ip_data.get("city", "Unknown")
                    else:
                        raise HTTPException(status_code=502, detail="IP geolocation failed")
                else:
                    raise HTTPException(status_code=502, detail="IP geolocation unavailable")
            else:
                city = None

            # Fetch weather from wttr.in (HTTP, no API key needed)
            wttr_resp = await client.get(
                f"http://wttr.in/{lat},{lon}?format=j1",
                headers={"Accept": "application/json"},
            )
            if wttr_resp.status_code != 200:
                raise HTTPException(status_code=502, detail=f"wttr.in returned {wttr_resp.status_code}")

            wttr_data = wttr_resp.json()
            current = wttr_data.get("current_condition", [{}])[0]

            # Map wttr.in fields to our expected format
            temp_c = float(current.get("temp_C", 0))
            humidity = int(current.get("humidity", 0))
            weather_code = int(current.get("weatherCode", 0))

            # wttr.in weather codes → WMO-like mapping
            # wttr.in codes: 113=sunny, 116=partly cloudy, 119=cloudy, 122=overcast,
            # 143=fog, 176/293/296/299/302/305/308/311/314=rain variants,
            # 227/230/260/263/266=snow/drizzle, 200/386/389=thunder
            is_day = 1  # wttr.in doesn't reliably give is_day, default to day

            result = {
                "temperature_2m": temp_c,
                "relative_humidity_2m": humidity,
                "weather_code": weather_code,
                "is_day": is_day,
                "city": city,
                "latitude": lat,
                "longitude": lon,
                "weather_desc": current.get("weatherDesc", [{}])[0].get("value", ""),
            }
            return result

    except HTTPException:
        raise
    except Exception as exc:
        logger.warning("Weather proxy error: %s", exc)
        raise HTTPException(status_code=502, detail=f"Weather service error: {exc}")
