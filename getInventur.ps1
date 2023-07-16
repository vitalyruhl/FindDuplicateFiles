
# C:\Windows\System32\WindowsPowerShell\v1.0

<#______________________________________________________________________________________________________________________

	(c) Vitaly Ruhl 2021-2022
    Homepage: Vitaly-Ruhl.de
    Github:https://github.com/vitalyruhl/
    License: GNU General Public License v3.0
______________________________________________________________________________________________________________________#>
#>

$Funktion = 'get-inventur.ps1'

<#  
______________________________________________________________________________________________________________________    
    		Version  	Datum           Author        Beschreibung
    		-------  	----------      -----------   -----------
#>
$Version = 'V1.0.0' #	26.03.2021		Vitaly Ruhl		init
$Version = 'V1.0.1' #	02.04.2021		Vitaly Ruhl		add deleteng script
$Version = 'V1.0.2' #	03.04.2021		Vitaly Ruhl		init publish

<#		
______________________________________________________________________________________________________________________
    Function:
    Find duplicate Files - Step 1 from 3
    get all files in selected folder recursiv in CSV with MD5 hash
______________________________________________________________________________________________________________________
#>

#**********************************************************************************************************************	
# Imports	
. .\module\recentlyUsedFunctions.ps1 #Import some Functions
#**********************************************************************************************************************

#**********************************************************************************************************************
# Settings
SetDebugState($false) #activate some debug informations
$AdminRightsRequired = $false #set $true, if Admin-Rights are for the Script reqired
#**********************************************************************************************************************

$global:Modul = 'Main'
Clear-Host


#region begin Request admin rights
if ($AdminRightsRequired) {
	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	##https://www.heise.de/ct/hotline/PowerShell-Skript-mit-Admin-Rechten-1045393.html
	$identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$princ = New-Object System.Security.Principal.WindowsPrincipal($identity)
	if (!$princ.IsInRole([System.Security.Principal.WindowsBuiltInRole]::Administrator)) {
		$powershell = [System.Diagnostics.Process]::GetCurrentProcess()
		$psi = New-Object System.Diagnostics.ProcessStartInfo $powerShell.Path
		$script = $MyInvocation.MyCommand.Path
		$prm = $script
		foreach ($a in $args) {
			$prm += ' ' + $a
		}
		$psi.Arguments = $prm
		$psi.Verb = "runas"
		[System.Diagnostics.Process]::Start($psi) | Out-Null
		return;
	}
	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
}
#endregion



if ($global:debug) {
    #Clear-Host
    whr
    log "entry"
    
    $global:Modul = 'ENV'
    sectiony "ENV-Test"
    $PC = $env:computername

    $datum = Get-Date -Format yyyy.MM.dd_HHmm
    #$DTminusEinMonat = (get-date).AddDays(-30).ToString("yyy.MM.dd") 
    $ScriptPath = Get-ScriptDirectory 
    $ParentPath = (get-item $ScriptPath ).parent.FullName #Verzeichnissname wo dieser Skript liegt (eine Ebene zurück)
    $Projekt = (get-item $ScriptPath ).Name #nur Verzeichnissname
    

    write-host "`r`n"
    $ausgabe = @(	
        @{Name = "Hostname:";               Value = "[$PC]" }
        , @{Name = "Date/Time:";            Value = "[$datum]" }
        #, @{Name = "Date -30 days:";	    Value = "[$DTminusEinMonat]" }
        , @{Name = "Script Pathfragment:";  Value = "[$Projekt]" }
        , @{Name = "Complete Path:";        Value = "[$ScriptPath]" }
        , @{Name = "Parent Path:";          Value = "[$ParentPath]" }
    )
    $ausgabe | ForEach-Object { [PSCustomObject]$_ } | Format-Table -Property Name, Value -AutoSize
}

#region get all files recursivly
    SetDebugState($false)
    Write-debug "`r`n`r`n------------------------------------------------------`r`n"
    Write-debug 'get all files recursivly'

    $SD = Get-ScriptDirectory
    $SerchPath = Get-FolderDialog ("$SD")

    if ($SerchPath -eq "-CANCEL-"){
        Write-Warning "No Folder selected - Exit Script"
        exit
    }
    elseif ($SerchPath -eq "-ERROR-") {
        Write-Error "Error in Get-Folder-Dialog - Exit Script"
        exit
    }

    #$SerchPath | Get-Member
    Write-Host "Searching, please wait..."
    $FilesObject = Get-ChildItem $SerchPath -Recurse -exclude xvba_debug.log #bugfix crashes on own debug-files -> add -exclude xvba_debug.log
    $FilesObject.FullName | Write-debug 
#endregion

#region set-propertys
    SetDebugState($false)
    Write-debug "`r`n`r`n------------------------------------------------------`r`n"
    Write-debug 'set-propertys'

    $erg = $FilesObject  | foreach-object { 
        if ($_ -is [System.IO.DirectoryInfo]){
            # is a directory and haven't a Hash
            Add-Member -InputObject $_ -MemberType NoteProperty -Name 'isFolder' -Value ($true)
            Add-Member -InputObject $_ -MemberType NoteProperty -Name 'MD5Hash' -Value '-'
        }
        else {
            Add-Member -InputObject $_ -MemberType NoteProperty -Name 'isFolder' -Value ($false)
            $FileHash = Get-FileHash $_.fullname -Algorithm MD5
            Add-Member -InputObject $_ -MemberType NoteProperty -Name 'MD5Hash' -Value ($FileHash.Hash)
        }
    } 
    Write-debug 'done'
    $erg += "" #disable warning fo unused variable
#endregion

#region Create CSV Object
    SetDebugState($false)
    Write-debug "`r`n`r`n------------------------------------------------------`r`n"
    Write-debug 'Create CSV Object:'
    $csv = $FilesObject | Select-Object -Property isFolder, MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime # | Write-debug |Format-Table

    if ($csv.Length -eq 0){
        sectionY "Sorry no files found! - exit Script" 
        If (Test-Path .\All-Files-With-Hashes.csv) {
            Remove-Item .\All-Files-With-Hashes.csv -force
        }
        exit
    }
    else {
        sectionY "Some Files found!" 
        $csv | Write-debug | Format-Table

        #region Export as CSV
            SetDebugState($false)
            Write-debug "`r`n`r`n------------------------------------------------------`r`n"
            Write-debug 'Export as CSV'
            $csv | Export-Csv -Path .\All-Files-With-Hashes.csv -Force
            Write-debug 'done'
        #endregion
    }
#endregion

#region Select duplicates
    SetDebugState($false)
    Write-debug "`r`n`r`n------------------------------------------------------`r`n"
    Write-debug 'Select duplicates'

    $Dupcsv = $csv | Where-Object{$_.isFolder -eq $False} | Select-Object -Property MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime 
    $Dupcsv = $Dupcsv | Group-Object MD5Hash | Where-Object{$_.count -gt 1} | ForEach-Object{$_.Group}
    if ($Dupcsv.Length -eq 0){
        sectionY "Geat! No Duplicate Files found!" 
        If (Test-Path .\All-Duplicate-Files.csv) {
            Remove-Item .\All-Duplicate-Files.csv -force
        }
        
    }
    else {
        sectionY "Duplicate Files found!" 
        $Dupcsv | Write-Host | Format-Table

        #region Select duplicates export as CSV
        SetDebugState($false)
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Select duplicates export as CSV'

        $Dupcsv | Add-Member -MemberType NoteProperty -Name 'MarkToDelete' -Value ($false)

        Write-Host 'See for more information the file "All-Duplicate-Files.csv"' -ForegroundColor Green
        Write-Host 'in security reason you need to mark the files to delete manualy in the CSV! - Set it to "TRUE"' -ForegroundColor red
        $Dupcsv | Export-Csv -Path .\All-Duplicate-Files.csv -Force

        Write-debug 'done'
        #endregion

    }
#endregion

#$FilesObject | ConvertTo-Json
    Write-Host "`r`n`r`n"
    Write-Warning "------------------------------------------------------`r`n"
    Write-Warning 'Skript is done!'
    Write-Host 'All Files are Scanned with MD5-Hash. Your find more information the file "All-Files-With-Hashes.csv"' -ForegroundColor Green
    Write-Warning 'When you dont see any red than is all fine ;-)'#-ForegroundColor Green

#start-countdown 30
#pause



