$Name = "B"
$Path = "\\nspinfwcipp01.corp.pvt\WAD"

write-host ('Mapping Drive ' + ($Name) + ' ' + ($Path))
$MappedDrive = (Get-PSDrive -Name $Name -ErrorAction SilentlyContinue)

#Check if drive is already mapped
if($MappedDrive)
{
  #Drive is mapped. Check to see if it mapped to the correct path
  if($MappedDrive.DisplayRoot -ne $Path)
  {
    # Drive Mapped to the incorrect path. Remove and readd:
    Remove-PSDrive -Name $Name
    New-PSDrive -Name $Name -Root $Path -PSProvider "FileSystem" -Scope Global -Persist
  }
}
else
{
  #Drive is not mapped
  New-PSDrive -Name $Name -Root $Path -PSProvider "FileSystem" -Scope Global -Persist
}
