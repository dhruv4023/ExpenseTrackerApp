from fastapi import APIRouter, UploadFile, File, Response
from requests_toolbelt.multipart.encoder import MultipartEncoder
from appConfig import EnvVariables
from helpers.response import ResponseHandler
import requests

router = APIRouter()
AUTH_API_END = EnvVariables.AUTH_API_END 

@router.post("/login/")
async def login_control(req: dict):
    try:
        response = requests.post(f"{AUTH_API_END}/api/v1/auth/login/", json=req)
        print(response)
        response.raise_for_status()
        return ResponseHandler.success_mediator(response.json())
    except Exception as e:
        # Provide a specific error code for identifying the error type
        return ResponseHandler.error_mediator(e)


@router.post("/register/")
async def register_control(req: dict, file: UploadFile = File(None)):
    try:
        form_data = MultipartEncoder()
        for key, value in req.items():
            if value is not None:
                form_data.append(key, str(value))

        if file:
            form_data.append('picPath', file.file, filename=file.filename)

        headers = {'Content-Type': form_data.content_type}
        response = requests.post(f"{AUTH_API_END}/api/v1/auth/register/", headers=headers, data=form_data)
        response.raise_for_status()
        return ResponseHandler.success(Response(), data=response.json())
    except Exception as e:
        return ResponseHandler.error(Response(), error=e)

@router.get("/get/usernames")
async def get_user_names():
    try:
        response = requests.get(f"{AUTH_API_END}/api/v1/auth/get/usernames")
        response.raise_for_status()
        return ResponseHandler.success(Response(), data=response.json())
    except Exception as e:
        return ResponseHandler.error(Response(), error=e)

@router.post("/change/password/")
async def change_pass_control(req: dict, authorization: str = None):
    try:
        headers = {'Content-Type': 'application/json'}
        if authorization:
            headers['Authorization'] = authorization

        response = requests.post(f"{AUTH_API_END}/api/v1/auth/change/password", headers=headers, json=req)
        response.raise_for_status()
        return ResponseHandler.success(Response(), data=response.json())
    except Exception as e:
        return ResponseHandler.error(Response(), error=e)
