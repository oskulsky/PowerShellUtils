Import-LocalizedData -bindingVariable fileMsgTable -BaseDirectory $PSScriptRoot/../i18n -FileName filesUtil.psd1

function Test-File {
  <#
  .SYNOPSIS
  Test that the file exists

  .DESCRIPTION
  This is a rapper for Test-Path, that adds validations and logging 

  .EXAMPLE
  Test-File testing123
  verifies that there is a file called testing123 in the current directory.
  #>
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the file")]
      [ValidateScript({Test-Path $_ -IsValid -PathType Leaf})]
      [String]$file
  )
  if ($pscmdlet.ShouldProcess($file , "Test-Path -PathType Leaf")) {
    $exists = Test-Path $file -PathType Leaf
    if($exists) {
      $logger.LogVerbose($($fileMsgTable.test_message_exists -replace '<entityType>', "file" -replace "<entityName>", $file))
    } else {
      $logger.LogVerbose($($fileMsgTable.test_message_not_exists -replace '<entityType>', "file" -replace "<entityName>", $file))
    }
    return $exists
  }
}
function New-File {
  <#
  .SYNOPSIS
  Creates a new file

  .DESCRIPTION
  This is a rapper for New-Item, that adds validations and logging 

  .EXAMPLE
  New-File testing123
  This will create a file called testing123 in the current directory

  .NOTES
  If the file already exists it will throw an exception
  #>
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the file")]
      [ValidateScript({Test-Path $_ -IsValid -PathType Leaf})]
      [String]$file
  )
  if ($pscmdlet.ShouldProcess($file , "New-Item -ItemType File")) {
    $logger.LogVerbose($($fileMsgTable.new_message -replace '<entityType>', 'File' -replace '<entityName>', $file))
    New-Item -path $file -ItemType File
  }
}
function Remove-File{
  <#
  .SYNOPSIS
  Delete a file, supports Force.

  .DESCRIPTION
  This is a rapper for Remove-Item, that adds validations and logging

  .EXAMPLE
  Remove-File .\testing123
  This will remove the file testing123 from the current directory
  #>
  [cmdletbinding(SupportsShouldProcess=$True)]
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the file")]
      [ValidateScript({Test-Path $_ -IsValid -PathType container})]
      [String]$file,
      [Parameter(Position=1,Mandatory=$false,HelpMessage="force delete")]
      [Switch]$Force
  )
  if ($pscmdlet.ShouldProcess($file , "Remove-Item -Force:$Force -ErrorAction SilentlyContinue")) {
    $logger.LogVerbose($($fileMsgTable.remove_message -replace '<entityType>', 'File' -replace '<entityName>', $file))
    Remove-Item -path $file -Force:$Force -ErrorAction SilentlyContinue
  }
}
function Test-Folder  {
  [cmdletbinding(SupportsShouldProcess=$True)]
  <#
  .SYNOPSIS
  Test that the folder exists

  .DESCRIPTION
  This is a rapper for Test-Path, that adds validations and logging 

  .EXAMPLE
  Test-Folder testing123
  verifies that there is a folder called testing123 in the current directory.
  #>
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the folder")]
      [ValidateScript({Test-Path $_ -IsValid -PathType container})]
      [String]$folder
  )
  if ($pscmdlet.ShouldProcess($folder , "Test-Path -PathType Container")) {
    $exists = Test-Path $folder -PathType Container
    if($exists) {
      $logger.LogVerbose($($fileMsgTable.test_message_exists -replace '<entityType>', "folder" -replace "<entityName>", $folder))
    } else {
      $logger.LogVerbose($(($fileMsgTable.test_message_not_exists -replace '<entityType>', "folder") -replace "<entityName>", $folder))
    }
    return $exists
  }
}
function New-Folder {
  <#
  .SYNOPSIS
  Creates a new folder

  .DESCRIPTION
  This is a rapper for New-Item, that adds validations and logging 

  .EXAMPLE
  New-Folder testing123
  This will create a directory called testing123 in the current directory

  .NOTES
  If the directory already exists it will throw an exception
  #>
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the folder")]
      [ValidateScript({Test-Path $_ -IsValid -PathType container})]
      [String]$folder
  )
  $logger.LogVerbose($(($fileMsgTable.new_message -replace '<entityType>', 'Folder') -replace '<entityName>', $folder))
  New-Item -path $folder -ItemType "directory"
}
function Remove-Folder{
  <#
  .SYNOPSIS
  Delete a folder, supports Recurse and Force.

  .DESCRIPTION
  This is a rapper for Remove-Item, that adds validations and logging

  .EXAMPLE
  Remove-Folder .\testing123
  This will remove the directory testing123 from the current directory
  #>
  Param (
      [Parameter(Position=0,Mandatory=$true,HelpMessage="Path to the folder")]
      [ValidateScript({Test-Path $_ -IsValid -PathType container})]
      [String]$folder,
      [Parameter(Position=1,Mandatory=$false,HelpMessage="include all subfolders")]
      [Switch]$Recurse,
      [Parameter(Position=2,Mandatory=$false,HelpMessage="force delete")]
      [Switch]$Force
  )
  $logger.LogVerbose($($fileMsgTable.remove_message -replace '<entityType>', 'Folder' -replace '<entityName>', $folder))
  Remove-Item -path $folder -Recurse:$Recurse -Force:$Force -ErrorAction SilentlyContinue
}
function Test-IsFolderInUse($sourcePath) {
  <#
  .SYNOPSIS
  Returns true if the sourcePath is a directory that is in use

  .EXAMPLE
  Test-IsFolderInUse testing123
  if there is no directory in the current directory called testing123 it will return $null,
  if there is a directory in the current directory called testing123 it will return $true if it is in use or $false if it is not in use.
  #>
  Write-FunctionStart 'Test IsFolderInUse'
  if($(Test-Path $sourcePath) -eq $false) {
    $logger.LogError("'$sourcePath' does not exist")
    Write-FunctionEnd "Test IsFolderInUse"
    return $null
  }
  if ([String]::IsNullOrEmpty($global:dateKey)) {
    $global:dateKey = (Get-Date -format u).replace(":","_").replace(" ","-")
  }
  $logger.LogVerbose("rename $sourcePath to '$sourcePath-$global:dateKey'")

  Rename-Item $sourcePath "$sourcePath-$global:dateKey" -ErrorAction SilentlyContinue
  if($(Test-Path "$sourcePath-$global:dateKey") -eq $false) {
    $logger.LogWarning("'$sourcePath' is in use")
    Write-FunctionEnd "Test IsFolderInUse"
    return $true
  }
  $logger.LogVerbose("rename '$sourcePath-$global:dateKey' back to $sourcePath")
  Rename-Item "$sourcePath-$global:dateKey" $sourcePath
  if($(Test-Path "$sourcePath") -eq $false) {
    $msg = "Failed to rename '$sourcePath-$global:dateKey' back to $sourcePath"
    throw $msg
  }
  $logger.LogInfo("'$sourcePath' is not in use")
  Write-FunctionEnd 'Test IsFolderInUse'
  return $false
}

$__Permissions = @{
  ChangePermissions = 262144 
  CreateDirectories = 4
  CreateFiles = 2
  Delete = 65536
  DeleteSubdirectoriesAndFiles = 64
  ExecuteFile = 32
  FullControl = 2032127
  ListDirectory = 1
  Modify = 197055
  Read = 131209
  ReadAndExecute = 131241
  ReadAttributes = 128
  ReadData = 1
  ReadExtendedAttributes = 8
  ReadPermissions = 131072
  Synchronize = 1048576
  TakeOwnership = 524288
  Traverse = 32
  Write = 278
  WriteAttributes = 256
  WriteData = 2
  WriteExtendedAttributes = 16
}

$__Permissions > $null

Export-ModuleMember -Function Test-Folder, New-Folder, Remove-Folder, Test-File, New-File, Remove-File, Test-IsFolderInUse