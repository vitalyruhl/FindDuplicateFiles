<#
______________________________________________________________________________________________________________________

	(c) HERMES Systeme GmbH                             Telefon: +49 (0) 4431 9360-0
        MSR & Automatisierungstechnik                   Telefax: +49 (0) 4431 9360-60
        Visbeker Str. 55                                E-Mail: info@hermes-systeme.de
        27793 Wildeshausen                              Home: www.hermes-systeme.de
______________________________________________________________________________________________________________________

$Funktion = 'recentlyUsedFunctions.ps1'

<#  
______________________________________________________________________________________________________________________
    
    		Version  	Datum           Author        Beschreibung
    		-------  	----------      -----------   -----------

$Version = 'V1.0.0' #	26.03.2021		Vitaly Ruhl		init
		

______________________________________________________________________________________________________________________
    Function:
    Find and or delete duplicate Files - Step 1 from 3
    get all files in contained folder recursivla in a json with simple hash
______________________________________________________________________________________________________________________
#>



#**********************************************************************************************************************
# Settings
$AdminRightsRequired = $false 
#**********************************************************************************************************************

#**********************************************************************************************************************
# Debug Einstellungen
$global:debug = $false # $true $false
$global:DebugPrefix = $Funktion + ' ' + $Version + ' -> ' #Variable für Debug-log vorbelegen
$global:Modul = 'Main' #Variable für Debug-log vorbelegen
$ErrorActionPreference = "Continue" #Fehlerbehandlung im Skript - Bei Fehler einfach mal weitergehen, aber Fehler ausgeben....(Möglich:Ignore,SilentlyContinue,Continue,Stop,Inquire) 
$global:DebugPreference = if ($global:debug) {"Continue"} else {"SilentlyContinue"} #Powershell-Own Debug settings
#**********************************************************************************************************************



	
function EmptyFunction() {
    <#
		Info/Example:

	#>
    $tempModul = $global:Modul # save Modul-Prefix
    $global:Modul = 'EmptyFunction'
    try {
        log "Function EmptyFunction execute" 	
        return $true
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
        return $false
    }
    finally{
        $global:Modul = $tempModul #set saved Modul-Prefix
    }	
	
    return $true
}






#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region Debugging and User-Interface Functions
function SetDebugState ($b){
    $global:DebugPreference = if ($b) {"Continue"} else {"SilentlyContinue"} #Powershell-Own Debug settings
}


function whr ()	{ Write-Host "`r`n`r`n" }
	
function section ($text) {
    Write-Host "`r`n-----------------------------------------------------------------------------------------------"
    Write-Host " $text"
    Write-Host "`r`n"
}
	
function sectionY ($text) {
    Write-Host "`r`n-----------------------------------------------------------------------------------------------" -ForegroundColor Yellow
    Write-Host " $text" -ForegroundColor Yellow
    Write-Host "`r`n"
}
	
function log ($text) {
    if ($global:debug) {
        Write-Host "$global:DebugPrefix $global:Modul -> $text" -ForegroundColor DarkGray	
    }
}

function debug ($text){
    if ($global:debug) {
        Write-debug "$global:DebugPrefix $global:Modul -> $text"# -ForegroundColor DarkGray
    }	
}


function MsgBox($Title, $msg, $Typ, $Aussehen) {
		
    <# example:
            $test = MsgBox  "test tittel"  "Test text" 0 5 
    #>

    <#
		Types of Messageboxes	
		0:	OK
		1:	OK Cancel
		2:	Abort Retry Ignore
		3:	Yes No Cancel
		4:	Yes No
		5:	Retry Cancel
		
		#Icons...
			Symbol			Icon	                english
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
    $tempModul = $global:Modul
    $global:Modul = 'MsgBox'
    try {
        log "passed parameters ($Title, $msg, $Typ, $Aussehen)"
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
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
    return $result
}

function Get-UserInput($title, $msg, $Vorbelegung) {
    <# example:
		
        $global:Modul = 'Input-Test:'
        sectionY " Input - Test "
        $test = get-UserInput  "test titel"  "for exsample 192.168.2.250" "192.168.2.250"
        Write-Host "Returnvalue from Inputdialog: $test"

	#>

    $tempModul = $global:Modul # Save pre-text temporarily 
    $global:Modul = 'Get-UserInput'
    try {
        log "passed parameters ($Title, $msg, $Vorbelegung)"
        [void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')
        $inp = [Microsoft.VisualBasic.Interaction]::InputBox($msg, $title, $Vorbelegung, 5)
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
    return $inp
}

#endregion


#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
#region File and Direcrory Functions

function Get-FileDialog($InitialDirectory, [switch]$AllowMultiSelect) {
    $tempModul = $global:Modul # Save pre-text temporarily 
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
            $global:Modul = $tempModul #restore old module text	
            return $openFileDialog.Filenames 
        } 
        else { 
            $global:Modul = $tempModul #restore old module text	
            return $openFileDialog.Filename 
        }
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
}
function  Get-FolderDialog([string]$InitialDirectory="") {
	$tempModul = $global:Modul # save Modul-Prefix
	$global:Modul = 'Get-FolderDialog'
    log "Passed Init Directory is:$InitialDirectory"
	try {
		#Add-Type -AssemblyName System.Windows.Forms
        [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null
        log 1
		$openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
        log 2
        $openFolderDialog.Description = "Select a folder"
        log 3
		$openFolderDialog.ShowNewFolderButton = $true
        log 4
		$openFolderDialog.rootfolder  = "MyComputer"
        log 5
		$openFolderDialog.SelectedPath   = $InitialDirectory
        log 6
		#$openFolderDialog.ShowDialog()
        $od = $openFolderDialog.ShowDialog()
        if($od -eq "OK")
            {
                $folder = $openFolderDialog.SelectedPath	
                return $folder
            }
            else{
                Write-Warning "$global:Modul - Dialog are canceled" 
                return ("-CANCEL-")
            }
	}
	catch { 
		Write-Warning "$global:Modul -  Something went wrong" 
        return  ("-ERROR-" )
	}	
    finally{
        $global:Modul = $tempModul #set saved Modul-Prefix
    }
    
}

function Add-Path($MyPath) {
    #Checks path exists, otherwise creates a new one .....
    <#
               example: 
               $Pfad="$env:TEMP\PS_Skript"
               Add-Path($Pfad)
       #>
    $tempModul = $global:Modul # Save pre-text temporarily 
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
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
}	
function Get-ScriptDirectory() {
    $tempModul = $global:Modul # Save pre-text temporarily 
    $global:Modul = 'Get-ScriptDirectory'
    try {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        Split-Path $Invocation.MyCommand.Path
    }
    catch { 
        Write-Warning "$global:Modul -  Something went wrong" 
    }	
    $global:Modul = $tempModul #restore old module text	
}


#endregion



#region begin AdminRights

#You need to import this Function in your Root-Project, otherwise it dont work!
function AdminRightsRequired {
    log "get Adminrights - Allow? $AdminRightsRequired"
        #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
            $psi.Verb = 'runas'
            [System.Diagnostics.Process]::Start($psi) | Out-Null
            return;
        }
        #+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  
}
#endregion



function ftimer(){
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    $window = New-Object System.Windows.Forms.Form
    $window.Width = 1000
    $window.Height = 800
    $Label = New-Object System.Windows.Forms.Label
    $Label.Location = New-Object System.Drawing.Size(10,10)
    $Label.Text = "Text im Fenster"
    $Label.AutoSize = $True
    $window.Controls.Add($Label)

    $i=0
    $timer_Tick={
        $script:i++
        $Label.Text= "$i new text"
    }
    $timer = New-Object 'System.Windows.Forms.Timer'
    $timer.Enabled = $True 
    $timer.Interval = 1000
    $timer.add_Tick($timer_Tick)
    
    [void]$window.ShowDialog()

}






# https://devblogs.microsoft.com/scripting/use-a-powershell-cmdlet-to-work-with-file-attributes/
