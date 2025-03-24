# =================================================================
# Fichier     : Step4_MacAddressGUI.ps1
# Role        : Interface graphique de gestion des adresses MAC
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
        $networkAdapterComboBox = New-Object System.Windows.Forms.ComboBox
        $networkAdapterComboBox.Location = New-Object System.Drawing.Point(20,45)
        $networkAdapterComboBox.Size = New-Object System.Drawing.Size(460,30)
        $networkAdapterComboBox.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $networkAdapterComboBox.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $networkAdapterComboBox.ForeColor = [System.Drawing.Color]::White
        $networkAdapterComboBox.DropDownStyle = [System.Windows.Forms.ComboBoxStyle]::DropDownList
        $form.Controls.Add($networkAdapterComboBox)

        # NE PAS SUPPRIMER - Labels pour l'affichage de l'adresse MAC actuelle
        $macAddressCurrentLabel = New-Object System.Windows.Forms.Label
        $macAddressCurrentLabel.Text = "Adresse MAC actuelle:"
        $macAddressCurrentLabel.Location = New-Object System.Drawing.Point(20,85)
        $macAddressCurrentLabel.Size = New-Object System.Drawing.Size(460,20)
        $macAddressCurrentLabel.ForeColor = [System.Drawing.Color]::White
        $macAddressCurrentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($macAddressCurrentLabel)

        $macAddressCurrentValue = New-Object System.Windows.Forms.Label
        $macAddressCurrentValue.Location = New-Object System.Drawing.Point(20,105)
        $macAddressCurrentValue.Size = New-Object System.Drawing.Size(460,20)
        $macAddressCurrentValue.ForeColor = [System.Drawing.Color]::FromArgb(0,120,215)
        $macAddressCurrentValue.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($macAddressCurrentValue)

        # NE PAS SUPPRIMER - Contrôles pour la nouvelle adresse MAC
        $macAddressNewLabel = New-Object System.Windows.Forms.Label
        $macAddressNewLabel.Text = "Nouvelle adresse MAC:"
        $macAddressNewLabel.Location = New-Object System.Drawing.Point(20,135)
        $macAddressNewLabel.Size = New-Object System.Drawing.Size(460,20)
        $macAddressNewLabel.ForeColor = [System.Drawing.Color]::White
        $macAddressNewLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($macAddressNewLabel)

        $macAddressNewInput = New-Object System.Windows.Forms.TextBox
        $macAddressNewInput.Location = New-Object System.Drawing.Point(20,160)
        $macAddressNewInput.Size = New-Object System.Drawing.Size(300,25)
        $macAddressNewInput.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $macAddressNewInput.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $macAddressNewInput.ForeColor = [System.Drawing.Color]::White
        $form.Controls.Add($macAddressNewInput)

        # NE PAS SUPPRIMER - Boutons d'action
        $macAddressGenerateButton = New-Object System.Windows.Forms.Button
        $macAddressGenerateButton.Text = "Générer une adresse MAC aléatoire"
        $macAddressGenerateButton.Location = New-Object System.Drawing.Point(20,195)
        $macAddressGenerateButton.Size = New-Object System.Drawing.Size(460,30)
        $macAddressGenerateButton.ForeColor = [System.Drawing.Color]::White
        $macAddressGenerateButton.BackColor = [System.Drawing.Color]::FromArgb(0,120,215)
        $macAddressGenerateButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $macAddressGenerateButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($macAddressGenerateButton)

        $macAddressApplyButton = New-Object System.Windows.Forms.Button
        $macAddressApplyButton.Text = "Appliquer le changement"
        $macAddressApplyButton.Location = New-Object System.Drawing.Point(20,235)
        $macAddressApplyButton.Size = New-Object System.Drawing.Size(460,30)
        $macAddressApplyButton.ForeColor = [System.Drawing.Color]::White
        $macAddressApplyButton.BackColor = [System.Drawing.Color]::FromArgb(60,60,60)
        $macAddressApplyButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $macAddressApplyButton.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $form.Controls.Add($macAddressApplyButton)

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
        $networkAdapters = Get-NetworkAdapters
        foreach ($adapter in $networkAdapters) {
            # Créer une description simplifiée de l'adaptateur
            $speedGbps = [math]::Round($adapter.Speed / 1000000000, 2)
            $adapterInfo = "$($adapter.ProductName) - $speedGbps Gbps"
            $networkAdapterComboBox.Items.Add($adapterInfo)
        }
        if ($networkAdapterComboBox.Items.Count -gt 0) {
            $networkAdapterComboBox.SelectedIndex = 0
            $macAddressCurrentValue.Text = $networkAdapters[0].MacAddress
        } else {
            $errorLabel.Text = "Aucun adaptateur réseau physique trouvé"
            $macAddressApplyButton.Enabled = $false
            $macAddressGenerateButton.Enabled = $false
        }
        #endregion

        #region Configuration des événements
        # NE PAS SUPPRIMER - Événements de l'interface
        $networkAdapterComboBox.Add_SelectedIndexChanged({
            $selectedAdapter = $networkAdapters[$networkAdapterComboBox.SelectedIndex]
            $macAddressCurrentValue.Text = $selectedAdapter.MacAddress
        })

        $macAddressGenerateButton.Add_Click({
            $macAddressNewInput.Text = New-MacAddress
        })

        $macAddressApplyButton.Add_Click({
            $errorLabel.Text = ""
            if ($networkAdapterComboBox.SelectedItem -and $macAddressNewInput.Text) {
                try {
                    $selectedAdapter = $networkAdapters[$networkAdapterComboBox.SelectedIndex]
                    $newMacAddress = $macAddressNewInput.Text
                    
                    if (Test-MacAddress -MacAddress $newMacAddress) {
                        $macAddressApplyButton.Enabled = $false
                        $macAddressApplyButton.Text = "Modification en cours..."
                        $form.Cursor = [System.Windows.Forms.Cursors]::WaitCursor
                        
                        # Ajouter journalisation détaillée
                        Write-ConsoleLog "Tentative de modification d'adresse MAC pour $($selectedAdapter.Name)" -Color Cyan
                        Write-ConsoleLog "Nouvelle adresse MAC: $newMacAddress" -Color Cyan
                        
                        $result = Set-MacAddress -AdapterName $selectedAdapter.Name -MacAddress $newMacAddress
                        if (-not $result) {
                            Write-ConsoleLog "Échec de la modification de l'adresse MAC" -Color Red
                            $errorLabel.Text = "Échec de la modification de l'adresse MAC. Vérifiez les permissions administrateur."
                            
                            # Afficher une boîte de dialogue avec plus d'informations
                            [System.Windows.Forms.MessageBox]::Show(
                                "La modification de l'adresse MAC a échoué.`n`nAssurez-vous de :`n- Exécuter en tant qu'administrateur`n- Vérifier que l'adaptateur n'est pas utilisé par un autre programme`n`nConsultez les logs dans la console pour plus de détails.",
                                "Erreur",
                                [System.Windows.Forms.MessageBoxButtons]::OK,
                                [System.Windows.Forms.MessageBoxIcon]::Error
                            )
                        } else {
                            Write-ConsoleLog "Adresse MAC modifiée avec succès" -Color Green
                            # Mettre à jour l'affichage et notifier le succès
                            $macAddressCurrentValue.Text = $newMacAddress
                            [System.Windows.Forms.MessageBox]::Show(
                                "L'adresse MAC a été modifiée avec succès.`n`nNouvelle adresse: $newMacAddress",
                                "Succès",
                                [System.Windows.Forms.MessageBoxButtons]::OK,
                                [System.Windows.Forms.MessageBoxIcon]::Information
                            )
                        }
                    } else {
                        $errorLabel.Text = "Format d'adresse MAC invalide. Format attendu: XX-XX-XX-XX-XX-XX"
                    }
                }
                catch {
                    Write-ConsoleLog "Error détaillée: $($_.Exception.Message)" -Color Red
                    $errorLabel.Text = "Error: $($_.Exception.Message)"
                    
                    [System.Windows.Forms.MessageBox]::Show(
                        "Une erreur est survenue lors de la modification de l'adresse MAC:`n$($_.Exception.Message)`n`nVérifiez que vous exécutez l'application en tant qu'administrateur.",
                        "Erreur",
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Error
                    )
                }
                finally {
                    $macAddressApplyButton.Enabled = $true
                    $macAddressApplyButton.Text = "Appliquer le changement"
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





