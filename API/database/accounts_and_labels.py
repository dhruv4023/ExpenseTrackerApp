from database.main import *
from database.unique_id import getUniqueId

from database.account import addAccount
from database.labels import addLabel


# to add new Document in TotalAndLabel
def addNewAccountLabelDoc(walletId: str, session):
    try:
        doc = {"_id": walletId, "labels": []}
        ACCOUNTS_AND_LABELS.insert_one(doc, session=session)
        addAccount(
            walletId,
            accountName="Pocket",
            openingBalance=0.0,
            accountId="0",
            default=True,
            session=session,
        )
        addLabel(
            walletId, labelName="Other", labelId="1", default=True, session=session
        )
    except Exception as e:
        raise Exception("Failed to add new total and label document: " + str(e))


def getSumOfAccountLabel(walletId: str):
    return list(
        WALLETS.aggregate(
            [
                {"$match": {"_id": walletId}},
                {"$unwind": "$transactions"},
                {
                    "$facet": {
                        "sumByAccountId": [
                            {
                                "$group": {
                                    "_id": "$transactions.account_id",
                                    "totalAmt": {"$sum": "$transactions.amt"},
                                },
                            },
                            {"$project": {"totalAmt": {"$round": ["$totalAmt", 2]}}},
                        ],
                        "sumByLabelId": [
                            {
                                "$group": {
                                    "_id": "$transactions.label_id",
                                    "totalAmt": {"$sum": "$transactions.amt"},
                                }
                            },
                            {"$project": {"totalAmt": {"$round": ["$totalAmt", 2]}}},
                        ],
                    }
                },
            ]
        )
    )



def getLabelsAccounts(walletId: str, session=None):
    try:
        return ACCOUNTS_AND_LABELS.find_one({"_id": walletId}, session=session)
    except Exception as e:
        raise Exception("Failed to retrieve accounts and labels: " + str(e))
