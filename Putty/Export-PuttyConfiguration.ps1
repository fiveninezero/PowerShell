$strExportRegKey = "HKCU\Software\SimonTatham\PuTTY"
$strExportPath = $env:USERPROFILE\OneDrive\Konfigurationen\Windows\Putty
$strExportFileName = "clearbyte_$(get-date -f yyyyMMddhhmmss).reg"
 
reg export $strExportRegKey $strExportPath\$strExportFileName