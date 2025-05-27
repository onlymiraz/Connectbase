param(
    [string]$PythonExe = "D:\Scripts\WebApp\env\Scripts\python.exe",
    [string]$ScriptPath = "D:\Scripts\WebApp\app_AddressBilling\db\create_sql_objects.py"
)

Write-Host "Using Python: $PythonExe"
Write-Host "Running script: $ScriptPath"

# *** 1) Important: change directory to D:\Scripts\WebApp ***
Set-Location "D:\Scripts\WebApp"

try {
    & $PythonExe $ScriptPath
    if ($LASTEXITCODE -eq 0) {
        Write-Host "SQL object creation completed successfully."
    }
    else {
        Write-Host "SQL object creation script returned error code $LASTEXITCODE."
        exit $LASTEXITCODE
    }
}
catch {
    Write-Host "Failed to run the SQL object creation script. $_"
    exit 1
}
