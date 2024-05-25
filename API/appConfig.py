import os
import logging
from dotenv import load_dotenv

load_dotenv()


class ENV_VAR:
    MONGO_DB_URL = os.environ.get("MONGO_DB_URL")
    JWT_SECRET = os.environ.get("JWT_SECRET")
    AUTH_API_END = os.environ.get("AUTH_API_END")
    DEBUG = (
        os.environ.get("DEBUG").lower() == "true" if os.environ.get("DEBUG") else False
    )
print(os.environ.get("AUTH_API_END"))

class CONST_VAR:
    COLLECTIONS = {
        "USERS": "users",
        "WALLETS": "wallets",
        "TOTAL_AND_LABEL": "totalAndLabel",
        "ARCHIVED_TRANSACTIONS": "archivedTransactions",
        "ARCHIVED_TOTAL_AND_LABEL": "archivedTotalAndLabel",
    }


class LOG:
    def __init__(self) -> None:
        pass

    @staticmethod
    def configure_logging(level=logging.INFO):
        logging.basicConfig(level=level)  # Set the logging level

    @staticmethod
    def debug(msg):
        logging.debug(msg)

    @staticmethod
    def info(msg):
        logging.info(msg)

    @staticmethod
    def warning(msg):
        logging.warning(msg)

    @staticmethod
    def error(msg):
        logging.error(msg)

    @staticmethod
    def critical(msg):
        logging.critical(msg)


if ENV_VAR.DEBUG:
    LOG.configure_logging(logging.DEBUG)
