from database.unique_id import *
from database.main import *
from helpers.pagination import get_paginated_response
from database.total_and_label import (
    incrementInTotalCollection,
    decrementInTotalCollection,
    decreamentAndIncrement,
    getDefaultLabelId,
)


def addNewTransaction(
    userId: str,
    comment: str,
    amt: int,
    labelId: str,
    dateTime: str = getDateTimeUniqueNumber(),
):
    # Generate transaction ID and method ID
    transactionId = getUniqueId()
    walletId = userId + "_" + dateTime[:4]

    # Create transaction document
    doc = {
        "_id": str(transactionId),
        "dateTime": dateTime,
        "comment": comment,
        "label_id": labelId if labelId else getDefaultLabelId(walletId),
        "amt": amt,
    }

    validate_document(document=doc, schema=transaction_schema)

    with db_client.start_session() as session:
        with session.start_transaction():
            try:
                query = {"_id": walletId}
                update = {"$push": {"transactions": {"$each": [doc], "$position": 0}}}
                result = updateOne(query, update, session=session)

                if not incrementInTotalCollection(walletId, doc, session=session):
                    raise Exception("Failed to increment total amount")

                if result == 0:
                    raise Exception("Failed to update transactions list")

                return True
            except Exception as e:
                # Abort transaction on error
                session.abort_transaction()
                print(f"Error adding new transaction: {e}")
                # Decrement total collection
                # decrementInTotalCollection(walletId, doc, session=session)
                return False


# to delete a transaction from transactions array
def deleteTransaction(walletId: str, transactionData: dict):
    try:
        query = {"_id": walletId}
        update = {"$pull": {"transactions": {"_id": transactionData["transactionId"]}}}
        with db_client.start_session() as session:
            return decrementInTotalCollection(
                walletId, transactionData, session=session
            ) and updateOne(query, update, session=session)
    except Exception as e:
        raise Exception(f"Error deleting transaction: {e}")


# to edit comment in a transaction
def editTransactionsComment(walletId: str, transactionId: str, comment: str):
    try:
        query = {"_id": walletId, "transactions._id": transactionId}
        update = {"$set": {"transactions.$.comment": comment}}
        with db_client.start_session() as session:
            return updateOne(query, update, session=session)
    except Exception as e:
        raise Exception(f"Error editing comment in transaction: {e}")


# to edit label in a transaction
def changelableTransactions(walletId: str, newLabelId: str, transactionId: str):
    try:
        transactionData = getTransactionById(walletId, transactionId)
        if transactionData["label_id"]==newLabelId:
            return True
        query = {
            "_id": walletId,
            "transactions._id": transactionId,
        }
        update = {"$set": {"transactions.$.label_id": newLabelId}}
        with db_client.start_session() as session:
            decreamentAndIncrement(
                walletId,
                newLabelId,
                transactionData,
                session,
            )

            if updateOne(query, update, session=session) == 0:
                raise Exception(f"Error changing label in transaction")
            return True
    except Exception as e:
        print(f"Error changing label in transaction: {e}")
        raise Exception(f"Error changing label in transaction: {e}")


# to retrive transactions
def getTransactions(walletId: str, page: int = 1, limit: int = 10):
    query = {"_id": walletId}
    tnxs = wallets.find_one(
        query,
        {
            "transactions": {"$slice": [(page - 1) * limit, limit]},
            "transactionCount": {
                "$size": "$transactions",
            },
        },
    )
    return get_paginated_response(
        list(tnxs["transactions"]), page, limit, tnxs["transactionCount"]
    )


def getTransactionById(walletId: str, transactionId: str):
    return wallets.find_one(
        {"_id": walletId, "transactions._id": transactionId}, {"transactions.$": 1}
    )["transactions"][0]


# common updateOne function
def updateOne(query, update, session):
    return wallets.update_one(query, update, session=session).modified_count