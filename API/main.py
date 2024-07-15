from starlette.middleware.gzip import GZipMiddleware
from starlette.middleware.cors import CORSMiddleware
from fastapi import FastAPI
from routes.main import main_router
from appConfig import ENV_VAR
from database.main import *
# import os
origins = ["*"]

# origins = os.getenv("ALLOWED_ORIGINS", "").split(",")
app = FastAPI(debug=ENV_VAR.DEBUG)

app.add_middleware(GZipMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # You can replace '*' with specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],  # or specific methods
    allow_headers=["Authorization", "Content-Type", "Accept"],  # or specific headers
)

app.include_router(main_router, prefix="/api", tags=["main"])

from helpers.response import ResponseHandler


@app.get("/")
async def home():
    return ResponseHandler.success(message_code=9000)


import uvicorn

if __name__ == "__main__":
    uvicorn.run(
        "main:app",
        host="localhost",
        port=5000,
        reload=ENV_VAR.DEBUG,
        # ssl_certfile=".//API//ssl//server-cert.pem",
        # ssl_keyfile=".//API//ssl//server-key.pem",
    )
