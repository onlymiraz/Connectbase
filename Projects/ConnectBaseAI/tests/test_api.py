"""Unit tests for the Connectbase API functions."""

from pathlib import Path
import sys

BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(BASE_DIR))

from backend.api.connectbase_mock import locations
from backend.api.address_validate import address_validate

def test_locations():
    data = locations()
    assert "locations" in data
    assert isinstance(data["locations"], list)


def test_address_validate_semicolon():
    data = address_validate(raw="123 Main St;456 Elm St")
    results = data["validated"]
    assert results[0]["normalized"] == "123 Main St"
    assert len(results) == 2

