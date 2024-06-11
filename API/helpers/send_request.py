from requests import request
from appConfig import LOG

def sendRequest(url, method="get", data=None, files=None, headers=None):
    try:
        if files:
            return request(method, url, data=data, files=files, headers=headers)
        return request(method, url, json=data, headers=headers)
    except Exception as e:
        # Handle exceptions and return None
        LOG.debug(f"Error occurred during request: {e}")
        return None
