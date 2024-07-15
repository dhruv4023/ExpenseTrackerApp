from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.account import (
    addAccount,
    editAccountName,
    setDefaultAccount,
)

router = APIRouter()


@router.post("/add/wallet/{walletId}")
async def add_account(req: Request, walletId: str, token: str = Depends(verify_token)):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        body = await req.json()
        accountName = body.get("accountName")
        openingBalance = body.get("openingBalance")
        accountId = addAccount(
            walletId=walletId,
            accountName=accountName,
            openingBalance=float(openingBalance),
        )
        return ResponseHandler.success(4001, {"accountId": accountId})
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/edit/name/wallet/{walletId}/account/{accountId}")
async def edit_accountName(
    req: Request, walletId: str, accountId: str, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        body = await req.json()
        newAccountName = body.get("newAccountName")
        editAccountName(walletId, accountId, newAccountName)
        return ResponseHandler.success(4003)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put(
    "/set/default/{accountId}/wallet/{walletId}"
)
async def set_default_account(
    walletId: str,
    accountId: str,
    token: str = Depends(verify_token),
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        setDefaultAccount(walletId, accountId)
        return ResponseHandler.success(4002)
    except Exception as e:
        return ResponseHandler.error(9999, e)



# @router.delete("/delete/wallet/{walletId}/label/{labelId}")
# async def delete_label(walletId: str, labelId: str, token: str = Depends(verify_token)):
#     try:
#         if walletId[:-5] != token["username"]:
#             return ResponseHandler.error(5001, None, 403)
#         deleteLabel(walletId, labelId)
#         return ResponseHandler.success(3005)
#     except Exception as e:
#         return ResponseHandler.error(9999, e)
