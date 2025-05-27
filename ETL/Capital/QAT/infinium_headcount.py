import pandas as pd
import os
import shutil
import gc
import sys
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from varasset_headcount import send_email, log_error

def copy_files_to_qat(source_path, qat_path):
    if not os.path.exists(qat_path):
        os.makedirs(qat_path)
    
    for file in os.listdir(source_path):
        if file.endswith('.csv'):
            source_file = os.path.join(source_path, file)
            qat_file = os.path.join(qat_path, file)
            shutil.copy2(source_file, qat_file)
            #print(f"Copied {file} to QAT folder.")

    print("Source files copied to QAT folder. Checking for differences...")

def read_csv_in_chunks(filepath, chunk_size=50000, encodings=['ISO-8859-1', 'utf-8', 'latin1']):
    for encoding in encodings:
        try:
            chunks = pd.read_csv(filepath, encoding=encoding, on_bad_lines='skip', chunksize=chunk_size, low_memory=False)
            df = pd.concat(chunks)
            # print(f"Successfully read {filepath} with encoding {encoding}")
            return df
        except (pd.errors.ParserError, ValueError, UnicodeDecodeError) as e:
            print(f"Error reading file {filepath} with encoding {encoding}: {e}")
    return None

def compare_files(qat_path, landing_zone_path):
    failure_detected = False
    
    for file in os.listdir(qat_path):
        if file.endswith('.csv'):
            qat_file = os.path.join(qat_path, file)
            landing_zone_file = os.path.join(landing_zone_path, file)

            try:
                qat_df = read_csv_in_chunks(qat_file)
                landing_zone_df = read_csv_in_chunks(landing_zone_file)

                if qat_df is None or landing_zone_df is None:
                    print(f"Failed to read file {file}. Skipping.")
                    continue

                if qat_df.empty:
                    print(f"QAT DataFrame for file {file} is empty. Skipping.")
                    continue
                if landing_zone_df.empty:
                    print(f"Landing Zone DataFrame for file {file} is empty. Skipping.")
                    continue

                qat_rows, qat_cols = qat_df.shape
                landing_zone_rows, landing_zone_cols = landing_zone_df.shape
                if qat_rows != landing_zone_rows or qat_cols != landing_zone_cols:
                    print(f"Comparing {file}...")
                    print(f"QAT Rows: {qat_rows}, Columns: {qat_cols}")
                    print(f"Landing Zone Rows: {landing_zone_rows}, Columns: {landing_zone_cols}")
                    print("Row and column counts do not match.")
                    failure_detected = True

                qat_numerical_cols = qat_df.select_dtypes(include=['number']).columns.tolist()
                landing_zone_numerical_cols = landing_zone_df.select_dtypes(include=['number']).columns.tolist()

                if qat_numerical_cols != landing_zone_numerical_cols:
                    print(f"QAT Numerical Columns: {qat_numerical_cols}")
                    print(f"Landing Zone Numerical Columns: {landing_zone_numerical_cols}")
                    print("Numerical columns do not match.")
                    failure_detected = True

                for column in qat_numerical_cols:
                    if column in landing_zone_numerical_cols:
                        qat_sum = qat_df[column].sum()
                        landing_zone_sum = landing_zone_df[column].sum()
                        if qat_sum != landing_zone_sum:
                            print(f"Column: {column}")
                            print(f"QAT Sum: {qat_sum}")
                            print(f"Landing Zone Sum: {landing_zone_sum}")
                            print("Sums do not match.")
                            failure_detected = True

                if not failure_detected:
                    print(f"File {file} check passed successfully.")
                
                del qat_df
                del landing_zone_df
                gc.collect()

            except ValueError as e:
                print(f"ValueError for file {file}: {e}")
                failure_detected = True
            except Exception as e:
                print(f"Unexpected error for file {file}: {e}")
                failure_detected = True

    if failure_detected:
        print("One or more errors detected during file comparisons.")
    else:
        print("All files processed successfully. Exiting with success status.")

def delete_qat_files(qat_path):
    for file in os.listdir(qat_path):
        if file.endswith('.csv'):
            qat_file = os.path.join(qat_path, file)
            os.remove(qat_file)
    print("QAT folder cleaned up successfully.")

def main():
    source_csv_path = r'\\CAPINFWWAPV01\DataDump'
    landing_zone_path = r'D:\LZ\Capital'
    qat_folder_path = r'D:\LZ\Capital\QAT'

    copy_files_to_qat(source_csv_path, qat_folder_path)
    compare_files(qat_folder_path, landing_zone_path)
    delete_qat_files(qat_folder_path)

if __name__ == "__main__":
    main()
