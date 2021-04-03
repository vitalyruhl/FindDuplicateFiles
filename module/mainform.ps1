
#region Form-Main
    # https://www.windowspro.de/script/grafische-oberflaeche-gui-fuer-powershell-scripts-erstellen
    # https://lazyadmin.nl/powershell/powershell-gui-howto-get-started/

    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
    [void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")
    $form = New-Object System.Windows.Forms.Form
    $form.Backcolor="white"
    $form.BackgroundImageLayout = 2

    $form.StartPosition = "CenterScreen"
    $form.Size = New-Object System.Drawing.Size(300,300)
    $form.Text = "Select Settings"
#endregion


#region Radio Buttons
    $radioButton1 = New-Object System.Windows.Forms.RadioButton
    $radioButton2 = New-Object System.Windows.Forms.RadioButton
    $radioButton3 = New-Object System.Windows.Forms.RadioButton
    $radioButton4 = New-Object System.Windows.Forms.RadioButton
    $groupBox = New-Object System.Windows.Forms.GroupBox
    $groupBox.Controls.AddRange(

    @(
    $radioButton1,
    $radioButton2,
    $radioButton3,
    $radioButton4
    ))

    $groupBox.Location = New-Object System.Drawing.Point(10, 10)
    $groupBox.Name = 'groupBox'
    $groupBox.Size = New-Object System.Drawing.Size(220, 180)
    $groupBox.Text = 'choose Option'

    # radioButton1
    $radioButton1.Location = New-Object System.Drawing.Point(8, 32)
    $radioButton1.Name = 'radioButton1'
    $radioButton1.Text = 'Check'
    $radioButton1.Checked = $true

    # radioButton2
    $radioButton2.Location = New-Object System.Drawing.Point(8, 64)
    $radioButton2.Name = 'radioButton2'
    $radioButton2.Text = 'Move'

    # radioButton3
    $radioButton3.Location = New-Object System.Drawing.Point(8, 96)
    $radioButton3.Name = 'radioButton3'
    $radioButton3.Text = 'Delete'

    # radioButton4
    $radioButton4.Location = New-Object System.Drawing.Point(8, 128)
    $radioButton4.Name = 'radioButton4'
    $radioButton4.Text = 'Delete empty Folder'


    $form.Controls.Add($groupBox)
 
#endregion

#region Buttons


    #region Cancel-Buttons
        $CancelButton = New-Object System.Windows.Forms.Button
        # Die nächsten beiden Zeilen legen die Position und die Größe des Buttons fest
        $CancelButton.Location = New-Object System.Drawing.Size(90,220)
        $CancelButton.Size = New-Object System.Drawing.Size(75,23)
        $CancelButton.Text = "Cancel"
        $CancelButton.Name = "Cancel"
        $CancelButton.DialogResult = "Cancel"
        
        #Die folgende Zeile ordnet dem Click-Event die Schließen-Funktion für das Formular zu
        $CancelButton.Add_Click({$form.Close()})
        $form.Controls.Add($CancelButton)
    #endregion


    #region OK Button 
        $okButton = New-Object System.Windows.Forms.Button
        $okButton.Location = New-Object System.Drawing.Size(190,220)
        $okButton.Size = New-Object System.Drawing.Size(75,23)
        $okButton.Text = 'OK'
        $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
        $form.AcceptButton = $okButton
        $form.Controls.Add($okButton)
        $okButton.Add_Click({
            okButtonClick
         })
    #endregion
   
#endregion

 [void] $form.ShowDialog()