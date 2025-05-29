# =====================================================================
# full path: backend/api/summarize.py       ← add this file
# =====================================================================

from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from transformers import pipeline

router = APIRouter(prefix="/cb", tags=["AI/ML"])

# ------------------------------------------------------------
#  Initialise a small-footprint summariser once at startup
#  (🤗 defaults to facebook/bart-large-cnn; you can pin a model
#   with pipeline(model="sshleifer/distilbart-cnn-12-6") if size
#   or runtime is an issue.)
# ------------------------------------------------------------
summariser = pipeline("summarization")

class SummariseIn(BaseModel):
    text: str
    max_words: int | None = 150

class SummariseOut(BaseModel):
    summary: str

@router.post(
    "/summarise",
    summary="Summarise long text",
    response_model=SummariseOut,
)
def summarise(payload: SummariseIn):
    """Return a concise extractive summary of the input text."""
    try:
        out = summariser(
            payload.text,
            max_length=payload.max_words,
            min_length=max(30, int(payload.max_words * 0.3)) if payload.max_words else 30,
            do_sample=False,
        )[0]["summary_text"]
        return SummariseOut(summary=out)
    except Exception as exc:  # pragma: no cover
        raise HTTPException(status_code=500, detail=str(exc))
