from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.transaction import (
    addNewTransaction,
    deleteTransaction,
    editTransactionsComment,
    changelableTransactions,
    getTransactions,
)

router = APIRouter()


@router.post("/add")
async def add_transaction(req: Request, token: str = Depends(verify_token)):
    try:
        body = await req.json()
        comment = body.get("comment")
        amt = body.get("amt")
        labelIds = body.get("labelIds")
        if addNewTransaction(token["username"], comment, float(amt), labelIds):
            return ResponseHandler.success(2001)
        else:
            return ResponseHandler.success(2002)

    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.delete("/{transactionId}/delete/wallet/{walletId}")
async def delete_transaction(
    walletId: str, transactionId: str, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        if deleteTransaction(walletId,  transactionId):
            return ResponseHandler.success(2003)
        else:
            return ResponseHandler.error(2004)
    except Exception as e:
        return ResponseHandler.error(2004, e)


@router.put("/{transactionId}/edit/comment/wallet/{walletId}")
async def edit_comment(
    walletId: str, transactionId: str, req: Request, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        body = await req.json()
        comment = body.get("comment")
        if editTransactionsComment(walletId, transactionId, comment):
            return ResponseHandler.success(2005)
        else:
            return ResponseHandler.error(2006)
    except Exception as e:
        return ResponseHandler.error(2006, e)


@router.put("/{transactionId}/edit/labelname/wallet/{walletId}")
async def edit_label(
    walletId: str, transactionId: str, req: Request, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        body = await req.json()
        newLabelIds = body.get("newLabelIds")
        if changelableTransactions(walletId, newLabelIds, transactionId):
            return ResponseHandler.success(2007)
        else:
            return ResponseHandler.error(2008)
    except Exception as e:
        return ResponseHandler.error(2008, e)


@router.get("/get/wallet/{walletId}")
async def get_transactions(
    walletId: str,
    page: int,
    limit: int,
    token: str = Depends(verify_token),
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        transactions = getTransactions(walletId, page, limit)
        return ResponseHandler.success(2009, {"transactions": (transactions)})
    except Exception as e:
        return ResponseHandler.error(500, str(e))
