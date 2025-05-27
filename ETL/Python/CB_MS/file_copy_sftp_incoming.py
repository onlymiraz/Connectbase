import os
import shutil
import logging

# Configuration
source_directory = r"\\WADINFWWAPV02\D$\LZ\IT_Data_Transmission"
destination_directories = [
    r"\\WADINFWWAPV01\D$\LZ\IT_Data_Transmission",
    r"\\WADINFWWDDV01\D$\LZ\IT_Data_Transmission"
]

# Set up logging
logging.basicConfig(filename='file_sync.log', level=logging.INFO,
                    format='%(asctime)s - %(levelname)s - %(message)s')


def copy_files(src_path):
    file_name = os.path.basename(src_path)
    for destination in destination_directories:
        dest_path = os.path.join(destination, file_name)
        try:
            if not os.path.exists(destination):
                os.makedirs(destination)
                print(f"Created directory: {destination}")

            if os.path.exists(dest_path):
                logging.info(f"Overwriting existing file: {dest_path}")
                print(f"Overwriting existing file: {dest_path}")

            shutil.copy2(src_path, dest_path)
            logging.info(f"Copied {src_path} to {dest_path}")
            print(f"Copied {src_path} to {dest_path}")
        except Exception as e:
            logging.error(f"Failed to copy {src_path} to {dest_path}. Error: {e}")
            print(f"Failed to copy {src_path} to {dest_path}. Error: {e}")


def delete_extra_files():
    source_files = set(os.listdir(source_directory))
    for destination in destination_directories:
        try:
            dest_files = set(os.listdir(destination))
            extra_files = dest_files - source_files
            for extra_file in extra_files:
                extra_file_path = os.path.join(destination, extra_file)
                if os.path.isfile(extra_file_path):
                    os.remove(extra_file_path)
                    logging.info(f"Deleted {extra_file_path} from {destination}")
                    print(f"Deleted {extra_file_path} from {destination}")
        except Exception as e:
            logging.error(f"Failed to delete files in {destination}. Error: {e}")
            print(f"Failed to delete files in {destination}. Error: {e}")


if __name__ == "__main__":
    print("Starting file copy process...")
    for file_path in os.listdir(source_directory):
        src_path = os.path.join(source_directory, file_path)
        if os.path.isfile(src_path):
            print(f"Processing file: {src_path}")
            copy_files(src_path)
    print("File copy process completed.")

    print("Starting cleanup process...")
    delete_extra_files()
    print("Cleanup process completed.")
