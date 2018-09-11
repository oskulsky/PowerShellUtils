if ($IsWindows) {
  $wshell = New-Object -ComObject Wscript.Shell
}

$logger = New-Object -Type PSObject -Property @{
  Filename = ''
  popupTitle = ''
  console  = $true
  popup = $true
  consoleLevel  = 'Verbose'
  popupLevel = 'Error'
  allLevels =  @('Error', 'Warning', 'Information', 'Verbose', 'Debug')
}
$logger | Add-Member -Type ScriptMethod -Name Log -Value {
  Param(
    [Parameter(Mandatory=$true, Position=0)]
    [ValidateNotNullOrEmpty()]
    [string]$Message,
    [Parameter(Mandatory=$false, Position=1)]
    [ValidateSet('Error', 'Warning', 'Information', 'Verbose', 'Debug')]
    [string]$LogLevel = 'Verbose'
  )
  $LogLevelIndex = $this.allLevels.indexof($LogLevel)
  
  if (![String]::IsNullOrEmpty($this.Filename)) {
    $DateLine = Get-Date -format u
    $message.Split("`n") | ForEach-Object {
      $logstring = "$DateLine $LogLevel : $Message"
      Add-content -Path $this.Filename -value $logstring
    }
  }
  
  if ($this.console -eq $true) {
    if($LogLevelIndex -le $this.allLevels.indexof($this.consoleLevel)) {
      $color = @('Red','Yellow','Green','Gray','White')[$LogLevelIndex]
      Write-Host $Message -ForegroundColor $color
    }
  }

  if ($IsWindows) {
    if ($this.popup -eq $true) {
      if($LogLevelIndex -le $this.allLevels.indexof($this.popupLevel)) {
        $popupIconValue = @(16,48,64)[$LogLevelIndex]
        if ($popupIconValue) {
          $wshell.Popup("$LogLevel : $message",0,"$($this.popupTitle) - $LogLevel",$popupIconValue);
        }
      }
    }
  }
}

$logger | Add-Member -Type ScriptMethod -Name SetLog -Value {
  Param([Parameter(Mandatory=$true)][string]$file)
  $this.Filename = $file
  New-File $file
}

$logger | Add-Member -Type ScriptMethod -Name SetPopUp -Value {
  Param([Parameter(Mandatory=$true)][bool]$ispopup)
  $this.popup = $ispopup
}

$logger | Add-Member -Type ScriptMethod -Name SetPopUpLevel -Value {
  Param([Parameter(Mandatory=$true)][String]$popupLevel)
  $this.popupLevel = $popupLevel
}

$logger | Add-Member -Type ScriptMethod -Name SetConsoleLevel -Value {
  Param([Parameter(Mandatory=$true)][bool]$consoleLevel)
  $this.consoleLevel = $consoleLevel
}

$logger | Add-Member -Type ScriptMethod -Name LogError -Value {
  Param([Parameter(Mandatory=$true)][string]$Message)
  $this.Log($Message, 'Error') > $null
}
$logger | Add-Member -Type ScriptMethod -Name LogWarning -Value {
  Param([Parameter(Mandatory=$true)][string]$Message)
  $this.Log($Message, 'Warning') > $null
}
$logger | Add-Member -Type ScriptMethod -Name LogInfo -Value {
  Param([Parameter(Mandatory=$true)][string]$Message)
  $this.Log($Message, 'Information') > $null
}
$logger | Add-Member -Type ScriptMethod -Name LogVerbose -Value {
  Param([Parameter(Mandatory=$true)][string]$Message)
  $this.Log($Message, 'Verbose') > $null
}
$logger | Add-Member -Type ScriptMethod -Name LogDebug -Value {
  Param([Parameter(Mandatory=$true)][string]$Message)
  $this.Log($Message, 'Debug') > $null
}

Export-ModuleMember -Variable logger