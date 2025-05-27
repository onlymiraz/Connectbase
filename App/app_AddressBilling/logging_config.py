# D:\Scripts\WebApp\app_AddressBilling\logging_config.py
import os
import logging
from logging.handlers import RotatingFileHandler

# Ensure debug folder exists in app_AddressBilling
LOG_DEBUG_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'debug')
os.makedirs(LOG_DEBUG_DIR, exist_ok=True)

# Rotating file for app-level logs
APP_LOG_FILE = os.path.join(LOG_DEBUG_DIR, 'app_logger.log')
logger = logging.getLogger("app_logger")
logger.setLevel(logging.INFO)

if not logger.handlers:
    file_handler = RotatingFileHandler(
        APP_LOG_FILE,
        maxBytes=5 * 1024 * 1024,
        backupCount=5,
        encoding='utf-8'
    )
    file_handler.setLevel(logging.INFO)
    formatter = logging.Formatter(
        '%(asctime)s | %(levelname)s | %(name)s:%(lineno)d | %(message)s',
        datefmt='%Y-%m-%d %H:%M:%S'
    )
    file_handler.setFormatter(formatter)
    logger.addHandler(file_handler)

# Optional console logs
console_handler = logging.StreamHandler()
console_handler.setLevel(logging.INFO)
console_formatter = logging.Formatter('%(asctime)s | %(levelname)s | %(message)s')
console_handler.setFormatter(console_formatter)
logger.addHandler(console_handler)
logger.propagate = False
