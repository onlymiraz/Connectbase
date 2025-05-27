import os
import subprocess
from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler
import time

# Configuration
watch_directory = os.path.dirname(os.path.abspath(__file__))

class DirectoryChangeHandler(FileSystemEventHandler):
    def on_any_event(self, event):
        if not event.is_directory:
            self.run_script()

    def run_script(self):
        script_path = os.path.join(watch_directory, 'file_copy.py')
        try:
            subprocess.run(['python', script_path], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Error running script: {e}")

if __name__ == "__main__":
    event_handler = DirectoryChangeHandler()
    observer = Observer()
    observer.schedule(event_handler, path=watch_directory, recursive=False)
    observer.start()

    try:
        print(f"Monitoring {watch_directory} for changes...")
        while True:
            time.sleep(1)
    except KeyboardInterrupt:
        observer.stop()
    observer.join()
