##
# Program: ftp_upload.ps1
# Purpose: Take a specified file type and ftp them to a server location. Archive
#          them afterwards and send an email with the filesnames of the files uploaded
##

# source directory to search for files
$source_directory = "C:\Data\Upload\"

# archive location after upload
$archive_directory = "C:\Data\Archive\"

# extensions to search for upload
$extension = "*.txt" 

# once uploaded, the source file paths are kept here
$uploaded_files = @();

##
## ftp connection information
##
$ftp_host = "<IP ADDRESS>"
$ftp_uname = "<USERNAME>";
$ftp_pass = "<PASSWORD>";


##
## smtp mail variables
##
$smtp_host = "<EMAIL SERVER RELAY>"
$smtp_port = "25"
$msg_from = "ftpupload@burmat.co"
$msg_sub = "FTP Files Uploaded"
$msg_to = "burmat@burmat.co,nathan.burchfield@burmat.co"
$msg_body = "The following files were uploaded to $($ftp_host):`n`n"
#$smtp_user = "MyUserName";
#$smtp_pass = "MyPassword";
#$attach_path = "C:\Data\attachment.txt"; # optional

## this function will send an email using the following parameters (attachment is optional):
function Send-ToEmail([string]$destination, [string]$from, [string]$subject, [string]$body, [string]$attachmentpath){
    
    $message = new-object Net.Mail.MailMessage;
    $message.From = $from;
    $message.To.Add($destination);
    $message.Subject = $subject;
    $message.Body = $body;

    ## only if attachment exists (optional):
    if ($attachmentpath -ne $null -and $attachmentpath -ne "") {
        Write-Host "Attaching file: " $attachmentpath
        $attachment = New-Object Net.Mail.Attachment($attachmentpath);
        $message.Attachments.Add($attachment);
    }

    $smtp = new-object Net.Mail.SmtpClient($smtp_host, $smtp_port);
    $smtp.EnableSSL = $true;
    #$smtp.Credentials = New-Object System.Net.NetworkCredential($smtp_user, $smtp_pass);
    $smtp.send($message);

    if ($attachment -ne $null) { $attachment.Dispose(); }
    if ($message -ne $null) { $message.Dispose(); }
}

# pass it a src and dest, and it will upload based on the variables above
function Ftp-Upload([string]$src, [string]$dest) {
    
    # create the FtpWebRequest and configure it
    $ftp = [System.Net.FtpWebRequest]::Create("ftp://$ftp_host/$dest")
    $ftp = [System.Net.FtpWebRequest]$ftp
    $ftp.Method = [System.Net.WebRequestMethods+Ftp]::UploadFile
    $ftp.Credentials = new-object System.Net.NetworkCredential($ftp_uname, $ftp_pass)
    $ftp.UseBinary = $true
    $ftp.UsePassive = $true
    
    # read in the file to a byte array
    $content = [System.IO.File]::ReadAllBytes($src)
    $ftp.ContentLength = $content.Length

    # write the bytes to the request stream
    $rs = $ftp.GetRequestStream()
    $rs.Write($content, 0, $content.Length)

    # cleanup
    if ($rs -ne $null) { $rs.Close(); $rs.Dispose(); }
}

# based on the variables above, read in all files and upload them
Get-ChildItem $source_directory -Filter $extension | Foreach-Object {

    $f_source = $_.FullName
    $f_destination = $_.Name

    # run the upload
    Ftp-Upload -src $f_source -dest $f_destination

    # append to the list for archive:
    $uploaded_files += $f_source
}

# if files were uploaded...
if ($uploaded_files.count -gt 0) {

    # for each file we uploaded, archive it and remove it
    foreach ($file in $uploaded_files) {
    
        # get the base filename
        $filename = Split-Path -Path $file -Leaf -Resolve

        # copy the file to archive location and delete it
        Copy-Item $file -Destination "$archive_directory$filename"
        Remove-Item $file

        $msg_body += "[>] $filename uploaded and archived.`n"
    }

    # log to console and send via email
    Write-Host $msg_body
    Send-ToEmail  -destination $msg_to -from $msg_from -subject $msg_sub -body $msg_body;

} else {
    # no files found - keep moving
    Write-Host "[#] No Files Uploaded."
}

$date_finished = (Get-Date -Format g) | Out-String
$date_finished = $date_finished -replace "`t|`n|`r",""

Write-Host "`n`n[>] Finished! ($date_finished)"