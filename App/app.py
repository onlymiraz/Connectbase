# /App/app.py
import os
import logging
import psutil
from flask import Flask, render_template
from app_AddressBilling.logging_config import logger

# Import your route functions from app_AddressBilling
from app_AddressBilling.routes import (
    upload,
    select_sheet,
    mapping,
    process_mapping,
    get_batch_data,
    show_fuzzymatch_results,
    show_fuzzymatch_summary,
    download_fuzzymatch_excel,
    download_fuzzymatch_csv,
    fuzzymatch_powerbi_view,
    batch_history,
    generate_documentation  # <-- Using the function directly
)
# Import location routes
from app_Locations.routes import all_locations_map, all_locations_map_v2
# Circuit inventory blueprint
from app_CircuitInventory import circuit_inventory_bp

app = Flask(
    __name__,
    template_folder=os.path.dirname(os.path.abspath(__file__)),
    static_url_path='',
    static_folder=os.path.dirname(os.path.abspath(__file__))
)

app.config['UPLOAD_FOLDER'] = os.path.join(
    os.path.dirname(os.path.abspath(__file__)),
    'app_AddressBilling',
    'uploads'
)
app.config['ALLOWED_EXTENSIONS'] = {'xls', 'xlsx', 'csv', 'txt'}
app.config['SECRET_KEY'] = 'your_secret_key_here'

@app.route('/')
def index():
    logger.info("User accessed home page")
    return render_template('index.html')

# ~~~ AddressBilling Routes ~~~
app.add_url_rule('/upload', 'upload', upload, methods=['GET','POST'])
app.add_url_rule('/select_sheet', 'select_sheet', select_sheet, methods=['GET','POST'])
# ↓↓↓ CHANGE HERE: MAPPING NOW ALLOWS GET + POST ↓↓↓
app.add_url_rule('/mapping', 'mapping', mapping, methods=['GET','POST'])
app.add_url_rule('/process_mapping', 'process_mapping', process_mapping, methods=['POST'])
app.add_url_rule('/get_batch_data', 'get_batch_data', get_batch_data, methods=['GET','POST'])
app.add_url_rule('/show_fuzzymatch_results/<batch_id>', 'show_fuzzymatch_results', show_fuzzymatch_results)
app.add_url_rule('/show_fuzzymatch_summary/<batch_id>', 'show_fuzzymatch_summary', show_fuzzymatch_summary)
app.add_url_rule('/download_fuzzymatch_excel/<batch_id>', 'download_fuzzymatch_excel', download_fuzzymatch_excel)
app.add_url_rule('/download_fuzzymatch_csv/<batch_id>', 'download_fuzzymatch_csv', download_fuzzymatch_csv)
app.add_url_rule('/fuzzymatch_powerbi_view/<batch_id>', 'fuzzymatch_powerbi_view', fuzzymatch_powerbi_view)
app.add_url_rule('/batch_history', 'batch_history', batch_history, methods=['GET'])

# ~~~ Doc-generation route ~~~
app.add_url_rule('/generate_doc/<doc_type>', 'generate_documentation', generate_documentation, methods=['GET'])

# ~~~ Location Routes ~~~
app.add_url_rule('/all_locations_map', 'all_locations_map', all_locations_map)
app.add_url_rule('/all_locations_map_v2', 'all_locations_map_v2', all_locations_map_v2)

# ~~~ Circuit Inventory Blueprint ~~~
app.register_blueprint(circuit_inventory_bp, url_prefix='/circuit_inventory')

if __name__ == '__main__':
    logger.info("Starting Flask App...")
    app.run(debug=True)
