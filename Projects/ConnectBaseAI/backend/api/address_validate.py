# backend/api/address_validate.py

from fastapi import APIRouter, Query

router = APIRouter(prefix="/cb", tags=["Address Validation"])

@router.get("/address-validate", summary="Validate one or more raw addresses")
def address_validate(
    raw: str = Query(..., description="Semicolon-separated list of raw addresses", alias="raw")
):
    """
    Mock address validation: splits on semicolon, returns each with a fake status.
    """
    results = []
    for addr in raw.split(";"):
        addr = addr.strip()
        if not addr:
            continue
        results.append({
            "input": addr,
            "normalized": addr.title(),
            "valid": True,
        })
    return {"validated": results}
