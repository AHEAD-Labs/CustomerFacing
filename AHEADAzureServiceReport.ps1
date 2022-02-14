## AHEAD Azure Service Report v1.2
##
## Dependencies: PowerShell AZ Modules (https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az)
##
## **This Powershell script should be run on a local machine and NOT utilizing Azure Cloud Shell
## 
## DIRECTIONS - Please update the file location you would like to save to under the "saveLocation" variable, choose whether you would like to provide sanitized or unsanitized data under the "sanitizedData" variable, run the script and login when prompted, Finally please review the exported CSV file and provide the output to AHEAD team via email or preferred file sharing service.

#----------------------------------------------------------------------------------------
# Modules to determine path to save Excel file
#----------------------------------------------------------------------------------------
function Get-DesktopPath {
  [CmdletBinding()]
  Param(
    [Parameter(
      ValueFromPipeline = $true
    )]
    [string]
    $date
  )

  process { 
    If ($env:HOME) {
      Write-Verbose "Running on a non Windows computer.  Saving file to /users/%USERNAME%/Desktop"
      $path = "$env:HOME/Desktop/AzResources-$date.csv"
      $desktopPath = "$env:HOME/Desktop"
    }
    elseif ($env:HOMEPATH) {
      Write-Verbose "Running a Windows PC. Saving file to C:\users\%USERNAME%\Desktop"
      $path = "$env:HOMEPATH\Desktop\AzResources-$date.csv"
      $desktopPath = "$env:HOMEPATH\Desktop\"
    }

    If (Test-Path -Path $desktopPath) {
      Write-Verbose "Desktop path is valid"
    }
    Else {
      Write-Verbose "Path is not valid.  Setting output to current working directory"
      $folderPath = Get-Location | Select-Object -ExpandProperty Path
      if ($env:HOME) {
        Write-Verbose "Running on a non Windows computer."
        $path = $folderPath + "/AzResources-$date.csv"
      }
      else {
        Write-Verbose "Running on a Windows computer."
        $path = $folderPath + "\AzResources-$date.csv"
      }
    }

    return $path
  }
}

Login-AzAccount

## Location to save the CSV file to on your local computer
## Please do NOT include file name, this is defaulted on the following line of code

$date = (Get-Date).ToShortDateString().Replace("/", "-")

$desktopPath = Get-DesktopPath -date $date

## Remove existing version of file in event it already exists or script is rerun
try { Remove-Item -Path $desktopPath -Confirm } catch { Write-Host "File $($desktopPath) does not currently exist." }

## Setting this flag to true will ONLY include Azure Resource Types & Locations, Names, guids and other potentially identifiable information are excluded.
$sanitizedData = $False ## Values should be either "$True" or "$False"



## Select all Azure Subscriptions available, gather export of each subscription
$subs = Get-AzSubscription
foreach($sub in $subs) {
    $null = Set-AzContext -subscriptionId $sub.Id
    $subName = $sub.Name
    Write-Host "Setting context to $subName" -ForegroundColor green
    if($sanitizedData) {
        $resources = Get-AzResource | Select-Object @{Name = 'Resource Type'; Expression ={($_.ResourceType).Split("/")[1]}}, Location
    } else {
        $resources = Get-AzResource
    }
    $resources | Export-Csv -Path $desktopPath -Append
}
