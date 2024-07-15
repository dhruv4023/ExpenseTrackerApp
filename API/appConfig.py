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

class CONST_VAR:
    COLLECTIONS = {
        "WALLETS": "WALLETS",
        "ACCOUNTS_AND_LABELS": "ACCOUNTS_AND_LABELS",
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

LOG.debug(os.environ.get("AUTH_API_END"))