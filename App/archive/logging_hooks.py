# /App/logging_hooks.py

import logging
import time
from flask import request

def before_request_hook():
    """
    Called by Flask before every request.
    We'll store the start time and log request details.
    """
    request.start_time = time.time()
    logging.info(
        "REQUEST START: method=%s path=%s remote_addr=%s user_agent=%s",
        request.method,
        request.path,
        request.remote_addr,
        request.headers.get('User-Agent')
    )

def after_request_hook(response):
    """
    Called by Flask after every request.
    We'll log the response status + duration.
    """
    start_time = getattr(request, 'start_time', time.time())
    elapsed_ms = (time.time() - start_time) * 1000.0
    logging.info(
        "REQUEST END: path=%s status=%s time=%.1fms",
        request.path,
        response.status,
        elapsed_ms
    )
    return response
