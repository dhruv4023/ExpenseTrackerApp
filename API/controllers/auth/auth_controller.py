from fastapi import APIRouter, Response, Request, UploadFile
from appConfig import ENV_VAR
from helpers.response import ResponseHandler
from helpers.send_request import sendRequest
from typing import Optional

router = APIRouter()
AUTH_API_END = ENV_VAR.AUTH_API_END


@router.post("/register/")
async def register(req: Request, picPath: UploadFile = None):
    try:
        form_data = await req.form()

        payload = {key: form_data[key] for key in form_data if key != "picPath"}

        files = None
        if picPath:
            files = {"picPath": (picPath.filename, picPath.file, picPath.content_type)}

        print(payload, picPath, files)
        # else    f"{AUTH_API_END}/api/v1/auth/register/", json=payload}
        response = sendRequest(
            f"{AUTH_API_END}/api/v1/auth/register/", "post", payload, files
        )
        print(response.content)
        return ResponseHandler.success_mediator(response)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.get("/get/usernames")
async def get_user_names():
    try:
        response = sendRequest(f"{AUTH_API_END}/api/v1/auth/get/usernames")
        return ResponseHandler.success_mediator(response)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.post("/login")
async def login_control(req: dict):
    try:
        print("AUTH_API_END :", AUTH_API_END)
        response = sendRequest(f"{AUTH_API_END}/api/v1/auth/login/", "post", req)
        return ResponseHandler.success_mediator(response)
    except Exception as e:
        return ResponseHandler.error(9999, e)


@router.post("/change/password/")
async def change_pass_control(req: dict, authorization: str = None):
    try:
        headers = {"Content-Type": "application/json"}
        if authorization:
            headers["Authorization"] = authorization

        response = sendRequest(
            f"{AUTH_API_END}/api/v1/auth/change/password", "post", req, None, headers
        )
        return ResponseHandler.success_mediator(response)
    except Exception as e:
        return ResponseHandler.error(9999, e)