#############
# TFSCommit.ps1
# Author: burmat
#
##
# This script is for a special case where we have a large code repository, but 
# no way to properly check out and make modifications. This is because the code
# needs to be run on a particular server and compiler service to 
# test. This makes it impossible to use revision control as designed and still
# maintain a team of programmers.
##
# This script was created to pull down those working directories push the files 
#into TFS anyway, so we can at least track changes to the project folders. This 
# script is heavy in that it will copy everything and try to commit everything 
# (only changes are ACTUALLY committed). Futher optimization can by done by 
# only copying modified files and attempting to merge modified files only (TODO)
#
# PARAMETER: -ProjectName "<PROJECT>"
#     The friendly name of your project, mapped to a remote directory in Merge-ProductCode()
#
# PARAMETER: -Initialize
#     This switch will set up (after removing) the workspace on your computer
#
# PARAMETER: -Merge
#     This switch will auto-merge the project folder code to workspace w/o confirmation
#
# EXAMPLE - Initialize project folder and workspace:
# PS > ./TFSCommit.ps1 -Initialize -ProjectName "VTP"
#
# EXAMPLE - Merge without a confirmation (good for scheduled task):
# PS > ./TFSCommit.ps1 -ProjectName "VTP" -Merge
#############

param([string]$ProjectName = "VTT", [switch]$Initialize = $false, [switch]$Merge = $false)

Add-PSSnapin Microsoft.TeamFoundation.PowerShell

$PROJECT = $ProjectName
$URL = "http://coderepo.burmat.co:8080/tfs/Software"
$SERVERPATH = "$/$PROJECT"
$LOCALFOLDER = "C:\TFS\Repository\$PROJECT\"
$WORKSPACENAME = "TFS-$PROJECT"

## used to simulate a "change" to the directory - see `change-file()`
$LOCALFILE = "$LOCALFOLDER\burmatwashere.txt"


#
# Copy down the live code to the workspace
function Merge-ProjectCode() {
    # !! CHANGE THESE to suit needs
    switch ($PROJECT) {
        "PROJECT1" { $source = "\\CODEREPO\Project1\code\*"; break }
        "PROJECT2" { $source = "\\CODEREPO\Project2\code\*"; break }
        default { $source = "INVALID"; break }  
    }
    if ($source -eq "INVALID") {
        Exit-WithError "ProjectName provided is invalid. Please check your spelling"
    } else {
        Print-Debug "Merging development server code (May take a while).."
        Copy-Item $source -Destination $LOCALFOLDER -Force -Recurse
    }
}

#
# Set up shop on the system
function Initialize-Workspace() {

    # if the local directory exists, remove it
    if (Test-Path -Path $LOCALFOLDER) {
        Print-Debug "Deleting local folder: $LOCALFOLDER"
        Remove-Item -Path $LOCALFOLDER -Recurse -Force | Out-Null
    }

    # create the directory again
    New-Item -Path $LOCALFOLDER -Type directory | Out-Null

    Try {
        ## try to find the workspace
        $Workspace = $VcServer.GetWorkspace($WORKSPACENAME, $env:USERNAME)
        if ($Workspace -ne $null) {
            $VcServer.DeleteWorkspace($WORKSPACENAME, $env:USERNAME) | Out-Null
        }
        Print-Debug "Workspace found, deleting it now.."
    } Catch {
        Print-Debug "Workspace not found, creating now.."
    }

    ## create the workspace, link to local directory
    $Workspace = $VcServer.CreateWorkspace($WORKSPACENAME, $env:USERNAME)
    $Workspace.Map($SERVERPATH, $LOCALFOLDER)

    $Confirm = Read-Host "Would you like to clone a local copy of $PROJECT now? [y/N]"
    if ($Confirm -Match "[yY]") {
        $workspace.Get([Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest, 
        [Microsoft.TeamFoundation.VersionControl.Client.GetOptions]::Overwrite)
    }
}

#
# Iterate all files in the directory and add them to staging.
# Check for changes and output them to console before committing them.
function Commit-workspace() {

    Try {
        # get the workspace
        $Workspace = $VcServer.GetWorkspace($WORKSPACENAME, $env:USERNAME)
    } Catch {
        Exit-WithError "Unable to commit, workspace doesn't exist. Please re-initialize."
    }

    ## loop through the project folder and add every file to staging:
    Get-ChildItem $LOCALFOLDER -Recurse | ForEach-Object { 
        Add-TfsPendingChange -Add -Item "$_.FullName" | Out-Null
        #Add-TfsPendingChange -Edit -Item "$_.FullName" # will catch edits, but not additions
    }

    # take a look at all of the staged changes:
    $PendingChanges = $Workspace.GetPendingChanges()

    ## if we have some, commit them:
    if ($PendingChanges) {

        ## for logging purposes:
        Print-Debug "`nStaged changes:"
        $PendingChanges | fl FileName,ChangeType,ServerItem,CreationDate

        ## check in the code
        $Author = "POWERSHELL"
        $Comment = "*** AUTO COMMIT ***"
        $PolicyOverrideInfo = New-Object Microsoft.TeamFoundation.VersionControl.Client.PolicyOverrideInfo("Auto checkin", $null)
        $CheckinOptions = [Microsoft.TeamFoundation.VersionControl.Client.CheckinOptions]::SuppressEvent
        $Workspace.CheckIn($PendingChanges, $Author, $Comment, $null, $null, $PolicyOverrideInfo, $CheckinOptions)
        
        Print-Debug "`n`n---> Check-in Completed"
    
        ## you can check in file by file with: New-TfsChangeset -Item "$LOCALFOLDER\burmatwashere.txt"" -Verbose -Override true

    } else {
        Print-Debug "No files to check in"
    }
}

# Exit with error code 1 after logging message
function Exit-WithError([string]$msg) { Write-Host("[#] Exiting due to error: $msg"); Exit 1; }

# Log a debug message
function Print-Debug([string]$msg) { Write-Host "[#] $msg"; }

# Simulate a change to the workspace
function Alter-Workspace() { Get-Date | Out-File $LOCALFILE }


## instatiate the tfs server
$TfsServer = Get-TfsServer -Name $URL

## instatiate the version control server
$VcServer = $TfsServer.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])

## instatiate the project
$VcProject = $VcServer.GetTeamProject($PROJECT)

## remove and re-create directory/workspace
if ($Initialize) {
    $Confirm = Read-Host "Initializing will remove the workspace and folder from your machine.`nAre you sure you want to do this? [y/N]"
    if ($Confirm -Match "[yY]") {
        Initialize-Workspace
    }    
}

#Alter-Workspace ## simulate a change to the workspace

if ($Merge) {
    Merge-ProjectCode
} else {
    $Confirm = Read-Host "Would you like to merge live $PROJECT code into this workspace? [y/N]"
    if ($Confirm -Match "[yY]") {
        Merge-ProjectCode
    }
}

## attempt to commit any changes to the workspace
Commit-Workspace

Write-Host "`n------"
Write-Host "Done."