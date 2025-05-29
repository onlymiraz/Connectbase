# full path: backend/api/rule_query.py
from fastapi import APIRouter, Query
from backend.agent.rule_rag import query_rule_book

router = APIRouter(prefix="/cb", tags=["Rule‑Book QA"])

@router.get("/rule-query")
def rule_query(question: str = Query(..., description="Ask about the rule book")):
    """Return an answer pulled from the local rule book via RAG."""
    answer = query_rule_book(question)
    return {"question": question, "answer": answer}
