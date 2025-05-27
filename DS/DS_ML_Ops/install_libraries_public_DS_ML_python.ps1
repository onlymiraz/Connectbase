# Get the directory of the current script
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# Define the path to the text file containing the pip install commands
$textFilePath = Join-Path -Path $scriptDir -ChildPath "libraries_public_DS_ML_python.txt"

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
