from fastapi import APIRouter
from routes.auth_routes import main_auth_router
from routes.transaction_routes import main_tnx_router
from routes.wallet_routes import main_wallet_router
from routes.label_routes import main_label_router

main_router = APIRouter()

main_router.include_router(main_auth_router)
main_router.include_router(main_wallet_router)
main_router.include_router(main_label_router)
main_router.include_router(main_tnx_router)
