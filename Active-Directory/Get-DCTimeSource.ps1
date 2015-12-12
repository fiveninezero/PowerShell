# source: http://ajmckean.com/check-time-source-for-all-domain-controllers/

$DomainControllers =  Get-ADDomainController -Filter * | Select-Object -expand name
foreach ($DomainController in $DomainControllers)
{
  write-host “———————————————–”
  write-host “Domain Controller: $DomainController”
  write-host “Time Source:”
  w32tm /query /computer:$DomainController /source
  write-host “———————————————–”
}
