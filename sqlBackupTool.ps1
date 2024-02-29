<#
.SYNOPSIS
    Name: sqlBackupTool.ps1
            
.NOTES
    Updated: xx-xx-20xx
    Release Date: 28-02-2024
    Author: Jordy Scheers     
    LICENCE: MIT

.NOTES
    ## DEBUG ##
    
####################################
#>
#-----------------[Date ]-------------------------------------------------------------------------------
$date = Get-Date -Format "dd-MM-yyyy"
#----------------[ LogFile_Module ]----------------------------------------------------
try {
function set-LogLineHeader($string) {
    $global:msg_header = $string
}

function Set-LogInit($Prefix) {
    $time = Get-Date -Format "dd-MM-yyyy HHmmss"
    $logDir = New-Item -Path "C:\Logs\" -Name "Tools" -ItemType "directory" -Force
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
} catch {
    $msg = "STOP The application has caught an error"
            Write-LogLine " "
            Write-LogLine ("## DEBUG ##" + "`n")
            Write-LogLine ($msg + "`n")
            Write-LogLine $_.Exception.Message
            Write-Host "Open Log file to see Error message"
            Write-LogLine ("`n" + "## DEBUG END ##")
            Write-logoutput
    }
#----------------[Version]-------------------------------------------------------------
$version = "Version: 1.3.6"
$space = "---------------------------------"
#----------------[Pre text]-----------------------------------------------------------------------------
Write-Host "##########################################################################"
Write-Host "Welkom bij de SQL Backup Tool $version.                            #"                                 
Write-Host "Met deze tool kan je gemakkelijk een SQL backup maken en exporteren.     #"
Write-Host "Kies een bestaand Locatie path voor het exporteren  bijv C:\Temp\        #"
Write-host "                                                                         #"
Write-host "                       ##DEBUG##                                         #"
Write-Host "BUG INFO: De zip functionaliteit functioneert nog niet!                  #"
Write-Host "##########################################################################"
Write-host "`n"
#----------------[ Global Default ]---------------------------------------------------------------------------
$global:returncode = 0 # VCB 0 = succes , 1 = failed
#----------------[ Global Vars ]---------------------------------------------------------------------------
$locatie = Read-Host "Locatie path"
$folderName = Read-Host "Foldername"
$fileName = Read-Host "Filename"
$global:main = "$locatie\$folderName"
$global:sqlBackup = "$locatie\$folderName\$fileName.bak"
$global:zipMe = "$locatie\$folderName.zip"
#-------------------(Function)-----------------------------------------------------------------------------
#TODO backupZipFolder
function backupZipFolder  {

    try {

    If((Test-Path $global:main)-eq $false){
        Write-Host " "
        Write-host "Creating folder with the name $folderName at locatie $locatie."
        Write-host " "
        New-Item -path $locatie -Name $folderName -ItemType Directory
        Start-Sleep 2
        Write-LogLine "Folder $folderName created at location $locatie."
        Write-Host ("`n" + "Folder $folderName created at location $locatie.")
        Write-host " "
        # sleep timer for user to see outpute
        Start-sleep -Seconds 4
    } else {
        Write-LogLine "Folder naam bestaat al"
    }
    } catch{

        $msg = "STOP The application has caught an error"
            Write-LogLine " "
            Write-LogLine ("## DEBUG ##" + "`n")
            Write-LogLine ($msg + "`n")
            Write-LogLine $_.Exception.Message
            Write-Host "Open Log file to see Error message"
            Write-LogLine ("`n" + "## DEBUG END ##")
            Write-logoutput
            pause

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
        Write-LogLine ("## DEBUG ##" + "`n")
        Write-LogLine ($msg + "`n")
        Write-LogLine $_.Exception.Message
        Write-Host "Open Log file to see Error message"
        Write-LogLine ("`n" + "## DEBUG END ##")
        Write-logoutput
        pause
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
            Write-LogLine ("## DEBUG ##" + "`n")
            Write-LogLine ($msg + "`n")
            Write-LogLine $_.Exception.Message
            Write-Host "Open Log file to see Error message"
            Write-LogLine ("`n" + "## DEBUG END ##")
            Write-logoutput
            pause
    }
}

#--------------------(Main)-----------------------------------------------------------------------------
Set-logInit("Create a SQL backup_")
Write-LogLine("$(get-date) Create a SQL Backup")
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
