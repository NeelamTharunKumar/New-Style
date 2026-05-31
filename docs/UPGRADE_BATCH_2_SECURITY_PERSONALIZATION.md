# Upgrade Batch 2: Security, Privacy Boundaries, LLM Controls and Personalization

This batch deepens the previous privacy/ML/personalization work.

## Privacy boundary hardening

`WardrobeItem.feature_vector_summary` now rejects sensitive keys such as:

```text
raw_image
image_bytes
base64
face_image
selfie
body_image
embedding
clip_embedding
```

This prevents raw image-like payloads and embeddings from being accepted into structured wardrobe metadata.

Expanded tests verify that sensitive values do not enter LLM payloads or data export text.

## Audit logging

Added privacy-safe audit event storage for sensitive operations.

Events include:

```text
user_data_export
user_data_delete_requested
wardrobe_item_upsert
wardrobe_item_delete
outfit_generate
outfit_feedback
```

Audit logs store metadata only, not photos.

## Normalized backend schema

Added migration:

```text
backend/alembic/versions/0003_normalized_columns_audit.py
```

Adds searchable columns to `wardrobe_items`:

```text
category
color
style_mode
formality
created_at
updated_at
```

Adds table:

```text
audit_events
```

## LLM controls

LLM explanation layer now has:

- payload cache
- per-user daily call limit
- occasion-specific guidance in payloads

Env:

```text
DRAPE_LLM_DAILY_LIMIT_PER_USER=50
```

## Personalization

Feedback-based personalization is now applied during outfit generation before optional LLM explanations.

## Validation

Backend tests pass:

```text
17 passed, 1 warning
```

Alembic migration smoke test passed through head.
