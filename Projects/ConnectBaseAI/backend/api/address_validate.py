# backend/api/address_validate.py

from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import List

router = APIRouter(prefix="/cb", tags=["Address Validation"])


class AddressItem(BaseModel):
    input: str
    normalized: str
    valid: bool


class AddressValidationResponse(BaseModel):
    validated: List[AddressItem]

@router.get(
    "/address-validate",
    summary="Validate one or more raw addresses",
    response_model=AddressValidationResponse,
)
def address_validate(
    raw: List[str] = Query(..., description="Semicolon-separated list of raw addresses", alias="raw")
) -> AddressValidationResponse:
    """Mock address validation that normalizes and flags addresses as valid."""
    results: List[AddressItem] = []
    for addr in raw:
        addr = addr.strip()
        if not addr:
            continue
        results.append(
            AddressItem(input=addr, normalized=addr.title(), valid=True)
        )
    return AddressValidationResponse(validated=results)
