from database.main import *
from database.unique_id import getUniqueId

from database.account import addAccount
from database.labels import addLabel


# to add new Document in TotalAndLabel
def addNewAccountLabelDoc(userName: str, session):
    try:
        doc = {
            "_id": userName,
            "labels": [],
            "added_on": str(datetime.now()),
            "updated_on": str(datetime.now()),
        }
        ACCOUNTS_AND_LABELS.insert_one(doc, session=session)
        addAccount(
            userName,
            accountName="Pocket",
            accountId="0",
            default=True,
            session=session,
        )
        addLabel(
            userName, labelName="Other", labelId="1", default=True, session=session
        )
    except Exception as e:
        raise Exception("Failed to add new total and label document: " + str(e))


def getSumOfAccountLabel(walletId: str):
    openingBalances = WALLETS.find_one(walletId, {"opening_balances": 1})
    balance = list(
        WALLETS.aggregate(
            [
                {"$match": {"_id": walletId}},
                {"$project": {"transactions": 1}},
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

    def add_opening_balances(wallet, balance):
        opening_balances_map = {
            ob["_id"]: ob["balance"] for ob in wallet["opening_balances"]
        }

        for entry in balance:
            for account in entry["sumByAccountId"]:
                if account["_id"] in opening_balances_map:
                    account["totalAmt"] += opening_balances_map[account["_id"]]
                    account["totalAmt"] = round(account["totalAmt"], 2)

            for label in entry["sumByLabelId"]:
                if label["_id"] in opening_balances_map:
                    label["totalAmt"] += opening_balances_map[label["_id"]]
                    label["totalAmt"] = round(label["totalAmt"], 2)

    add_opening_balances(openingBalances, balance)
    return balance


def getLabelsAccountsNameOnly(userName: str, session=None):
    try:
        return ACCOUNTS_AND_LABELS.find_one(
            {"_id": userName},
            {
                "labels._id": 1,
                "labels.label_name": 1,
                "labels.default": 1,
                "accounts._id": 1,
                "accounts.account_name": 1,
                "accounts.default": 1,
            },
        )
    except Exception as e:
        raise Exception("Failed to retrieve accounts and labels: " + str(e))


def getLabelsAccounts(userName: str, session=None):
    try:
        return ACCOUNTS_AND_LABELS.find_one(
            {"_id": userName}, {"opening_balance": 0}, session=session
        )
    except Exception as e:
        raise Exception("Failed to retrieve accounts and labels: " + str(e))


def getLabelsAccountsWithBalance(userName: str, walletId: str):
    try:
        labelsAccounts = getLabelsAccounts(userName)
        balance = getSumOfAccountLabel(walletId)

        sumByAccountId = {
            item["_id"]: item["totalAmt"] for item in balance[0]["sumByAccountId"]
        }
        sumByLabelId = {
            item["_id"]: item["totalAmt"] for item in balance[0]["sumByLabelId"]
        }

        for account in labelsAccounts["accounts"]:
            account_balance = sumByAccountId.get(account["_id"], 0)
            account["balance"] = account_balance + account.get("opening_balance", 0)

        for label in labelsAccounts["labels"]:
            label["balance"] = sumByLabelId.get(label["_id"], 0)

        return labelsAccounts

    except Exception as e:
        print(str(e))
        raise Exception(str(e))
