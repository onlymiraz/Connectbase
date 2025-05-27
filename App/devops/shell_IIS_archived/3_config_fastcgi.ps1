# Define paths
$pythonExe = 'D:\Program Files\Python\python.exe'
$wfastcgiPy = 'D:\Program Files\Python\Lib\site-packages\wfastcgi.py'

# Add FastCGI application mapping
Import-Module WebAdministration
$fastCgiSection = Get-WebConfigurationSection -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/fastCgi'
$fastCgiCollection = $fastCgiSection.Collection

# Check if the FastCGI application mapping already exists
$existingMapping = $fastCgiCollection | Where-Object { $_.fullPath -eq $pythonExe -and $_.arguments -eq $wfastcgiPy }

if (-not $existingMapping) {
    # Create new FastCGI application mapping
    $newFastCgi = $fastCgiCollection.CreateNewElement('application')
    $newFastCgi.Properties['fullPath'].Value = $pythonExe
    $newFastCgi.Properties['arguments'].Value = $wfastcgiPy
    $fastCgiCollection.AddElement($newFastCgi)
    Set-WebConfiguration -filter 'system.webServer/fastCgi' -value $fastCgiSection
}
