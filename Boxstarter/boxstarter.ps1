# Configure execution policy for posh
Update-ExecutionPolicy Unrestricted -Force

# Configure and install Windows updates
Enable-MicrosoftUpdate
Install-WindowsUpdate -Full -AcceptEula

# Enable RDP
if ((Get-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server').fDenyTSConnections -eq 1) {
  Enable-RemoteDesktop
}

# Enable Hyper-V
Enable-WindowsOptionalFeature -FeatureName Microsoft-Hyper-V-All -Online -All -NoRestart
Enable-WindowsOptionalFeature -FeatureName TFTP -Online -All -NoRestart
Enable-WindowsOptionalFeature -FeatureName TelnetClient -Online -All -NoRestart

# Software deployment 
choco install 7zip -y
choco install googlechrome -y
choco install keepass -y
choco install notepadplusplus -y
choco install putty -y
choco install skype -y
choco install skype-utility-project -y
choco install spotify -y
choco install sysinternals -y
choco install teamviewer -y
choco install texniccenter -y
choco install tortoisegit -y
choco install vlc -y
choco install windbg -y
choco install winscp -y

# Dumps go here
if (!(Test-Path -Path C:\Dumps ))
{
  mkdir C:\Dumps
}
# VMs go here
if (!(Test-Path -Path C:\Hyper-V ))
{
  mkdir C:\Hyper-V
}
# Debugging Symbols go here
if (!(Test-Path -Path C:\Symbols ))
{
  mkdir C:\Symbols
}

# Configuration for TECHSOFT Datenverarbeitung GmbH
# L2TP VPN
$vpn = Get-VpnConnection -Name "TECHSOFT L2TP VPN"
if ($vpn) {
	$vpn | Remove-VpnConnection -Force
}
Add-VpnConnection -Name "TECHSOFT L2TP VPN" -ServerAddress "vpn.techsoft.at" -TunnelType L2tp -EncryptionLevel Required -AuthenticationMethod MsChapv2 -L2tpPsk "obviouslynottherealpw" -Force -RememberCredential -PassThru
# SSTP VPN
$vpn = Get-VpnConnection -Name "TECHSOFT SSL VPN"
if ($vpn) {
	$vpn | Remove-VpnConnection -Force
}
Add-VpnConnection -Name "TECHSOFT SSL VPN" -ServerAddress "sslvpn.techsoft.at" -TunnelType Sstp -EncryptionLevel "Required" -AuthenticationMethod MSChapv2 -Force -RememberCredential -PassThru

# Configure and install Windows updates (again!)
Enable-MicrosoftUpdate
Install-WindowsUpdate -Full -AcceptEula