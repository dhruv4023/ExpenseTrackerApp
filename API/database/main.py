from database.schemas import *
from datetime import datetime
from pymongo import MongoClient
from appConfig import ENV_VAR, CONST_VAR,LOG

db_client = MongoClient(ENV_VAR.MONGO_DB_URL)

LOG.debug("Connected successfully")

db = db_client["ExpenseTrackerDb"]

# All collections
WALLETS = db[CONST_VAR.COLLECTIONS["WALLETS"]]
ACCOUNTS_AND_LABELS = db[CONST_VAR.COLLECTIONS["ACCOUNTS_AND_LABELS"]]
