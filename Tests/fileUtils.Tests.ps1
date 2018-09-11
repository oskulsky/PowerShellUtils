Import-Module $PSScriptRoot/../PowerShellUtils_tests.psm1 -Force

Describe "Testing folder actions" {
  It 'should create test and delete a folder' {
    New-Folder testing123
    Test-Folder testing123 | should be $true
    Remove-Folder .\testing123
    Test-Folder testing123 | should be $false
  }
}
Describe "Testing file actions" {
  It 'should create test and delete a file' {
    New-File testing123
    Test-File testing123 | should be $true
    Remove-File .\testing123
    Test-File testing123 | should be $false
  }
}
Describe 'Testing IsFolderInUse' {
  BeforeEach {
    Push-Location $PSScriptRoot
    New-Folder testing123
  }
  It 'should test folder in use' {
    $global:dateKey = $null
    $logger.setPopUp($false)
    Test-IsFolderInUse $( (((get-item $PWD).parent).GetDirectories('CodeCoverage').GetDirectories('logs').FullName  )) | Should be $false
    Test-IsFolderInUse testing123 | Should be $false
    Test-IsFolderInUse 'c:\\xxxx\\yyyy' |should be $null
  }
  AfterEach {
    Remove-Folder .\testing123
    Pop-Location
  }
}