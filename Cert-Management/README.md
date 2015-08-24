cert-notifier
=============

Early warning system for certificates that are about to expire

#### Usage:
```
powershell "cert-notifier.ps1 -domain "your email domain" -sender "your email account" -recipient "notification reviever" -daysLeft 30 -mail True|False -log C:\Logs\certs.log
```

#### Parameters:
*  `-domain` Mandatory. This parameter is used for finding your mail server, as well as printing the FQDN of a host.
*  `-sender` Optional. The sender address for the notification mail. If this is not set, notification@$domain is used.
*  `-recipient` Mandatory. This email address will get the notification mails. 
*  `-daysleft` Optional. Controls how soon cert-notifier will alert you to expiring certificates.
*  `-mail` Optional. Default is false, to enable mail notification, set it to true.
*  `-log` Optional. If this is not set, the default path "C:\Logs\certs.log" is used.

#### Features:
cert-notifier will check all certificates in the personal certificate store of the computer account. If a certificate will get invalid in or less than the daysLeft parameter, an alert will either be logged and/or sent via email.

#### Requirements:
Since the script is not signed (yet), the execution policy must be modified. This can be done by opening an administrative shell and executing:
```
Set-ExecutionPolicy Unrestricted
```

To get the current execution policy, execute: 
```
Get-ExecutionPolicy
```

####Todo:
- [ ] Sign the script
- [ ] Windows event log integration
- [ ] handle multiple mx records (i haven't done any testing regarding multiple mx records)
- [ ] Nice output formatting
