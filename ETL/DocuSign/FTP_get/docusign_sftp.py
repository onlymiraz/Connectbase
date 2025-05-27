import os
import paramiko  # 2.8.1 works, latest version does not
import time
import pickle

# SFTP connection details
hostname = 'sftpna11.springcm.com'
username = 'jack.sawilowsky@ftr.com'
password = 'REDACTED'
port = 22
key_path = 'C:/Users/jss7571/OneDrive - Frontier Communications/Documents/new_docusign_private_key'

# Create an SSH client
ssh = paramiko.SSHClient()
ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())

private_key = paramiko.RSAKey.from_private_key_file(key_path)

# Set timeout to 30 hours
ssh.connect(hostname, port=port, username=username, password=password, key_filename=key_path, timeout=108000)

sftp = ssh.open_sftp()

# sftp.chdir('Frontier/Wholesale')

remote_dir = 'Frontier/Wholesale'
local_dir = "C:/Docusign_Contracts"


def download_files(sftp, remote_dir, local_dir, max_retries=3):
    # Load the last downloaded file/dir from a pickle file
    try:
        with open('last_downloaded.pkl', 'rb') as f:
            last_downloaded = pickle.load(f)
    except FileNotFoundError:
        last_downloaded = None

    files_and_dirs = sftp.listdir(remote_dir)
    for file_or_dir in files_and_dirs:
        remote_path = os.path.join(remote_dir, file_or_dir)
        try:
            stat = sftp.stat(remote_path)
            if stat.st_mode & 0o100000 == 0o100000:
                local_path = os.path.join(local_dir, file_or_dir)
                if last_downloaded and last_downloaded == local_path:
                    print(f"Resuming from {local_path}")
                retries = 0
                while retries < max_retries:
                    try:
                        sftp.get(remote_path, local_path)
                        print(f"Downloaded file: {local_path}")
                        # Save the last downloaded file/dir to a pickle file
                        with open('last_downloaded.pkl', 'wb') as f:
                            pickle.dump(local_path, f)
                        break
                    except OSError as e:
                        print(f"Error downloading file: {local_path} (retry {retries+1}/{max_retries})")
                        retries += 1
                        time.sleep(1)
                if retries == max_retries:
                    print(f"Failed to download file: {local_path}")
            elif stat.st_mode & 0o40000 == 0o40000:
                local_path = os.path.join(local_dir, file_or_dir)
                if not os.path.exists(local_path):
                    os.makedirs(local_path)
                download_files(sftp, remote_path, local_path, max_retries)
        except FileNotFoundError:
            print(f"File or directory not found: {remote_path}")
            continue
        except paramiko.SSHException as e:
            # Reconnect and resume
            print(f"Connection dropped: {e}")
            ssh.connect(hostname, port=port, username=username, password=password,
                        key_filename=key_path, timeout=108000)
            sftp = ssh.open_sftp()
            download_files(sftp, remote_dir, local_dir, max_retries)


# Start the recursive download
download_files(sftp, remote_dir, local_dir)

sftp.close()
ssh.close()
