from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.total_and_label import (
    addLabel,
    editLabelName,
    deleteLabel,
    setDefaultLabel,
    getLabels,
)

router = APIRouter()


@router.post("/add")
async def add_label(req: Request, token: str = Depends(verify_token)):
    try:
        body = await req.json()
        labelName = body.get("labelName")
        isAccount = body.get("isAccount")
        labelId = addLabel(
            UID=token["username"], labelName=labelName, isAccount=isAccount
        )
        return ResponseHandler.success(3001, {"labelId": labelId})
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/edit/name/wallet/{walletId}/label/{labelId}")
async def edit_labelName(
    req: Request, walletId: str, labelId: str, token: str = Depends(verify_token)
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        body = await req.json()
        newLabelName = body.get("newLabelName")
        editLabelName(walletId, labelId, newLabelName)
        return ResponseHandler.success(3003)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put(
    "/set/default/{labelId}/wallet/{walletId}/oldDefaultLabel/{oldDefaultLabelId}"
)
async def set_default_label(
    walletId: str,
    labelId: str,
    oldDefaultLabelId: str,
    token: str = Depends(verify_token),
):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        setDefaultLabel(walletId, labelId, oldDefaultLabelId)
        return ResponseHandler.success(3002)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.get("/get/wallet/{walletId}")
async def get_labels(walletId: str, token: str = Depends(verify_token)):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        labels = getLabels(walletId)
        return ResponseHandler.success(3004, {"labels": labels})
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.delete("/deleteLabel/{walletId}/{labelId}")
async def delete_label(walletId: str, labelId: str, token: str = Depends(verify_token)):
    try:
        if walletId[:-5] != token["username"]:
            return ResponseHandler.error(5001, None, 403)
        deleteLabel(walletId, labelId)
        return ResponseHandler.success(3005)
    except Exception as e:
        return ResponseHandler.error(9999, e)
