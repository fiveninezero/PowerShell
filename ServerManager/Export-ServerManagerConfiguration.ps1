$Config = "$env:appdata\Microsoft\Windows\ServerManager\ServerList.xml"
$Destination = "$env:USERPROFILE\OneDrive\Konfigurationen\Windows\ServerManager\"

Copy-Item $Config -Destination $Destination -Force