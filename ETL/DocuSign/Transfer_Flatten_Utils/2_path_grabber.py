# Preserve original file path into CSV with ID, filename, fullpath

import os
import pandas as pd
import uuid


def traverse_directory(root_dir):
    """
    Recursively traverse a directory and its subdirectories, listing every file and its full path.
    Assigns a unique ID to each file. For duplicate filenames, adds _1, _2, etc.

    Args:
        root_dir (str): The root directory to start traversing from.

    Returns:
        pd.DataFrame: A DataFrame with three columns: 'filename', 'full_path', and 'unique_id'.
        Tricky example: Broadwing WA Amend _1.doc -> Broadwing WA Amend _1_1.doc (_1.doc because duplicate)
    """
    data = []
    filename_counts = {}

    for root, dirs, files in os.walk(root_dir):
        for file in files:
            file_path = os.path.join(root, file)
            base, ext = os.path.splitext(file)

            # Handle multiple extensions
            while '.' in base:
                base, extra_ext = os.path.splitext(base)
                ext = extra_ext + ext

            if file in filename_counts:
                filename_counts[file] += 1
                suffix = filename_counts[file] - 1
                filename = f"{base}_{suffix+1}{ext}"
            else:
                filename_counts[file] = 1
                filename = file

            unique_id = uuid.uuid4().int & (1<<32)-1  # Generate a random 32-bit integer
            unique_id_str = f"{unique_id:010d}"  # Convert to string and add leading zeros

            data.append({'unique_id': unique_id_str,
                         'filename': filename,
                         'full_path': str(file_path).split('\\', 1)[1]})

    df = pd.DataFrame(data)
    return df


root_dir = 'C:/Users/jss7571/2024-08-28-Wholesale'
df = traverse_directory(root_dir)

df.to_csv('files_and_paths.csv', index=False)
