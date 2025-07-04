from fastapi import APIRouter

router = APIRouter(prefix='/cb')

@router.get('/locations')
def locations():
    return {'locations': ['123 Main St', '456 Elm St']}

@router.get('/products')
def get_products():
    return {'products': ['Fiber 1G', 'Ethernet 10G', 'Wave']}

@router.post('/quote')
def create_quote(request: dict):
    return {'quote_id': 'Q123', 'status': 'generated'}

@router.get('/rag-test')
def rag_test():
    from backend.agent.rag_agent import dummy_rag
    result = dummy_rag()
    return {'rag_output': result}
