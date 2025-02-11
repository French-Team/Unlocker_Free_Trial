# =================================================================
# Fichier     : Step4_MacAddressGUI.ps1
# Role        : Centre commercial principal de l'interface graphique
# Magasins    : - Magasin des configurations (imports et setup)
#               - Magasin des composants (interface graphique)
#               - Magasin des événements (gestion des actions)
# Connection  : Utilise Step3_MacInfo.ps1 et Step4_MacAddress.ps1
# =================================================================

#region Fonction d'affichage des logs
# NE PAS SUPPRIMER - Fonction utilisée pour l'affichage des messages dans la console
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

#region Fonction principale de l'interface MAC
# NE PAS SUPPRIMER - Fonction principale pour l'interface de modification d'adresse MAC
function Show-MacAddressWindow {
    Clear-Host
    Write-ConsoleLog "=== Interface de Modification d'Adresse MAC ===" -Color Cyan
    Write-ConsoleLog "Initialisation..." -Color Gray

    try {
        #region Configuration initiale
        # ===== Magasin des configurations =====
        Write-ConsoleLog "Configuration du magasin..." -Color Cyan
        
        # NE PAS SUPPRIMER - Vérification des chemins
        $scriptPath = $PSScriptRoot
        if (-not $scriptPath) {
            $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
        }
        if (-not $scriptPath) {
            $scriptPath = (Get-Location).Path
        }
        
        Write-ConsoleLog "Chemin du script: $scriptPath" -Color Gray
        
        # NE PAS SUPPRIMER - Vérification des fichiers requis
        $requiredFiles = @(
            "Step3_MacInfo.ps1",
            "Step4_MacAddress.ps1"
        )
        
        foreach ($file in $requiredFiles) {
            $filePath = Join-Path -Path $scriptPath -ChildPath $file
            Write-ConsoleLog "Recherche de $file..." -Color Gray
            
            if (-not (Test-Path -Path $filePath)) {
                throw "Fichier requis non trouvé: $file"
            }
            
            Write-ConsoleLog "Chargement de $file" -Color Green
            . $filePath
        }
        #endregion

        #region Chargement des composants Windows Forms
        # NE PAS SUPPRIMER - Chargement des assemblies nécessaires
        Write-ConsoleLog "Chargement des composants Windows Forms..." -Color Gray
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing
        Write-ConsoleLog "Composants Windows Forms chargés" -Color Green
        #endregion

        #region Création de l'interface
        # ===== Magasin des composants =====
        Write-ConsoleLog "Création des composants..." -Color Cyan

        # NE PAS SUPPRIMER - Création de la fenêtre principale
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Modification d'adresse MAC"
        $form.Size = New-Object System.Drawing.Size(500,350)
        $form.StartPosition = "CenterScreen"
        $form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $form.ForeColor = [System.Drawing.Color]::White
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $form.MaximizeBox = $false
        $form.TopMost = $true
        $form.Focus()          # Donner le focus à la fenêtre
        $form.BringToFront()   # Forcer la fenêtre au premier plan
        $form.Activate()       # Activer la fenêtre

        # NE PAS SUPPRIMER - Création des contrôles de l'interface
        # Label pour le sélecteur de carte réseau
        $selectLabel = New-Object System.Windows.Forms.Label
        $selectLabel.Text = "Sélectionnez un adaptateur réseau:"
        $selectLabel.Location = New-Object System.Drawing.Point(20,20)
        $selectLabel.Size = New-Object System.Drawing.Size(460,20)
        $selectLabel.ForeColor = [System.Drawing.Color]::White
        $selectLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($selectLabel)

        # NE PAS SUPPRIMER - ComboBox pour la sélection de la carte réseau
        $adapterComboBox = New-Object System.Windows.Forms.ComboBox
        $adapterComboBox.Location = New-Object System.Drawing.Point(20,45)
        $adapterComboBox.Size = New-Object System.Drawing.Size(460,30)
        $adapterComboBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $adapterComboBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $adapterComboBox.ForeColor = [System.Drawing.Color]::White
        $adapterComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
        $form.Controls.Add($adapterComboBox)

        # NE PAS SUPPRIMER - Labels pour l'affichage de l'adresse MAC actuelle
        $currentMacLabel = New-Object System.Windows.Forms.Label
        $currentMacLabel.Text = "Adresse MAC actuelle:"
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

        # NE PAS SUPPRIMER - Contrôles pour la nouvelle adresse MAC
        $newMacLabel = New-Object System.Windows.Forms.Label
        $newMacLabel.Text = "Nouvelle adresse MAC:"
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

        # NE PAS SUPPRIMER - Boutons d'action
        $btnGenerate = New-Object System.Windows.Forms.Button
        $btnGenerate.Text = "Générer une adresse MAC aléatoire"
        $btnGenerate.Location = New-Object System.Drawing.Point(20,195)
        $btnGenerate.Size = New-Object System.Drawing.Size(460,30)
        $btnGenerate.ForeColor = [System.Drawing.Color]::White
        $btnGenerate.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
        $btnGenerate.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnGenerate.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($btnGenerate)

        $btnChange = New-Object System.Windows.Forms.Button
        $btnChange.Text = "Appliquer le changement"
        $btnChange.Location = New-Object System.Drawing.Point(20,235)
        $btnChange.Size = New-Object System.Drawing.Size(460,30)
        $btnChange.ForeColor = [System.Drawing.Color]::White
        $btnChange.BackColor = [System.Drawing.Color]::FromArgb(60,60,60)
        $btnChange.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnChange.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($btnChange)

        # NE PAS SUPPRIMER - Label pour les messages d'erreur
        $errorLabel = New-Object System.Windows.Forms.Label
        $errorLabel.Location = New-Object System.Drawing.Point(20,320)
        $errorLabel.Size = New-Object System.Drawing.Size(460,20)
        $errorLabel.ForeColor = [System.Drawing.Color]::Red
        $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 8)
        $errorLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $form.Controls.Add($errorLabel)
        #endregion

        #region Initialisation des données
        # NE PAS SUPPRIMER - Remplissage de la liste des adaptateurs
        $adapters = Get-NetworkAdapters
        foreach ($adapter in $adapters) {
            $adapterComboBox.Items.Add($adapter.InterfaceDescription)
        }
        if ($adapterComboBox.Items.Count -gt 0) {
            $adapterComboBox.SelectedIndex = 0
            $currentMacValue.Text = $adapters[0].MacAddress
        }
        #endregion

        #region Configuration des événements
        # NE PAS SUPPRIMER - Événements de l'interface
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
                        $btnChange.Text = "Modification en cours..."
                        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
                        
                        $result = Set-MacAddress -AdapterName $selectedAdapter.Name -MacAddress $newMac
                        if (-not $result) {
                            $errorLabel.Text = "Error lors de la modification de l'adresse MAC. Vérifiez les logs dans la console."
                        } else {
                            $currentMacValue.Text = $newMac
                            [System.Windows.Forms.MessageBox]::Show(
                                "L'adresse MAC a été modifiée avec succès.",
                                "Success",
                                [System.Windows.Forms.MessageBoxButtons]::OK,
                                [System.Windows.Forms.MessageBoxIcon]::Information
                            )
                        }
                    } else {
                        $errorLabel.Text = "Format d'adresse MAC invalide. Format attendu: XX-XX-XX-XX-XX-XX"
                    }
                }
                catch {
                    $errorLabel.Text = "Error: $_"
                    Write-Host "Error détaillée: $($_.Exception.Message)" -ForegroundColor Red
                }
                finally {
                    $btnChange.Enabled = $true
                    $btnChange.Text = "Appliquer le changement"
                    $form.Cursor = [System.Windows.Forms.Cursors]::Default
                }
            }
        })
        #endregion

        #region Affichage de l'interface
        # NE PAS SUPPRIMER - Lancement de l'interface
        Write-ConsoleLog "Affichage de l'interface..." -Color Cyan
        [System.Windows.Forms.Application]::EnableVisualStyles()
        $form.ShowDialog()
        Write-ConsoleLog "Interface fermée" -Color Green
        #endregion
    }
    catch {
        $errorMessage = "Error lors du chargement de l'interface MAC: $_"
        Write-ConsoleLog $errorMessage -Color Red
        [System.Windows.Forms.MessageBox]::Show(
            $errorMessage,
            "Error",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
}
#endregion





