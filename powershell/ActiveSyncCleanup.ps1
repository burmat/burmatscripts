#
# Program: ActiveSynceCleanup.ps1
# By: burmat 03/2019
# Purpose: Remove old/stale ActiveSync devices, inventory live ones
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# RUNNING THIS SCRIPT WILL REMOVE ACTIVESYNC DEVICES FROM AD / EXCHANGE
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

Import-Module ActiveDirectory # to delete retired objects

# get all mobile devices:
$devices = Get-ActiveSyncDevice -ResultSize unlimited;

# iterate them:
foreach ($device in $devices) {
	
	# get the last sync date:
	$stats = Get-ActiveSyncDeviceStatistics -Identity $device
	
    # if statistics were found:
	if ($stats) {
		
        # pull out the user
        $userAcct = ([regex]::split($device.Identity,'\/ExchangeActiveSyncDevices'))[0]
        $userAcct = ([regex]::split($userAcct, "/"))[2] # hacked but works

        # values we want to save back tot he `$device`
		$lastAttempt = $stats.LastSyncAttemptTime
        $lastSuccess = $stats.LastSuccessSync

        # if it hasn't even attempted to sync in 1 year, remove it
		if ($lastAttempt -lt (Get-Date).AddDays(-365)) {
			Write-Host "[>] REMOVING DEVICE - $userAcct [$stats.Guid] (last sync attempt: $lastAttempt)"
            Remove-ActiveSyncDevice $device -Confirm:$False
		} else {
            Write-Host "[#] ACTIVE DEVICE FOUND FOR $userAcct (last sync success: $lastSuccess"
			$device | Add-Member -MemberType NoteProperty -Name "LastSuccessSync" -Value $lastSuccess
            $device | Add-Member -MemberType NoteProperty -Name "LastSyncAttemptTime" -Value $lastAttempt
		}
	} else {
        # no stats found? If the user is in retire OU, remove device completely:
        if ($device.Identity -Like "*/Retire/*") {
            Write-Host "[>] REMOVING AD OBJECT: $device.Identity"
			## `Remove-ActiveSyncDevice` won't work if the mailbox is disconnected or user disabled
			Remove-ADObject -Identity $device.DistinguishedName -Confirm:$False
		} else {
            Write-Host "[!] ORPHANED ACTIVESYNC DEVICE: $device.Identity"
        }
	}
}

# Export to CSV
$devices | Export-CSV C:\mobile_devices.csv
