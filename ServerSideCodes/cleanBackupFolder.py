import os
import datetime

def delete_old_files_recursive(folder_path, threshold_date):
    try:
        for root, dirs, files in os.walk(folder_path):
            for file_name in files:
                file_path = os.path.join(root, file_name)

                last_modification_time = datetime.datetime.fromtimestamp(os.path.getmtime(file_path))

                if last_modification_time < threshold_date:
                    try:
                        os.remove(file_path)
                        print(f"Deleted: {file_path}")
                    except Exception as e:
                        pass
                        # SQL Agent will properly display errors if any come up.
    except Exception as e:
        pass
        # Handle any other exceptions if necessary

def delete_old_files(folder_path):
    threshold_date = datetime.datetime.now() - datetime.timedelta(days=14)
    delete_old_files_recursive(folder_path, threshold_date)

folder_path_prod = "\\\\NSPINFWCIPP01.corp.pvt\\WAD\\Backup\\DB\\STG"
folder_path_staging = "\\\\NSPINFWCIPP01.corp.pvt\\WAD\\Backup\\DB\\PRD"

delete_old_files(folder_path_prod)
delete_old_files(folder_path_staging)
