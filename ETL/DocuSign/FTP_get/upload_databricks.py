# process fails. does not even get past "a" before timing out

import os
import subprocess

os.environ['DATABRICKS_HOST'] = 'https://dbc-4ee5e339-1e79.cloud.databricks.com'
os.environ['DATABRICKS_TOKEN'] = 'dapi290da5bf5e73c7c71d145a401898b83f'

# Set the local directory and Databricks catalog path
local_dir = "C:/Users/jss7571/Wholesale"
databricks_catalog_path = "/Volumes/wholesale/default/contracts"

# Construct the databricks fs command
command = f"databricks fs cp -r {local_dir} dbfs:{databricks_catalog_path}"

# Run the command in the Command Prompt
subprocess.run(command, shell=True)
