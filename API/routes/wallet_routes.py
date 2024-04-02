from fastapi import APIRouter
from controllers.wallet.wallet_controller import router as wallet_routes
main_wallet_router = APIRouter()

main_wallet_router.include_router(wallet_routes, prefix="/wallet", tags=["wallet"])
