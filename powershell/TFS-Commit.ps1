###############################################################################
# TFS-Commit.ps1 
# Author: burmat
# Get-Command -Module Microsoft.TeamFoundation.PowerShell
###############################################################################
#
# This script is for a special case where we have a large code repository, but 
# no way to properly check out and make modifications. This is because the code
# needs to be run on a particular server and compiler service to test. This 
# makes it impossible to use revision control as designed and still maintain a 
# team of programmers.
#
# This script was created to pull down those working directories and push the 
# files into TFS so we can track the revision history
#
###############################################################################
#
# TO USE ON NEW PROJECT - FIRST RUN/COMMIT:
#   1) Create a project in TFS
#   2) Add the Project name to the `Merge-ProjectCode()` w/ filesystem location
#   2) Run with the -FullCommit switch to copy all files and commit all files
#
###############################################################################
#
#   PARAMETER: -ProjectName "<PROJECT>"
#       The name of your TFS project, mapped to directory in Merge-ProductCode()
#
#   PARAMETER: -Merge
#       Merge development code into the workspace directory without confirmation
#
#   PARAMETER: -Clone
#       Clone the TFS Project to the workspace directory without confirmation
#
#   PARAMETER: -FullCommit
#       Push all code (-Add) to staging and attempt to commit everything
#
#   PARAMETER: -Alteration
#       Simulate an alteration by adding a new file to the workspace
#
#   EXAMPLE - Push a new project into TFS (All files and folders)
#       PS > ./TFS-Commit.ps1 -ProjectName "PROJECT1" -FullCommit
#
#   EXAMPLE - Merge without a confirmation (good for scheduled task):
#       PS > ./TFS-Commit.ps1 -ProjectName "PROJECT1" -Clone -Merge
#
###############################################################################

param(
    [string]$ProjectName = "INVALID", 
    [switch]$Merge = $false, 
    [switch]$Clone = $false, 
    [switch]$FullCommit = $false,
    [switch]$Alteration = $false
)

Add-PSSnapin Microsoft.TeamFoundation.PowerShell

$PROJECT = $ProjectName
$URL = "http://coderepo.burmat.co:8080/tfs/Projects"
$SERVERPATH = "$/$PROJECT"
$LOCALFOLDER = "C:\TFS-REPO\$PROJECT\"
$WORKSPACENAME = "TFS-$PROJECT"

## used to simulate a change to the workspace (call `Alter-Workspace()`)
$LOCALFILE = "$LOCALFOLDER\burmatwashere.txt"

## Maps TFS Project to development code.  Copies everything to 
## the workspaces local directory.
function Merge-ProjectCode() {

    switch ($PROJECT) {
        "PROJECT1" { $source = "\\CODEREPO\PROJECT1\*"; break }
        "PROJECT2" { $source = "\\CODEREPO\PROJECT2\*"; break }
        default { $source = "INVALID"; break }  
    }

    if ($source -eq "INVALID") {
        Exit-WithError "ProjectName provided is invalid! Please check your spelling"
    } else {
        Print-Debug "Merging development server code (May take a while).."
        Copy-Item $source -Destination $LOCALFOLDER -Force -Recurse
    }
}

## Remove the directory and the workspace if it exists. Re-create the
## directory and map the workspace to it.
function Initialize-Workspace() {

    ## if the local directory exists, remove it
    if (Test-Path -Path $LOCALFOLDER) {
        Print-Debug "Deleting local folder: $LOCALFOLDER"
        Remove-Item -Path "$LOCALFOLDER\*" -Recurse -Force | Out-Null
        Remove-Item -Path "$LOCALFOLDER" -Recurse -Force | Out-Null
        # yes i know it's twice - it's on purpose
    }

    ## create the directory to house the workspace
    New-Item -Path $LOCALFOLDER -Type Directory | Out-Null 

    Try {
        ## try to find the workspace
        $workspace = $vcServer.GetWorkspace($WORKSPACENAME, $env:USERNAME)
        if ($workspace -ne $null) {
            Print-Debug "Workspace found, deleting it now.."
            $vcServer.DeleteWorkspace($WORKSPACENAME, $env:USERNAME) | Out-Null
        }
    } Catch {
        Print-Debug "No workspace found."
    }

    ## create the workspace, link to local directory
    Print-Debug "Initializing workspace..."
    $workspace = $vcServer.CreateWorkspace($WORKSPACENAME, $env:USERNAME)
    $workspace.Map($SERVERPATH, $LOCALFOLDER)

    ## if desired, clone the TFS Project code down to workspace:
    if ($Clone) {
        Print-Debug "Cloning TFS project to $LOCALFOLDER (May take a while).."
        $workspace.Get([Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest, 
            [Microsoft.TeamFoundation.VersionControl.Client.GetOptions]::Overwrite)
    } else {
        $confirm = Read-Host "Would you like to clone a local copy of $PROJECT now? [y/N]"
        if ($confirm -Match "[yY]") {
            Print-Debug "Cloning TFS project to $LOCALFOLDER (May take a while).."
            $workspace.Get([Microsoft.TeamFoundation.VersionControl.Client.VersionSpec]::Latest, 
            [Microsoft.TeamFoundation.VersionControl.Client.GetOptions]::Overwrite)
        }
    }
}


## Iterate all files in the directory. If this is a -FullCommit, all files
## are added to staging with -Add. Otherwise, the files are only added to 
## staging if they have been modified in the last 48 hours. This speeds
## up the script dramatically and causes less confusion on -Add / -Edit
function Commit-workspace() {
    Try {
        $workspace = $vcServer.GetWorkspace($WORKSPACENAME, $env:USERNAME)
        if ($workspace -eq $null) {
            Exit-WithError "Workspace not initialized properly. Please re-initialize."
        }
    } Catch {
        Exit-WithError "Unable to commit, workspace doesn't exist. Please re-initialize."
    }

    Print-Debug "Adding files to staging..."

    ## for every file in the workspace directory:
    Get-ChildItem $LOCALFOLDER -Recurse | ForEach-Object { 

        $file = $_.FullName
        $isDir = Test-Path -Path $file -PathType Container

        if ($isDir -eq $False -And $file.contains('/$tf/') -eq $False){
         
            ## if flag given, add all files to staging
            if ($FullCommit) {
                Add-TfsPendingChange -Add -Item "$file" | Out-Null
            } else {
                ## only add files to staging if modified in last 48 hours
                if ($_.LastWriteTime -gt (Get-Date).AddDays(-2) -And $file.contains('*/$tf/*') -eq $False) {
                    ## check if already in workspace and add if not
                    $added = Get-TfsItemProperty -Item $file | Select -ExpandProperty IsInWorkspace
                    if ($added) {
                        Add-TfsPendingChange -Edit -Item $file | Out-Null
                    } else {
                        Add-TfsPendingChange -Add -Item "$file" | Out-Null
                    }
                }
            }
        }
    }

    $pendingChanges = $workspace.GetPendingChanges()
    if ($pendingChanges) {

        ## for logging purposes:
        Print-Debug "`n`nStaged files to commit:"
        $pendingChanges | fl FileName,ChangeType,ServerItem,CreationDate

        ## check in the code
        $Author = "POWERSHELL"
        $Comment = "*** AUTO COMMIT ***"
        if ($FullCommit) {
            $Comment = "Project Full Commit"
        }
        $policyOverrideInfo = New-Object Microsoft.TeamFoundation.VersionControl.Client.PolicyOverrideInfo("Auto checkin", $null)
        $checkinOptions = [Microsoft.TeamFoundation.VersionControl.Client.CheckinOptions]::SuppressEvent
        $workspace.CheckIn($pendingChanges, $Author, $Comment, $null, $null, $policyOverrideInfo, $checkinOptions)
        
        Print-Debug "`n`n---> Check-in Completed"
    
        ## you can check in file by file with: 
        ##  PS > New-TfsChangeset -Item "$LOCALFOLDER\burmatwashere.txt"" -Verbose -Override true

    } else {
        Print-Debug "No files to check in"
    }
}

# Exit with error code 1 after logging message
function Exit-WithError([string]$msg) { Write-Host("[#] Exiting due to error: $msg"); Exit 1; }

# Log a debug message
function Print-Debug([string]$msg) { Write-Host "[#] $msg" }

# Simulate a change to the workspace
function Alter-Workspace() { Get-Date | Out-File $LOCALFILE }


## instatiate the tfs server
$tfsServer = Get-TfsServer -Name $URL

## instatiate the version control server
$vcServer = $tfsServer.GetService([Microsoft.TeamFoundation.VersionControl.Client.VersionControlServer])

## instatiate the project
Try {
    $vcProject = $vcServer.GetTeamProject($PROJECT)
} Catch {
    Exit-WithError "Unable to find project with that name on TFS Server."
}

## remove and re-create directory/workspace
Initialize-Workspace

if ($Alteration) {
    ## simulate a change to the workspace
    Alter-Workspace 
}

if ($Merge) {
    Merge-ProjectCode
} else {
    $confirm = Read-Host "Would you like to merge live $PROJECT code into this workspace? [y/N]"
    if ($confirm -Match "[yY]") {
        Merge-ProjectCode
    }
}

## attempt to commit any changes to the workspace
Commit-Workspace

Write-Host "`n------"
Write-Host "Done."