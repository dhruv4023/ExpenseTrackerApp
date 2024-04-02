from fastapi import APIRouter
from controllers.transaction.transaction_controller import router as transaction_routes
main_tnx_router = APIRouter()

main_tnx_router.include_router(transaction_routes, prefix="/transaction", tags=["TransactionMethod"])
