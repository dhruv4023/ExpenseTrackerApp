from database.main import *
from database.total_and_label import addNewTotalLabelDoc


# Function to create a new wallet document
def createWallet(userName: str, methodName: str, yyyy: str = None):
    if yyyy is None:
        yyyy = str(datetime.now().date())[:4]

    # Generate a unique ID for the wallet
    _id = userName + "_" + yyyy

    # Construct the wallet document
    wallet_doc = {
        "_id": _id,
        "title": methodName,
        "year": yyyy,
        "username": userName,
        "transactions": [],
        "started_on": str(datetime.now()),
    }

    # Validate the wallet document against the schema
    validate_document(document=wallet_doc, schema=wallet_schema)

    # Start a MongoDB transaction
    with db_client.start_session() as session:
        # Start a transaction
        with session.start_transaction():
            try:
                # Insert the wallet document into the database
                wallets.insert_one(wallet_doc, session=session)

                # Add new total and label document
                if not addNewTotalLabelDoc(userName, session=session):
                    raise Exception("An error occurred")

                # Commit the transaction
                session.commit_transaction()
                return True
            except Exception as e:
                # Abort the transaction on error
                session.abort_transaction()
                return False


def getWallets(userName: str):
    return list(
        wallets.find(
            {"username": userName},
            {
                "_id": 1,
                "title": 1,
                "year": 1,
            },
        )
    )
