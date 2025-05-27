import os
import shutil
import logging
import logging.handlers
import time

# Ensure logging directory exists
log_directory = r'D:\Logs\ETL\Python\PBI'
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


def copy_directory(src, dest, retries=5, wait_time=2):
    """
    Copy all the contents from the source directory to the destination directory.
    If an object already exists at the destination, it will be replaced.

    :param src: Source directory path (network drive path)
    :param dest: Destination directory path (network drive path)
    :param retries: Number of retry attempts if a file is in use
    :param wait_time: Wait time in seconds between retries
    """
    try:
        if not os.path.exists(dest):
            os.makedirs(dest)
            logger.info(f'Created directory: {dest}')
            print(f'Created directory: {dest}')

        for item in os.listdir(src):
            src_item = os.path.join(src, item)
            dest_item = os.path.join(dest, item)
            if os.path.isdir(src_item):
                if os.path.exists(dest_item):
                    shutil.rmtree(dest_item)
                    logger.info(f'Removed existing directory: {dest_item}')
                    print(f'Removed existing directory: {dest_item}')
                shutil.copytree(src_item, dest_item)
                logger.info(f'Copied directory: {src_item} to {dest_item}')
                print(f'Copied directory: {src_item} to {dest_item}')
            else:
                if os.path.exists(dest_item):
                    for attempt in range(retries):
                        try:
                            os.remove(dest_item)
                            logger.info(f'Removed existing file: {dest_item}')
                            print(f'Removed existing file: {dest_item}')
                            break
                        except PermissionError:
                            logger.warning(f'File in use: {dest_item}, attempt {attempt + 1} of {retries}')
                            print(f'File in use: {dest_item}, attempt {attempt + 1} of {retries}')
                            time.sleep(wait_time)
                    else:
                        logger.error(f'Failed to remove file: {dest_item} after {retries} attempts')
                        print(f'Failed to remove file: {dest_item} after {retries} attempts')
                        continue
                shutil.copy2(src_item, dest_item)
                logger.info(f'Copied file: {src_item} to {dest_item}')
                print(f'Copied file: {src_item} to {dest_item}')
    except Exception as e:
        logger.error(f'Error occurred: {e}')
        print(f'Error occurred: {e}')
        raise


def main():
    source_network_drive = r'\\MBIINFWWAPV01\Wholesale'
    destination_network_drive = r'\\Wadinfwwapv01\lz\PBI\Wholesale'

    copy_directory(source_network_drive, destination_network_drive)
    logger.info("All objects have been copied and replaced successfully.")
    print("All objects have been copied and replaced successfully.")


if __name__ == "__main__":
    main()
