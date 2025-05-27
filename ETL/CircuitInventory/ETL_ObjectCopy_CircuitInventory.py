import os
import shutil
import logging

# Setup logging
logging.basicConfig(level=logging.DEBUG, format='%(asctime)s - %(levelname)s - %(message)s')

# List of specific files to copy
files_to_copy = [
    "ALL_ACTIVE_CZN.csv",
    "ALL_ACTIVE_RTC.csv",
    "ALL_ACTIVE_SOC.csv",
    "ALL_DISCO_CZN.csv",
    "ALL_DISCO_RTC.csv",
    "ALL_DISCO_SOC.csv"
]

def check_and_log_path_access(path):
    """Check if a path is accessible and log the result."""
    if os.path.exists(path):
        logging.debug(f"Path exists: {path}")
        print(f"Path exists: {path}")
    else:
        logging.error(f"Path does not exist: {path}")
        print(f"Path does not exist: {path}")

def main():
    source_directory = r'\\nspinfwcipp01\ftpstore\users\public'
    destination_directory = r'd:\lz\CircuitInventory'

    # Check access to source and destination directories
    check_and_log_path_access(source_directory)
    check_and_log_path_access(destination_directory)

    # Attempt to copy files
    for file_name in files_to_copy:
        src_file = os.path.join(source_directory, file_name)
        dest_file = os.path.join(destination_directory, file_name)

        logging.debug(f"Preparing to copy: {src_file} to {dest_file}")
        print(f"Preparing to copy: {src_file} to {dest_file}")

        if os.path.exists(src_file):
            try:
                shutil.copy2(src_file, dest_file)
                logging.info(f"Successfully copied {src_file} to {dest_file}")
                print(f"Successfully copied {src_file} to {dest_file}")
            except Exception as e:
                logging.error(f"Failed to copy {src_file} to {dest_file}: {e}")
                print(f"Failed to copy {src_file} to {dest_file}: {e}")
        else:
            logging.error(f"Source file does not exist: {src_file}")
            print(f"Source file does not exist: {src_file}")

        # Verify the file exists at the destination
        if os.path.exists(dest_file):
            logging.info(f"File confirmed at destination: {dest_file}")
            print(f"File confirmed at destination: {dest_file}")
        else:
            logging.error(f"File not found at destination: {dest_file}")
            print(f"File not found at destination: {dest_file}")

if __name__ == "__main__":
    main()
