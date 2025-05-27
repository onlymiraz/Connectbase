# Get the directory where the PowerShell script is located
$scriptDirectory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent

# Define the path to the text file containing the pip install commands
$textFilePath = Join-Path -Path $scriptDirectory -ChildPath "libraries_public_python.txt"

# Read each line from the text file
$pipCommands = Get-Content -Path $textFilePath

# Loop through each install command and execute it only if the package isn't already installed
foreach ($command in $pipCommands) {
    # Extract the package name from the install command
    $packageName = $command -replace 'py -m pip install ', ''

    # Check if the package is already installed
    $packageInstalled = py -m pip show $packageName 2>&1 | Select-String "Name: "

    # Install the package if it is not installed
    if (-not $packageInstalled) {
        # Add '--system' to install for all users (requires administrative privileges)
        $fullCommand = "$command --system"
        Write-Output "Installing $packageName..."
        Invoke-Expression -Command $fullCommand
        Write-Output "$packageName installed for all users."
    } else {
        Write-Output "$packageName is already installed."
    }
}

Write-Output "System-wide installation process completed."
