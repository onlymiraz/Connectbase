# Define list of usernames and passwords for service accounts and SQL Server credentials
$credentials = @{
    "s_WAD3" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "c2cuser" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "S_BIWMRPTR" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CarrierMetrics" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "asap" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD0" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD1" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD2" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD3" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "CORP\s_WAD4" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "tsql_wad_pbi" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force
    "postgres" = ConvertTo-SecureString -String "PUT YOUR PASSWORD HERE" -AsPlainText -Force

    # Add more users and passwords as needed
}

# Iterate over each credential and set environment variables for all users (Machine scope)
foreach ($user in $credentials.GetEnumerator()) {
    $username = $user.Key
    $securePassword = $user.Value
    
    # Set the environment variables for the current user
    [Environment]::SetEnvironmentVariable("SERVICE_USERNAME_$username", $username, "Machine")
    [Environment]::SetEnvironmentVariable("SERVICE_PASSWORD_$username", $securePassword, "Machine")
}