
<#**********************************************************************************************************************

    #**********************************************************************************************************************
    #(c) HERMES Systeme GmbH                             Telefon: +49 (0) 4431 9360-0
    #    MSR & Automatisierungstechnik                   Telefax: +49 (0) 4431 9360-60
    #    Visbeker Str. 55                                E-Mail: info@hermes-systeme.de
    #    27793 Wildeshausen                              Home: www.hermes-systeme.de
    #______________________________________________________________________________________________________________________
    #
    #Funktion: Skeleton.ps1
    #______________________________________________________________________________________________________________________
    #
    #Version  Datum           Author        Beschreibung
    #-------  ----------      -----------   -----------
    #V1.0     20.02.2020      Vitaly Ruhl   Erstellungsversion 
	#V1.1     12.03.2020      Vitaly Ruhl   Erweitert, aufgeräumt
    #
    #Funktionsbeschreibung:
    #Grundgerüst mit wichtigsten Funktionen
    #**********************************************************************************************************************
    #>

#**********************************************************************************************************************
#Einstellungen
$ErrorActionPreference = "Continue" #Fehlerbehandlung im Skript - Bei Fehler einfach mal weitergehen, aber Fehler ausgeben....(Möglich:Ignore,SilentlyContinue,Continue,Stop,Inquire) 
Set-Alias wh Write-Host # mann ist ja Faul so kann man abkürzen.... wh "Hello World!" 
$debug = $false # $true $false
#**********************************************************************************************************************


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Div Funktionen
#region begin Diverse
#nicht benötigte wegen Performance entfernen....
function whr ()	{ Write-Host "`r`n`r`n" }
	
function trenn ($text) {
	whr #-ForegroundColor Yellow
	wh '-----------------------------------------------------------------------------------------------'# -ForegroundColor Yellow
	wh "      $text" #-ForegroundColor Yellow
	whr #-ForegroundColor Yellow
}
	
function trennY ($text) {
	whr -ForegroundColor Yellow
	wh '-----------------------------------------------------------------------------------------------' -ForegroundColor Yellow
	wh "      $text" -ForegroundColor Yellow
	whr -ForegroundColor Yellow
}
	
function log ($text)
	{
		if ($debug) {
			wh "(debug) - $text" -ForegroundColor Gray
		}
		
	}
	
function Get-ScriptDirectory { #Rückgabe vollständiger Pfad zum Skript
	<#
			#Beispiel...
			$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
		#>
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

function Packe($Was, $Wohin) {
	<#
			#Beispiel...
			$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
			 
		wh ""
		wh ""
		wh '------------------------------------------------------------------------------------------'
		wh ""
		$SicherungsGrundPfad = (get-item $InstallPath ).parent.FullName
		$Projekt = (get-item $InstallPath ).Name
		$zd = $SicherungsGrundPfad + '\' + $Projekt + '_' + $Datum + '.zip'
		wh "Dateien Packen: [$InstallPath]...."
		wh "bitte Warten.... je nach Gr��e dauert etwas..." -ForegroundColor Yellow
		wh "Projekt: $Projekt"
		wh "Nach: $zd"
		wh '------------------------------------------------------------------------------------------'
		Packe "$InstallPath" "$zd"
		wh '------------------------------------------------------------------------------------------'
		#>

	wh 'Archiviere ... (je nach gr��e dauert etwas)'
	#Add-Type -AssemblyName System.IO.Compression.FileSystem
	#$compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
	#[System.IO.Compression.ZipFile]::CreateFromDirectory($Was, $Wohin, $compressionLevel, $True)    

	if (-not (test-path "$env:ProgramFiles\7-Zip\7z.exe")) { throw "$env:ProgramFiles\7-Zip\7z.exe needed" } 
	set-alias sz "$env:ProgramFiles\7-Zip\7z.exe"  
	sz a -mx=9 "$Wohin" "$Was"
}

function Add-Path($MyPath) { #Prüft, ob der Pfad vorhanden ist, sonnst erstellt einen neuen.....
	<#
			Beispiel: 
			$Pfad="$env:TEMP\PS_Skript"
			Add-Path($Pfad)
		#>
	if (!(Test-Path -path $MyPath -ErrorAction SilentlyContinue )) {
		# Pfad anlegen wenn nicht vorhanden
		if (!(Test-Path -Path $MyPath)) {
			New-Item -Path $MyPath -ItemType Directory -ErrorAction SilentlyContinue # | Out-Null
		}      
	}
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
					wh "Taste gedrückt [$($key.keychar)]"
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
	wh "parameter übergeben ([$Title], [$msg], [$Typ],[$Aussehen])"
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
		
	return $result
}

function Get-UserInput($title, $msg, $Vorbelegung) {

	<# Beispiel:
			$test = get-UserInput  "test tittel"  "192.168.2.250" 0
		#>

	wh "parameter übergeben ([$Title], [$msg], [$Vorbelegung])"
	[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
	$inp = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $Vorbelegung, 5)
	return $inp
}

function Get-FileDialog($InitialDirectory, [switch]$AllowMultiSelect) {
	Add-Type -AssemblyName System.Windows.Forms
	$openFileDialog = New-Object System.Windows.Forms.OpenFileDialog
	$openFileDialog.initialDirectory = $InitialDirectory
	$openFileDialog.filter = "All files (*.*)| *.*"
	if ($AllowMultiSelect) { $openFileDialog.MultiSelect = $true }
	$openFileDialog.ShowDialog() > $null
	if ($allowMultiSelect) { return $openFileDialog.Filenames } else { return $openFileDialog.Filename }
}

function Get-FolderDialog([string]$InitialDirectory) {
	Add-Type -AssemblyName System.Windows.Forms
	$openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
	$openFolderDialog.ShowNewFolderButton = $true
	$openFolderDialog.RootFolder = $InitialDirectory
	$openFolderDialog.ShowDialog()
	return $openFolderDialog.SelectedPath
}

function Get-SkriptAbbruch() {
	try {
		if ([console]::KeyAvailable) {
			$key = [system.console]::readkey($true)
			if (($key.modifiers -band [consolemodifiers]"control") -and ($key.key -eq "C")) {
				wh "CTRL-C gedrückt" 
				return $($key.keychar)
			}
			else {
				wh "Taste gedrückt [$($key.keychar)]"
			}
		}	
	}
	catch { Write-Warning "Start in der ISE - keine Consolenabfage Möglich..." }		
}
#endregion


#region begin SQL
#**********************************************************************************************************************
#**********************************************************************************************************************
#Folgende Funktionen benötigen SQL-Modul...
<#
		wh '------------------------------------------------------------------------------------------'
		wh " --> Modul für SQL-Server-Verwaltung und direkten Zugriff auf die Tabellen installieren..."
		wh ""
		#install-module sqlps; #das ist die alte Version... falls die installiert ist muss die neue mit "-AllowClobber" ausgeführt werden!
		install-module SqlServer -AllowClobber
		import-module SqlServer
		wh ""
		wh "--> SQL-Modul Ende <--"
		wh '------------------------------------------------------------------------------------------'
	#>
function Get-DBList ($mserver) { #Rückgabe der Datenbanken im Server
	<#
			#Beispiel...
			$PC          = $env:computername
			$Instance    = "SQLHERMES"
			Get-DBList "$PC\$Instance" 
		#>
	$srv = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $mserver
	$tt = $srv.Databases | Select-Object -ExpandProperty name #, RecoveryModel, 
	#Write-Host $tt
	return $tt
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

	wh "...................................................................................................................."
	wh "Server: [$serverName]"
	wh "Backup Dir: [$backupDirectory]"
	#wh "ablöschen nach: [$daysToStoreBackups] Tag(en)"
	wh "...................................................................................................................."
		 
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SMO") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoExtended") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.ConnectionInfo") | Out-Null
	[System.Reflection.Assembly]::LoadWithPartialName("Microsoft.SqlServer.SmoEnum") | Out-Null

	$server = New-Object 'Microsoft.SqlServer.Management.Smo.Server' $serverName
	$dbs = $server.Databases
			
	$timestamp = Get-Date -format yyyy.MM.dd-HHmm
	foreach ($database in $dbs | Where-Object { $_.IsSystemObject -eq $False }) {
		$dbName = $database.Name
				
		$targetPath = $backupDirectory + "\" + $dbName + "_" + $timestamp + ".bak"
		$targetPath = $backupDirectory + "\" + $dbName + ".bak"
		wh "DB:[$dbName] --> zu Datei:[$targetPath]"
				
		$smoBackup = New-Object ("Microsoft.SqlServer.Management.Smo.Backup")
		$smoBackup.Action = "Database"
		$smoBackup.BackupSetDescription = "Full Backup of " + $dbName
		$smoBackup.BackupSetName = $dbName + " Backup"
		$smoBackup.Database = $dbName
		$smoBackup.MediaDescription = "Disk"
		$smoBackup.Devices.AddDevice($targetPath, "File")
		#$smoBackup.CompressionOption = 1
		$smoBackup.SqlBackup($server)

		wh ".............................................................................................................................................................................."
	}
		   
	#wh "entferne Sicherungen älter als $daysToStoreBackups Tage..." 
	#Get-ChildItem "$backupDirectory\*.bak" |? { $_.lastwritetime -le (Get-Date).AddDays(-$daysToStoreBackups)} |% {Remove-Item $_ -force }     
}

function DeleteSqlData-FromCSV ($CSV_File, $ServerInstanz, $Trennzeichen) { #Auch als Beispiel für Laden einer CSV-Datei
	<#
			#Beispiel...
			$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
			$Instance   = "SQLHERMES"
			$Tabelle 	= "HerObjMAParameter"
			$Import_File = "HerMAParameter.txt"
			DeleteSqlData-FromCSV "$InstallPath\$Import_File" "$PC\$Instance"
		#>

	wh "...................................................................................................................."
	wh "Server-Instanz : [$ServerInstanz]"
	wh "CSV-File       : [$CSV_File]"
	wh "...................................................................................................................."

	wh "Die CSV komplett ins Speicher laden..."
	$CcvData = Import-CSV $CSV_File -Delimiter "$Trennzeichen"

	wh ""
	wh "vorhandene Eintnräge ablöschen...."

	ForEach ($Line in $CcvData) {
		$MID = $Line.MAID  
		$Q = "DELETE FROM $Datenbank.dbo.$Tabelle WHERE MAID = $MID"
		Invoke-Sqlcmd -Query $Q -ServerInstance $ServerInstanz
		#wh $Q
	}
}
#SQL-Modul...
#**********************************************************************************************************************
#**********************************************************************************************************************
#endregion
# Div Funktionen
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


#**********************************************************************************************************************
#**********************************************************************************************************************
# 									Hauptprogramm
Clear-Host
whr | whr | whr | whr
  
 
if ($debug) {
 Clear-Host
}

#region begin AdminRechteAnfordern
#+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#auskommentieren, wenn Skript mit Admin-Rechten laufen soll!!!
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
#endregion


trenn " "
	
$PC = $env:computername #Aktuellen PC-Namen ermitteln

$datum = Get-Date -Format yyyy.MM.dd_HHmm
$DTminusEinMonat = (get-date).AddDays(-30).ToString("yyy.MM.dd") #die letzten 30 Tage ausrechnen
$InstallPath = Get-ScriptDirectory #Pfad wo der Skript ist
$SicherungsGrundPfad = (get-item $InstallPath ).parent.FullName #Verzeichnissname wo dieser Skript liegt (eine Ebene zurück)
$Projekt = (get-item $InstallPath ).Name #nur Verzeichnissname
trenn " "
wh "Rechner				: [$PC]"
wh "Datum/Zeit			: [$datum]"
wh "Dazum vor 30 Tagen		: [$DTminusEinMonat]"
wh "Verzeichnis			: [$Projekt]"
wh ""
wh "Als Nächstes der Skriptpfad und eine Ebene zurück:`r`nSkriptpfad:[$InstallPath]`r`nParent:[$SicherungsGrundPfad]"
whr


if ($debug) {
	trenn ""
	wh "Hello World!" 
}

	
trenn 'Skript ausgefuehrt!'
wh 'Wenn nichts rot, dann alles ok ;-)'

start-countdown 30


<##**********************************************************************************************************************
	#Div. Infos
	C:\Windows\System32\WindowsPowerShell\v1.0
	psexec.exe \\192.168.1.10 -u "domain\administrator" -p "password" cmd
	set-executionpolicy remotesigned
	Get-ExecutionPolicy -list |% {Set-ExecutionPolicy -scope $_.scope remotesigned -force -ErrorAction SilentlyContinue} #in allen scopes durchlaufen
	-ErrorAction SilentlyContinue
	-ForegroundColor Yellow
	powershell.exe -NoLogo -NoProfile -Command 'Install-Module -Name PackageManagement -Force -MinimumVersion 1.4.6 -Scope CurrentUser -AllowClobber'
#>

<#
[-BackgroundColor {Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White}]
[-ForegroundColor {Black | DarkBlue | DarkGreen | DarkCyan | DarkRed | DarkMagenta | DarkYellow | Gray | DarkGray | Blue | Green | Cyan | Red | Magenta | Yellow | White}]
#>

<#
	$TageZL = 30*2;#2 Monate
	$DatumVorXTagen = (Get-Date).AddDays($TageZL * -1)
	get-childitem "$Source" | where {$_.mode -match "d" -and $_.LastWriteTime -lt $DatumVorXTagen}| remove-item -Recurse -force -verbose # nur Ordner
	#get-childitem "$Source" | where {$_.lastwritetime -lt $DatumVorXTagen -and -not $_.psiscontainer} |% {remove-item $_.fullname -force -verbose} #ohne Ordner
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
		if ($s=Get-WinEvent -ListLog HERMES -ErrorAction SilentlyContinue) { if ($debug) {wh "eventlog existiert bereits"}} else {New-EventLog -Source "HERMES" -LogName "HERMES"} 
	
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
        if ($debug) {wh $errText}
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
	while(($inp = Read-Host -Prompt "Wählen Sie einen Befehl") -ne "Q")
	{
		switch($inp)
		{
			L {wh "Datei wird gelöscht"}
			A {wh "Datei wird angezeigt"}
			R {wh "Datei erhält Schreibschutz"}
			Q {wh "Ende"}
			default {wh "Ungültige Eingabe"}
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



















