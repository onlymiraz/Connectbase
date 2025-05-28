# Connectbase Agentic AI Platform

This demo showcases a simple FastAPI service used to experiment with AI driven
workflows at Connectbase. It exposes a handful of mock endpoints together with
prototype AI capabilities powered by LangChain.

## Running locally

```bash
# install deps
pip install -r requirements.txt

# start the API
uvicorn backend.app:app --reload
```

The API will be available at `http://localhost:8000` with Swagger docs at
`/docs`. A minimal HTML interface can be reached at `/ui` when the server is
running.

You can also start the stack with Docker:

```bash
docker compose up --build
```

### Environment variables

- `OPENAI_API_KEY` – required for the code search features
- `ELASTICSEARCH_URL` – optional, used by other experiments
- `REDIS_URL` – optional

## Endpoints

- `/cb/locations` – return demo location data
- `/cb/products` – return demo product data
- `/cb/quote` – generate a dummy quote
- `/cb/code-search` – question answering over the project code
- `/cb/address-validate` – simple address normalization
- `/cb/rag-test` – example RAG query

## Tests

Run unit tests with `pytest`:

```bash
pytest -q
```

### Included virtual environment

For convenience the repository contains a pre-built Python environment under
`App/env`. Activate it instead of installing dependencies if desired:

```bash
source ../../App/env/bin/activate
```

This environment includes FastAPI and other packages used for local testing.

---
Created for internal prototyping with Ben Edmond at Connectbase.

