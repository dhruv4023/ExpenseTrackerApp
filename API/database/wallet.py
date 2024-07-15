from database.main import *
from database.accounts_and_labels import addNewAccountLabelDoc


# Function to create a new wallet document
def createWallet(userName: str, yyyy: str):
    # Generate a unique ID for the wallet
    walletId = userName + "_" + yyyy

    # Construct the wallet document
    wallet_doc = {
        "_id": walletId,
        "year": yyyy,
        "username": userName,
        "transactions": [],
        "started_on": str(datetime.now()),
        "updated_on": str(datetime.now()),
    }

    # Validate the wallet document against the schema
    validate_document(document=wallet_doc, schema=wallet_schema)

    # Start a MongoDB transaction
    with db_client.start_session() as session:
        # Start a transaction
        with session.start_transaction():
            try:
                # Insert the wallet document into the database
                WALLETS.insert_one(wallet_doc, session=session)
            
                # Add new total and label document
                addNewAccountLabelDoc(walletId, session=session)

                # Commit the transaction
                session.commit_transaction()
            except Exception as e:
                # Abort the transaction on error
                session.abort_transaction()
                raise Exception("failed to created Wallet" + str(e))


def getWallets(userName: str):
    res = list(
        WALLETS.find(
            {"username": userName},
            {
                "_id": 1,
                "title": 1,
                "year": 1,
            },
        )
    )
    if res == []:
        createWallet(userName, str(datetime.now().date())[:4])
        return getWallets(userName)

    return res
