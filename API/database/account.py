from database.main import *
from database.unique_id import getUniqueId


# to add new Label object in TotalAndLabel Document
def addAccount(
    userName: str,
    accountName: str,
    default=False,
    accountId=str(getUniqueId()),
    session=None,
):
    try:
        doc = {
            "_id": accountId,
            "account_name": accountName,
            "default": default,
            "added_on": datetime.now(),
            "updated_on": datetime.now(),
        }
        validate_document(doc, schema=account_schema)
        res = ACCOUNTS_AND_LABELS.update_one(
            {"_id": userName}, {"$push": {"accounts": doc}}, session=session
        ).modified_count
        if res == 0:
            raise Exception("Failed to add account")
        return accountId
    except Exception as e:
        raise Exception("Failed to add account: " + str(e))


# to remove Account object from TotalAndAccount Document
def deleteAccount(userName: str, accountId: str, session=None):
    try:
        if accountId == "0":
            raise Exception("You can't delete the default account")

        x = ACCOUNTS_AND_LABELS.update_one(
            {"_id": userName},
            {"$pull": {"accounts": {"_id": accountId}}},
            session=session,
        )
        if x.modified_count == 0:
            raise Exception("Failed to delete account")
        return True
    except Exception as e:
        raise Exception("Failed to delete account: " + str(e))


# to set Account object as default in TotalAndAccount Document
def setDefaultAccount(userName: str, accountId: str, session=None):
    try:
        accounts = ACCOUNTS_AND_LABELS.find_one({"_id": userName}, {"accounts": 1})[
            "accounts"
        ]
        if len([i for i in accounts if i["_id"] == accountId]) == 0:
            raise Exception("wrong account Id")

        oldDefaultAccountId = [i for i in accounts if i["default"]][0]["_id"]
        if oldDefaultAccountId == accountId:
            return
        query = {
            "_id": userName,
            "accounts._id": {"$in": [accountId, oldDefaultAccountId]},
        }
        update = {
            "$set": {
                f"accounts.$[new].default": True,
                f"accounts.$[old].default": False,
            }
        }
        array_filters = [
            {"new._id": accountId},
            {"old._id": oldDefaultAccountId},
        ]
        x = ACCOUNTS_AND_LABELS.update_one(
            query, update, array_filters=array_filters, session=session
        )
        if x.modified_count == 0:
            raise Exception("Failed to set default account")
        return True
    except Exception as e:
        raise Exception("Failed to set default account: " + str(e))


# to edit Account name in object of account in TotalAndAccount Document
def editAccountName(userName: str, accountId: str, newAccountName: str, session=None):
    try:
        query = {"_id": userName, "accounts._id": accountId}
        update = {"$set": {"accounts.$.account_name": newAccountName}}
        x = ACCOUNTS_AND_LABELS.update_one(query, update, session=session)
        if x.modified_count == 0:
            raise Exception("Failed to edit account name")
        return True
    except Exception as e:
        raise Exception("Failed to edit account name: " + str(e))
