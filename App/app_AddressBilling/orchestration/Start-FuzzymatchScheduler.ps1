# D:\Scripts\WebApp\app_AddressBilling\orchestration\Start-FuzzymatchScheduler.ps1
# -----------------------------------------------------------------------------
# This PowerShell script creates/updates the Windows Scheduled Task that runs
# the fuzzymatch_script.py on a defined interval (e.g. every 5 minutes).
#
# Usage:
#   .\Start-FuzzymatchScheduler.ps1
#   (or from your Azure DevOps pipeline using this path)
#
# Key Changes:
#   - Set PollScript to the correct path: D:\Scripts\WebApp\app_AddressBilling\orchestration\ETL\fuzzymatch_script.py
# -----------------------------------------------------------------------------

param(
    [string]$TaskName = "AddressBilling_FuzzymatchPoll",
    [string]$VenvPython = "D:\Scripts\WebApp\env\Scripts\python.exe",
    [string]$PollScript = "D:\Scripts\WebApp\app_AddressBilling\orchestration\ETL\fuzzymatch_script.py",
    [int]$IntervalMinutes = 5
)

Write-Host "STEP 1: Creating or updating the scheduled task '$TaskName' with STARTUP trigger only..."

# ACTION: the python command to run
$action = New-ScheduledTaskAction `
    -Execute $VenvPython `
    -Argument "`"$PollScript`""

# TRIGGER #1: At system startup
$triggerStartup = New-ScheduledTaskTrigger -AtStartup

# FIRST: create/update the task with the startup trigger only
Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger $triggerStartup `
    -Description "Run fuzzymatch poll script at system startup" `
    -User "NT AUTHORITY\SYSTEM" `
    -RunLevel Highest `
    -Force

Write-Host "STARTUP trigger registered. Now let's add the daily repeating trigger..."
Write-Host "STEP 2: Register daily (midnight) repeating trigger, $IntervalMinutes min interval for 24h."

# TRIGGER #2: once at midnight, repeat every IntervalMinutes, for 1 day
$triggerMidnight = New-ScheduledTaskTrigger `
    -Once `
    -At "00:00" `
    -RepetitionInterval (New-TimeSpan -Minutes $IntervalMinutes) `
    -RepetitionDuration (New-TimeSpan -Days 1)

# We re-register the same task name, now specifying the daily trigger
Register-ScheduledTask -TaskName $TaskName `
    -Action $action `
    -Trigger $triggerMidnight `
    -Description "Run fuzzymatch poll script daily at midnight, repeating every $IntervalMinutes mins for 24h" `
    -User "NT AUTHORITY\SYSTEM" `
    -RunLevel Highest `
    -Force

Write-Host "Scheduled Task '$TaskName' now has TWO triggers:"
Write-Host "  1) System startup"
Write-Host "  2) Daily at midnight repeating every $IntervalMinutes minutes for 24h"
Write-Host "Done. Check Task Scheduler -> 'Task Scheduler Library' to confirm."
