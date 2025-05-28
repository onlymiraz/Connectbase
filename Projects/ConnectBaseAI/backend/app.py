# backend/app.py

from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import RedirectResponse
from backend.api import connectbase_mock, code_search, address_validate
import pathlib

app = FastAPI(
    title="Connectbase Agentic AI Platform",
    description="API for locations, products, quotes, address validation, and code search",
    version="1.0.0"
)

# Mount the entire `static/` directory under `/static`
BASE_DIR = pathlib.Path(__file__).resolve().parents[1]
STATIC_DIR = BASE_DIR / "static"
app.mount("/static", StaticFiles(directory=str(STATIC_DIR)), name="static")

# Redirect `/ui` → `/static/ui.html`
@app.get("/ui", include_in_schema=False)
def serve_ui():
    return RedirectResponse(url="/static/ui.html")

# Core Connectbase endpoints
app.include_router(connectbase_mock.router)

# AI-powered endpoints
app.include_router(code_search.router)
app.include_router(address_validate.router)

@app.get("/", summary="Health Check")
def read_root():
    return {"message": "Agentic Connectbase API is live!"}
