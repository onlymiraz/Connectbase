# Used to move files from laptop to server.

import os
import shutil
import logging
import time


# Set up logging
logging.basicConfig(filename='log_file_transfer.txt', level=logging.INFO)

# Set up constants
LOCAL_FOLDER = 'C:/Users/jss7571/2024-08-28-Wholesale'
NETWORK_PATH = '\\\\WADINFWWAPV02\\ContractIntelligence'
BATCH_SIZE = 1
STATUS_UPDATE_INTERVAL = 600  # Print status update every 10 minutes (600 seconds)

# Get the list of subfolders in the local folder
subfolders = [f for f in os.listdir(LOCAL_FOLDER) if os.path.isdir(os.path.join(LOCAL_FOLDER, f))]

# Get the latest completed batch number from the log file
try:
    with open('log_file_transfer.txt', 'r') as f:
        lines = f.readlines()
        latest_batch = 0
        for line in reversed(lines):
            if 'Batch' in line:
                parts = line.split(' ')
                for part in reversed(parts):
                    if part.isdigit():
                        latest_batch = int(part)
                        break
                break
except FileNotFoundError:
    latest_batch = 0

# Start from the latest completed batch
start_batch = latest_batch + 1

# Initialize start time
start_time = time.time()
last_status_update = start_time

# Loop through the subfolders in batches
for batch in range(start_batch, len(subfolders) // BATCH_SIZE + 1):
    print(f"Copying batch {batch}...")
    batch_subfolders = subfolders[(batch - 1) * BATCH_SIZE:batch * BATCH_SIZE]
    logging.info(f'Batch {batch}: {len(batch_subfolders)} subfolders')

    # Copy the subfolders recursively
    for subfolder in batch_subfolders:
        src = os.path.join(LOCAL_FOLDER, subfolder)
        dst = os.path.join(NETWORK_PATH, subfolder)
        if os.path.exists(dst):
            logging.warning(f"Destination folder '{dst}' already exists. Skipping...")
        else:
            try:
                shutil.copytree(src, dst)
            except Exception as e:
                logging.error(f"Error copying folder '{src}' to '{dst}': {e}")

    # Write to the log file
    logging.info(f'Batch {batch} complete')

    # Save the latest batch number to the log file
    with open('log_file_transfer.txt', 'a') as f:
        f.write(f'Batch {batch} complete\n')

    # Print status update every 10 minutes
    current_time = time.time()
    if current_time - last_status_update >= STATUS_UPDATE_INTERVAL:
        print(f"Batch {batch} complete. Elapsed time: {current_time - start_time:.2f} seconds")
        last_status_update = current_time
