import subprocess
import sys
import argparse
import os
import logging
import time

# Configure basic logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s [%(levelname)s] %(message)s'
)

def create_or_update_task(
    task_name: str,
    python_exe: str,
    nightly_script: str,
    schedule: str = "DAILY",
    start_time: str = "02:00",
    run_as_user: str = r"NT AUTHORITY\NETWORK SERVICE"
):
    """
    Creates or updates a Windows Scheduled Task using schtasks.exe.
    By default, it runs daily at 2 AM, but you can pass different schedule and time.
    """
    # We must quote the command paths in case they have spaces
    command_line = f'"{python_exe}" "{nightly_script}"'

    # schtasks command line
    sch_cmd = [
        "SCHTASKS",
        "/Create",
        "/TN", task_name,
        "/SC", schedule,
        "/ST", start_time,
        "/TR", command_line,
        "/F",                  # force update if it exists
        "/RU", run_as_user     # run user
    ]

    logging.info("Creating/Updating task with command: %s", " ".join(sch_cmd))
    result = subprocess.run(sch_cmd, capture_output=True, text=True)

    if result.returncode == 0:
        logging.info("Task '%s' created/updated successfully.", task_name)
    else:
        logging.error("Failed to create/update task. Return code=%d", result.returncode)
        logging.error("stderr: %s", result.stderr)
        sys.exit(result.returncode)

def run_task_now(task_name: str):
    """
    Manually triggers the scheduled task once using 'SCHTASKS /Run /TN'
    This is optional for immediate testing.
    """
    cmd = ["SCHTASKS", "/Run", "/TN", task_name]
    logging.info("Running task now: %s", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode == 0:
        logging.info("Task '%s' started successfully.", task_name)
    else:
        logging.error("Failed to run task '%s'. Return code=%d", task_name, result.returncode)
        logging.error("stderr: %s", result.stderr)
        sys.exit(result.returncode)

def main():
    parser = argparse.ArgumentParser(
        description="Orchestrate Windows Scheduled Task for nightly_fuzzymatch"
    )
    parser.add_argument("--task-name", default="NightlyFuzzymatch",
                        help="Name of the scheduled task")
    parser.add_argument("--schedule", default="DAILY",
                        choices=["DAILY", "HOURLY", "WEEKLY", "MINUTE"],
                        help="Schedule type, default=DAILY")
    parser.add_argument("--start-time", default="02:00",
                        help="Start time in HH:MM (24-hour) format")
    parser.add_argument("--run-now", action="store_true",
                        help="Optionally trigger the task right after creating it.")
    parser.add_argument("--python-exe", default=r"D:\Scripts\WebApp\env\Scripts\python.exe",
                        help="Path to your python.exe in the venv")
    parser.add_argument("--nightly-script", default=r"D:\Scripts\WebApp\App\app_AddressBilling\nightly_fuzzymatch.py",
                        help="Path to nightly_fuzzymatch.py")
    parser.add_argument("--run-as-user", default=r"NT AUTHORITY\NETWORK SERVICE",
                        help="Which user to run as")

    args = parser.parse_args()

    # 1) Create or update the scheduled task
    create_or_update_task(
        task_name=args.task_name,
        python_exe=args.python_exe,
        nightly_script=args.nightly_script,
        schedule=args.schedule,
        start_time=args.start_time,
        run_as_user=args.run_as_user
    )

    # 2) If requested, run the task immediately for testing
    if args.run_now:
        run_task_now(args.task_name)

    logging.info("Orchestration complete.")

if __name__ == "__main__":
    main()
