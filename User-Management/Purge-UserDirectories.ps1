### simple ps script to purge the Windows User Profile Folder
### add directories you want to keep to $excludeDirs

$rootVolume = "C:"
$userDir = "temp\Users"
$excludeDirs = "Administrator","Default"

$targetDirs = Get-ChildItem -Path $rootVolume\$userDir -Name -attributes D

foreach($dir in $targetDirs)
{
	$purge = "true"
	
	foreach($protectedDir in $excludeDirs)
	{
		if ($dir -eq $protectedDir)
		{
			$purge = "false"
			break
		}
	}
	
	if ($purge -eq "true")
	{
		Remove-Item -Path $rootVolume\$userDir\$dir -Recurse -Force
	}
}