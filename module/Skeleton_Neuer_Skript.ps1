
<#
______________________________________________________________________________________________________________________

	(c) HERMES Systeme GmbH                             Telefon: +49 (0) 4431 9360-0
        MSR & Automatisierungstechnik                   Telefax: +49 (0) 4431 9360-60
        Visbeker Str. 55                                E-Mail: info@hermes-systeme.de
        27793 Wildeshausen                              Home: www.hermes-systeme.de
______________________________________________________________________________________________________________________
#>
$Funktion = 'Skeleton.ps1'

<#  
______________________________________________________________________________________________________________________
    
    			Version  	Datum           Author        Beschreibung
    			-------  	----------      -----------   -----------
    			V1.0     	20.02.2020      Vitaly Ruhl   Erstellungsversion 
				V1.1     	12.03.2020      Vitaly Ruhl   Erweitert, aufgeräumt
#>
$Version = 'V2.0.0' #	26.03.2021		Vitaly Ruhl		Bereinigen und Versionierung als Variablen
<#		

______________________________________________________________________________________________________________________
    Funktionsbeschreibung:
    Grundgerüst mit wichtigsten Funktionen
______________________________________________________________________________________________________________________
#>


#**********************************************************************************************************************
# Einstellungen
$AdminRightsRequired = $false # wenn dieser Skript die Adminrechte benötigt auf $true setzen
#**********************************************************************************************************************

#**********************************************************************************************************************
# Debug Einstellungen
$global:DebugPrefix = $Funktion + ' ' + $Version + ' -> ' #Variable für Debug-log vorbelegen
$global:Modul = 'Main' #Variable für Debug-log vorbelegen
$global:debug = $false # $true $false
$ErrorActionPreference = "Continue" #Fehlerbehandlung im Skript - Bei Fehler einfach mal weitergehen, aber Fehler ausgeben....(Möglich:Ignore,SilentlyContinue,Continue,Stop,Inquire) 
#**********************************************************************************************************************


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Div Funktionen
#region begin Diverse
#nicht benötigte wegen Performance entfernen....
function whr ()	{ Write-Host "`r`n`r`n" }
	
function trenn ($text) {
	Write-Host "`r`n-----------------------------------------------------------------------------------------------"
	Write-Host " $text"
	Write-Host "`r`n"
}
	
function trennY ($text) {
	Write-Host "`r`n-----------------------------------------------------------------------------------------------" -ForegroundColor Yellow
	Write-Host " $text" -ForegroundColor Yellow
	Write-Host "`r`n"
}
	
function log ($text) {
	if ($global:debug) {
		Write-Host "$global:DebugPrefix $global:Modul -> $text" -ForegroundColor DarkGray
	}		
}
	
function Get-ScriptDirectory() {
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-ScriptDirectory'
	try {
		$Invocation = (Get-Variable MyInvocation -Scope 1).Value
		Split-Path $Invocation.MyCommand.Path
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
}

function  Packe($Was, $Wohin) {
	<#
			#Beispiel...
			$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
			 
		Write-Host ""
		Write-Host ""
		Write-Host '------------------------------------------------------------------------------------------'
		Write-Host ""
		$SicherungsGrundPfad = (get-item $InstallPath ).parent.FullName
		$Projekt = (get-item $InstallPath ).Name
		$zd = $SicherungsGrundPfad + '\' + $Projekt + '_' + $Datum + '.zip'
		Write-Host "Dateien Packen: [$InstallPath]...."
		Write-Host "bitte Warten.... je nach Gr��e dauert etwas..." -ForegroundColor Yellow
		Write-Host "Projekt: $Projekt"
		Write-Host "Nach: $zd"
		Write-Host '------------------------------------------------------------------------------------------'
		Packe "$InstallPath" "$zd"
		Write-Host '------------------------------------------------------------------------------------------'
		#>

	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Packe'
	trennY 'Archiviere ... (je nach größe dauert etwas)'
	try {
		#Add-Type -AssemblyName System.IO.Compression.FileSystem
		#$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
		#[System.IO.Compression.ZipFile]::CreateFromDirectory($Was, $Wohin, $compressionLevel, $True)    

		if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" } 
		set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
		sz a -mx=9 "$Wohin" "$Was"
		Write-Host 'ohne fehler fertig...'
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
}

function Add-Path($MyPath) {
 #Prüft, ob der Pfad vorhanden ist, sonnst erstellt einen neuen.....
	<#
			Beispiel: 
			$Pfad="$env:TEMP\PS_Skript"
			Add-Path($Pfad)
	#>
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Add-Path'

	try {
		
		if (!(Test-Path -path $MyPath -ErrorAction SilentlyContinue )) {
			# Pfad anlegen wenn nicht vorhanden
			if (!(Test-Path -Path $MyPath)) {
				New-Item -Path $MyPath -ItemType Directory -ErrorAction SilentlyContinue # | Out-Null
			}      
		}

	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
}

function start-countdown ($sleepintervalsec) {
	<#
			#Beispiel...
			start-countdown 60
		#>
	$ec = 0
	foreach ($step in (1..$sleepintervalsec)) {
		try {
			if ([console]::KeyAvailable) {
				$key = [system.console]::readkey($true)
				if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
					Write-Warning "CTRL-C gedrückt" 
					return
				}
				else {
					Write-Host "Taste gedrückt [$($key.keychar)]"
					pause
					return
				}
			}
		}
		catch {
			if ($ec -eq 0) {
				Write-Warning "Start in der ISE - keine Consolenabfage Möglich..."
				$ec++
			}
		}
		finally {
			$rest = $sleepintervalsec - $step
			write-progress -Activity "Warten" -Status "das Fenster geht in $rest Sek. zu..." -SecondsRemaining ($rest) -PercentComplete  ($step / $sleepintervalsec * 100)
			start-sleep -seconds 1
		}
	}
}
	
function MsgBox($Title, $msg, $Typ, $Aussehen) {
		
	<# Beispiel:
            $test = MsgBox  "test tittel"  "Test text" 0 5 
        #>

	<#
		Types of Messageboxes sind bereits fesgelegt	
		0:	OK
		1:	OK Cancel
		2:	Abort Retry Ignore
		3:	Yes No Cancel
		4:	Yes No
		5:	Retry Cancel
		
		#Festlegen von AussehenTypen - viele sind seit Win 10 1909 gleich geworden...
			Symbol			Icon	                englische Bezeichnung
			0				kein Symbol				None
			1				(i)				        Information
			2				(?)					    Question
			3				Fehler (X)			    Error
			4				Ausruf /!\		        Exclamation
			5				(i)		                Asterisk
			6				Hand (X)			    Hand
			7				Stopp (X)			    Stop
			8				Warnung /!\		        Warning
		#>
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'MsgBox'
	try {
		log "parameter übergeben ([$Title], [$msg], [$Typ],[$Aussehen])"
		switch ($Aussehen) {
			0 { $result = [System.Windows.MessageBox]::show($msg, $Title, $Typ) }
			1 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Information) }
			2 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Question) }
			3 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Error) }
			4 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Exclamation) }
			5 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Asterisk) }
			6 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Hand) }
			7 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Stop) }
			8 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Warning) }
			9 { $result = [System.Windows.Forms.MessageBox]::show($msg, $Title, $Typ, [System.Windows.Forms.MessageBoxIcon]::Exclamation -band [System.Windows.Forms.MessageBoxIcon]::SystemModal) }
		}		
		log "Function Sceleton execute" 
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $result
}

function Get-UserInput($title, $msg, $Vorbelegung) {
	<# Beispiel:
		$test = get-UserInput  "test tittel"  "192.168.2.250" 0
	#>

	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-UserInput'
	try {
		log "Parameter übergeben ([$Title], [$msg], [$Vorbelegung])"
		[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
		$inp = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $Vorbelegung, 5)
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $inp
}

function Get-FileDialog($InitialDirectory, [switch]$AllowMultiSelect) {
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-FileDialog'
	try {
		Add-Type -AssemblyName System.Windows.Forms
		$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
		$openFileDialog.initialDirectory = $InitialDirectory
		$openFileDialog.filter = "All files (*.*)| *.*"
		if ($AllowMultiSelect) { 
			$openFileDialog.MultiSelect = $true 
		}
		$openFileDialog.ShowDialog() > $null
		if ($allowMultiSelect) { 
			$global:Modul = $tempModul #altes Modul wiederherstellen	
			return $openFileDialog.Filenames 
		} 
		else { 
			$global:Modul = $tempModul #altes Modul wiederherstellen	
			return $openFileDialog.Filename 
		}
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
}

function  Get-FolderDialog([string]$InitialDirectory) {
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-FolderDialog'
	try {
		Add-Type -AssemblyName System.Windows.Forms
		$openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
		$openFolderDialog.ShowNewFolderButton = $true
		$openFolderDialog.RootFolder = $InitialDirectory
		$openFolderDialog.ShowDialog()
	
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $openFolderDialog.SelectedPath
}

function Get-SkriptAbbruch() {
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-SkriptAbbruch'
	try {
		if ([console]::KeyAvailable) {
			$key = [system.console]::readkey($true)
			if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
				log "CTRL-C gedrückt" 
				$global:Modul = $tempModul #altes Modul wiederherstellen
				return $($key.keychar)
			}
			else {
				log "Taste gedrückt [$($key.keychar)]"
			}
		}	
	}
	catch { Write-Warning "$global:Modul - Start in der ISE - keine Consolenabfage Möglich..." }	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
}
#endregion




#region begin SQL
#**********************************************************************************************************************
#**********************************************************************************************************************
#Folgende Funktionen benötigen SQL-Modul...
<#
		Write-Host '------------------------------------------------------------------------------------------'
		Write-Host " --> Modul für SQL-Server-Verwaltung und direkten Zugriff auf die Tabellen installieren..."
		Write-Host ""
		#install-module sqlps; #das ist die alte Version... falls die installiert ist muss die neue mit "-AllowClobber" ausgeführt werden!
		install-module SqlServer -AllowClobber
		import-module SqlServer
		Write-Host ""
		Write-Host "--> SQL-Modul Ende <--"
		Write-Host '------------------------------------------------------------------------------------------'
	#>


function Get-DBList ($mserver) {
	#Rückgabe der Datenbanken im Server
	<#
			   #Beispiel...
			   $PC          = $env:computername
			   $Instance    = "SQLHERMES"
			   Get-DBList "$PC\$Instance" 
		   #>
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Get-DBList'
	try {
		$srv = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $mserver
		$tt = $srv.Databases | Select-Object -ExpandProperty name #, RecoveryModel, 
		log $tt
		$global:Modul = $tempModul #altes Modul wiederherstellen
		return $tt
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 

	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return ''
}

function Backup-SQLDB($serverName, $backupDirectory, $daysToStoreBackups) {
	<#
			#Beispiel...
			$PC          = $env:computername
			$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
			$Instance    = "SQLHERMES"
			$SicherungenAbloeschenNachTagen=10
			Backup-SQLDB "$PC\$Instance"  $InstallPath $SicherungenAbloeschenNachTagen
	#>

	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Backup-SQLDB'
	try {
		
		Write-Host "...................................................................................................................."
		Write-Host "Server: [$serverName]"
		Write-Host "Backup Dir: [$backupDirectory]"
		#Write-Host "ablöschen nach: [$daysToStoreBackups] Tag(en)"
		Write-Host "...................................................................................................................."
	
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
		[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

		$server = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $serverName
		$dbs = $server.Databases	
				
		$timestamp = Get-Date -format yyyy.MM.dd-HHmm
		foreach ($database in $dbs | Write-Hostere-Object { $_.IsSystemObject -eq $False }) {
			$dbName = $database.Name
				
			$targetPath = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"
			$targetPath = $backupDirectory + "\" + $dbName + ".bak"
			Write-Host "DB:[$dbName] --> zu Datei:[$targetPath]"
				
			$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
			$smoBackup.Action = "Database"
			$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
			$smoBackup.BackupSetName = $dbName + " Backup"
			$smoBackup.Database = $dbName
			$smoBackup.MediaDescription = "Disk"
			$smoBackup.Devices.AddDevice($targetPath, "File")
			#$smoBackup.CompressionOption = 1
			$smoBackup.SqlBackup($server)

			Write-Host ".............................................................................................................................................................................."
			#Write-Host "entferne Sicherungen älter als $daysToStoreBackups Tage..." 
			#Get-ChildItem "$backupDirectory\*.bak" |? { $_.lastwritetime -le (Get-Date).AddDays(-$daysToStoreBackups)} |% {Remove-Item $_ -force }     

		}
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
		$global:Modul = $tempModul #altes Modul wiederherstellen	
		return $false
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $true
}

function Remove-SqlDataFromCSV ($CSV_File, $ServerInstanz, $Trennzeichen) {
	#Auch als Beispiel für Laden einer CSV-Datei
	<#
			   #Beispiel...
			   $InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
			   $Instance   = "SQLHERMES"
			   $Tabelle 	= "HerObjMAParameter"
			   $Import_File = "HerMAParameter.txt"
			   Remove-SqlDataFromCSV "$InstallPath\$Import_File" "$PC\$Instance"
		   #>
   
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Sceleton'
	try {
		
		Write-Host "...................................................................................................................."
		Write-Host "Server-Instanz : [$ServerInstanz]"
		Write-Host "CSV-File       : [$CSV_File]"
		Write-Host "...................................................................................................................."

		Write-Host "Die CSV komplett ins Speicher laden..."
		$CcvData = Import-CSV $CSV_File -Delimiter "$Trennzeichen"

		Write-Host ""
		Write-Host "vorhandene Eintnräge ablöschen...."

		ForEach ($Line in $CcvData) {
			$MID = $Line.MAID  
			$Q = "DELETE FROM $Datenbank.dbo.$Tabelle Write-HostERE MAID = $MID"
			Invoke-Sqlcmd -Query $Q -ServerInstance $ServerInstanz
			log $Q
		}
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
		$global:Modul = $tempModul #altes Modul wiederherstellen	
		return $false
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $true
}

#SQL-Modul...
#**********************************************************************************************************************
#**********************************************************************************************************************
#endregion
# Div Funktionen
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


function leereFunction() {
	<#
		Infos zum Modul:

	#>
	$tempModul = $global:Modul # Vortext zwischenspeichern
	$global:Modul = 'Sceleton'
	try {
		log "Function Sceleton execute" 
		$global:Modul = $tempModul #altes Modul wiederherstellen	
		return $true
	}
	catch { 
		Write-Warning "$global:Modul -  Etwas ist schief gegangen" 
		$global:Modul = $tempModul #altes Modul wiederherstellen	
		return $false
	}	
	$global:Modul = $tempModul #altes Modul wiederherstellen	
	return $true
}



#**********************************************************************************************************************
#**********************************************************************************************************************
# 									Hauptprogramm

$global:Modul = 'Main'
if ($global:debug) {
	Clear-Host
	whr
	log "entry debug ist an..."
}

#region begin AdminRechteAnfordern
if ($AdminRightsRequired) {
	#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
	trenn "Admin-Rechte anfordern..."
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

$global:Modul = 'Input-Test-Bereich:'
trenny " Input - Test "
$test = get-UserInput  "test tittel"  "Zum Beispiel 192.168.2.250" "192.168.2.250"
Write-Host "vom Inputdialog zurückgegebener Wert: $test"

$global:Modul = 'ENV'
trenny "ENV-Test"
$PC = $env:computername #Aktuellen PC-Namen ermitteln

$datum = Get-Date -Format yyyy.MM.dd_HHmm
$DTminusEinMonat = (get-date).AddDays(-30).ToString("yyy.MM.dd") #die letzten 30 Tage ausrechnen
$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
$SicherungsGrundPfad = (get-item $InstallPath ).parent.FullName #Verzeichnissname wo dieser Skript liegt (eine Ebene zurück)
$Projekt = (get-item $InstallPath ).Name #nur Verzeichnissname

$ausgabe = @(	
			 @{Name= "Rechner:"; 			Value= "[$PC]"}
			,@{Name= "Datum/Zeit:";			Value= "[$datum]"}
			,@{Name= "Dazum vor 30 Tage:";	Value= "[$DTminusEinMonat]"}
			,@{Name= "Verzeichnis:";		Value= "[$Projekt]"}
)
$ausgabe | ForEach-Object {[PSCustomObject]$_} | Format-Table -Property Name, Value -AutoSize

write-host "`r`nAls Nächstes der Skriptpfad und eine Ebene zurück:`r`n`r`nSkriptpfad:[$InstallPath]`r`nParent:[$SicherungsGrundPfad]"

$global:Modul = 'Ende'
if ($global:debug) {
	whr
	log "ende erreicht!"
}

log "ende erreicht!"
trenn 'Skript ausgefuehrt!'
Write-Warning 'Wenn nichts rot, dann alles ok ;-)'#-ForegroundColor Green

#start-countdown 30
#pause

<##**********************************************************************************************************************
	#Div. Infos
	C:\Windows\System32\WindowsPowerShell\v1.0
	
	Erlaubte Verben:
	https://docs.microsoft.com/de-de/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.1
	
	psexec.exe \\192.168.1.10 -u "domain\administrator" -p "password" cmd
	set-executionpolicy remotesigned
	Get-ExecutionPolicy -list |% {Set-ExecutionPolicy -scope $_.scope remotesigned -force -ErrorAction SilentlyContinue} #in allen scopes durchlaufen
	-ErrorAction SilentlyContinue
	-ForegroundColor Yellow
	powershell.exe -NoLogo -NoProfile -Command 'Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber'
#>

<#
if ($global:debug) {
	Clear-Host
    whr
    log "entry"
    
    $global:Modul = 'ENV'
    sectiony "ENV-Test"
    $PC = $env:computername
	
    $datum = Get-Date -Format yyyy.MM.dd_HHmm
    $DTminusEinMonat = (get-date).AddDays(-30).ToString("yyy.MM.dd") 
    $ScriptPath = Get-ScriptDirectory 
    $ParentPath = (get-item $ScriptPath ).parent.FullName #Verzeichnissname wo dieser Skript liegt (eine Ebene zurück)
    $Projekt = (get-item $ScriptPath ).Name #nur Verzeichnissname
    
	
    write-host "`r`n"
    $ausgabe = @(	
		@{Name = "Hostname:";               Value = "[$PC]" }
        , @{Name = "Date/Time:";            Value = "[$datum]" }
        , @{Name = "Date -30 days:";	    Value = "[$DTminusEinMonat]" }
        , @{Name = "Script Pathfragment:";  Value = "[$Projekt]" }
        , @{Name = "Complete Path:";        Value = "[$ScriptPath]" }
        , @{Name = "Parent Path:";          Value = "[$ParentPath]" }
		)
		$ausgabe | ForEach-Object { [PSCustomObject]$_ } | Format-Table -Property Name, Value -AutoSize
	}
	
#>


#https://www.windowspro.de/script/json-powershell-erzeugen-bearbeiten
# $h = [ordered]@{M = 1; N = [ordered]@{}; A = @("Schwarz", "Weiß"); O = 2 }
# 
# $h.N.N1 = 1.1
# $h.N.N2 = 1.2
# 
# $h | ConvertTo-Json


<#
[-BackgroundColor {Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | Write-Hostite}]
[-ForegroundColor {Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | Write-Hostite}]
#>

<#
	$TageZL = 30*2;#2 Monate
	$DatumVorXTagen = (Get-Date).AddDays($TageZL * -1)
	get-childitem "$Source" | Write-Hostere {$_.mode -match "d" -and $_.LastWriteTime -lt $DatumVorXTagen}| remove-item -Recurse -force -verbose # nur Ordner
	#get-childitem "$Source" | Write-Hostere {$_.lastwritetime -lt $DatumVorXTagen -and -not $_.psiscontainer} |% {remove-item $_.fullname -force -verbose} #ohne Ordner
	$_.LastWriteTime
	$_.Length
#>

<#
	$TransScriptPrefix = "ClearOldFiles_Dateien_" + $TageZL + "_Tage_"
	start-transcript "$Source\$TransScriptPrefix$(get-date -format yyyy.MM).txt"
	... code
	
	Stop-Transcript
#>

<# anstatt ls oder dir kann mann gci benutzen --> har mehr Möglichkeiten 
	gci -r -force -include *.tmp -ErrorAction SilentlyContinue $env:USERPROFILE #alle Tempdateien ab den Skriptordner auflisten -> kann an remove-item übergeben werden....
#>

<# Eventlog
	#Einen Benutzerdefinirten Eventlog erstellen (Vorher prüfen, ob der bereits existiert, sonnst komt ein Fehler - unschön)
		if ($s=Get-WinEvent -ListLog HERMES -ErrorAction SilentlyContinue) { if ($debug) {Write-Host "eventlog existiert bereits"}} else {New-EventLog -Source "HERMES" -LogName "HERMES"} 
	
	# Event-Eintrag senden	
		Write-EventLog -LogName 'HERMES' -Source 'HERMES' -EventID 1111 -EntryType Information -Message "Registryeinträge für einen Fake -WSUS angelegt"
		Write-EventLog -LogName 'HERMES' -Source 'HERMES' -EventID 1111 -EntryType Error -Message $errText		
#>

<# Reristry einträge
	New-ItemProperty "hklm:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "UseWUServer" -Value 1 -PropertyType "DWord" 
	New-ItemProperty "hklm:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate"    -Name "WUServer"    -Value "https://fakename.fake:8531" -PropertyType "String"
#>

<# Fehlerbehandlung:	
	try 
	{
		
	} 
	catch 
	{
		$errText = "Windowsaufgabe '$NewTaskName' --> Anlegen der Aufgabe Fehlgeschlagen! `r`n Fehler: $Error `r`n"
        if ($debug) {Write-Host $errText}
	} 
	finally 
	{
	
	}
	
	#$error | %{$_ | select CategoryInfo, Exception | fl}
	#$error.Count
#>


<# Aufgabenplaner:	
	#Enstellungen...
		$NewTaskName = "No-Win10-Updates"
		$username = "$env:USERDOMAIN\$env:USERNAME" #derzeitigen Benutzer auslesen
		$cred = Get-Credential $username #über die Windows-Net-Security-Funktion das Passwort erfragen
		$Password = $cred.GetNetworkCredential().Password #Das Passwort im Klartext zwischenspeichern
	
	#Aufgabe konfigurieren...
		$trig    = New-ScheduledTaskTrigger -Once -At (date) -RepetitionDuration  (New-TimeSpan -Days 1)  -RepetitionInterval  (New-TimeSpan -Minutes 1) #Trigger: jeden Tag jede Minute ausf�hren
		$action  = New-ScheduledTaskAction -WorkingDirectory $env:TEMP -Execute $env:SystemRoot\System32\WindowsPowerShell\v1.0\powershell.exe -Argument "-Command '$InstallPath\Windows_Updates_Deaktivieren.ps1'"
		$conf    = New-ScheduledTaskSettingsSet -RunOnlyIfIdle -WakeToRun 
		$STPrincipal = New-ScheduledTaskPrincipal -RunLevel Highest -User $username #-Password $Password #Hier kann leider nur Passwort per Klartext übergeben werden. Netzwerk Prinzipale werden nicht �nterst�tzt
		$MyTask =  New-ScheduledTask -Action $action -Settings $conf -Trigger $trig -Principal $STPrincipal 
		Register-ScheduledTask $NewTaskName -TaskPath "\HERMES" -InputObject $MyTask -User $username -Password $Password -Force #Aufgabe "Erstellen"
	
	#nochmal anzeigen	
	if ($debug) {Get-ScheduledTask | ? TaskName -eq $NewTaskName }	

	#weitere....
		$trig = New-ScheduledTaskTrigger -weekly -At 21:00 -DaysOfWeek @("Monday","Friday")
		Bei Bedarf kann man den Befehl mit dem Parameter CimSession auch auf einen Remote-PC anwenden.
#>


<#----------------------------
	for ($i=1; $i -le 10; $i++) {$i,"`n"}
#>


<#----------------------------
	Write-Hostile(($inp = Read-Host -Prompt "Wählen Sie einen Befehl") -ne "Q")
	{
		switch($inp)
		{
			L {Write-Host "Datei wird gelöscht"}
			A {Write-Host "Datei wird angezeigt"}
			R {Write-Host "Datei erhält Schreibschutz"}
			Q {Write-Host "Ende"}
			default {Write-Host "Ungültige Eingabe"}
		}
	}
#>


<#----------------------------
	$user = Get-ADUser -Filter *
	foreach($u in $user) 
	{
		$u.surname
	}

	(Get-ADUser -Filter *).Surname #macht das selbe - Ausgabe wegen ()
#>



<#----------------------------
	Function MsgBoxGlbl ($Title, $Text)
	{
		[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
		$responseA=[System.Windows.Forms.MessageBox]::Show($Text, $Title, 4)
		Set-Variable -Name _ResponseA ($responseA) -Scope "Global"
	}
#>


#**********************************************************************************************************************
<##Interesantes!!!!

	#... hier USBs die eingesteckt werden erkennen und auf erlaubnis prüfen...
		https://social.technet.microsoft.com/Forums/de-DE/4689e5e5-b445-4f95-8ac3-896ea9886045/skript-lsst-sich-in-ise-aber-nicht-ber-powershell-oder-batch-ausfhren?forum=powershell_de
	
	#Fehlerbehandlung - falls ein Skript partu nicht laufen will
		https://disziplean.de/powershell-leerzeichen-startet-nicht-verknuepfung-parameter/
#>



















