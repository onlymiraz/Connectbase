from fastapi import APIRouter
router = APIRouter(prefix='/cb')

@router.get('/locations')
def locations():
    return {'locations': ['123 Main St', '456 Elm St']}