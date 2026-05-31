# Privacy Architecture

This product is designed around a strict rule:

> **Raw user photos should stay on-device. The backend receives structured features only.**

## Stays on the phone

- Selfie / full-body photo
- Wardrobe item photos
- Local thumbnails
- Raw camera frames
- Face/body image data
- Optional local embeddings if the user chooses no cloud sync

## May leave the phone

Only structured data such as:

```json
{
  "item_id": "shirt_001",
  "category": "shirt",
  "color": "light blue",
  "fabric": "cotton",
  "fit": "regular",
  "style_tags": ["formal", "minimal"],
  "occasion_tags": ["office", "interview"],
  "local_image_ref": "local://wardrobe/shirt_001.jpg"
}
```

The backend can store `local_image_ref` only as a pointer for the app. It cannot use that string to retrieve the photo.

## Recommendation flow

1. App stores wardrobe photos locally.
2. App extracts clothing/body/style features locally.
3. App sends item IDs + structured features to backend.
4. Backend returns exact item IDs + explanation.
5. App maps item IDs back to local images and renders visual outfit cards.

## LLM rule

When an LLM is added, it should receive only:

- User profile features
- Occasion/context
- Candidate outfit item IDs
- Human-readable item descriptions

It should never receive raw photos.
