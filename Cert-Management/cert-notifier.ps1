####################
### simple certificate expiration early warning script
### Run it as a scheduled task, administrative access is required for querying the certificate store 

param (
    [string]$domain = $(throw "-domain is required."),
	[string]$mail = "false",
	[string]$logPath = "C:\logs\certs.log",
	[string]$daysLeft = "30",
    [string]$sender = "Benachrichtigungsdienst <notificaton@$domain>",
    [string]$recipient = $(throw "-recipient is required.")
)

####################
### Function to get the MX Records for a domain
### Usage: Get-DnsMXQuery -DomainName "gmail.com"
### Reference: http://serverfault.com/questions/164508/anyone-have-a-powershell-script-to-look-up-the-mx-record-for-a-domain
 
function Get-DnsAddressList
{
    param(
        [parameter(Mandatory=$true)][Alias("Host")]
          [string]$HostName)
 
    try {
        return [System.Net.Dns]::GetHostEntry($HostName).AddressList
    }
    catch [System.Net.Sockets.SocketException] {
        if ($_.Exception.ErrorCode -ne 11001) {
            throw $_
        }
        return = @()
    }
}
 
function Get-DnsMXQuery
{
    param(
        [parameter(Mandatory=$true)]
          [string]$DomainName)
 
    if (-not $Script:global_dnsquery) {
        $Private:SourceCS = @'
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Runtime.InteropServices;
 
namespace PM.Dns {
  public class MXQuery {
    [DllImport("dnsapi", EntryPoint="DnsQuery_W", CharSet=CharSet.Unicode, SetLastError=true, ExactSpelling=true)]
    private static extern int DnsQuery(
        [MarshalAs(UnmanagedType.VBByRefStr)]
        ref string pszName,
        ushort     wType,
        uint       options,
        IntPtr     aipServers,
        ref IntPtr ppQueryResults,
        IntPtr pReserved);
 
    [DllImport("dnsapi", CharSet=CharSet.Auto, SetLastError=true)]
    private static extern void DnsRecordListFree(IntPtr pRecordList, int FreeType);
 
    public static string[] Resolve(string domain)
    {
        if (Environment.OSVersion.Platform != PlatformID.Win32NT)
            throw new NotSupportedException();
 
       List<string> list = new List<string>();
 
        IntPtr ptr1 = IntPtr.Zero;
        IntPtr ptr2 = IntPtr.Zero;
        int num1 = DnsQuery(ref domain, 15, 0, IntPtr.Zero, ref ptr1, IntPtr.Zero);
        if (num1 != 0)
            throw new Win32Exception(num1);
        try {
            MXRecord recMx;
            for (ptr2 = ptr1; !ptr2.Equals(IntPtr.Zero); ptr2 = recMx.pNext) {
                recMx = (MXRecord)Marshal.PtrToStructure(ptr2, typeof(MXRecord));
                if (recMx.wType == 15)
                   list.Add(Marshal.PtrToStringAuto(recMx.pNameExchange));
            }
        }
        finally {
            DnsRecordListFree(ptr1, 0);
        }
 
        return list.ToArray();
    }
 
    [StructLayout(LayoutKind.Sequential)]
    private struct MXRecord
    {
        public IntPtr pNext;
        public string pName;
        public short  wType;
        public short  wDataLength;
        public int    flags;
        public int    dwTtl;
        public int    dwReserved;
        public IntPtr pNameExchange;
        public short  wPreference;
        public short  Pad;
    }
  }
}
'@
 
        Add-Type -TypeDefinition $Private:SourceCS -ErrorAction Stop
        $Script:global_dnsquery = $true
    }
 
    [PM.Dns.MXQuery]::Resolve($DomainName) | % {
        $rec = New-Object PSObject
        Add-Member -InputObject $rec -MemberType NoteProperty -Name "Host"        -Value $_
        Add-Member -InputObject $rec -MemberType NoteProperty -Name "AddressList" -Value $(Get-DnsAddressList $_)
        $rec
    }
}
 
### END Function ##################################

# host settings
$fqdn = [System.Net.Dns]::GetHostByName(($env:computerName))  | fl HostName | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
$ipAddr = [System.Net.Dns]::GetHostByName(($env:computerName))  | fl AddressList | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
$ipAddr = $ipAddr.Substring(1,$ipAddr.length-2)

# cert store settings, expiration settings
$certs = Get-ChildItem -Path cert:LocalMachine\My -ExpiringInDays $daysLeft | ForEach-Object {$_.Subject.Split(",")} | where {$_ -match "CN=*"}
$date = Get-Date -format d

# email settings
if ($mail) {
	$mailServer = Get-DnsMXQuery -DomainName $domain | fl Host | Out-String | %{ "{0}" -f $_.Split(':')[1].Trim() };
}

$msg = "One or more of the following certificates on $fqdn (IP: $ipAddr) are expiring in less than $daysLeft days: "

# generate notification mail/log entry if $certs contains certificate information
if ($certs) {
	$severity = "MAJOR"
	$logText = $date + " " + $severity + ": " + $msg + " " + $certs
	if ($logPath) {
		Out-File -Encoding "UTF8" -FilePath $logPath -Append -InputObject $logText
	}
	 if ($mail) {
		$subject = "Certificate early warning system"
		$body = $msg + "
$certs"
		send-MailMessage -SmtpServer $mailServer -to $recipient -from $sender -Subject $subject -body $body
	}
} else {
	$severity = "INFORMATION"
	$logText = $date + " " + $severity + ": " + "All is well."
	if ($logPath) {
		Out-File -Encoding "UTF8" -FilePath $logPath -Append -InputObject $logText
	}
}

exit 0