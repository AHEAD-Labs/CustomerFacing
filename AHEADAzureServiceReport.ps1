## AHEAD Azure Service Report v1.2
##
## Dependencies: PowerShell AZ Modules (https://docs.microsoft.com/en-us/powershell/azure/new-azureps-module-az)
##
## **This Powershell script should be run on a local machine and NOT utilizing Azure Cloud Shell
## 
## DIRECTIONS - Please update the file location you would like to save to under the "saveLocation" variable, choose whether you would like to provide sanitized or unsanitized data under the "sanitizedData" variable, run the script and login when prompted, Finally please review the exported CSV file and provide the output to AHEAD team via email or preferred file sharing service.

Login-AzAccount

## Location to save the CSV file to on your local computer
## Please do NOT include file name, this is defaulted on the following line of code

$saveLocation = "$env:USERPROFILE\Desktop" ## Update to your preferred save location
$saveFile = $saveLocation + "\AHEAD-AzureExport.csv"

## Remove existing version of file in event it already exists or script is rerun
try { Remove-Item -Path $saveFile -Confirm} catch { Write-Host "File $($saveFile) does not currently exist."}

## Setting this flag to true will ONLY include Azure Resource Types & Locations, Names, guids and other potentially identifiable information are excluded.
$sanitizedData = $True ## Values should be either "$True" or "$False"

## Select all Azure Subscriptions available, gather export of each subscription
$subs = Get-AzSubscription
foreach($sub in $subs) {
    if($sanitizedData) {
        $resources = Get-AzResource | Select ResourceType, Location
    } else {
        $resources = Get-AzResource
    }
    $resources | Export-Csv -Path $saveFile -Append
}
