# backend/api/code_search.py

from fastapi import APIRouter, Query
from langchain.vectorstores import FAISS
from langchain.embeddings.openai import OpenAIEmbeddings
from langchain.chains import RetrievalQA
from langchain.llms import OpenAI
from langchain.docstore.document import Document
import os

router = APIRouter(prefix="/cb", tags=["LangChain Code Search"])

# Set your OpenAI API key securely
os.environ["OPENAI_API_KEY"] = os.getenv("OPENAI_API_KEY", "sk-...replace-me...")

@router.get("/code-search")
def code_search(question: str = Query(..., description="Ask something about the codebase")):
    with open("gpt-code-index.txt", "r") as f:
        raw_text = f.read()

    docs = [Document(page_content=raw_text[i:i+1000]) for i in range(0, len(raw_text), 1000)]
    embeddings = OpenAIEmbeddings()
    db = FAISS.from_documents(docs, embeddings)
    retriever = db.as_retriever()

    qa = RetrievalQA.from_chain_type(llm=OpenAI(), retriever=retriever)
    response = qa.run(question)

    return {"question": question, "answer": response}
