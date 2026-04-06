"""
PathForge API — main application entry point.

This file creates the FastAPI app, registers middleware,
and mounts top-level routes. Business logic lives in
services/. Route handlers live in api/v1/.
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

# ── App Instance ──────────────────────────────────────
app = FastAPI(
    title="PathForge API",
    description="Professional SVG editor and multi-format file design tool.",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

# ── CORS Middleware ───────────────────────────────────
# In development we allow the Vite dev server origin.
# In production this list is locked down to the real domain.
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",   # Vite dev server
        "http://localhost",        # Nginx (dev)
        "http://127.0.0.1:3000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ── Root Route ────────────────────────────────────────
@app.get("/", tags=["Root"])
async def root():
    """
    Root endpoint — confirms the API is reachable.
    """
    return {
        "message": "PathForge API",
        "version": "0.1.0",
        "docs": "/docs",
    }


# ── Health Check ──────────────────────────────────────
@app.get("/health", tags=["Health"])
async def health():
    """
    Health check endpoint used by Docker and load balancers.
    Returns 200 when the application is running and ready.
    """
    return {
        "status": "ok",
        "service": "pathforge-api",
        "version": "0.1.0",
    }
