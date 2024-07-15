from database.main import *
from database.unique_id import getUniqueId


# to add new Label object in TotalAndLabel Document
def addLabel(
    walletId: str,
    labelName: str,
    default=False,
    labelId=str(getUniqueId()),
    session=None,
):
    try:
        doc = {
            "_id": labelId,
            "label_name": labelName,
            "default": default,
            "added_on": datetime.now(),
            "updated_on": datetime.now(),
        }
        validate_document(doc, schema=label_schema)
        res = ACCOUNTS_AND_LABELS.update_one(
            {"_id": walletId}, {"$push": {"labels": doc}}, session=session
        ).modified_count
        if res == 0:
            raise Exception("Failed to add label")
        return labelId
    except Exception as e:
        raise Exception("Failed to add label: " + str(e))


# to remove Label object from TotalAndLabel Document
def deleteLabel(walletId: str, labelId: str, session=None):
    try:
        if labelId == "0":
            raise Exception("You can't delete the default label or account")
        x = ACCOUNTS_AND_LABELS.update_one(
            {"_id": walletId}, {"$pull": {"labels": {"_id": labelId}}}, session=session
        )
        if x.modified_count == 0:
            raise Exception("Failed to delete label or account")
        return True
    except Exception as e:
        raise Exception("Failed to delete label or account: " + str(e))


# to set Label object as default in TotalAndLabel Document
def setDefaultLabel(walletId: str, labelId: str, session=None):
    try:

        labels = ACCOUNTS_AND_LABELS.find_one({"_id": walletId}, {"labels": 1})[
            "labels"
        ]
        if len([i for i in labels if i["_id"] == labelId]) == 0:
            raise Exception("wrong label Id")

        oldDefaultLabelId = [i for i in labels if i["default"]][0]["_id"]
        if oldDefaultLabelId == labelId:
            return

        query = {"_id": walletId, "labels._id": {"$in": [labelId, oldDefaultLabelId]}}

        update = {
            "$set": {f"labels.$[new].default": True, f"labels.$[old].default": False}
        }
        array_filters = [
            {"new._id": labelId},
            {"old._id": oldDefaultLabelId},
        ]
        x = ACCOUNTS_AND_LABELS.update_one(
            query, update, array_filters=array_filters, session=session
        )
        if x.modified_count == 0:
            raise Exception("Failed to set default label or account")
        return True
    except Exception as e:
        raise Exception("Failed to set default label or account: " + str(e))


# to edit Label name in object of label in TotalAndLabel Document
def editLabelName(walletId: str, labelId: str, newLabelName: str, session=None):
    try:
        query = {"_id": walletId, "labels._id": labelId}
        update = {"$set": {"labels.$.label_name": newLabelName}}
        x = ACCOUNTS_AND_LABELS.update_one(query, update, session=session)
        if x.modified_count == 0:
            raise Exception("Failed to edit label or account name ")
        return True
    except Exception as e:
        raise Exception("Failed to edit label or account name: " + str(e))
