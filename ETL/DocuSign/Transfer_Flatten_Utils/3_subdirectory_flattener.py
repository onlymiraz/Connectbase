# Flatten subdirectories into single folder

import os
import shutil
import hashlib


def copy_files_to_root(input_dir, output_dir):
    """
    Recursively traverse subdirectories in the input directory and copy files to the output directory.
    """
    log_file = 'log_flatener_error_skipped.txt'

    # Iterate through all files in the input directory
    for root, dirs, files in os.walk(input_dir):
        for file in files:
            file_path = os.path.join(root, file)

            # Determine the new filename
            if len(file) > 250:
                # Use a shorter hash function to generate a unique name for the file
                file_hash = hashlib.md5(file.encode()).hexdigest()[:8]
                new_filename = f"{file_hash}{os.path.splitext(file)[1]}"
            else:
                # Keep the original filename if it's not too long
                new_filename = file

            # Construct the destination path
            dest_path = os.path.join(output_dir, new_filename)

            # Check if the destination file already exists
            if os.path.exists(dest_path):
                # Append a suffix to the file name to avoid overwriting
                suffix = 1
                while os.path.exists(dest_path):
                    base, ext = os.path.splitext(new_filename)
                    dest_path = os.path.join(output_dir, f"{base}_{suffix}{ext}")
                    suffix += 1
                print(f"Renaming file to avoid overwrite: {file} -> {os.path.basename(dest_path)}")

            try:
                # Copy the file to the destination
                shutil.copy2(file_path, dest_path)
                print(f"Copied file: {file_path} -> {dest_path}")
            except FileNotFoundError as e:
                # Log any errors that occur during the copy process
                with open(log_file, 'a') as f:
                    f.write(f"Error copying file: {file_path} - {e}\n")
                print(f"Error copying file: {file_path} - {e}")


# Define the input and output directories
input_dir = 'C:/Users/jss7571/2024-08-28-Wholesale'
output_dir = 'C:/Users/jss7571/2024-08-28-Wholesale-FLAT'

# Create the output directory if it doesn't exist
if not os.path.exists(output_dir):
    os.makedirs(output_dir)
    print(f"Created output directory: {output_dir}")

# Call the function to copy files to the root directory
copy_files_to_root(input_dir, output_dir)
