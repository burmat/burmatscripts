Import-Module ActiveDirectory

function Get-StaleComputers() {
    $time = (Get-Date).Adddays(-30)
    Get-ADComputer -Filter { LastLogonTimeStamp -lt $time } -Properties LastLogonTimeStamp | Select-Object Name,@{Name="Stamp"; Expression={[DateTime]::FromFileTime($_.lastLogonTimestamp)}} # | Export-CSV C:\temp\unused_machines.csv -notypeinformation
    Write-Host done.
}

Get-StaleComputers
