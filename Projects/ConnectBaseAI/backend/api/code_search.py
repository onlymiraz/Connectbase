# backend/api/code_search.py

"""API endpoint for code search using LangChain RAG utilities."""

from fastapi import APIRouter, Query
from backend.agent.rag_agent import run_code_query
import os


router = APIRouter(prefix="/cb", tags=["LangChain Code Search"])

# Set your OpenAI API key securely
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY", "sk-...replace-me...")

@router.get("/code-search")
def code_search(question: str = Query(..., description="Ask something about the codebase")):
    """Return an answer to a natural language code query."""
    response = run_code_query(question)
    return {"question": question, "answer": response}
