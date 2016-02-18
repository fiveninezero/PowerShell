<# Simple script to test all external services
based on: https://rcmtech.wordpress.com/2015/12/09/test-your-web-access-with-powershell/
#>

# Create hashtable for sites to be tested
$Sites = @{}
$Services = @{}
# Create hashtable for the results
$SiteResults = @{}
$ServiceResults = @{}

$MaxSiteLength = 0

# Stop progress bar appearing during Invoke-WebRequest
$ProgressPreference = "SilentlyContinue"

# Add sites hashtable
# Format is: <URL to be retieved>,<text to find on that page>
$Sites.Add("https://doku.techsoft.at/doku.php","Anmelden")
$Sites.Add("https://filecenter.techsoft.at/accounts/login/?next=/","TECHSOFT Datenverarbeitung GmbH")
$Sites.Add("https://intranet.techsoft.at/login/auth","WILLKOMMEN BEI CORE")
$Sites.Add("https://mail.techsoft.at/owa/auth/logon.aspx","Password")
$Sites.Add("https://portal.techsoft.at/","Portal")
$Sites.Add("https://ticket.techsoft.at/secure/Dashboard.jspa","System Dashboard")
$Sites.Add("https://tswt.techsoft.at/ecm/app","TECHSOFT ECM")
$Sites.Add("http://www.techsoft.at/","Linz")
$Sites.Add("https://api.techsoft.at/iFactory/iFactoryIntegration/", "blar")

# Add services hashtables
# Format is: <Hostname>,<TCP PORT>
$Services.Add("sslvpn.techsoft.at", "443")
$Services.Add("mail.techsoft.at", "25")

function Print-ServiceStatus {
  param(
    $Results,
    [string]$Type
    )

  Write-Host ""
  Write-Host ("$Type".PadRight($MaxSiteLength+2)+"Result")
  # Sort the sites into alphabetical order - hashtables display randomly otherwise
  foreach($Result in ($Results.GetEnumerator() | Sort-Object -Property Name)){
    # Look for keywords in the result text and set the colour variable appropriately
    switch -Wildcard ($Result.Value)
    {
      "*ok*" {$ForegroundColour = "Green"}
      "*warning*" {$ForegroundColour = "Yellow"}
      "*fail*" {$ForegroundColour = "Red"}
      Default {$ForegroundColour = "Gray"}
    }
    # Display the site name, padded to ensure the results line up neatly
    Write-Host $Result.Name.PadRight($MaxSiteLength+2) -NoNewline
    # Display the result in colour
    Write-Host $Result.Value -ForegroundColor $ForegroundColour
  }
}

foreach($Site in $Sites.GetEnumerator()){
  $x = $Site.Name -match "//.*?/" # regex with "lazy" wildcard to get DNS domain name from URL
  $SiteName = $matches[0] -replace "/",""
  # Find the longest site name so results can be displayed neatly in a table
  if($SiteName.Length -gt $MaxSiteLength){
    $MaxSiteLength = $SiteName.Length
  }
  # Clear the variable used to hold the page content
  # If Invoke-WebRequest fails this would otherwise contain the previously tested page
  $Page = $null
  # Check the DNS is resolving correctly
  try{
    $x = Resolve-DnsName -Name $SiteName -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop
    try{
      # DNS is OK, fetch the page
      try {
        $Page = Invoke-WebRequest -Uri $Site.Name -TimeoutSec 5 -ErrorAction Stop
      } catch {
        $status = $_.Exception.Response.StatusCode.Value__
      }
      if($Page.Content -like ("*"+$Site.Value+"*")){
        # Everything is good
        $SiteResults.Add($SiteName,"OK")
      } elseif ($status) {
        # Weg got SOMETHING!
        $SiteResults.Add($SiteName,"HTTP Status $status")
        $status = ""
      }else{
        # The page loaded but the text wasn't found
        $SiteResults.Add($SiteName,"Page Text Warning")
      }
    } catch {
      $SiteResults.Add($SiteName,"Page Load Fail")
    }
  } catch {
    $SiteResults.Add($SiteName,"DNS Fail")
  }
}

foreach($Service in $Services.GetEnumerator()){
  try{
    $x = Resolve-DnsName -Name $Service.Name -DnsOnly -NoHostsFile -QuickTimeout -ErrorAction Stop
    $result = Test-NetConnection $Service.Name -Port $Service.Value
    if ($result.TcpTestSucceeded) {
      $ServiceResults.Add($Service.Name,"TCP OK")
    } else {
      $ServiceResults.Add($Service.Name,"TCP Fail")
    }
  }	catch {
    $ServiceResults.Add($Service.Name,"DNS Fail")
  }
}

# Display the results
$date = Get-Date -Format s
Write-Host ""
Write-Host "TECHSOFT External Services Check"
Write-Host $date

# Write the table header
if ($Sites.count -gt 0) {
  Print-ServiceStatus -Result $SiteResults -Type "Site"
}
if ($Services.count -gt 0) {
  Print-ServiceStatus -Result $ServiceResults -Type "Service"
}
