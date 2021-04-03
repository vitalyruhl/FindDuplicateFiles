

#**********************************************************************************************************************

    #**********************************************************************************************************************
    #(c) Vitaly Ruhl                            
    #    
    #______________________________________________________________________________________________________________________
    #
    #Function: Verzeichnisse-Vergleichen.ps1
    #______________________________________________________________________________________________________________________
    #
    #Version  Datum           Author        Beschreibung
    #-------  ----------      -----------   -----------
    #V1.0     24.01.2017      Vitaly Ruhl   Erstellungsversion 
    #
    #Funktionsbeschreibung:
    #Über cron möchte ich Änderungen in Meinen Projekten anzeigen lassen (Server)
	#hat zum Beispiel jemand neue Datei hinzugefügt, oder verändert???
    #**********************************************************************************************************************

    #**********************************************************************************************************************
    #Anderungsverlauf                                          
    #24.01.2017 vr V1.0    Skripterstellung
    #21.08.2017 vr V1.1    Unnötigen geruffel mit der Abfrage entfernt
    # 
    # 
    #********************************************************************************************************************** 


	
#**********************************************************************************************************************	
#Work-Around	
Add-Type –AssemblyName System.Windows.Forms
set-alias wh "Write-Host"#etwas Tipparbeit ersparen

#Remove-Item $env:temp\vr_compare\last\*.xml -force	#Schnapschüsse löschen	
#wh 'Neuer Schnapschuss wird erstellt'
#$ZuVergleichendePfade | Get-ChildItem -Recurse | Select-Object fullname,length,LastWriteTime | Export-Clixml $SnapShotFile -force #Schnapschuss erstellen
    	
# Hilfe Lesen !
#Get-Help Compare-Object -Full | More	
	
#**********************************************************************************************************************
#Einstellungen

$ZuVergleichendePfade = @(	
                            "P:\Projektsicherung\____Projekte\Nordenham\NSW";
                            "P:\Projektsicherung\____Projekte\Lemwerder\Abeking & Rasmussen";
							"P:\Projektsicherung\____Projekte\Oschersleben\tav Börde";
							"P:\Projektsicherung\____Projekte\Schortens\Freizeitbad Aqua Toll Schortens";
							"P:\Projektsicherung\____Projekte\Bremerhaven\BTZ Bio Nord";
						  )



$SnapShotPath = "d:\temp\vr_compare\last"
$SnapShotFile = $SnapShotPath + '\LastData.xml'
$SnapShotNow = $SnapShotPath + '\NowData.xml'
$SnapShotCP = $SnapShotPath + '\LastCompare.xml'
$DesktopPath = "$env:USERPROFILE\Desktop\PathCompare.csv"
#**********************************************************************************************************************






#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Div Funktionen
function Create-mNewSnapshot ()
{
#cls
wh 'Neuer Schnapschuss wird erstellt'
$ZuVergleichendePfade | Get-ChildItem -Recurse | Select-Object fullname,length,LastWriteTime | Export-Clixml $SnapShotFile -force #Schnapschuss erstellen
}


function Create-Path($MyPath) {
#22.01.2017 vr
if (!(Test-Path -path $MyPath -ErrorAction SilentlyContinue )) 
    {
		# Pfad anlegen wenn nicht vorhanden
		if (!(Test-Path -Path $MyPath)) 
            {
			 New-Item -Path $MyPath -ItemType Directory -ErrorAction SilentlyContinue # | Out-Null
		    }      
    }
}

#cls

Create-Path $SnapShotPath #Pfade Prüfen und geg. erstellen

if (!(Test-Path -path $SnapShotFile -ErrorAction SilentlyContinue ))  
{
wh 'Snapschuss nicht gefunden --> neuen erstellen..'
#$ZuVergleichendePfade | Get-ChildItem -Recurse | Select-Object fullname,length,LastWriteTime | Export-Clixml $SnapShotFile -force #Schnapschuss erstellen
Create-mNewSnapshot
}
else
{



    #erstmal Prüfen,ob Pfade erreichbar

    $myPathAvaible = Test-Path $ZuVergleichendePfade
    #wh $myPathAvaible

    $bStarten =$myPathAvaible -contains $false
    #wh $bStarten

    if ($bStarten) 
        {
            wh "Pfade nicht erreichbar! Aktion abbrechen" 
            break
        }

    #else
    wh "alles klar! Pfade gefunden!"     
    wh 'Vergleichen...'
    #do man to

    $ZuVergleichendePfade | Get-ChildItem -Recurse | Select-Object fullname,length,LastWriteTime | Export-Clixml $SnapShotNow -force #Schnapschuss erstellen

    $XML_SnapShot = Import-Clixml $SnapShotFile #Schnapschuss holen
    $XML_Now = Import-Clixml $SnapShotNow  #Jetzt holen

    Compare $XML_SnapShot $XML_Now -Prop fullname,length,LastWriteTime | Export-Clixml $SnapShotCP -Force 
    $XML_CP = Import-Clixml $SnapShotCP  #Vergleich holen

    wh 'falls es Untershiede gibt... hier ausgeben:'
    $XML_CP | Select-Object Fullname | Group-Object -property fullname | foreach-object {wh $_.Values} #erstmal alle untershiede ausgeben
    $XML_CP | Select-Object fullname | Group-Object -property fullname | Select-Object name | Export-Csv $DesktopPath -force #und in eine CSV auf dem Desktop ablegen
   
} 


wh 'Neuen Schnapschuss erstellen...'
    $ZuVergleichendePfade | Get-ChildItem -Recurse | Select-Object fullname,length,LastWriteTime | Export-Clixml $SnapShotFile -force #Schnapschuss erstellen
 
wh ' ' 
wh ' ' 
wh 'Skript ausgeführt!'


