$strExportRegKey = "HKCU\Software\SimonTatham\PuTTY"
$strExportPath = "$env:USERPROFILE\OneDrive\Konfigurationen\Windows\Putty"
$strExportFileName = "putty.reg"
 
reg export $strExportRegKey $strExportPath\$strExportFileName