from fastapi import APIRouter
from controllers.label.label_controller import router as label_routes
from controllers.account.account_controller import router as account_routes
from controllers.label_account.label_account_controller import router as label_account_routes

main_account_label_router = APIRouter()

main_account_label_router.include_router(label_routes, prefix="/label", tags=["Label"])
main_account_label_router.include_router(account_routes, prefix="/account", tags=["Account"])
main_account_label_router.include_router(label_account_routes, prefix="/label_account", tags=["LabelAccount"])
