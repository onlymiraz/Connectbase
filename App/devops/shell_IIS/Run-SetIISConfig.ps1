<#
    Run-SetIISConfig.ps1
    A convenience wrapper to call Set-IISFastCgiConfig.ps1 with desired parameters
#>

Write-Host "Running Set-IISFastCgiConfig with 1hr timeouts, 2GB upload, etc..."

.\Set-IISFastCgiConfig.ps1 `
    -AppPoolName "stg-wad.ftr.com" `
    -PythonExePath "D:\Scripts\WebApp\env\Scripts\python.exe" `
    -MaxFileUploadMB 2048 `
    -ActivityTimeout "01:00:00" `
    -RequestTimeout "01:00:00" `
    -IdleTimeout "00:30:00" `
    -PingResponseTime "00:30:00"
