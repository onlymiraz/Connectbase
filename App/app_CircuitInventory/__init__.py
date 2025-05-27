# app_CircuitInventory/__init__.py
from flask import Blueprint

circuit_inventory_bp = Blueprint('circuit_inventory', __name__)

from . import routes
