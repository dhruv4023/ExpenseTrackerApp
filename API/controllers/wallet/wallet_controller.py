from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.wallet import createWallet, getWallets
from controllers.auth.user_controller import get_user_date

router = APIRouter()

@router.get("/get")
async def get_wallets(req: Request, token: str = Depends(verify_token)):
    try:
        return ResponseHandler.success(1002, {"wallets": getWallets(token["username"])})
    except Exception as e:
        return ResponseHandler.error(9999, e)
