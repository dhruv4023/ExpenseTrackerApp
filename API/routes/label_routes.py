from fastapi import APIRouter
from controllers.label.label_controller import router as label_routes

main_label_router = APIRouter()

main_label_router.include_router(label_routes, prefix="/label", tags=["Label"])
