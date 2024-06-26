# Schema for wallets and archived collection
wallet_schema = {
    "_id": str,
    "title": str,
    "year": str,
    "username": str,
    "transactions": list,
    "started_on": str,
}

transaction_schema = {
    "_id": str,
    "dateTime": str,
    "comment": str,
    "account_id": str,
    "label_id": str,
    "amt": float,
}

# Schema for wallets collection
total_label_schema = {
    "_id": str,
    "labels": list,
}

label_schema = {
    "_id": str,
    "label_name": str,
    "default": bool,
    "isAccount": bool,
    "jan": dict,
    "feb": dict,
    "mar": dict,
    "apr": dict,
    "may": dict,
    "jun": dict,
    "jul": dict,
    "aug": dict,
    "sep": dict,
    "oct": dict,
    "nov": dict,
    "dec": dict,
}

total_schema = {
    "dr": float,
    "cr": float,
}


def validate_document(document, schema: dict):
    for field, field_type in schema.items():
        if field not in document:
            raise ValueError(f"Missing field: {field}")
        if not isinstance(document[field], field_type):
            raise ValueError(
                f"Invalid field type for {field}. Expected: {field_type.__name__}, Actual: {type(document[field]).__name__}"
            )
