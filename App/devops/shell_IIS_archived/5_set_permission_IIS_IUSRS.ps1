# Define the directory and user/group
$directory = 'D:\Scripts\WebApp'
$user = 'IIS_IUSRS'

# Get the current ACL
$acl = Get-Acl $directory

# Define the permission rule
$permission = "$user","ReadAndExecute","ContainerInherit,ObjectInherit","None","Allow"
$accessRule = New-Object System.Security.AccessControl.FileSystemAccessRule $permission

# Add the permission rule to the ACL
$acl.SetAccessRule($accessRule)

# Apply the updated ACL to the directory
Set-Acl -Path $directory -AclObject $acl
