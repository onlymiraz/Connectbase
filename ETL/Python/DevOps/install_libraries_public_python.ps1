# Function to get the script directory
function Get-ScriptDirectory {
    $Invocation = (Get-Variable MyInvocation -Scope 1).Value
    if ($Invocation.PSCommandPath) {
        return Split-Path -Parent $Invocation.PSCommandPath
    } else {
        return Get-Location
    }
}

# Get the directory of the current script
$scriptDir = Get-ScriptDirectory

# Define the path to the text file containing the pip install commands using the provided network share path
$textFilePath = "d:\Scripts\ETL\PRD02\Python\DevOps\libraries_public_python.txt"

# Check if the text file exists
if (-Not (Test-Path -Path $textFilePath -PathType Leaf)) {
    Write-Error "The path '$textFilePath' does not exist. Please specify a valid path."
    exit 1
}

# Read each line from the text file
$pipCommands = Get-Content -Path $textFilePath

# Loop through each install command and execute it only if the package isn't already installed
foreach ($command in $pipCommands) {
    # Extract the package name from the install command
    $packageName = $command -replace 'py -m pip install ', ''

    # Check if the package is already installed
    $packageInstalled = py -m pip show $packageName | Select-String "Name: "

    # Install the package if it is not installed
    if (-not $packageInstalled) {
        # Add '--system' to install for all users (requires administrative privileges)
        Invoke-Expression -Command "$command --system"
        Write-Output "$packageName installed for all users."
    } else {
        Write-Output "$packageName is already installed."
    }
}

Write-Output "System-wide installation process completed."
