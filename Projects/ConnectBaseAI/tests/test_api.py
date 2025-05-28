import pathlib
import sys

PROJECT_ROOT = pathlib.Path(__file__).resolve().parents[1]
sys.path.insert(0, str(PROJECT_ROOT))

from backend.app import read_root
from backend.api.connectbase_mock import locations
from backend.api.address_validate import address_validate


def test_health():
    assert read_root() == {"message": "Agentic Connectbase API is live!"}


def test_locations():
    data = locations()
    assert "locations" in data
    assert isinstance(data["locations"], list)


def test_address_validate():
    resp = address_validate(raw=["123 main st", "456 elm st"])
    assert len(resp.validated) == 2
    assert resp.validated[0].normalized == "123 Main St"
