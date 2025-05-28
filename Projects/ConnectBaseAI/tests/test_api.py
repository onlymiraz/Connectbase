from fastapi.testclient import TestClient
from backend.app import app

client = TestClient(app)

def test_health():
    resp = client.get("/")
    assert resp.status_code == 200
    assert resp.json() == {"message": "Agentic Connectbase API is live!"}

def test_address_validate_semicolon():
    resp = client.get("/cb/address-validate", params={"raw": "123 Main St;456 Elm St"})
    assert resp.status_code == 200
    data = resp.json()["validated"]
    assert data[0]["normalized"] == "123 Main St"
    assert len(data) == 2

