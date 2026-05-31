from fastapi import FastAPI
from app.ml.graph_engine import WardrobeGraphEngine
from pydantic import BaseModel

app = FastAPI(title="StyleDNA AI Backend")
graph_engine = WardrobeGraphEngine()

class OutfitRequest(BaseModel):
    user_id: int
    occasion: str

@app.post("/outfits/generate")
async def generate_outfits(req: OutfitRequest):
    graph_engine.build_compatibility_graph()
    combos = graph_engine.generate_outfits(req.occasion)
    return {"outfits": combos[:5], "source": "local_graph"}

@app.get("/health")
async def health():
    return {"status": "ok", "ml_mode": "on_device_first"}