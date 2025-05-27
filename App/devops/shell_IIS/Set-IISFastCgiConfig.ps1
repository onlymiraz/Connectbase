param(
    [string]$AppPoolName = "stg-wad.ftr.com",
    [string]$PythonExePath = "D:\Scripts\WebApp\env\Scripts\python.exe",
    [string]$MaxFileUploadMB = "1024",  # 1GB default
    [string]$ActivityTimeout = "00:30:00",
    [string]$RequestTimeout = "00:30:00",
    [string]$IdleTimeout = "00:20:00",
    [string]$PingResponseTime = "00:30:00"
)

################################################################################
# 1) Function to convert HH:MM:SS -> integer seconds for global FastCGI
################################################################################
function ConvertTo-TotalSeconds([string]$timeStr) {
    [TimeSpan]$ts = [TimeSpan]::Parse($timeStr)
    return [int][Math]::Round($ts.TotalSeconds)
}

################################################################################
# 2) Convert times to integer seconds for FastCGI
################################################################################
$fastCgiIdleSecs    = ConvertTo-TotalSeconds $IdleTimeout
$fastCgiActivitySecs= ConvertTo-TotalSeconds $ActivityTimeout
$fastCgiRequestSecs = ConvertTo-TotalSeconds $RequestTimeout

Write-Host "Configuring FastCGI timeouts for $PythonExePath..."
Write-Host " idleTimeout=$fastCgiIdleSecs activityTimeout=$fastCgiActivitySecs requestTimeout=$fastCgiRequestSecs (in seconds)"

& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set config /section:system.webServer/fastCgi `
    "/[fullPath='$PythonExePath'].idleTimeout:$fastCgiIdleSecs" `
    /commit:apphost

& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set config /section:system.webServer/fastCgi `
    "/[fullPath='$PythonExePath'].activityTimeout:$fastCgiActivitySecs" `
    /commit:apphost

& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set config /section:system.webServer/fastCgi `
    "/[fullPath='$PythonExePath'].requestTimeout:$fastCgiRequestSecs" `
    /commit:apphost

& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set config /section:system.webServer/fastCgi `
    "/[fullPath='$PythonExePath'].instanceMaxRequests:10000" `
    /commit:apphost

################################################################################
# 3) Increase maxAllowedContentLength to avoid 413 errors (in bytes)
################################################################################
$maxAllowedBytes = [int]$MaxFileUploadMB * 1MB
Write-Host "Increasing maxAllowedContentLength to $MaxFileUploadMB MB = $maxAllowedBytes bytes..."
& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set config /section:requestFiltering `
    /requestLimits.maxAllowedContentLength:$maxAllowedBytes `
    /commit:apphost

################################################################################
# 4) Update Application Pool: idleTimeout & pingResponseTime accept HH:MM:SS
################################################################################
Write-Host "Updating Application Pool '$AppPoolName' ..."
& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set apppool "$AppPoolName" `
    /processModel.idleTimeout:"$IdleTimeout"

& "$Env:SystemRoot\System32\inetsrv\appcmd.exe" set apppool "$AppPoolName" `
    /processModel.pingResponseTime:"$PingResponseTime"

################################################################################
# 5) Restart IIS
################################################################################
Write-Host "Done! Restarting IIS ..."
iisreset /restart
