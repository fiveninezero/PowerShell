# swerner, 24.08.2015
#
# This script will query a given ou in active directory for:
# user accounts that have not changed their password for $MaxAge days,
# user accounts where the last logon date is older than $MaxAge,
# user accounts that have been disabled,
# user accounts with expired passwords,
# computer accounts where the last logon date is older than $MaxAge,
# computer accounts that have been disabled.
#
# The output is a csv with tab delimiter, including Name and DN of a given object
 
$MaxAge = 180 # adjust this parameter for more aggressive cleanup
$SearchBase = "ou=root,dc=amhs,dc=local" # this is the base ou - leave this blank if you want to query your whole ad!
$UserList = "C:\temp\StaleUsers.csv" # Path to the output file for stale users, leave this blank to ignore stale users
$ComputerList = "C:\temp\StaleComputers.csv" # Path to the output file for stale computers, leave this blank to ignore stale computers

if ($UserList) {
	$Users = Get-AdUser -searchbase $SearchBase -Filter * -Properties PasswordLastSet,LastLogonDate | ? { 
		$_.PasswordLastSet -lt [DateTime]::Now.Subtract([TimeSpan]::FromDays($MaxAge)) -or 
		$_.LastLogonDate -lt [DateTime]::Now.Subtract([TimeSpan]::FromDays($MaxAge)) -or
		$_.Enabled -eq $false -or
		$_.PasswordExpired -eq $true
	}
$Users | select-object Name,DistinguishedName | Export-Csv -Delimiter `t -NoTypeInformation -encoding "unicode" -Path $UserList 
}

if ($ComputerList) {
	$Computers = Get-ADComputer -searchbase $SearchBase -Filter * -Properties PasswordLastSet,LastLogonDate | ? { 
		$_.LastLogonDate -lt [DateTime]::Now.Subtract([TimeSpan]::FromDays($MaxAge)) -or
		$_.Enabled -eq $false
	} 
$Computers | select-object Name,DistinguishedName | Export-Csv -Delimiter `t -NoTypeInformation -encoding "unicode" -Path $ComputerList 
}