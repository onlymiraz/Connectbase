"""Unit tests for the Connectbase API functions."""

import pathlib
import sys

# ensure project root is on the path
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


def test_address_validate_semicolon():
    data = address_validate(raw="123 Main St;456 Elm St")
    results = data["validated"]
    assert results[0]["normalized"] == "123 Main St"
    assert len(results) == 2


def test_address_validate_list():
    data = address_validate(raw=["123 main st", "456 elm st"])
    results = data["validated"]
    assert len(results) == 2
    assert results[0]["normalized"] == "123 Main St"
