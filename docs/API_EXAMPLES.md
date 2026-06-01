# API Examples

Run locally:

```bash
cd backend
uvicorn app.main:app --reload
```

## Create profile

```bash
curl -X POST http://localhost:8000/users/profile \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "u1",
    "style_mode": "menswear",
    "skin_tone": "medium warm",
    "preferences": ["smart casual", "minimal", "budget-conscious"]
  }'
```

## Add structured wardrobe item

```bash
curl -X POST http://localhost:8000/wardrobe/items \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "u1",
    "item_id": "shirt_001",
    "style_mode": "menswear",
    "category": "shirt",
    "color": "light blue",
    "fabric": "cotton",
    "formality": 8,
    "style_tags": ["formal", "minimal"],
    "occasion_tags": ["office"],
    "local_image_ref": "local://wardrobe/shirt_001.jpg"
  }'
```

## Generate outfit

```bash
curl -X POST http://localhost:8000/outfits/generate \
  -H 'Content-Type: application/json' \
  -d '{
    "user_id": "u1",
    "occasion": "office",
    "weather": {"temperature_c": 34, "condition": "hot_humid"}
  }'
```

The response contains exact `item_ids`. The Flutter app should use those IDs to display the local wardrobe photos.
