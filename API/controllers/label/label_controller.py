from fastapi import APIRouter, Depends, Request
from helpers.response import ResponseHandler
from middleware.verifyToken import verify_token
from database.labels import (
    addLabel,
    editLabelName,
    deleteLabel,
    setDefaultLabel,
)


router = APIRouter()


@router.post("/add")
async def add_label(req: Request, token: str = Depends(verify_token)):
    try:
        body = await req.json()
        labelName = body.get("labelName")
        labelId = addLabel(userName=token["username"], labelName=labelName)
        return ResponseHandler.success(3001, {"labelId": labelId})
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/edit/name/label/{labelId}")
async def edit_labelName(
    req: Request, labelId: str, token: str = Depends(verify_token)
):
    try:
        body = await req.json()
        newLabelName = body.get("newLabelName")
        editLabelName(token["username"], labelId, newLabelName)
        return ResponseHandler.success(3003)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.put("/set/default/{labelId}")
async def set_default_label(
    labelId: str,
    token: str = Depends(verify_token),
):
    try:
        setDefaultLabel(token["username"], labelId)
        return ResponseHandler.success(3002)
    except Exception as e:
        return ResponseHandler.error(9999, e)


# @router.get("/get")
# async def get_labels token: str = Depends(verify_token)):
#     try:
#         if walletId[:-5] != token["username"]:
#             return ResponseHandler.error(5001, None, 403)
#         labels = getLabels(walletId)
#         return ResponseHandler.success(3004, {"labels": labels})
#     except Exception as e:
# return ResponseHandler.error(9999, e)



@router.delete("/delete/label/{labelId}")
async def delete_label(labelId: str, token: str = Depends(verify_token)):
    try:
        deleteLabel(token["username"], labelId)
        return ResponseHandler.success(3005)
    except Exception as e:
        return ResponseHandler.error(9999, e)
