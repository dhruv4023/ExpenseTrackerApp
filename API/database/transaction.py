from database.unique_id import *
from database.main import *
from helpers.pagination import get_paginated_response
from database.accounts_and_labels import (
    getLabelsAccounts,
)


def addNewTransaction(
    walletId: str, comment: str, amt: float, accountId: str, labelId: str
):
    with db_client.start_session() as session:
        with session.start_transaction():
            try:
                # Generate transaction ID and method ID
                transactionId = getUniqueId()

                # Create transaction document
                doc = {
                    "_id": str(transactionId),
                    "comment": comment,
                    "account_id": accountId,  # if accountId else defaltAccId,
                    "label_id": labelId,  # if labelId else defaultLabelId,
                    "added_on": datetime.now(),
                    "updated_on": datetime.now(),
                    "amt": amt,
                }

                validate_document(document=doc, schema=transaction_schema)

                query = {"_id": walletId}
                update = {"$push": {"transactions": {"$each": [doc], "$position": 0}}}
                result = updateOne(query, update, session=session)

                if result == 0:
                    raise Exception("Failed to update transactions list")
                session.commit_transaction()
                return transactionId
            except Exception as e:
                session.abort_transaction()
                raise Exception(f"Error adding new transaction: {e}")


# to delete a transaction from transactions array
def deleteTransaction(walletId: str, transactionId: str):
    with db_client.start_session() as session:
        with session.start_transaction():
            try:
                query = {"_id": walletId}
                transactionData = getTransactionById(walletId, transactionId)
                update = {"$pull": {"transactions": {"_id": transactionData["_id"]}}}
                session.commit_transaction()
                updateOne(query, update, session=session)
            except Exception as e:
                session.abort_transaction()
                LOG.debug(f"Error deleting transaction: {e}")
                raise Exception(f"Error deleting transaction: {e}")


# to edit comment in a transaction
def editTransactionsComment(walletId: str, transactionId: str, comment: str):
    with db_client.start_session() as session:
        with session.start_transaction():
            try:
                query = {"_id": walletId, "transactions._id": transactionId}
                update = {"$set": {"transactions.$.comment": comment}}
                session.commit_transaction()
                return updateOne(query, update, session=session)
            except Exception as e:
                session.abort_transaction()
                LOG.debug(f"Error editing comment in transaction: {e}")
                raise Exception(f"Error editing comment in transaction: {e}")


# to edit label in a transaction
def changelableTransactions(walletId: str, newLabelId: str, transactionId: str):
    with db_client.start_session() as session:
        with session.start_transaction():
            try:
                transactionData = getTransactionById(walletId, transactionId)
                if transactionData["label_id"] == newLabelId:
                    raise Exception(f"new label and old label are same")

                query = {
                    "_id": walletId,
                    "transactions._id": transactionId,
                }
                update = {"$set": {"transactions.$.label_id": newLabelId}}
                if updateOne(query, update, session=session) == 0:
                    raise Exception(f"Error changing label in transaction")
                session.commit_transaction()
                return "label updated successfully"
            except Exception as e:
                session.abort_transaction()
                LOG.debug(f"Error changing label in transaction: {e}")
                raise Exception(f"Error changing label in transaction: {e}")


# to retrive transactions
def getTransactions(walletId: str, page: int = 1, limit: int = 10):
    query = {"_id": walletId}
    tnxs = WALLETS.find_one(
        query,
        {
            "transactions": {"$slice": [(page - 1) * limit, limit]},
            "transactionCount": {
                "$size": "$transactions",
            },
        },
    )
    labels = None
    if page == 1:
        labelsAccounts = getLabelsAccounts(walletId)
    return get_paginated_response(
        list(tnxs["transactions"]),
        page,
        limit,
        tnxs["transactionCount"],
        **{"labelsAccounts": labelsAccounts},
    )


def getTransactionById(walletId: str, transactionId: str):
    return WALLETS.find_one(
        {"_id": walletId, "transactions._id": transactionId}, {"transactions.$": 1}
    )["transactions"][0]


# common updateOne function
def updateOne(query, update, session):
    return WALLETS.update_one(query, update, session=session).modified_count
