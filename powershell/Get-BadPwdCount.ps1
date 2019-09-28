Import-Module ActiveDirectory

#
# badpwdcount is tied to the dc, so you have to loop the dc's
#

$dcs = Get-ADComputer -Filter * -SearchBase "ou=Domain Controllers,dc=burmat,dc=co";
$users = Get-ADUser -Filter { Enabled -eq $true } | Sort SamAccountName

foreach ($user in $users) {
	$badpwdcount = 0;
	foreach ($dc in $dcs) {
		$newuser = Get-ADUser $user.SamAccountName -Server $dc.Name -Properties badpwdcount;
		$badpwdcount = $badpwdcount + $newuser.badpwdcount;
	}
 
	if ($badpwdcount -gt 0) {
		Write-Host "[!] " + $user.name + " - Bad Password Count: " + $badpwdcount -ForegroundColor Red;
	}
	else {
		Write-Host "[+] " + $user.name + " - Bad Password Count: " + $badpwdcount -ForegroundColor Green;
	}
} 
