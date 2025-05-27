from fastapi import FastAPI
from backend.api import connectbase_mock
app = FastAPI()
app.include_router(connectbase_mock.router)
@app.get('/')
def read_root():
    return {'message': 'Agentic Connectbase API'}