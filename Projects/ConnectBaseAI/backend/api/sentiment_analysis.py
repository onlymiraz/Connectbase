# full path: backend/api/sentiment_analysis.py
from fastapi import APIRouter, HTTPException
from pydantic import BaseModel
from transformers import pipeline

router = APIRouter(prefix="/cb", tags=["AI/ML"])

# Initialize a sentiment-analysis pipeline on startup
sentiment_analyzer = pipeline("sentiment-analysis")

class TextItem(BaseModel):
    text: str

class SentimentResponse(BaseModel):
    label: str
    score: float

@router.post(
    "/sentiment",
    summary="Analyze sentiment of input text",
    response_model=SentimentResponse,
)
async def analyze_sentiment(item: TextItem):
    try:
        result = sentiment_analyzer(item.text)[0]
        return SentimentResponse(label=result['label'], score=result['score'])
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

