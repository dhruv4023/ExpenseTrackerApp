from database.schemas import *
from datetime import datetime
from pymongo import MongoClient
from appConfig import ENV_VAR, CONST_VAR

db_client = MongoClient(ENV_VAR.MONGO_DB_URL)

print("Connected successfully")

db = db_client["ExpenseTrackerDb"]

# All collections
users = db[CONST_VAR.COLLECTIONS["USERS"]]
wallets = db[CONST_VAR.COLLECTIONS["WALLETS"]]
totalAndLabel = db[CONST_VAR.COLLECTIONS["TOTAL_AND_LABEL"]]
archivedTransactions = db[CONST_VAR.COLLECTIONS["ARCHIVED_TRANSACTIONS"]]
archivedTotalAndLabel = db[CONST_VAR.COLLECTIONS["ARCHIVED_TOTAL_AND_LABEL"]]
