import math


def get_paginated_response(data, current_page, limit, total, **kwargs):
    total_pages = math.ceil(total / limit)
    current_page = int(current_page)
    previous_page = current_page - 1 if current_page > 1 else None
    next_page = current_page + 1 if current_page < total_pages else None

    response = {
        "page_data": data,
        "page_information": {
            "total_data": total,
            "last_page": total_pages,
            "current_page": current_page,
            "previous_page": previous_page,
            "next_page": next_page,
        },
    }

    # Add additional objects to the response
    response.update(kwargs)

    return response
