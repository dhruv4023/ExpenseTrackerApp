MESSAGES = {
    # wallet
    1001: "wallet added successfully",
    1002: "wallet retrived successfully",
    # Transaction
    2001: "Transaction added successfully",
    2002: "Failed to add transaction",
    2003: "Transaction deleted successfully",
    2004: "Failed to delete transaction",
    2005: "Transaction comment edited successfully",
    2006: "Failed to edit transaction comment",
    2007: "Transaction label changed successfully",
    2008: "Failed to change transaction label",
    2009: "Returns the list of transactions",
    # Label
    3001: "Label added successfully",
    3002: "Default label updated successfully",
    3003: "Label name updated successfully",
    3004: "Labels retrieved successfully",
    3005: "Label deleted successfully",
    # Authorization messages
    5001: "Unauthorized - Admin access required",
    5002: "Access denied - Unauthorized",
    5003: "Your session expired! Please log in again",
    # General messages
    9000: "api server is running...",
    9999: "Internal Server Error",
}


def get_message(message_code):
    if isinstance(message_code, int) and message_code in MESSAGES:
        return MESSAGES[message_code]

    return message_code
