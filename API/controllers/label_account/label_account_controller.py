from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.accounts_and_labels import getLabelsAccountsWithBalance

router = APIRouter()


@router.get("/get/wallet/{walletId}")
async def get_labels_accounts_with_balance(
    walletId: str, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        labelsAccounts = getLabelsAccountsWithBalance(
            userName=token["username"], walletId=walletId
        )
        return ResponseHandler.success(3004, {"labelsAccounts": labelsAccounts})
    except Exception as e:
        return ResponseHandler.error(9999, e)
