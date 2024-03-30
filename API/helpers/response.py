from fastapi import Response
from langs.en.messages import get_message

class ResponseHandler:
    @staticmethod
    def success(message_code=None, data=None, status_code=200):
        response = {
            "success": True,
            "message": get_message(message_code)
        }
        if data is not None:
            response["data"] = data
        return response, status_code

    @staticmethod
    def error(message_code, s_code=422, error=None, data=None):
        response = {
            "success": False,
            "message": get_message(message_code)
        }
        if data is not None:
            response["data"] = data
        if error is not None:
            response["Error Message"] = str(error)
        return response, (500 if message_code == 9999 else s_code)

    @staticmethod
    def success_mediator(response):
        print(response)
        return response

    @staticmethod
    def error_mediator(error):
        print(error)
        return error
