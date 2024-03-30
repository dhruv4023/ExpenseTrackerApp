

from pydantic import BaseModel
from typing import List, Optional
from fastapi.responses import JSONResponse
from starlette.middleware.gzip import GZipMiddleware
from starlette.middleware.cors import CORSMiddleware
from fastapi import FastAPI,Response
from routes.main import main_router

# import os
origins = ["http://localhost:3000"]

# origins = os.getenv("ALLOWED_ORIGINS", "").split(",")

app = FastAPI(debug=True)

app.add_middleware(GZipMiddleware)
app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,  # You can replace '*' with specific origins
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],  # or specific methods
    allow_headers=["Authorization", "Content-Type", "Accept"]  # or specific headers
)

app.include_router(main_router, prefix="/api", tags=["main"])

class BodyModel(BaseModel):
    query: str
    chain_name: Optional[str] = None  # Made chain_name optional
    

@app.get("/")
async def home(response: Response):
    response.status_code = 200  # Set the status code
    return {"status": response.status_code, "message": "chatbot api server is running..."}

@app.exception_handler(Exception)
async def exception_handler(request, exc):
    return JSONResponse(status_code=500, content={"message": "Internal Server Error"})


if __name__ == "__main__":
    import uvicorn

    uvicorn.run("main:app", host="0.0.0.0", port=5000, reload=True)


# @app.post("/ask")
# async def askQ(body: BodyModel, token: str = Depends(verify_token_and_role)):
#     try:
#         return JSONResponse(content={"success": True, "data": "response"})
#     except Exception as e:  # Catch specific exceptions
#         return JSONResponse(content={"success": False, "error": str(e)})


