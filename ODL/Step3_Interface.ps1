# =================================================================
# File       : Step3_Interface.ps1
# Role       : Shopping mall for the graphical interface
# Shops      : - Components shop (windows, panels)
#              - Styles shop (buttons, labels)
#              - Events shop (clicks, hovers)
# =================================================================

# Variables globales pour la langue
$global:CurrentLanguage = "EN"
$global:Translations = @{
    "FR" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker Free Trial"
        "Subtitle" = "pour Cursor"
        "BtnMacAddress" = "1. Modifier l'adresse MAC"
        "BtnDeleteStorage" = "2. Supprimer storage.json"
        "BtnExecuteAll" = "3. Exécuter toutes les actions"
        "BtnExit" = "4. Quitter"
        "Ready" = "Prêt"
        "NetworkCard" = "Carte réseau active"
        "MacAddress" = "Adresse MAC"
        "NoNetwork" = "Aucune carte réseau active trouvée"
        "NetworkError" = "Impossible de récupérer les informations réseau"
    }
    "EN" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker Free Trial"
        "Subtitle" = "for Cursor"
        "BtnMacAddress" = "1. Change MAC Address"
        "BtnDeleteStorage" = "2. Delete storage.json"
        "BtnExecuteAll" = "3. Execute All Actions"
        "BtnExit" = "4. Exit"
        "Ready" = "Ready"
        "NetworkCard" = "Active Network Card"
        "MacAddress" = "MAC Address"
        "NoNetwork" = "No active network card found"
        "NetworkError" = "Unable to retrieve network information"
    }
}

function Initialize-MainWindow {
    try {
        # ===== Main components shop =====
        Write-Host "🏪 Creating main components..." -ForegroundColor Cyan
        
        # Main window section
        $mainForm = New-Object System.Windows.Forms.Form
        $mainForm.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
        $mainForm.Size = New-Object System.Drawing.Size(800,600)
        $mainForm.StartPosition = "CenterScreen"
        $mainForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)  # Dark gray
        $mainForm.ForeColor = [System.Drawing.Color]::White
        $mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $mainForm.MaximizeBox = $false
        $mainForm.TopMost = $true  # Force window to foreground
        $mainForm.Focus()          # Give focus to window
        $mainForm.BringToFront()
        $mainForm.Activate()       # Activate window

        # Main window closing management
        $mainForm.Add_FormClosing({
            param($sender, $e)
            Write-Host "Closing application..." -ForegroundColor Yellow
            [System.Windows.Forms.Application]::Exit()
            [Environment]::Exit(0)
        })
        Write-Host "✓ Main window created" -ForegroundColor Green

        # Main panel section
        $mainPanel = New-Object System.Windows.Forms.Panel
        $mainPanel.Size = New-Object System.Drawing.Size(780,560)
        $mainPanel.Location = New-Object System.Drawing.Point(10,10)
        $mainPanel.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)  # Dark gray
        $mainForm.Controls.Add($mainPanel)
        Write-Host "✓ Main panel created" -ForegroundColor Green

        # ===== Labels shop =====
        Write-Host "`n🏪 Creating labels..." -ForegroundColor Cyan
        
        # Title section
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = $global:Translations[$global:CurrentLanguage]["MainTitle"]
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 32)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $titleLabel.Size = New-Object System.Drawing.Size(780,50)
        $titleLabel.Location = New-Object System.Drawing.Point(0,20)
        $mainPanel.Controls.Add($titleLabel)

        # Subtitle
        $subtitleLabel = New-Object System.Windows.Forms.Label
        $subtitleLabel.Text = $global:Translations[$global:CurrentLanguage]["Subtitle"]
        $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 16)
        $subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)  # Lighter gray
        $subtitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $subtitleLabel.Size = New-Object System.Drawing.Size(780,30)
        $subtitleLabel.Location = New-Object System.Drawing.Point(0,70)
        $mainPanel.Controls.Add($subtitleLabel)
        Write-Host "✓ Titles created" -ForegroundColor Green

        # MAC info section
        $macInfoPanel = New-Object System.Windows.Forms.Panel
        $macInfoPanel.Location = New-Object System.Drawing.Point(90,110)
        $macInfoPanel.Size = New-Object System.Drawing.Size(600,80)
        $macInfoPanel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)  # Slightly lighter gray
        
        # Add rounded corners for MAC panel
        $macInfoPanel.Add_Paint({
            param($sender, $e)
            
            $diameter = 10
            $arc = New-Object System.Drawing.Drawing2D.GraphicsPath
            
            # Rounded corners
            $arc.AddArc(0, 0, $diameter, $diameter, 180, 90)
            $arc.AddArc($sender.Width - $diameter, 0, $diameter, $diameter, 270, 90)
            $arc.AddArc($sender.Width - $diameter, $sender.Height - $diameter, $diameter, $diameter, 0, 90)
            $arc.AddArc(0, $sender.Height - $diameter, $diameter, $diameter, 90, 90)
            
            $arc.CloseFigure()
            $sender.Region = New-Object System.Drawing.Region($arc)
            
            # Gray border
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60,60,60), 1)
            $e.Graphics.DrawPath($pen, $arc)
        })

        $mainPanel.Controls.Add($macInfoPanel)

        $macInfoLabel = New-Object System.Windows.Forms.Label
        $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
        $macInfoLabel.Size = New-Object System.Drawing.Size(580,60)
        $macInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $macInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)  # Brighter
        $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $macInfoPanel.Controls.Add($macInfoLabel)
        Write-Host "✓ MAC panel created" -ForegroundColor Green

        # ===== Styles shop =====
        Write-Host "`n🏪 Configuring styles..." -ForegroundColor Cyan
        
        # Section dimensions des boutons
        $buttonWidth = 600
        $buttonHeight = 35
        $buttonX = [int](($mainPanel.Width - $buttonWidth) / 2)
        $buttonStartY = 200  # Réduit l'espace vide
        $buttonSpacing = 45  # Réduit l'espacement

        # Section fabrique de boutons
        function Create-StyledButton {
            param(
                [Parameter(Mandatory=$true)]
                [string]$text,
                [Parameter(Mandatory=$false)]
                [int]$y = 0,
                [Parameter(Mandatory=$false)]
                [int]$width = 0,
                [Parameter(Mandatory=$false)]
                [int]$height = 0,
                [Parameter(Mandatory=$false)]
                [int]$x = 0,
                [Parameter(Mandatory=$false)]
                [System.Drawing.Color]$customBackColor = [System.Drawing.Color]::FromArgb(50,50,50)
            )
            
            try {
                $button = New-Object System.Windows.Forms.Button
                
                # Gestion de la taille
                if ($width -gt 0 -and $height -gt 0) {
                    $button.Size = New-Object System.Drawing.Size($width, $height)
                } else {
                    $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
                }

                # Gestion de la position
                if ($x -gt 0 -and $y -gt 0) {
                    $button.Location = New-Object System.Drawing.Point($x, $y)
                } elseif ($y -gt 0) {
                    $button.Location = New-Object System.Drawing.Point($buttonX, $y)
                }

                $button.Text = $text
                $button.Font = New-Object System.Drawing.Font("Segoe UI Light", 11)
                $button.ForeColor = [System.Drawing.Color]::White  # White text
                $button.BackColor = $customBackColor
                $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                $button.FlatAppearance.BorderSize = 1
                $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)  # Gray border
                $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60,60,60)
                $button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(70,70,70)
                $button.Cursor = [System.Windows.Forms.Cursors]::Hand

                # Hover effect
                $button.Add_MouseEnter({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
                    }
                })
                
                $button.Add_MouseLeave({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)  # Back to gray
                    }
                })

                return $button
            }
            catch {
                Write-Host "  ❌ Error creating button: $_" -ForegroundColor Red
                throw
            }
        }

        # ===== Buttons shop =====
        Write-Host "`n🏪 Creating buttons..." -ForegroundColor Cyan
        
        # Standard buttons section
        # Determine button text based on current location
        $currentPath = $PSScriptRoot
        $isInEnglishFolder = $currentPath.EndsWith('\EN')

        # Bouton de langue (FR/EN) - Création séparée des autres boutons
        $btnLanguage = New-Object System.Windows.Forms.Button
        $btnLanguage.Size = New-Object System.Drawing.Size(70, 35)
        $btnLanguage.Location = New-Object System.Drawing.Point(($mainPanel.Width - 80), 10)
        $btnLanguage.Text = "FR/EN"
        $btnLanguage.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Regular)
        $btnLanguage.ForeColor = [System.Drawing.Color]::White
        $btnLanguage.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
        $btnLanguage.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnLanguage.FlatAppearance.BorderSize = 1
        $btnLanguage.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)
        $btnLanguage.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60,60,60)
        $btnLanguage.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(70,70,70)
        $btnLanguage.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnLanguage.Anchor = [System.Windows.Forms.AnchorStyles]::Top -bor [System.Windows.Forms.AnchorStyles]::Right

        # Effet de survol pour le bouton de langue
        $btnLanguage.Add_MouseEnter({
            $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
        })
        
        $btnLanguage.Add_MouseLeave({
            $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)
        })

        # Ajout immédiat du bouton de langue au panneau
        $mainPanel.Controls.Add($btnLanguage)

        $btnMacAddress = Create-StyledButton $global:Translations[$global:CurrentLanguage]["BtnMacAddress"] $buttonStartY $buttonWidth $buttonHeight $buttonX
        $btnDeleteStorage = Create-StyledButton $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"] ($buttonStartY + $buttonSpacing)
        Write-Host "✓ Standard buttons created" -ForegroundColor Green

        # Special buttons section
        $btnExecuteAll = Create-StyledButton $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"] ($buttonStartY + $buttonSpacing * 3) ([System.Drawing.Color]::FromArgb(255,140,0))  # Orange
        $btnExit = Create-StyledButton $global:Translations[$global:CurrentLanguage]["BtnExit"] ($buttonStartY + $buttonSpacing * 4) ([System.Drawing.Color]::FromArgb(185,45,45))  # Red
        Write-Host "✓ Special buttons created" -ForegroundColor Green

        # ===== Events shop =====
        Write-Host "`n🏪 Configuring events..." -ForegroundColor Cyan
        
        # Exit events section
        $btnExit.Add_Click({
            try {
                Write-Host "Closing application..." -ForegroundColor Yellow
                $form = $this.FindForm()
                if ($form) {
                    [System.Windows.Forms.Application]::Exit()
                    [Environment]::Exit(0)
                }
            }
            catch {
                Write-Host "❌ Error during closure: $_" -ForegroundColor Red
                [Environment]::Exit(1)
            }
        })
        Write-Host "✓ Exit event configured" -ForegroundColor Green

        # MAC events section
        $btnMacAddress.Add_Click({
            try {
                Write-Host "🔄 Loading MAC interface..." -ForegroundColor Gray
                # Load script in current scope
                . "$PSScriptRoot\Step4_MacAddressGUI.ps1"
                # Call function
                Show-MacAddressWindow
                Write-Host "✓ MAC interface closed" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Error loading MAC interface: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error loading MAC interface: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ MAC event configured" -ForegroundColor Green

        # Delete events section
        $btnDeleteStorage.Add_Click({
            try {
                Write-Host "🔄 Deleting storage.json file..." -ForegroundColor Gray
                # Load script in current scope
                . "$PSScriptRoot\Step5_FileManager.ps1"
                
                # Call delete function
                $result = Remove-CursorStorage
                
                if ($result.Success) {
                    [System.Windows.Forms.MessageBox]::Show(
                        "The storage.json file has been successfully deleted.",
                        "Success",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                } else {
                    [System.Windows.Forms.MessageBox]::Show(
                        $result.Message,
                        "Information",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                }
            }
            catch {
                Write-Host "❌ Error deleting file: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error deleting file: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Delete event configured" -ForegroundColor Green

        # Global execution events section
        $btnExecuteAll.Add_Click({
            try {
                # Load and execute script
                . "$PSScriptRoot\Step6_ExecuteAll.ps1"
                $results = Start-AllActions
                
                # Display result
                $message = @"
Actions summary:

MAC modification: $(if($results.MAC){'✓ Success'}else{'❌ Failed'})
storage.json deletion: $(if($results.Storage){'✓ Success'}else{'❌ Failed'})

Please proceed with your new registration
on cursor.com
"@
                
                if ((Show-CustomDialog -Message $message -Title "Actions Result") -eq [System.Windows.Forms.DialogResult]::OK) {
                    # Open browser after user clicked on cursor.com
                    Write-Host "`n=== Opening Cursor website ===" -ForegroundColor Yellow
                    try {
                        Start-Process "https://www.cursor.com/"
                        Write-Host "  ✓ Website opened successfully" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "  ❌ Error opening website: $_" -ForegroundColor Red
                        [System.Windows.Forms.MessageBox]::Show(
                            "Error opening website: $_",
                            "Error",
                            [System.Windows.Forms.MessageBoxButtons]::OK,
                            [System.Windows.Forms.MessageBoxIcon]::Error
                        )
                    }
                }
                
                # Update MAC information
                if ($macInfoLabel -and $macInfoLabel.IsHandleCreated) {
                    Write-Host "`n=== Updating MAC information ===" -ForegroundColor Yellow
                    Start-Sleep -Seconds 2  # Wait for network adapter to be properly reset
                    Update-MacInfoLabel -Label $macInfoLabel
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Error executing actions: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Global execution event configured" -ForegroundColor Green

        # Language events section
        $btnLanguage.Add_Click({
            try {
                $currentPath = $PSScriptRoot
                $isInEnglishFolder = $currentPath.EndsWith('\EN')
                
                # Determine script path to start
                if ($isInEnglishFolder) {
                    # If in EN, start FR version at root
                    $startPath = Join-Path (Split-Path $currentPath -Parent) "start.ps1"
                    $global:CurrentLanguage = "FR"
                } else {
                    # If at root, start EN version
                    $startPath = Join-Path $currentPath "EN\start.ps1"
                    $global:CurrentLanguage = "EN"
                }

                # Update interface texts
                $mainForm = $this.FindForm()
                if ($mainForm) {
                    $mainForm.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
                    foreach ($control in $mainForm.Controls) {
                        if ($control -is [System.Windows.Forms.Panel]) {
                            foreach ($panelControl in $control.Controls) {
                                if ($panelControl -is [System.Windows.Forms.Label]) {
                                    if ($panelControl.Font.Size -eq 32) {
                                        $panelControl.Text = $global:Translations[$global:CurrentLanguage]["MainTitle"]
                                    }
                                    elseif ($panelControl.Font.Size -eq 16) {
                                        $panelControl.Text = $global:Translations[$global:CurrentLanguage]["Subtitle"]
                                    }
                                }
                                elseif ($panelControl -is [System.Windows.Forms.Button]) {
                                    switch ($panelControl.Text) {
                                        "1. Change MAC address of a network adapter" { 
                                            $panelControl.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                                        }
                                        "2. Delete storage.json file" { 
                                            $panelControl.Text = $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]
                                        }
                                        "3. Execute all actions" { 
                                            $panelControl.Text = $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"]
                                        }
                                        "4. Exit" { 
                                            $panelControl.Text = $global:Translations[$global:CurrentLanguage]["BtnExit"]
                                        }
                                    }
                                }
                            }
                        }
                    }
                }

                # Check if script exists
                if (-not (Test-Path $startPath)) {
                    throw "Requested version does not exist. Please verify that the EN folder and its files are present."
                }

                Write-Host "Starting version in $startPath..." -ForegroundColor Yellow
                
                # Start new instance in hidden mode
                $startInfo = New-Object System.Diagnostics.ProcessStartInfo
                $startInfo.FileName = "pwsh.exe"
                $startInfo.Arguments = "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$startPath`""
                $startInfo.Verb = "RunAs"
                $startInfo.UseShellExecute = $true
                $startInfo.WindowStyle = [System.Diagnostics.ProcessWindowStyle]::Hidden
                
                [System.Windows.Forms.Application]::EnableVisualStyles()
                [System.Windows.Forms.Application]::DoEvents()
                
                $process = [System.Diagnostics.Process]::Start($startInfo)
                Start-Sleep -Seconds 1
                
                # Close current instance
                if ($mainForm) {
                    $mainForm.Close()
                    [System.Windows.Forms.Application]::Exit()
                    [Environment]::Exit(0)
                }
            }
            catch {
                Write-Host "❌ Error during language change: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error during language change: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Language event configured" -ForegroundColor Green

        # ===== Final assembly =====
        Write-Host "`n🔧 Assembling components..." -ForegroundColor Cyan
        
        # Add buttons section
        $mainPanel.Controls.AddRange(@(
            $btnLanguage,
            $btnMacAddress,
            $btnDeleteStorage,
            $btnExecuteAll,
            $btnExit
        ))
        Write-Host "✓ Buttons assembled" -ForegroundColor Green

        # Update MAC information
        try {
            Update-MacInfoLabel -Label $macInfoLabel
            Write-Host "✓ MAC information updated" -ForegroundColor Green
        }
        catch {
            $macInfoLabel.Text = $global:Translations[$global:CurrentLanguage]["NetworkError"]
            Write-Host "⚠️ Error updating MAC" -ForegroundColor Yellow
        }

        # ===== Final checkout =====
        Write-Host "`n Finalizing interface..." -ForegroundColor Cyan
        return @{
            Form = $mainForm
            LanguageButton = $btnLanguage
            MacAddressButton = $btnMacAddress
            DeleteStorageButton = $btnDeleteStorage
            ExecuteAllButton = $btnExecuteAll
            ExitButton = $btnExit
        }
    }
    catch {
        Write-Host "`n❌ Error creating interface: $_" -ForegroundColor Red
        return $null
    }
}

function Show-MainInterface {
    try {
        # Culture configuration
        [System.Windows.Forms.Application]::CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')
        
        # Launch interface
        $interface = Initialize-MainWindow
        if ($interface -and $interface.Form) {
            # Window configuration
            $interface.Form.Add_Load({
                $this.Activate()
                $this.BringToFront()
                $this.Focus()
            })
            
            # Start Windows Forms message loop
            [System.Windows.Forms.Application]::Run($interface.Form)
            return $true
        } else {
            throw "Failed to initialize interface"
        }
    }
    catch {
        Write-Host "❌ Error launching interface: $_" -ForegroundColor Red
        throw
    }
}

# Function to display a custom dialog
function Show-CustomDialog {
    param (
        [string]$Message,
        [string]$Title
    )
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size(400,250)
    $form.StartPosition = "CenterScreen"
    $form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
    $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true  # Force window to foreground
    $form.Focus()          # Give focus to window
    $form.BringToFront()   # Force window to foreground
    $form.Activate()       # Activate window

    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(20,20)
    $label.Size = New-Object System.Drawing.Size(360,100)
    $label.Text = $Message
    $label.ForeColor = [System.Drawing.Color]::White
    $label.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $label.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $form.Controls.Add($label)

    $btnExtension = New-Object System.Windows.Forms.Button
    $btnExtension.Location = New-Object System.Drawing.Point(20,130)
    $btnExtension.Size = New-Object System.Drawing.Size(360,30)
    $btnExtension.Text = "Install Temporary Email extension"
    $btnExtension.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
    $btnExtension.ForeColor = [System.Drawing.Color]::White
    $btnExtension.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnExtension.Add_Click({
        Start-Process "https://chromewebstore.google.com/detail/temporary-email-emailonde/mkpcaklladfpajiaikehdinfaabmnajh"
    })
    $form.Controls.Add($btnExtension)

    $btnOK = New-Object System.Windows.Forms.Button
    $btnOK.Location = New-Object System.Drawing.Point(200,170)
    $btnOK.Size = New-Object System.Drawing.Size(80,30)
    $btnOK.Text = "cursor.com"
    $btnOK.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $btnOK.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
    $btnOK.ForeColor = [System.Drawing.Color]::White
    $btnOK.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $form.Controls.Add($btnOK)

    $btnCancel = New-Object System.Windows.Forms.Button
    $btnCancel.Location = New-Object System.Drawing.Point(300,170)
    $btnCancel.Size = New-Object System.Drawing.Size(80,30)
    $btnCancel.Text = "Cancel"
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnOK
    $form.CancelButton = $btnCancel

    # Add event handler for window loading
    $form.Add_Load({
        $this.Activate()
        $this.BringToFront()
        $this.Focus()
    })

    return $form.ShowDialog()
} 