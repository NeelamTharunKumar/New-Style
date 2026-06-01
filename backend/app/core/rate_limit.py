from __future__ import annotations

import time
from collections import defaultdict, deque
from typing import Deque, Dict

from fastapi import HTTPException, Request, status

from app.core.config import get_settings

_BUCKETS: Dict[str, Deque[float]] = defaultdict(deque)


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
