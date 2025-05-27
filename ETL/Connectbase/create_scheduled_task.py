import os
import sys
import win32com.client

# Get the directory where the script is located
script_directory = os.path.dirname(os.path.abspath(__file__))

# Configuration
script_path = os.path.join(script_directory, "monitor_directory.py")
task_name = "DirectoryMonitorTask"
bat_file_path = os.path.join(script_directory, "run_monitor.bat")

# Create a batch file to run the Python script
with open(bat_file_path, 'w') as bat_file:
    bat_file.write(f'@echo off\npython "{script_path}"\n')

# Create the scheduled task
scheduler = win32com.client.Dispatch('Schedule.Service')
scheduler.Connect()

root_folder = scheduler.GetFolder('\\')

# Delete the task if it already exists
try:
    root_folder.DeleteTask(task_name, 0)
except Exception as e:
    pass

task_def = scheduler.NewTask(0)

# Create the trigger
trigger = task_def.Triggers.Create(2)  # 2 = TASK_TRIGGER_LOGON
trigger.StartBoundary = '2023-05-01T08:00:00'

# Create the action
action = task_def.Actions.Create(0)  # 0 = TASK_ACTION_EXEC
action.Path = bat_file_path

# Set parameters
task_def.RegistrationInfo.Description = 'Monitor directory and run script on changes'
task_def.Principal.UserId = 'SYSTEM'
task_def.Principal.LogonType = 3  # 3 = TASK_LOGON_SERVICE_ACCOUNT
task_def.Settings.Enabled = True
task_def.Settings.StartWhenAvailable = True
task_def.Settings.Hidden = False

# Register the task
root_folder.RegisterTaskDefinition(
    task_name,
    task_def,
    6,  # 6 = TASK_CREATE_OR_UPDATE
    None,  # No user
    None,  # No password
    3,  # TASK_LOGON_SERVICE_ACCOUNT
    ''
)

print(f'Task "{task_name}" created successfully.')
