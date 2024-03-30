from fastapi import APIRouter
from routes.auth.auth_routes import router as auth_routes

main_router = APIRouter()

main_router.include_router(auth_routes, prefix="/auth", tags=["Authentication"])
