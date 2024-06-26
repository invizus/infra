Invoke-WebRequest "http://webserver.private/psdeploy/scripts/Start1.ps1" -Outfile "X:\Scripts\start.ps1"
if (-Not (Test-Path "X:\Scripts\start.ps1")) {
Write-Host "File was not downloaded, waiting 30 seconds before retrying..."
Start-Sleep 30
Invoke-WebRequest "http://webserver.private/psdeploy/scripts/Start.ps1" -Outfile "X:\Scripts\start.ps1"
} else { Write-host "File downloaded" }
Write-Host "Starting script."
Start-Process powershell.exe -ArgumentList "-file X:\Scripts\start.ps1"

