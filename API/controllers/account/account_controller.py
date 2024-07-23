from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.account import (
    addAccount,
    editAccountName,
    setDefaultAccount,
)

router = APIRouter()


@router.post("/add")
async def add_account(req: Request, token: str = Depends(verify_token)):
    try:
        body = await req.json()
        accountName = body.get("accountName")
        accountId = addAccount(
            userName=token["username"],
            accountName=accountName,
        )
        return ResponseHandler.success(4001, {"accountId": accountId})
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/edit/name/account/{accountId}")
async def edit_accountName(
    req: Request, accountId: str, token: str = Depends(verify_token)
):
    try:
        body = await req.json()
        newAccountName = body.get("newAccountName")
        editAccountName(token["username"], accountId, newAccountName)
        return ResponseHandler.success(4003)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/set/default/{accountId}")
async def set_default_account(
    accountId: str,
    token: str = Depends(verify_token),
):
    try:
        setDefaultAccount(token["username"], accountId)
        return ResponseHandler.success(4002)
    except Exception as e:
        return ResponseHandler.error(9999, e)


# @router.delete("/delete/label/{labelId}")
# async def delete_label(walletId: str, labelId: str, token: str = Depends(verify_token)):
#     try:
#         if walletId[:-5] != token["username"]:
#             return ResponseHandler.error(5001, None, 403)
#         deleteLabel(walletId, labelId)
#         return ResponseHandler.success(3005)
#     except Exception as e:
#         return ResponseHandler.error(9999, e)
