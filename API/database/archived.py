from   database.main import *
from  database.total_and_label import addLabel


# to archive previous year transactions
def archiveTransactions(doc_id: str):
    LOG.debug(doc_id)
    oldTransMethId = doc_id[:-2]+str(int(doc_id[-2:])-1)
    oldIdQuery = {"_id": oldTransMethId}

    tranMethObj = wallets.find_one(oldIdQuery)
    totalAndLabelObj = totalAndLabel.find_one(oldIdQuery)

    LOG.debug(totalAndLabelObj)
    if archivedTransactions.insert_one(tranMethObj) and archivedTotalAndLabel.insert_one(totalAndLabelObj):
        wallets.delete_one(oldIdQuery)
        totalAndLabel.delete_one(oldIdQuery)

        try:
            labelNames = totalAndLabelObj["labels"]
            LOG.debug(labelNames)
            i = 0
            for label in labelNames:
                LOG.debug(label["labelName"])
                if i:
                    addLabel(_id=doc_id, labelName=label["labelName"])
                else:
                    i = 1
        except:
            LOG.debug("label not added")

    return True
