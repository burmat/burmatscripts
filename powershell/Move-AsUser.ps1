# impersonating a user, mount a network share and move a file to it 
#     Example:
# PS> powershell -nop -exec bypass -F C:\scripts\Move-AsUser.ps1 C:\code\working\framwork.py

param(
    [Parameter(Position=0,mandatory=$True)]
    [string] $filePath
)

$username = "burmat.co\xsvc"
$secure = ConvertTo-SecureString "PASSWORD" -AsPlainText -Force
$credential = New-Object System.management.Automation.PSCredential $username, $secure

$scriptBlock = {

    $cred = $args[0]
    $source = $args[1]
    $iam = whoami

    Write-Host "[#] Impersonating $iam"

    Write-Host "[#] Mounting location to Y:\ drive"
    New-PSDrive -Credential $cred -Name "Y" -PSProvider "FileSystem" -Root "\\FILESERV\code"

    Write-Host "[#] Moving $source to Y:\"
    #New-Item -Path "Y:\" -Name "_testupload.txt" -ItemType "file" -Value "test" -Force #testing
    Move-Item -Path $source -Destination "Y:\" -Force  

    Write-Host "[#] Removing Y:\ Drive.."
    Remove-PSDrive -Name "Y" -Force
}

# invoke the script block we just defined, impersonating another user
# (if not allowed, make sure impersonation user is in local "Remote Management Users" group)
Invoke-Command -ComputerName DEV01.burmat.co -Credential $credential -ScriptBlock  $scriptBlock -ArgumentList $credential,$filePath

Write-Host "[#] Script Finished." 