"""Unit tests for the Connectbase API functions."""

from pathlib import Path
import sys

BASE_DIR = Path(__file__).resolve().parents[1]
sys.path.append(str(BASE_DIR))

from backend.api.address_validate import address_validate



def test_address_validate_semicolon():
    """Address validation should parse semicolon-delimited addresses."""
    data = address_validate(raw="123 Main St;456 Elm St")
    results = data["validated"]
    assert results[0]["normalized"] == "123 Main St"
    assert len(results) == 2

