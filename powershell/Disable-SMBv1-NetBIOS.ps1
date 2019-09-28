$logfile = "C:\Disable-SMBv1-NetBIOS.log"

$WindowsBuild = (Get-WmiObject -Class Win32_OperatingSystem).BuildNumber

#
# get to work
#
"[#] executing Disable-SMBv1-NetBIOS.ps1`n" | Out-File $logfile

#
# disable netbios
#
$i = 'HKLM:\SYSTEM\CurrentControlSet\Services\NetBT\Parameters\Interfaces'  
Get-ChildItem $i | ForEach-Object {  
    Set-ItemProperty -Path "$i\$($_.pschildname)" -name NetBiosOptions -value 2
}
Add-Content $logfile "[>] netbios disabled on all interfaces"

#
# disable smbv1
#
Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Services\LanmanServer\Parameters" SMB1 -Type DWORD -Value 0 –Force
Add-Content $logfile "[>] smbv1 disabled via registry"

if (Get-Command "Get-SmbServerConfiguration" -errorAction SilentlyContinue) {
    if ((Get-SmbServerConfiguration).SMB1Protocol) {
        Set-SmbServerConfiguration -EnableSMB1Protocol $false -Force
        Add-Content $logfile "[>] smb v1 disabled via powershell"
    } else {
        Add-Content $logfile "[#] smb v1 previously disabled via powershell"
    }
}

if (Get-Command "Get-WindowsOptionalFeature" -errorAction SilentlyContinue) {
    if ((Get-WindowsOptionalFeature -Online -FeatureName SMB1Protocol).State -EQ "Enabled") {
        Disable-WindowsOptionalFeature -Online -FeatureName SMB1Protocol -NoRestart
        Add-Content $logfile "[>] smb v1 removed via powershell"
    } else {
        Add-content $logfile "[#] smb v1 previously removed via powershell"
    }
}
