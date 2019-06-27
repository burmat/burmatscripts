## Folders we want to backup:
$folders = @( 
        # scheduled task as admin to see E$
        "\\SERVER01\E$\APP1\code",
        "\\SERVER01\E$\APP1\code-test",
        "\\SERVER01\E$\APP2\code",
        "\\SERVER01\E$\APP2\code-test"
)

## The location we will backup to:
$today = Get-Date -UFormat "%m-%d-%Y"
$backup_location = "\\BACKUP01\repo\$today"
$messages = @()     ## will hold our output
$mismatch = $false


## get directory size function
function getDirSize([string]$folderpath) {
    #return (Get-ChildItem $folderpath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum
    return "{0:N2} MB" -f ((Get-ChildItem $folderpath -Recurse | Measure-Object -Property Length -Sum -ErrorAction Stop).Sum / 1MB)

}

## send email function
function sendEmail([string]$Subject, [string]$Body) {
    $message = new-object Net.Mail.MailMessage;
    $message.From = "backup@burmat.co";
    $message.To.Add("logging@burmat.co");
    $message.Subject = $Subject;
    $message.Body = $Body;
    $smtp = new-object Net.Mail.SmtpClient("mail.burmat.co", "25");
    $smtp.EnableSSL = $true;
    $smtp.send($message);
    if ($message -ne $null) { $message.Dispose(); }
}

#### START:

## Create the backup location if it doesn't exist:
if((Test-Path -Path $backup_location )){
   $messages += "[!] Directory exists - Overwriting"
} else {
    Write-Host "[>] Running Code Backup Script (Might take a while..)"
    $messages += "[#] Backing up to directory: $backup_location"
    New-Item -ItemType "Directory" -Path $backup_location | Out-Null
    New-Item -ItemType "Directory" -Path "$backup_location\APP1" | Out-Null
    New-Item -ItemType "Directory" -Path "$backup_location\APP2" | Out-Null
}

## For each folder we defined, bring them in:
foreach ($folder in $folders) {
    $messages += "[#] Backing up: $folder"
    $sub_folder = ""

    ## get the folder name from the path
    $folder_name = $folder |split-path -leaf

    ## dupe names like "code" and "code-test" need to be handled with this:
    if ($folder -like "*\APP1\*") {
        $sub_folder = "\APP1"
    } elseif ($folder -like "*\APP2\*") {
         $sub_folder = "\APP2"
    } else {
        $sub_folder = ""
    }

    ## copy the folder to the backup location
    Copy-Item $folder -Destination "$backup_location$sub_folder" -Force -Recurse

    ## output, compare directory sizes (bytes):
    $local_size = getDirSize $folder
    $remote_size = getDirSize "$backup_location$sub_folder\$folder_name"

    ## if they don't match, flip the flag:
    if ($local_size -ne $remote_size) {
        $mismatch = $true
        $messages += "[!] Folder Size Mismatch Found!!"
    }
    
    # append the file sizes
    $messages += "$local_size bytes (Local Copy)"
    $messages += "$remote_size bytes (Remote Backup)"
    $messages += "-----------------------------"
}

## craft our message subject
$msg_subject = "Code Backup Successfully Completed"
if ($mismatch) {
    $msg_subject ="[Error] Code Backup Integrity Mismatch"
}

## for our message body:
$msg_body = $messages -join "`n"

# send the email:
SendEmail -Subject $msg_subject  -Body $msg_body

## FINISHED.