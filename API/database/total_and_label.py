from database.main import *
from database.unique_id import getUniqueId


MONTHS = [
    "jan",
    "feb",
    "mar",
    "apr",
    "may",
    "jun",
    "jul",
    "aug",
    "sep",
    "oct",
    "nov",
    "dec",
]


# to add new Document in TotalAndLabel
def addNewTotalLabelDoc(UID: str, session):
    try:
        _id = UID + "_" + str(datetime.now().date())[:4]
        doc = {"_id": _id, "labels": []}
        totalAndLabel.insert_one(doc, session=session)
        res = addLabel(UID, "default", labelId="0", default=True, session=session)
        if res:
            return True
        else:
            raise Exception("Failed to add default label")
    except Exception as e:
        raise Exception("Failed to add new total and label document: " + str(e))


# to add new Label object in TotalAndLabel Document
def addLabel(
    UID: str, labelName: str, labelId=str(getUniqueId()), default=False, session=None
):
    try:
        _id = UID + "_" + str(datetime.now().date())[:4]
        doc = {"_id": labelId, "label_name": labelName, "default": default}
        doc = generateArrayOfMonthlyTotal(doc)
        validate_document(doc, schema=label_schema)
        res = totalAndLabel.update_one(
            {"_id": _id}, {"$push": {"labels": doc}}, session=session
        ).modified_count
        if labelId and res:
            return labelId
        else:
            raise Exception("Failed to add label")
    except Exception as e:
        raise Exception("Failed to add label: " + str(e))


# to remove Label object from TotalAndLabel Document
def deleteLabel(walletId: str, labelId: str, session=None):
    try:
        query = {"_id": walletId}
        if labelId == "0":
            raise Exception("You can't delete the default label")
        args = {"labels": {"$elemMatch": {"_id": labelId}}}
        labelData = totalAndLabel.find_one(query, args, session=session)["labels"][0]
        for i in MONTHS:
            if labelData[i]["dr"] != 0 or labelData[i]["cr"] != 0:
                raise Exception(
                    "Some transactions are marked with this label. Please remove them and try again."
                )
        x = totalAndLabel.update_one(
            {"_id": walletId}, {"$pull": {"labels": {"_id": labelId}}}, session=session
        )
        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to delete label")
    except Exception as e:
        raise Exception("Failed to delete label: " + str(e))


# to set Label object as default in TotalAndLabel Document
def setDefaultLabel(walletId: str, labelId: str, oldDefaultLabelId: str, session=None):
    try:
        query = {"_id": walletId, "labels._id": {"$in": [labelId, oldDefaultLabelId]}}
        update = {
            "$set": {f"labels.$[new].default": True, f"labels.$[old].default": False}
        }
        array_filters = [
            {"new._id": labelId},
            {"old._id": oldDefaultLabelId},
        ]
        x = totalAndLabel.update_one(
            query, update, array_filters=array_filters, session=session
        )
        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to set default label")
    except Exception as e:
        raise Exception("Failed to set default label: " + str(e))


# to edit Label name in object of label in TotalAndLabel Document
def editLabelName(walletId: str, labelId: str, newLabelName: str, session=None):
    try:
        query = {"_id": walletId, "labels._id": labelId}
        update = {"$set": {"labels.$.label_name": newLabelName}}
        x = totalAndLabel.update_one(query, update, session=session)
        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to edit label name")
    except Exception as e:
        raise Exception("Failed to edit label name: " + str(e))


def getLabels(walletId: str, session=None):
    try:
        return totalAndLabel.find_one({"_id": walletId}, session=session)["labels"]
    except Exception as e:
        raise Exception("Failed to retrieve labels: " + str(e))


# increment total while adding new transaction
def incrementInTotalCollection(walletId: str, transactionData: dict, session):
    try:
        amt = transactionData["amt"]
        labelId = transactionData["label_id"]
        mm = int(transactionData["dateTime"][4:6])
        label = "dr" if amt < 0 else "cr"

        query = {"_id": walletId, "labels._id": labelId}
        inc_field = {"labels.$." + MONTHS[mm - 1] + "." + label: abs(amt)}

        x = totalAndLabel.update_one(query, {"$inc": inc_field}, session=session)
        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to increment total")
    except Exception as e:
        raise Exception("Failed to increment total: " + str(e))


# decrement total while deleting a transaction
def decrementInTotalCollection(walletId: str, transactionData: dict, session):
    try:
        amt = transactionData["amt"]
        labelId = transactionData["label_id"]
        mm = int(transactionData["dateTime"][4:6])
        label = "dr" if amt < 0 else "cr"

        query = {"_id": walletId, "labels._id": labelId}
        dec_field = {"labels.$." + MONTHS[mm - 1] + "." + label: -(abs(amt))}

        x = totalAndLabel.update_one(query, {"$inc": dec_field}, session=session)
        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to decrement total")
    except Exception as e:
        raise Exception("Failed to decrement total: " + str(e))


# change total while changing label of a transaction
def decreamentAndIncrement(
    walletId: str, newLabelId: str, transactionData: dict, session
):
    try:
        if newLabelId not in getistOfLabelIds(walletId): 
            raise Exception("Label not exist")
        amt = transactionData["amt"]
        oldLabelId = transactionData["label_id"]
        mm = int((transactionData["dateTime"][4:6]))
        label = "dr" if amt < 0 else "cr"
        query = {"_id": walletId, "labels._id": {"$in": [newLabelId, oldLabelId]}}
        update = {
            "$inc": {
                f"labels.$[old]." + MONTHS[mm - 1] + "." + label: -(abs(amt)),
                f"labels.$[new]." + MONTHS[mm - 1] + "." + label: (abs(amt)),
            }
        }
        array_filters = [{"old._id": oldLabelId}, {"new._id": newLabelId}]

        x = totalAndLabel.update_one(
            query, update, array_filters=array_filters, session=session
        )

        if x.modified_count != 0:
            return True
        else:
            raise Exception("Failed to update total while changing label")
    except Exception as e:
        raise Exception("Failed to update total while changing label: " + str(e))


def generateArrayOfMonthlyTotal(res):
    doc = {
        "dr": 0,
        "cr": 0,
    }
    validate_document(doc, total_schema)
    for i in range(0, 12):
        res[MONTHS[i]] = doc
    return res


def getDefaultLabelId(walletId: str):
    try:
        return totalAndLabel.find_one(
            {"_id": walletId, "labels.default": True}, {"labels.$": 1}
        )["labels"][0]["_id"]
    except Exception as e:
        raise Exception("Failed to retrieve default label ID: " + str(e))


def getistOfLabelIds(walletId: str):
    return [
        obj["_id"]
        for obj in totalAndLabel.find_one({"_id": walletId}, {"labels._id": 1})[
            "labels"
        ]
    ]
