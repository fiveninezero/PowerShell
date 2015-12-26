$Config = "$env:USERPROFILE\OneDrive\Konfigurationen\Windows\ServerManager\ServerList.xml"
$Destination = "$env:appdata\Microsoft\Windows\ServerManager\ServerList.xml"

Copy-Item $Config -Destination $Destination -Force