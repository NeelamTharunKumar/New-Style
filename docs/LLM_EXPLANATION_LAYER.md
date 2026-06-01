# LLM Explanation Layer

Phase 4 adds an optional LLM adapter for explanations only.

## Design rule

The LLM must never be the source of truth for outfit selection.

```text
Rule engine selects item IDs and scores outfits.
LLM only rewrites/explains title, why, styling_tips and avoid notes.
```

The LLM cannot change:

- selected item IDs
- outfit scores
- score breakdowns
- wardrobe contents

## Privacy contract

The LLM receives structured semantic data only.

Excluded from LLM payloads:

- raw photos
- selfies
- local image references
- image bytes
- embeddings / CLIP vectors
- face/body image data

Included in LLM payloads:

- item IDs
- category
- color
- fabric
- fit
- style tags
- occasion tags
- climate tags
- user style profile fields
- weather/occasion context
- rule-engine candidate outfits

## Files

```text
backend/app/services/prompt_templates.py
backend/app/services/llm_orchestrator.py
backend/tests/test_llm_contract.py
```

## API status endpoint

```text
GET /llm/status
```

Returns whether the LLM layer is enabled/configured.

## Environment variables

By default, the LLM adapter is disabled.

Enable with:

```bash
export DRAPE_LLM_ENABLED=true
export OPENAI_API_KEY=your_key_here
```

Optional:

```bash
export DRAPE_LLM_MODEL=gpt-4o-mini
export DRAPE_LLM_BASE_URL=https://api.openai.com/v1/chat/completions
export DRAPE_LLM_TIMEOUT_SECONDS=20
```

The adapter is OpenAI-compatible because it calls a chat-completions-style endpoint.

## Failure behavior

If the LLM is disabled, unconfigured, times out, returns invalid JSON, or the payload sanitizer detects sensitive keys, the system falls back to deterministic rule-engine explanations.

This fallback is intentional for privacy and reliability.

## Strict JSON output

The LLM is instructed to return only:

```json
{
  "outfits": [
    {
      "outfit_id": "outfit_001",
      "title": "Polished Office Look",
      "why": "Explanation text",
      "styling_tips": ["Tip 1"],
      "avoid": ["Avoid note"]
    }
  ]
}
```

Any attempted `item_ids` or `score` changes from the LLM response are ignored.
