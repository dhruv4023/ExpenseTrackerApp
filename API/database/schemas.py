from datetime import datetime

wallet_schema = {
    "_id": str,
    "year": str,
    "username": str,
    "transactions": list,
    "opening_balances": list,
    "started_on": str,
    "updated_on": str,
}
opening_balance_obj_schema = {"_id": str, "balance": float}

transaction_schema = {
    "_id": str,
    "comment": str,
    "account_id": str,
    "label_id": str,
    "amt": float,
    "added_on": datetime,
    "updated_on": datetime,
}

accounts_and_labels_schema = {
    "_id": str,
    "labels": list,
    "accounts": list,
    "added_on": datetime,
    "updated_on": datetime,
}

account_schema = {
    "_id": str,
    "account_name": str,
    "default": bool,
    "added_on": datetime,
    "updated_on": datetime,
}

label_schema = {
    "_id": str,
    "label_name": str,
    "default": bool,
    "added_on": datetime,
    "updated_on": datetime,
}


def validate_document(document, schema):
    for field, field_type in schema.items():
        if field not in document:
            raise ValueError(f"Missing field: {field}")
        if field_type == datetime:
            if not isinstance(document[field], datetime):
                raise ValueError(
                    f"Invalid field type for {field}. Expected: {field_type.__name__}, Actual: {type(document[field]).__name__}"
                )
        elif not isinstance(document[field], field_type):
            raise ValueError(
                f"Invalid field type for {field}. Expected: {field_type.__name__}, Actual: {type(document[field]).__name__}"
            )
