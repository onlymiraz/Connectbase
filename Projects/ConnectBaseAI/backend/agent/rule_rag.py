# =====================================================================
# full path: backend/agent/rule_rag.py
# =====================================================================

"""Retrieval-augmented generation chain over the local rule book."""

from __future__ import annotations

import pathlib
from typing import Optional

try:
    from langchain.chains import RetrievalQA
    from langchain.docstore.document import Document
    from langchain_community.embeddings import OpenAIEmbeddings
    from langchain_community.llms import OpenAI
    from langchain_community.vectorstores import FAISS
except ImportError:  # pragma: no cover
    RetrievalQA = None  # type: ignore
    Document = None  # type: ignore
    OpenAIEmbeddings = None  # type: ignore
    OpenAI = None  # type: ignore
    FAISS = None  # type: ignore

# ---------------------------------------------------------------------------
# Paths
# ---------------------------------------------------------------------------
BASE_DIR = pathlib.Path(__file__).resolve().parents[2]
RULE_FILE = BASE_DIR / "tools" / "ruleBook.txt"
INDEX_DIR = BASE_DIR / "faiss_rule_index"

_chain: Optional['RetrievalQA'] = None

def _build_vectorstore() -> 'FAISS':
    """Create or load the FAISS vector store for the rule book."""
    if FAISS is None:
        raise RuntimeError("LangChain is required for rule-book search")

    INDEX_DIR.mkdir(exist_ok=True)
    index_file = INDEX_DIR / "index"
    if index_file.exists():
        return FAISS.load_local(str(index_file), OpenAIEmbeddings())

    text = RULE_FILE.read_text(encoding="utf-8")
    # Split the rule book into ~1k-character chunks
    docs = [Document(page_content=text[i : i + 1000]) for i in range(0, len(text), 1000)]
    embeddings = OpenAIEmbeddings()
    store = FAISS.from_documents(docs, embeddings)
    store.save_local(str(index_file))
    return store

def get_rule_chain() -> 'RetrievalQA':
    """Return a RetrievalQA chain for the rule book."""
    global _chain
    if _chain is None:
        if RetrievalQA is None:
            raise RuntimeError("LangChain is required for rule-book search")
        store = _build_vectorstore()
        _chain = RetrievalQA.from_chain_type(
            llm=OpenAI(temperature=0.0),
            retriever=store.as_retriever(),
        )
    return _chain

def query_rule_book(question: str) -> str:
    """Ask a natural-language question against the rule book."""
    chain = get_rule_chain()
    return chain.run(question)
