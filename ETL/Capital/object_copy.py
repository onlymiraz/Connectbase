import os
import shutil
import logging
import logging.handlers
import time
import sys

# Ensure logging directory exists
log_directory = r'D:\Logs\ETL\Python\Capital'
if not os.path.exists(log_directory):
    os.makedirs(log_directory)

# Setup rotating file handler for logging
log_file = os.path.join(log_directory, 'copy_log.log')
handler = logging.handlers.RotatingFileHandler(log_file, maxBytes=5 * 1024 * 1024, backupCount=5)
formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
handler.setFormatter(formatter)

logger = logging.getLogger()
logger.setLevel(logging.DEBUG)
logger.addHandler(handler)

# Variable to determine whether to copy files recursively
recursive = False

def copy_directory(src, dest, recursive, retries=5, wait_time=2):
    """
    Copy all .csv files from the source directory to the destination directory.
    If an object already exists at the destination, it will be replaced.

    :param src: Source directory path (network drive path)
    :param dest: Destination directory path (network drive path)
    :param recursive: Boolean to determine whether to copy recursively
    :param retries: Number of retry attempts if a file is in use
    :param wait_time: Wait time in seconds between retries
    """
    try:
        if not os.path.exists(dest):
            os.makedirs(dest)
            logger.info(f'Created directory: {dest}')
            print(f'Created directory: {dest}')

        for root, dirs, files in os.walk(src):
            if not recursive and root != src:
                continue

            for file in files:
                if file.endswith('.csv'):
                    src_file = os.path.join(root, file)
                    relative_path = os.path.relpath(root, src)
                    dest_file_dir = os.path.join(dest, relative_path)
                    dest_file = os.path.join(dest_file_dir, file)

                    if not os.path.exists(dest_file_dir):
                        os.makedirs(dest_file_dir)

                    if os.path.exists(dest_file):
                        for attempt in range(retries):
                            try:
                                os.remove(dest_file)
                                logger.info(f'Removed existing file: {dest_file}')
                                print(f'Removed existing file: {dest_file}')
                                break
                            except PermissionError:
                                logger.warning(f'File in use: {dest_file}, attempt {attempt + 1} of {retries}')
                                print(f'File in use: {dest_file}, attempt {attempt + 1} of {retries}')
                                time.sleep(wait_time)
                        else:
                            logger.error(f'Failed to remove file: {dest_file} after {retries} attempts')
                            print(f'Failed to remove file: {dest_file} after {retries} attempts')
                            continue

                    shutil.copy2(src_file, dest_file)
                    logger.info(f'Copied file: {src_file} to {dest_file}')
                    print(f'Copied file: {src_file} to {dest_file}')

            if not recursive:
                break

    except Exception as e:
        logger.error(f'Error occurred: {e}')
        print(f'Error occurred: {e}')
        raise

def main():
    source_network_drive = r'\\CAPINFWWAPV01\DataDump'
    destination_network_drive = r'D:\LZ\Capital'
    
    copy_directory(source_network_drive, destination_network_drive, recursive)
    logger.info("Specified .csv files have been copied and replaced successfully.")
    print("Specified .csv files have been copied and replaced successfully.")

if __name__ == "__main__":
    main()
