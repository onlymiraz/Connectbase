# backend/api/address_validate.py

from fastapi import APIRouter, Query
from pydantic import BaseModel
from typing import List, Union

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
    raw: Union[str, List[str]] = Query(
        ...,
        description="Either a semicolon-separated string of addresses or a list of raw addresses",
        alias="raw"
    )
):
    """
    Mock address validation: accepts either a semicolon-separated string or a list of addresses,
    returns each with a fake status.
    """
    # Determine list of addresses to validate
    if isinstance(raw, list):
        raw_list = raw
    else:
        raw_list = [addr.strip() for addr in raw.split(";") if addr.strip()]

    results = []
    for addr in raw_list:
        normalized = addr.title()
        results.append(
            {
                "input": addr,
                "normalized": normalized,
                "valid": True,
            }
        )

    # Return a model instance so callers get attributes
    return AddressValidationResponse(validated=results)
