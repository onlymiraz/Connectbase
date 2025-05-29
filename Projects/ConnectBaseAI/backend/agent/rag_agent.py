# =====================================================================
# full path: backend/agent/rag_agent.py
# =====================================================================

"""Utilities for retrieval-augmented generation using LangChain."""

from __future__ import annotations

import pathlib
from typing import Optional

try:  # Optional import so tests run without langchain installed
    from langchain.chains import RetrievalQA
    from langchain.docstore.document import Document
    from langchain_community.embeddings import OpenAIEmbeddings
    from langchain_community.llms import OpenAI
    from langchain_community.vectorstores import FAISS
except Exception:  # pragma: no cover - library may be missing
    RetrievalQA = None
    Document = None
    OpenAIEmbeddings = None
    OpenAI = None
    FAISS = None

# Paths
BASE_DIR = pathlib.Path(__file__).resolve().parents[2]
INDEX_DIR = BASE_DIR / "faiss_index"
CODE_FILE = BASE_DIR / "gpt-code-index.txt"

_chain: Optional['RetrievalQA'] = None

def _build_vectorstore() -> 'FAISS':
    """Create or load the FAISS vector store for the code index."""
    if FAISS is None:
        raise RuntimeError("LangChain is required for code search")
    INDEX_DIR.mkdir(exist_ok=True)
    index_file = INDEX_DIR / "index"
    if index_file.exists():
        return FAISS.load_local(str(index_file), OpenAIEmbeddings())

    text = CODE_FILE.read_text()
    docs = [Document(page_content=text[i:i + 1000]) for i in range(0, len(text), 1000)]
    embeddings = OpenAIEmbeddings()
    store = FAISS.from_documents(docs, embeddings)
    store.save_local(str(index_file))
    return store

def get_code_search_chain() -> 'RetrievalQA':
    """Return a RetrievalQA chain for searching the codebase."""
    global _chain
    if _chain is None:
        if RetrievalQA is None:
            raise RuntimeError("LangChain is required for code search")
        store = _build_vectorstore()
        _chain = RetrievalQA.from_chain_type(llm=OpenAI(), retriever=store.as_retriever())
    return _chain

def run_code_query(question: str) -> str:
    """Execute a natural language query against the codebase."""
    chain = get_code_search_chain()
    return chain.run(question)

def dummy_rag() -> str:
    """Example query used by the `/rag-test` endpoint."""
    try:
        return run_code_query("Describe the project")
    except RuntimeError:
        return "LangChain not installed"
