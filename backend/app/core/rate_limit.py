from __future__ import annotations

import time
from collections import defaultdict, deque
from typing import Deque, Dict

from fastapi import HTTPException, Request, status

from app.core.config import get_settings

_BUCKETS: Dict[str, Deque[float]] = defaultdict(deque)
_CLEANUP_INTERVAL = 60
_last_cleanup: float = 0.0


def _evict_stale() -> None:
    global _last_cleanup
    now = time.time()
    if now - _last_cleanup < _CLEANUP_INTERVAL:
        return
    _last_cleanup = now
    cutoff = now - 120
    stale = [k for k, v in _BUCKETS.items() if not v or v[-1] < cutoff]
    for k in stale:
        del _BUCKETS[k]


def client_key(request: Request) -> str:
    forwarded = request.headers.get("x-forwarded-for")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


async def enforce_rate_limit(request: Request) -> None:
    settings = get_settings()
    if settings.rate_limit_per_minute <= 0:
        return
    key = client_key(request)
    now = time.time()
    _evict_stale()
    window_start = now - 60
    bucket = _BUCKETS[key]
    while bucket and bucket[0] < window_start:
        bucket.popleft()
    if len(bucket) >= settings.rate_limit_per_minute:
        raise HTTPException(
            status_code=status.HTTP_429_TOO_MANY_REQUESTS,
            detail="rate limit exceeded",
        )
    bucket.append(now)
