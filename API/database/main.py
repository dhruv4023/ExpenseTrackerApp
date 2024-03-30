from database.schemas import *
from datetime import datetime
from pymongo import MongoClient
import ssl
from appConfig import EnvVariables, ConstVariables

# DB_URL = "mongodb://localhost:27017"

# Adding security by using Secure Socket Layer
client = MongoClient(EnvVariables.MONGO_DB_URL, ssl_cert_reqs=ssl.CERT_NONE)

print("Connected successfully")

db = client["ExpenseTrackerDb"]

# All collections
users = db[ConstVariables.COLLECTIONS["USERS"]]
transactionsMethods = db[ConstVariables.COLLECTIONS["TRANSACTION_METHODS"]]
totalAndLabel = db[ConstVariables.COLLECTIONS["TOTAL_AND_LABEL"]]
archivedTransactions = db[ConstVariables.COLLECTIONS["ARCHIVED_TRANSACTIONS"]]
archivedTotalAndLabel = db[ConstVariables.COLLECTIONS["ARCHIVED_TOTAL_AND_LABEL"]]
