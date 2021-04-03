
<#
______________________________________________________________________________________________________________________

	(c) HERMES Systeme GmbH                             Telefon: +49 (0) 4431 9360-0
        MSR & Automatisierungstechnik                   Telefax: +49 (0) 4431 9360-60
        Visbeker Str. 55                                E-Mail: info@hermes-systeme.de
        27793 Wildeshausen                              Home: www.hermes-systeme.de
______________________________________________________________________________________________________________________
#>

$Funktion = 'deleteDuplicateFiles.ps1'

<#  
______________________________________________________________________________________________________________________    
    		Version  	Datum           Author        Beschreibung
    		-------  	----------      -----------   -----------
#>
$Version = 'V1.0.0' #	29.03.2021		Vitaly Ruhl		init
$Version = 'V1.0.1' #	03.04.2021		Vitaly Ruhl		init publish

<#		
______________________________________________________________________________________________________________________
    Function:
    delete duplicate Files - Steps 2+3 from 3 (Created CSV and reviewed (Step2) - Delete or move Files (Step3))
______________________________________________________________________________________________________________________
#>

#**********************************************************************************************************************	
# Imports	
. .\module\recentlyUsedFunctions.ps1 #Import some Functions
#**********************************************************************************************************************

#**********************************************************************************************************************
# Settings
$CSVTable = ".\All-Duplicate-Files.csv"
SetDebugState($false) #activate some debug informations
$AdminRightsRequired = $false #set $true, if Admin-Rights are for the Script reqired
#**********************************************************************************************************************

$global:Modul = 'Main'
Clear-Host

if ($AdminRightsRequired){
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

#region Functions Main-Dialog
    function CheckToDelItems() {
        Write-Debug "Move Items are called"
        . .\module\checkform.ps1 
    }
    function MoveItems() {
        SetDebugState($false)
        $global:Modul = "MoveItems()"
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        write-Debug "Move Items are called"
       
        $SD = Get-ScriptDirectory
        Write-Host "Please select directory to moved in..."
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
        Write-host "Selected folder for Backup:$SerchPath"

        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Load CSV'
    
        $csv = import-Csv -Path $CSVTable #| Select-Object -Property MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime ,MarkToDelete
        

        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Get files to delete:'
        $FilesToDelete = $csv | Where-Object{$_.MarkToDelete -eq $true}
        #$FilesToDelete | Write-debug 
        $FilesToDelete | ForEach-Object {
            
            $dPath = $_.DirectoryName.replace("\","_").replace(":","-").replace(" ","")
            $MovePath = $SerchPath + '\' + $dPath + '\'
            Write-debug "Move to Path:$MovePath"
            
            try {
                add-path $MovePath
                $it = Get-Item $(Resolve-Path $_.FullName) 
                Write-debug "File to move is selected -->"
                $it | Write-debug 
                Write-debug "<-- File to move"
                $MovePath = $(Resolve-Path $MovePath)               
               
                $it | Move-Item -Destination $MovePath -Force
           
            }
            catch { 
                Write-Warning "$global:Modul -  Something went wrong on $_" 
            }	
        }



    }
    function DeleteItems() {
        $global:Modul = "DeleteItems()"
        SetDebugState($false)
        Write-debug "`r`n`r`n------------------------------------------------------`r`n" 
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        write-Debug "Delete Items are called"
        
        Write-debug 'Load CSV'
        $csv = import-Csv -Path $CSVTable #| Select-Object -Property MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime ,MarkToDelete
        
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Get files to delete:'
        $FilesToDelete = $csv | Where-Object{$_.MarkToDelete -eq $true}
        #$FilesToDelete | Write-debug 
        $FilesToDelete | ForEach-Object {
           
            try {
                $it = Get-Item $(Resolve-Path $_.FullName) 
                Write-debug "File to delete is selected -->"
                $it | Write-debug 
                Write-debug "<-- File to delete"
                #$it | remove-Item -Force
                $it | Send-ToRecycleBin #-Force
           
            }
            catch { 
                Write-Warning "$global:Modul -  Something went wrong on $_" 
            }	
        }
    }
    function DeleteEmptyFolder() {
        SetDebugState($true)
        $global:Modul = "DeleteEmptyFolder()"
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        write-Debug "DeleteEmptyFolder are called"
       
        $SD = Get-ScriptDirectory
        Write-Host "Please select directory to search in..."
        $SerchPath = Get-FolderDialog ("$SD")

        if ($SerchPath -eq "-CANCEL-"){
            Write-Warning "No Folder selected - Exit Script"
            exit
        }
        elseif ($SerchPath -eq "-ERROR-") {
            Write-Error "Error in Get-Folder-Dialog - Exit Script"
            exit
        }
        else {
            
        
            #$SerchPath | Get-Member
            Write-host "Selected folder for Search is:$SerchPath"

            

            Write-debug "`r`n`r`n------------------------------------------------------`r`n"
            Write-debug 'Get Folder to delete:'

            #https://stackoverflow.com/questions/28631419/how-to-recursively-remove-all-empty-folders-in-powershell
            <########################################################################
                define a script block that will remove empty folders under a root folder, 
                using tail-recursion to ensure that it only walks the folder tree once. 
                -Force is used to be able to process hidden files/folders as well.
            ########################################################################>
            $tailRecursion = {
            
                param(
                    $Path
                )

                foreach ($childDirectory in Get-ChildItem -Force -LiteralPath $Path -Directory) {
                        & $tailRecursion -Path $childDirectory.FullName
                    }
            
                try { 
                    $currentChildren = Get-ChildItem -Force -LiteralPath $Path
                    $isEmpty = $null -eq $currentChildren
                    if ($isEmpty) {
                        Write-Verbose "Removing empty folder at path '${Path}'." -Verbose
                        Remove-Item -Force -LiteralPath $Path -WhatIf
                    }
            
                }
                catch { 
                    Write-Warning "$global:Modul -  Something went wrong" 
                }	
            }

            & $tailRecursion -Path $SerchPath
        }
    }

    function okButtonClick (){
        #Radiobuttons...
        #foreach ($o in @($radioButton1, $radioButton2, $radioButton3)){
        #    if ($o.Checked){
        #        $option = $o.Text}
        #    }

        if ($radioButton1.Checked){CheckToDelItems} 
        elseif ($radioButton2.Checked) {MoveItems}  
        elseif ($radioButton3.Checked) {DeleteItems}  
        elseif ($radioButton4.Checked) {DeleteEmptyFolder}  

        #checkboxes
        #If ($objTypeCheckbox.Checked = $true)
        #{
        #    write-host "Checkbox is checked"
        #}
        #else {
        #    write-host "Checkbox is NOT checked"
        #}
        
        #wh  
        #$inpText =   $textBox.Text
        #write-host "Input-Text: $inpText"
        #write-host "Selected Option: $option"

        $form.Dispose()
    }

#endregion



#region Functions Form Check 
    function MarkToDelete {
        param (
            $MarkBy
        )
        
        SetDebugState($false)
        Write-Debug "param:[$MarkBy]"
        
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Load CSV'
    
        $csv = import-Csv -Path $CSVTable #| Select-Object -Property MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime ,MarkToDelete
       
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Sort and get unique'
        
        switch ($MarkBy) {
            "CT"    { 
                        $Dupcsv = $csv | Group-Object MD5Hash | Where-Object{$_.count -gt 1} | ForEach-Object {
                            $one = $false
                            $_.Group | Sort-Object CreationTime -Descending | ForEach-Object {
                                $_.MarkToDelete = $one
                                $one = $true
                                $_ 
                                }
                        } 
            }  

            "LW"    { 
                        $Dupcsv = $csv | Group-Object MD5Hash | Where-Object{$_.count -gt 1} | ForEach-Object {
                            $one = $false
                            $_.Group | Sort-Object LastWriteTime -Descending | ForEach-Object {
                                $_.MarkToDelete = $one
                                $one = $true
                                $_ 
                                }
                        } 
            }  
            
            "UN"    { 
                        $Dupcsv = $csv | Group-Object MD5Hash | Where-Object{$_.count -gt 1} | ForEach-Object {
                            $one = $false
                            $_.Group | ForEach-Object {
                                $_.MarkToDelete = $one
                                $one = $true
                                $_ 
                                }
                        } 
            }  

            Default    { 
                        $Dupcsv = $csv | Group-Object MD5Hash | Where-Object{$_.count -gt 1} | ForEach-Object {
                            $one = $false
                            $_.Group | ForEach-Object {
                                $_.MarkToDelete = $one
                                $one = $true
                                $_ 
                                }
                        } 
            }  
        }
        
        #$Dupcsv = $csv | Where-Object{$_.isFolder -eq $False} | Select-Object -Property MD5Hash, Name ,Extension, FullName, DirectoryName, CreationTime ,LastWriteTime 
        
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'Debug CSV --> '
        $Dupcsv | Write-debug 
        Write-debug '<--- Debug CSV'
        
        Write-debug "`r`n`r`n------------------------------------------------------`r`n"
        Write-debug 'export CSV'
        #$Dupcsv | Add-Member -MemberType NoteProperty -Name 'MarkToDelete' -Value ($false)
        $Dupcsv | Export-Csv -Path $CSVTable -Force

        Write-Host "Table $CSVTable is updated - please check the Files to deletion for security!" -ForegroundColor red

    }

    function MarkByCreateTime() {
        write-Debug "MarkByCreateTime are called"  
        MarkToDelete "CT" 
    }
    function MarkByLastWriteTime() {
        write-Debug "MarkByLastWriteTime are called"
        MarkToDelete "LW" 
    }
    function LeaveFirstOne() {
        write-Debug "LeaveFirstOne are called"
        MarkToDelete "UN" 
    }

    function okButtonClickCheck (){
        if ($radioButton1.Checked){MarkByCreateTime} 
        elseif ($radioButton2.Checked) {MarkByLastWriteTime}  
        elseif ($radioButton3.Checked) {LeaveFirstOne}  
        $form.Dispose()
    }
#endregion




#region Main
    SetDebugState($false)
    Write-debug "`r`n`r`n------------------------------------------------------`r`n"
    Write-debug 'Perform formular'

    . .\module\mainform.ps1 #Open Main-Dialog

    Write-debug 'done'
    #exit

#endregion


Write-Host "`r`n`r`n"
Write-Warning "------------------------------------------------------`r`n"
Write-Warning 'Skript is done!'
Write-Warning 'When you dont see any red than is all fine ;-)'#-ForegroundColor Green

#start-countdown 30
#pause



