# =====================================================================
# full path: backend/app.py
# =====================================================================

import os
from dotenv import load_dotenv
load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '..', '.env.dev'))

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from backend.api import (
    connectbase_mock,
    code_search,
    address_validate,
    sentiment_analysis,
    rule_query,      # NEW ― rule-book Q&A
    summarize,       # NEW ― text summarisation
)
import pathlib

app = FastAPI(
    title="Connectbase Agentic AI Platform",
    description=(
        "Demo API for locations, products, quotes, address validation, code search, "
        "sentiment analysis, rule-book Q&A and text summarisation"
    ),
    version="1.2.0",
)

# ------------------------------------------------------------------ #
#  Static UI
# ------------------------------------------------------------------ #
BASE_DIR = pathlib.Path(__file__).resolve().parents[1]
STATIC_DIR = BASE_DIR / "static"
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

@app.get("/ui", include_in_schema=False)
def serve_ui() -> RedirectResponse:
    """Redirect /ui → /static/ui.html."""
    return RedirectResponse(url="/static/ui.html")

# ------------------------------------------------------------------ #
#  Routers
# ------------------------------------------------------------------ #
app.include_router(connectbase_mock.router)
app.include_router(code_search.router)
app.include_router(address_validate.router)
app.include_router(sentiment_analysis.router)
app.include_router(rule_query.router)   # NEW
app.include_router(summarize.router)    # NEW

# ------------------------------------------------------------------ #
#  Health check
# ------------------------------------------------------------------ #
@app.get("/", summary="Health Check")
def read_root():
    return {"message": "Agentic Connectbase API (AI/ML demos v1.2) is live!"}
