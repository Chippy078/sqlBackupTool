<#
.SYNOPSIS
    Name: sqlBackupTool.ps1
      
.PARAMETER InitialDirectory
    This script can be run local filesystem at Workstation.
      
.NOTES
    Updated: xx-xx-2021
    Release Date: 28-02-2024
    Author: Jordy Scheers     

.NOTES
    ## DEBUG ##


####################################

.EXAMPLE 
    default 
     else{
            #Write-Host "(ERROR) file not found"
            Write-Logline ("$(get-date) code 404 [ERROR]")
             $global:returncode = 1;
        }
#>
#-----------------[Date ]-------------------------------------------------------------------------------
$date = Get-Date -Format "dd-MM-yyyy HH:mm:ss"
#----------------[Version]-------------------------------------------------------------
$version = "Version: 1.2.5"
$space = "---------------------------------"
#----------------[ LogFile_Module ]----------------------------------------------------
function set-LogLineHeader($string) {
    $global:msg_header = $string
}

function Set-LogInit($Prefix) {
    $time = Get-Date -Format "yyyyddMM_HHmmss"
    $logDir = New-Item -Path "C:\Logs\" -Name "VCB" -ItemType "directory" -Force
    $logFileName = ($Prefix) + $time + ".log"
    $global:logFile = New-Item -Path $logDir -Name $logFileName -ItemType "file" 
    $global:logLines = New-Object System.Collections.ArrayList
    set-logLineHeader("")
    #$global:logLines.Add($global:msg_header+"start of logging") > $null
}

function Write-LogLine($string) {
    $global:logLines.Add($global:msg_header + $string) > $null
}
function Write-Version($string) {
    $global:logLines.Add($global:msg_header + $string) > $null
}

function Write-LogLineAtPosition($param) {
    $pos = $param[0]
    $string = $param[1]
    #Write-Host "POS= $pos, string = $string"
    $global:logLines.insert($pos, $global:msg_header + $string)
}

function Write-LogOutput {
    foreach ($element in $global:logLines) {  
        Write-Host($element)
        $element | Out-File $global:logFile -Append
    }
}
#----------------[Pre text]-----------------------------------------------------------------------------
Write-Host "##########################################################################"
Write-Host "Welkom bij de SQL Backup Tool $version.                            #"                                 
Write-Host "Met deze tool kan je gemakkelijk een SQL backup maken en exporteren.     #"
Write-Host "Default backup path is C:\Backup\VSC-MMX.                                #"
Write-host "                                                                         #"
Write-host "                       ##DEBUG##                                         #"
Write-Host "BUG INFO: De zip functionaliteit functioneert nog niet!                  #"
Write-Host "##########################################################################"
Write-host "`n"
#----------------[ Global Default ]---------------------------------------------------------------------------
$global:returncode = 0 # VCB 0 = succes , 1 = failed
#----------------[ Global Vars ]---------------------------------------------------------------------------
$folderName = Read-Host "Locatie naam"
$fileName = Read-Host "Datum"
$global:main = "C:\Backup\VSC-MMX\$folderName"
$global:sqlBackup = "C:\Backup\VSC-MMX\$folderName\$fileName.bak"
$global:zipMe = "C:\Backup\VSC-MMX\$folderName.zip"
#-------------------(Function)-----------------------------------------------------------------------------
#TODO backupZipFolder
function backupZipFolder  {

    try {

        $location = "C:\Backup\VSC-MMX\"

    If((Test-Path $global:main)-eq $false){
        Write-Host " "
        Write-host "Creating folder with the name $folderName."
        Write-host " "
        New-Item -path $location -Name $folderName -ItemType Directory
        Start-Sleep 2
        Write-LogLine "Folder $folderName created."
        Write-Host ("`n" + "Folder $folderName created.")
        Write-host " "
        # sleep timer for user to see outpute
        Start-sleep -Seconds 4
    } else {
        Write-LogLine "Folder naam bestaat al"
    }
    } catch{

        $msg = "STOP The application has caught an error"
            Write-LogLine " "
            Write-LogLine "## DEBUG ## + `n"
            Write-LogLine ($msg + "`n")
            Write-LogLine $_.Exception.Message
            Write-Host "Open Log file to see Error message"
            Write-LogLine (`n + "## DEBUG END ##")
            Write-logoutput
            pause
            $global:returncode = 1;

    }

}
#TODO backupToFolder
function backupToFolder {
    try{
    Write-Host " "
    Write-host "Creating a SQL backup with the name $fileName.bak"
    Write-host " "
    Backup-SqlDatabase -ServerInstance "localhost\sqlexpress" -Database "VerkerkVSS" -BackupFile $global:sqlBackup
    Start-Sleep 2
    Write-LogLine "SQL backup $fileName.bak is created."
    Write-Host ("`n" + "SQL backup $fileName.bak is created.")
    Write-Host " "
    # sleep timer for user to see outpute
    Start-sleep -Seconds 4
    } catch {
        $msg = "STOP The application has caught an error"
        Write-LogLine " "
        Write-LogLine "## DEBUG ## + `n"
        Write-LogLine ($msg + "`n")
        Write-LogLine $_.Exception.Message
        Write-Host "Open Log file to see Error message"
        Write-LogLine (`n + "## DEBUG END ##")
        Write-logoutput
        pause
        $global:returncode = 1;
    }
}
#TODO ZipFile
function zipFile{
    try {
    Write-LogLine "Creating Zip File"
    Write-Host "Creating Zip File"
    Compress-Archive -Path $global:main  -DestinationPath $global:zipMe -Force
    Write-LogLine "File ready for download."
    Write-Host "File ready for download."
    } catch {
        $msg = "STOP The application has caught an error"
            Write-LogLine " "
            Write-LogLine "## DEBUG ## + `n"
            Write-LogLine ($msg + "`n")
            Write-LogLine $_.Exception.Message
            Write-Host "Open Log file to see Error message"
            Write-LogLine (`n + "## DEBUG END ##")
            Write-logoutput
            pause
            $global:returncode = 1;
    }
}

#--------------------(Main)-----------------------------------------------------------------------------
Set-logInit("Create a SQL backup zip _")
Write-LogLine("$(get-date) Create a SQL Backup zip file ")
Write-Version $version
Write-Version $space
#--------------------------------------
#TODO run
backupZipFolder
start-sleep -Seconds 2
backupToFolder
#Start-Sleep -Seconds 2
#zipFile
pause

Write-logoutput
return  $global:returncode
