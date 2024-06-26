Write-Host "This is autodeployment script."

Write-Host "Software: downloading..."
Invoke-WebRequest "http://webserver.private/deploy/ccsetup.exe" -OutFile C:\Temp\Deploy\ccsetup.exe
Invoke-WebRequest "http://webserver.private/deploy/openvpn.exe" -OutFile C:\Temp\Deploy\openvpn.exe
Invoke-WebRequest "http://webserver.private/deploy/spark.exe" -OutFile C:\Temp\Deploy\spark.exe
Write-Host "Software: downloaded."

Write-Host Starting ccsetup.exe
Start-Process C:\Temp\Deploy\ccsetup.exe -argumentlist "/S" -Wait
Write-Host Done with ccsetup.exe

Write-Host Starting openvpn.exe
Start-Process C:\Temp\Deploy\openvpn.exe -argumentlist "/S" -Wait
Write-Host Done with openvpn.exe

Write-Host Starting spark.exe
Start-Process C:\Temp\Deploy\spark.exe -argumentlist "-q" -Wait
Write-Host Done with spark.exe

sleep -S 20


