# =================================================================
# File       : Step4_MacAddressGUI.ps1
# Role       : Main shopping mall for the graphical interface
# Shops      : - Configuration shop (imports and setup)
#              - Components shop (graphical interface)
#              - Events shop (action management)
# Connection : Uses Step3_MacInfo.ps1 and Step4_MacAddress.ps1
# =================================================================

#region Log display function
# DO NOT DELETE - Function used to display messages in the console
function Write-ConsoleLog {
    param(
        [string]$Message,
        [string]$Color = "White",
        [string]$Prefix = ""
    )
    
    $prefixIcon = switch ($Color) {
        "Red" { "❌" }
        "Yellow" { "⚠️" }
        "Green" { "✓" }
        "Cyan" { "🏪" }
        "Gray" { "  🔍" }
        default { "  >" }
    }
    
    Write-Host "$prefixIcon $Message" -ForegroundColor $Color
}
#endregion

#region Main MAC interface function
# DO NOT DELETE - Main function for MAC address modification interface
function Show-MacAddressWindow {
    Clear-Host
    Write-ConsoleLog "=== MAC Address Modification Interface ===" -Color Cyan
    Write-ConsoleLog "Initialization..." -Color Gray

    try {
        #region Initial configuration
        # ===== Configuration shop =====
        Write-ConsoleLog "Configuring shop..." -Color Cyan
        
        # DO NOT DELETE - Path verification
        $scriptPath = $PSScriptRoot
        if (-not $scriptPath) {
            $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
        }
        if (-not $scriptPath) {
            $scriptPath = (Get-Location).Path
        }
        
        Write-ConsoleLog "Script path: $scriptPath" -Color Gray
        
        # DO NOT DELETE - Required files verification
        $requiredFiles = @(
            "Step3_MacInfo.ps1",
            "Step4_MacAddress.ps1"
        )
        
        foreach ($file in $requiredFiles) {
            $filePath = Join-Path -Path $scriptPath -ChildPath $file
            Write-ConsoleLog "Searching for $file..." -Color Gray
            
            if (-not (Test-Path -Path $filePath)) {
                throw "Required file not found: $file"
            }
            
            Write-ConsoleLog "Loading $file" -Color Green
            . $filePath
        }
        #endregion

        #region Loading Windows Forms components
        # DO NOT DELETE - Loading necessary assemblies
        Write-ConsoleLog "Loading Windows Forms components..." -Color Gray
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        Write-ConsoleLog "Windows Forms components loaded" -Color Green
        #endregion

        #region Interface creation
        # ===== Components shop =====
        Write-ConsoleLog "Creating components..." -Color Cyan

        # DO NOT DELETE - Main window creation
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "MAC Address Modification"
        $form.Size = New-Object System.Drawing.Size(500,350)
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $form.ForeColor = [System.Drawing.Color]::White
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $form.MaximizeBox = $false
        $form.TopMost = $true
        $form.Focus()          # Give focus to window
        $form.BringToFront()   # Force window to foreground
        $form.Activate()       # Activate window

        # DO NOT DELETE - Interface control creation
        # Label for network card selector
        $selectLabel = New-Object System.Windows.Forms.Label
        $selectLabel.Text = "Select a network adapter:"
        $selectLabel.Location = New-Object System.Drawing.Point(20,20)
        $selectLabel.Size = New-Object System.Drawing.Size(460,20)
        $selectLabel.ForeColor = [System.Drawing.Color]::White
        $selectLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($selectLabel)

        # DO NOT DELETE - ComboBox for network card selection
        $adapterComboBox = New-Object System.Windows.Forms.ComboBox
        $adapterComboBox.Location = New-Object System.Drawing.Point(20,45)
        $adapterComboBox.Size = New-Object System.Drawing.Size(460,30)
        $adapterComboBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $adapterComboBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $adapterComboBox.ForeColor = [System.Drawing.Color]::White
        $adapterComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
        $form.Controls.Add($adapterComboBox)

        # DO NOT DELETE - Labels for current MAC address display
        $currentMacLabel = New-Object System.Windows.Forms.Label
        $currentMacLabel.Text = "Current MAC address:"
        $currentMacLabel.Location = New-Object System.Drawing.Point(20,85)
        $currentMacLabel.Size = New-Object System.Drawing.Size(460,20)
        $currentMacLabel.ForeColor = [System.Drawing.Color]::White
        $currentMacLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($currentMacLabel)

        $currentMacValue = New-Object System.Windows.Forms.Label
        $currentMacValue.Location = New-Object System.Drawing.Point(20,105)
        $currentMacValue.Size = New-Object System.Drawing.Size(460,20)
        $currentMacValue.ForeColor = [System.Drawing.Color]::FromArgb(0,120,215)
        $currentMacValue.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($currentMacValue)

        # DO NOT DELETE - Controls for new MAC address
        $newMacLabel = New-Object System.Windows.Forms.Label
        $newMacLabel.Text = "New MAC address:"
        $newMacLabel.Location = New-Object System.Drawing.Point(20,135)
        $newMacLabel.Size = New-Object System.Drawing.Size(460,20)
        $newMacLabel.ForeColor = [System.Drawing.Color]::White
        $newMacLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($newMacLabel)

        $macTextBox = New-Object System.Windows.Forms.TextBox
        $macTextBox.Location = New-Object System.Drawing.Point(20,160)
        $macTextBox.Size = New-Object System.Drawing.Size(300,25)
        $macTextBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $macTextBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $macTextBox.ForeColor = [System.Drawing.Color]::White
        $form.Controls.Add($macTextBox)

        # DO NOT DELETE - Action buttons
        $btnGenerate = New-Object System.Windows.Forms.Button
        $btnGenerate.Text = "Generate random MAC address"
        $btnGenerate.Location = New-Object System.Drawing.Point(20,195)
        $btnGenerate.Size = New-Object System.Drawing.Size(460,30)
        $btnGenerate.ForeColor = [System.Drawing.Color]::White
        $btnGenerate.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
        $btnGenerate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnGenerate.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($btnGenerate)

        $btnChange = New-Object System.Windows.Forms.Button
        $btnChange.Text = "Apply change"
        $btnChange.Location = New-Object System.Drawing.Point(20,235)
        $btnChange.Size = New-Object System.Drawing.Size(460,30)
        $btnChange.ForeColor = [System.Drawing.Color]::White
        $btnChange.BackColor = [System.Drawing.Color]::FromArgb(60,60,60)
        $btnChange.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnChange.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($btnChange)

        # DO NOT DELETE - Label for error messages
        $errorLabel = New-Object System.Windows.Forms.Label
        $errorLabel.Location = New-Object System.Drawing.Point(20,320)
        $errorLabel.Size = New-Object System.Drawing.Size(460,20)
        $errorLabel.ForeColor = [System.Drawing.Color]::Red
        $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $errorLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $form.Controls.Add($errorLabel)
        #endregion

        #region Data initialization
        # DO NOT DELETE - Fill adapters list
        $adapters = Get-NetworkAdapters
        foreach ($adapter in $adapters) {
            $adapterComboBox.Items.Add($adapter.InterfaceDescription)
        }
        if ($adapterComboBox.Items.Count -gt 0) {
            $adapterComboBox.SelectedIndex = 0
            $currentMacValue.Text = $adapters[0].MacAddress
        }
        #endregion

        #region Events configuration
        # DO NOT DELETE - Interface events
        $adapterComboBox.Add_SelectedIndexChanged({
            $selectedAdapter = $adapters[$adapterComboBox.SelectedIndex]
            $currentMacValue.Text = $selectedAdapter.MacAddress
        })

        $btnGenerate.Add_Click({
            $macTextBox.Text = New-MacAddress
        })

        $btnChange.Add_Click({
            $errorLabel.Text = ""
            if ($adapterComboBox.SelectedItem -and $macTextBox.Text) {
                try {
                    $selectedAdapter = $adapters[$adapterComboBox.SelectedIndex]
                    $newMac = $macTextBox.Text
                    
                    if (Test-MacAddress -MacAddress $newMac) {
                        $btnChange.Enabled = $false
                        $btnChange.Text = "Modification in progress..."
                        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
                        
                        $result = Set-MacAddress -AdapterName $selectedAdapter.Name -MacAddress $newMac
                        if (-not $result) {
                            $errorLabel.Text = "Error modifying MAC address. Check logs in console."
                        } else {
                            $currentMacValue.Text = $newMac
                            [System.Windows.Forms.MessageBox]::Show(
                                "MAC address has been successfully modified.",
                                "Success",
                                [System.Windows.Forms.MessageBoxButtons]::OK,
                                [System.Windows.Forms.MessageBoxIcon]::Information
                            )
                        }
                    } else {
                        $errorLabel.Text = "Invalid MAC address format. Expected format: XX-XX-XX-XX-XX-XX"
                    }
                }
                catch {
                    $errorLabel.Text = "Error: $_"
                    Write-Host "Detailed error: $($_.Exception.Message)" -ForegroundColor Red
                }
                finally {
                    $btnChange.Enabled = $true
                    $btnChange.Text = "Apply change"
                    $form.Cursor = [System.Windows.Forms.Cursors]::Default
                }
            }
        })
        #endregion

        #region Interface display
        # DO NOT DELETE - Interface launch
        Write-ConsoleLog "Displaying interface..." -Color Cyan
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $form.ShowDialog()
        Write-ConsoleLog "Interface closed" -Color Green
        #endregion
    }
    catch {
        $errorMessage = "Error loading MAC interface: $_"
        Write-ConsoleLog $errorMessage -Color Red
        [System.Windows.Forms.MessageBox]::Show(
            $errorMessage,
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
} 