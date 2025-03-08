# =================================================================
# Fichier     : Step3_Interface.ps1
# Role        : Boutique spécialisée de l'interface utilisateur
# Magasins    : - Magasin des composants (fenêtres, panneaux)
#               - Magasin des styles (boutons, étiquettes)
#               - Magasin des événements (clics, survols)
# =================================================================

# Charger les dépendances seulement si on n'est pas en mode test
if (-not $env:TEST_MODE) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}

# Variables globales pour la langue
$global:CurrentLanguage = "FR"
$global:Translations = @{
    "FR" = @{
        "WindowTitle" = "Unlocker 3.0 - Essai gratuit"
        "MainTitle" = "Unlocker"
        "numTitle" = "3.0" 
        "freeTitle" = "Essai gratuit"
        "Subtitle" = "Renouveler" 
        "iconTitle" = "👻"
        "CursorTitle" = "Cursor"
        "BtnMacAddress" = "1. Modifier l'adresse MAC"
        "BtnDeleteStorage" = "2. Supprimer storage.json"
        "BtnExecuteAll" = "3. Exécuter toutes les actions"
        "BtnExit" = "4. Quitter"
        "Ready" = "Prêt"
        "NetworkCard" = "Carte réseau active"
        "MacAddress" = "Adresse MAC"
        "NoNetwork" = "Aucune carte réseau active trouvée"
        "NetworkError" = "Impossible de récupérer les informations réseau"
        
        # Nouveaux messages
        "SuccessTitle" = "Succès"
        "ErrorTitle" = "Erreur"
        "InfoTitle" = "Information"
        "MacSuccessMsg" = "L'adresse MAC a été modifiée avec succès."
        "StorageSuccessMsg" = "Le fichier storage.json a été supprimé avec succès."
        "ErrorOccurred" = "Une erreur est survenue: "
        "SummaryTitle" = "Résumé"
        "SummaryHeader" = "Résumé des actions :"
        "MacSuccess" = "✓ Succès"
        "MacFailure" = "❌ Échec"
        "StorageSuccess" = "✓ Succès"
        "StorageFailure" = "❌ Échec - "
        "RegistrationPrompt" = "Veuillez procéder à votre nouvelle inscription sur cursor.com"
        "GoToCursor" = "Aller sur cursor.com"
        "TempEmails" = "Emails Temporaires"
        
        # Messages de progression
        "Initializing" = "Initialisation..."
        "LoadingMacScript" = "Chargement du script MAC..."
        "GettingNetworkAdapter" = "Récupération de l'adaptateur réseau..."
        "GeneratingMacAddress" = "Génération de la nouvelle adresse MAC..."
        "ApplyingMacAddress" = "Application de la nouvelle adresse MAC..."
        "MacAddressModified" = "Adresse MAC modifiée avec succès"
        "LoadingFileManager" = "Chargement du script de gestion des fichiers..."
        "CheckingStorage" = "Vérification du fichier storage.json..."
        "DeletingStorage" = "Suppression du fichier storage.json..."
        "StorageDeleted" = "Fichier storage.json supprimé avec succès"
        "ActionsCompleted" = "Actions terminées"
    }
    "EN" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker"
        "numTitle" = "3.0" 
        "freeTitle" = "Free Trial"
        "Subtitle" = "Renew" 
        "iconTitle" = "👻"
        "CursorTitle" = "Cursor"
        "BtnMacAddress" = "1. Change MAC Address"
        "BtnDeleteStorage" = "2. Delete storage.json"
        "BtnExecuteAll" = "3. Execute All Actions"
        "BtnExit" = "4. Exit"
        "Ready" = "Ready"
        "NetworkCard" = "Active Network Card"
        "MacAddress" = "MAC Address"
        "NoNetwork" = "No active network card found"
        "NetworkError" = "Unable to retrieve network information"
        
        # Nouveaux messages
        "SuccessTitle" = "Success"
        "ErrorTitle" = "Error"
        "InfoTitle" = "Information"
        "MacSuccessMsg" = "MAC address has been successfully changed."
        "StorageSuccessMsg" = "The storage.json file has been successfully deleted."
        "ErrorOccurred" = "An error occurred: "
        "SummaryTitle" = "Summary"
        "SummaryHeader" = "Actions summary:"
        "MacSuccess" = "✓ Success"
        "MacFailure" = "❌ Failed"
        "StorageSuccess" = "✓ Success"
        "StorageFailure" = "❌ Failed - "
        "RegistrationPrompt" = "Please proceed with your new registration on cursor.com"
        "GoToCursor" = "Go to cursor.com"
        "TempEmails" = "Temporary Emails"
        
        # Messages de progression
        "Initializing" = "Initializing..."
        "LoadingMacScript" = "Loading MAC script..."
        "GettingNetworkAdapter" = "Getting network adapter..."
        "GeneratingMacAddress" = "Generating new MAC address..."
        "ApplyingMacAddress" = "Applying new MAC address..."
        "MacAddressModified" = "MAC address successfully modified"
        "LoadingFileManager" = "Loading file manager script..."
        "CheckingStorage" = "Checking for storage.json file..."
        "DeletingStorage" = "Deleting storage.json file..."
        "StorageDeleted" = "Storage.json file successfully deleted"
        "ActionsCompleted" = "Actions completed"
    }
}

function global:Initialize-MainWindow {
    try {
        # ===== Magasin des composants principaux =====
        Write-Host "🏪 Création des composants principaux..." -ForegroundColor Cyan
        
        # Section fenêtre principale
        $mainForm = New-Object System.Windows.Forms.Form
        $mainForm.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
        $mainForm.Size = New-Object System.Drawing.Size(700,550) 
        $mainForm.StartPosition = "CenterScreen"
        $mainForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $mainForm.ForeColor = [System.Drawing.Color]::White
        $mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $mainForm.MaximizeBox = $false
        $mainForm.TopMost = $true
        $mainForm.Focus()
        $mainForm.BringToFront()
        $mainForm.Activate()

        # Gestion de la fermeture
        $mainForm.Add_FormClosing({
            param($sender, $e)
            Write-Host "Fermeture de l'application..." -ForegroundColor Yellow
            [System.Windows.Forms.Application]::Exit()
            [Environment]::Exit(0)
        })
        Write-Host "✓ Fenêtre principale créée" -ForegroundColor Green

        # Section panneau principal
        $mainPanel = New-Object System.Windows.Forms.Panel
        $mainPanel.Size = New-Object System.Drawing.Size(680,550)
        $mainPanel.Location = New-Object System.Drawing.Point(10,10)
        $mainPanel.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $mainForm.Controls.Add($mainPanel)

        # Suspendre le layout pour éviter le scintillement
        $mainPanel.SuspendLayout()

        # ===== Magasin des styles =====
        Write-Host "`n🏪 Configuration des styles..." -ForegroundColor Cyan
        
        # Section dimensions des boutons
        $buttonWidth = 600
        $buttonHeight = 35
        $buttonX = [int](($mainPanel.Width - $buttonWidth) / 2)
        $buttonStartY = 250  # Position après le panneau MAC
        $buttonSpacing = 45  # Espacement entre les boutons

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
                [System.Drawing.Color]$customBackColor = [System.Drawing.Color]::FromArgb(50,50,50),
                [Parameter(Mandatory=$false)]
                [string]$fontFamily = "consolas",
                [Parameter(Mandatory=$false)]
                [int]$fontSize = 11
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
                $button.Font = New-Object System.Drawing.Font($fontFamily, $fontSize)
                $button.ForeColor = [System.Drawing.Color]::White
                $button.BackColor = $customBackColor
                $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                $button.FlatAppearance.BorderSize = 1
                $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)
                $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60,60,60)
                $button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(70,70,70)
                $button.Cursor = [System.Windows.Forms.Cursors]::Hand
                $button.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter

                # Effet de survol
                $button.Add_MouseEnter({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
                    }
                })
                
                $button.Add_MouseLeave({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)
                    }
                })

                return $button
            }
            catch {
                Write-Host "  ❌ Erreur lors de la création du bouton: $_" -ForegroundColor Red
                throw
            }
        }

        # ===== Magasin des composants =====
        Write-Host "`n🏪 Création des composants..." -ForegroundColor Cyan

        # Bouton de langue
        $btnLang = Create-StyledButton -text "FR/EN" -y 10 -width 80 -height 30 -fontFamily "consolas" -fontSize 10
        $btnLang.Location = New-Object System.Drawing.Point([int](($mainPanel.Width - 80) / 2), 10)
        $btnLang.Tag = "btnLang"
        $mainPanel.Controls.Add($btnLang)
        

        # Titre principal (Unlocker)
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = $global:Translations[$global:CurrentLanguage]["MainTitle"]
        $titleLabel.Font = New-Object System.Drawing.Font("Verdana", 38)
        $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $titleLabel.Size = New-Object System.Drawing.Size(260,60)
        $titleLabel.Location = New-Object System.Drawing.Point(60,30)
        $titleLabel.Tag = "titleLabel"
        $mainPanel.Controls.Add($titleLabel)

        # Version (3.0)
        $numTitleLabel = New-Object System.Windows.Forms.Label
        $numTitleLabel.Text = $global:Translations[$global:CurrentLanguage]["numTitle"]
        $numTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 40)
        $numTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $numTitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $numTitleLabel.Size = New-Object System.Drawing.Size(100,60)
        $numTitleLabel.Location = New-Object System.Drawing.Point(295,40)
        $numTitleLabel.Tag = "numTitleLabel"
        $mainPanel.Controls.Add($numTitleLabel)


        # Essai gratuit
        $freeTitleLabel = New-Object System.Windows.Forms.Label
        $freeTitleLabel.Text = $global:Translations[$global:CurrentLanguage]["freeTitle"]
        $freeTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 14)
        $freeTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)  # Gris clair
        $freeTitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $freeTitleLabel.Size = New-Object System.Drawing.Size(190,30)
        $freeTitleLabel.Location = New-Object System.Drawing.Point(380,60)
        $freeTitleLabel.Tag = "freeTitleLabel"
        $mainPanel.Controls.Add($freeTitleLabel)

        
        # Sous-titre ligne (Débloquer 👻 Cursor)
        $subtitleLabel1 = New-Object System.Windows.Forms.Label
        $subtitleLabel1.Text = $global:Translations[$global:CurrentLanguage]["Subtitle"]
        $subtitleLabel1.Font = New-Object System.Drawing.Font("Segoe UI Light", 20)
        $subtitleLabel1.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)  # Gris clair
        $subtitleLabel1.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
        $subtitleLabel1.Size = New-Object System.Drawing.Size(150,40)
        $subtitleLabel1.Location = New-Object System.Drawing.Point(155,80)
        $subtitleLabel1.Tag = "subtitleLabel1"
        $mainPanel.Controls.Add($subtitleLabel1)


        $iconTitleLabel = New-Object System.Windows.Forms.Label
        $iconTitleLabel.Text = $global:Translations[$global:CurrentLanguage]["iconTitle"]
        $iconTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 20)
        $iconTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $iconTitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $iconTitleLabel.Size = New-Object System.Drawing.Size(50,40)
        $iconTitleLabel.Location = New-Object System.Drawing.Point(320,100)
        $iconTitleLabel.Tag = "iconTitleLabel"
        $mainPanel.Controls.Add($iconTitleLabel)


        $subtitleLabel2 = New-Object System.Windows.Forms.Label
        $subtitleLabel2.Text = $global:Translations[$global:CurrentLanguage]["CursorTitle"]
        $subtitleLabel2.Font = New-Object System.Drawing.Font("consolas", 32)
        $subtitleLabel2.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $subtitleLabel2.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        $subtitleLabel2.Size = New-Object System.Drawing.Size(220,40)
        $subtitleLabel2.Location = New-Object System.Drawing.Point(380,80)
        $subtitleLabel2.Tag = "subtitleLabel2"
        $mainPanel.Controls.Add($subtitleLabel2)


        # Panneau MAC
        $macInfoPanel = New-Object System.Windows.Forms.Panel
        $macInfoPanel.Location = New-Object System.Drawing.Point(90,150)
        $macInfoPanel.Size = New-Object System.Drawing.Size(500,80)
        $macInfoPanel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $mainPanel.Controls.Add($macInfoPanel)


        # Label MAC
        $macInfoLabel = New-Object System.Windows.Forms.Label
        $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
        $macInfoLabel.Size = New-Object System.Drawing.Size(480,60)
        $macInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $macInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
        $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $macInfoPanel.Controls.Add($macInfoLabel)
        $macInfoLabel.BringToFront()

        # Boutons principaux
        $btnMacAddress = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnMacAddress"] -y $buttonStartY -fontFamily "consolas"
        $btnMacAddress.Tag = "btnMacAddress"
        $btnDeleteStorage = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"] -y ($buttonStartY + $buttonSpacing) -fontFamily "consolas"
        $btnDeleteStorage.Tag = "btnDeleteStorage"
        $btnExecuteAll = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"] -y ($buttonStartY + $buttonSpacing * 2) -customBackColor ([System.Drawing.Color]::FromArgb(255,140,0)) -fontFamily "consolas"
        $btnExecuteAll.Tag = "btnExecuteAll"
        $btnExit = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnExit"] -y ($buttonStartY + $buttonSpacing * 3) -customBackColor ([System.Drawing.Color]::FromArgb(185,45,45)) -fontFamily "consolas"
        $btnExit.Tag = "btnExit"

        # Barre de progression
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Location = New-Object System.Drawing.Point($buttonX, ($buttonStartY + $buttonSpacing * 4))
        $progressBar.Size = New-Object System.Drawing.Size($buttonWidth, 10)  # Plus fine
        $progressBar.Style = 'Continuous'
        $progressBar.Value = 0
        $progressBar.BackColor = [System.Drawing.Color]::FromArgb(20,20,20)  # Fond sombre
        $progressBar.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $progressBar.MarqueeAnimationSpeed = 30
        $progressBar.Visible = $true
        $mainPanel.Controls.Add($progressBar)
        $mainPanel.Controls.Add($progressBar)

        # Label de statut
        $statusLabel = New-Object System.Windows.Forms.Label
        $statusLabel.Location = New-Object System.Drawing.Point($buttonX, ($buttonStartY + $buttonSpacing * 4 + 20))
        $statusLabel.Size = New-Object System.Drawing.Size($buttonWidth, 40)
        $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)  # Plus grand
        $statusLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        $statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
        $mainPanel.Controls.Add($statusLabel)
        $mainPanel.Controls.Add($statusLabel)

        # Nettoyer les contrôles existants
        $mainPanel.Controls.Clear()

        # Ajouter les contrôles dans l'ordre (du fond vers l'avant)
        # Panneau MAC (fond)
        $mainPanel.Controls.Add($macInfoPanel)

        # Bouton de langue (premier plan)
        $mainPanel.Controls.Add($btnLang)

        # Boutons principaux
        $mainPanel.Controls.Add($btnMacAddress)
        $mainPanel.Controls.Add($btnDeleteStorage)
        $mainPanel.Controls.Add($btnExecuteAll)
        $mainPanel.Controls.Add($btnExit)

        # Barre de progression et statut
        $mainPanel.Controls.Add($progressBar)
        $mainPanel.Controls.Add($statusLabel)

        # Titres et sous-titres
        $mainPanel.Controls.Add($freeTitleLabel)
        $mainPanel.Controls.Add($subtitleLabel2)       
        $mainPanel.Controls.Add($iconTitleLabel)     
        $mainPanel.Controls.Add($numTitleLabel)
        $mainPanel.Controls.Add($titleLabel)
        $mainPanel.Controls.Add($subtitleLabel1)

        

        # Réactiver le layout
        $mainPanel.ResumeLayout($true)

        # ===== Magasin des événements =====
        Write-Host "`n🏪 Configuration des événements..." -ForegroundColor Cyan
        
        # Section événements de sortie
        $btnExit.Add_Click({
            try {
                Write-Host "Fermeture de l'application..." -ForegroundColor Yellow
                $form = $this.FindForm()
                if ($form) {
                    [System.Windows.Forms.Application]::Exit()
                    [Environment]::Exit(0)
                }
            }
            catch {
                Write-Host "❌ Erreur lors de la fermeture: $_" -ForegroundColor Red
                [Environment]::Exit(1)
            }
        })

        # Section événements MAC
        $btnMacAddress.Add_Click({
            try {
                Write-Host "🔄 Chargement de l'interface MAC..." -ForegroundColor Gray
                
                # Récupérer le label de statut depuis le formulaire
                $form = $this.FindForm()
                $statusLabel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Font.Size -eq 11 }
                
                if ($statusLabel) {
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                    
                    # Charger et exécuter le script MAC
                    . "$PSScriptRoot\Step4_MacAddress.ps1"
                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                    if ($adapter) {
                        $newMac = New-MacAddress
                        if ($newMac) {
                            $result = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                            if ($result) {
                                [System.Windows.Forms.MessageBox]::Show(
                                    $global:Translations[$global:CurrentLanguage]["MacSuccessMsg"],
                                    $global:Translations[$global:CurrentLanguage]["SuccessTitle"],
                                    [System.Windows.Forms.MessageBoxButtons]::OK,
                                    [System.Windows.Forms.MessageBoxIcon]::Information
                                )
                            }
                        }
                    }
                    
                    Start-Sleep -Seconds 1
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                }
            }
            catch {
                Write-Host "❌ Erreur lors de la modification MAC: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    $global:Translations[$global:CurrentLanguage]["ErrorOccurred"] + $_,
                    $global:Translations[$global:CurrentLanguage]["ErrorTitle"],
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })

        # Section événements Storage
        $btnDeleteStorage.Add_Click({
            try {
                Write-Host "🔄 Suppression du fichier storage.json..." -ForegroundColor Gray
                
                # Récupérer les contrôles depuis le formulaire
                $form = $this.FindForm()
                $statusLabel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Font.Size -eq 11 }
                
                if ($statusLabel) {
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]
                    
                    # Déterminer le chemin du script
                    $scriptPath = Join-Path $PSScriptRoot "Step5_FileManager.ps1"
                    Write-Host "PSScriptRoot: $PSScriptRoot" -ForegroundColor Gray
                    Write-Host "Chemin complet du script: $scriptPath" -ForegroundColor Gray
                    
                    # Vérifier si le fichier existe
                    if (Test-Path $scriptPath) {
                        Write-Host "Le fichier existe, tentative de chargement..." -ForegroundColor Gray
                        . $scriptPath
                        Write-Host "Script chargé avec succès" -ForegroundColor Green
                        
                        $result = Remove-CursorStorage
                
                if ($result.Success) {
                    [System.Windows.Forms.MessageBox]::Show(
                                $global:Translations[$global:CurrentLanguage]["StorageSuccessMsg"],
                                $global:Translations[$global:CurrentLanguage]["SuccessTitle"],
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                } else {
                    [System.Windows.Forms.MessageBox]::Show(
                        $result.Message,
                                $global:Translations[$global:CurrentLanguage]["InfoTitle"],
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                        }
                    } else {
                        Write-Host "❌ Le fichier n'existe pas à l'emplacement: $scriptPath" -ForegroundColor Red
                        throw "Le fichier Step5_FileManager.ps1 n'existe pas à l'emplacement: $scriptPath"
                    }
                    
                    Start-Sleep -Seconds 1
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                }
            }
            catch {
                Write-Host "❌ Erreur lors de la suppression du storage: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    $global:Translations[$global:CurrentLanguage]["ErrorOccurred"] + $_,
                    $global:Translations[$global:CurrentLanguage]["ErrorTitle"],
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })

        # Section événements Execute All
        $btnExecuteAll.Add_Click({
            try {
                # Récupérer les contrôles depuis le formulaire
                $form = $this.FindForm()
                $statusLabel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Font.Size -eq 11 }
                $progressBar = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.ProgressBar] }
                
                if ($statusLabel -and $progressBar) {
                    $this.Enabled = $false
                    $progressBar.Value = 0
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Initializing"]
                    Start-Sleep -Milliseconds 500
                    
                    # Mise à jour de la progression pour la modification MAC
                    $progressBar.Value = 10
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["LoadingMacScript"]
                    Start-Sleep -Milliseconds 500
                    
                    # Charger et exécuter le script MAC
                    . "$PSScriptRoot\Step4_MacAddress.ps1"
                    $progressBar.Value = 20
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["GettingNetworkAdapter"]
                    Start-Sleep -Milliseconds 500
                    
                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                    $macResult = $false
                    if ($adapter) {
                        $progressBar.Value = 30
                        $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["GeneratingMacAddress"]
                        Start-Sleep -Milliseconds 500
                        
                        $newMac = New-MacAddress
                        if ($newMac) {
                            $progressBar.Value = 40
                            $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["ApplyingMacAddress"]
                            Start-Sleep -Milliseconds 500
                            
                            $macResult = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                            if ($macResult) {
                                $progressBar.Value = 50
                                $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["MacAddressModified"]
                                Start-Sleep -Milliseconds 500
                            }
                        }
                    }
                    
                    # Mise à jour de la progression pour la suppression du storage
                    $progressBar.Value = 60
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["LoadingFileManager"]
                    Start-Sleep -Milliseconds 500
                    
                    # Charger et exécuter le script de suppression du storage
                    $scriptPath = Join-Path $PSScriptRoot "Step5_FileManager.ps1"
                    $storageResult = $false
                    $storageMessage = "Le fichier storage.json n'existe pas"
                    
                    if (Test-Path $scriptPath) {
                        $progressBar.Value = 70
                        $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["CheckingStorage"]
                        Start-Sleep -Milliseconds 500
                        
                        . $scriptPath
                        $progressBar.Value = 80
                        $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["DeletingStorage"]
                        Start-Sleep -Milliseconds 500
                        
                        $result = Remove-CursorStorage
                        $storageResult = $result.Success
                        $storageMessage = $result.Message
                        
                        if ($storageResult) {
                            $progressBar.Value = 90
                            $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["StorageDeleted"]
                            Start-Sleep -Milliseconds 500
                        }
                    }
                    
                    # Mise à jour finale de la progression
                    $progressBar.Value = 100
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["ActionsCompleted"]
                    Start-Sleep -Milliseconds 500
                    
                    # Créer la fenêtre de résumé avec les boutons
                    $summaryForm = New-Object System.Windows.Forms.Form
                    $summaryForm.Text = $global:Translations[$global:CurrentLanguage]["SummaryTitle"]
                    $summaryForm.Size = New-Object System.Drawing.Size(400, 300)
                    $summaryForm.StartPosition = "CenterScreen"
                    $summaryForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
                    $summaryForm.ForeColor = [System.Drawing.Color]::White
                    $summaryForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
                    $summaryForm.MaximizeBox = $false
                    $summaryForm.TopMost = $true
                    
                    # Label de résumé
                    $summaryLabel = New-Object System.Windows.Forms.Label
                    $summaryLabel.Text = @"
$($global:Translations[$global:CurrentLanguage]["SummaryHeader"])

$($global:Translations[$global:CurrentLanguage]["BtnMacAddress"]): $(if($macResult){$global:Translations[$global:CurrentLanguage]["MacSuccess"]}else{$global:Translations[$global:CurrentLanguage]["MacFailure"]})
$($global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]): $(if($storageResult){$global:Translations[$global:CurrentLanguage]["StorageSuccess"]}else{$global:Translations[$global:CurrentLanguage]["StorageFailure"] + $storageMessage})

$($global:Translations[$global:CurrentLanguage]["RegistrationPrompt"])
"@
                    $summaryLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
                    $summaryLabel.ForeColor = [System.Drawing.Color]::White
                    $summaryLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                    $summaryLabel.Size = New-Object System.Drawing.Size(380, 120)
                    $summaryLabel.Location = New-Object System.Drawing.Point(10, 20)
                    $summaryForm.Controls.Add($summaryLabel)
                    
                    # Bouton Cursor
                    $btnCursor = New-Object System.Windows.Forms.Button
                    $btnCursor.Text = $global:Translations[$global:CurrentLanguage]["GoToCursor"]
                    $btnCursor.Font = New-Object System.Drawing.Font("Segoe UI", 10)
                    $btnCursor.Size = New-Object System.Drawing.Size(200, 35)
                    $btnCursor.Location = New-Object System.Drawing.Point(100, 150)
                    $btnCursor.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
                    $btnCursor.ForeColor = [System.Drawing.Color]::White
                    $btnCursor.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $btnCursor.FlatAppearance.BorderSize = 1
                    $btnCursor.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
                    $btnCursor.Cursor = [System.Windows.Forms.Cursors]::Hand
                    $btnCursor.Add_Click({
                        Start-Process "https://cursor.com"
                    })
                    $summaryForm.Controls.Add($btnCursor)
                    
                    # Bouton Extension
                    $btnExtension = New-Object System.Windows.Forms.Button
                    $btnExtension.Text = $global:Translations[$global:CurrentLanguage]["TempEmails"]
                    $btnExtension.Font = New-Object System.Drawing.Font("Segoe UI", 10)
                    $btnExtension.Size = New-Object System.Drawing.Size(200, 35)
                    $btnExtension.Location = New-Object System.Drawing.Point(100, 200)
                    $btnExtension.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
                    $btnExtension.ForeColor = [System.Drawing.Color]::White
                    $btnExtension.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                    $btnExtension.FlatAppearance.BorderSize = 1
                    $btnExtension.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
                    $btnExtension.Cursor = [System.Windows.Forms.Cursors]::Hand
                    $btnExtension.Add_Click({
                        Start-Process "https://chromewebstore.google.com/detail/temporary-email-emailonde/mkpcaklladfpajiaikehdinfaabmnajh"
                    })
                    $summaryForm.Controls.Add($btnExtension)
                    
                    # Afficher la fenêtre de résumé
                    $summaryForm.ShowDialog()
                }
            }
            catch {
                Write-Host "❌ Erreur lors de l'exécution: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    $global:Translations[$global:CurrentLanguage]["ErrorOccurred"] + $_,
                    $global:Translations[$global:CurrentLanguage]["ErrorTitle"],
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
            finally {
                if ($statusLabel -and $progressBar) {
                    $this.Enabled = $true
                    $progressBar.Value = 0
                    $statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                }
            }
        })

        # Événement du bouton de langue
        $btnLang.Add_Click({
            try {
                # Changer la langue
                $global:CurrentLanguage = if ($global:CurrentLanguage -eq "FR") { "EN" } else { "FR" }
                Write-Host "🔄 Changement de langue vers $global:CurrentLanguage" -ForegroundColor Cyan
                
                # Mettre à jour tous les textes
                $form = $this.FindForm()
                $mainPanel = $form.Controls[0]
                
                # Mise à jour du titre de la fenêtre
                $form.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
                
                # Mise à jour des contrôles
                foreach ($control in $mainPanel.Controls) {
                    if ($control -is [System.Windows.Forms.Label]) {
                        if ($control.Tag -eq "titleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["MainTitle"]
                            Write-Host "  ✓ Titre principal mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "numTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["numTitle"]
                            Write-Host "  ✓ Numéro de version mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "freeTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["freeTitle"]
                            Write-Host "  ✓ Titre d'essai gratuit mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "subtitleLabel1") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["Subtitle"]
                            Write-Host "  ✓ Sous-titre mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "subtitleLabel2") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["CursorTitle"]
                            Write-Host "  ✓ Titre Cursor mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "iconTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["iconTitle"]
                            Write-Host "  ✓ Icône mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Font.Size -eq 11) {  # Status label
                            $control.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                            Write-Host "  ✓ Label de statut mis à jour" -ForegroundColor Green
                        }
                    }
                    # Mise à jour des boutons
                    elseif ($control -is [System.Windows.Forms.Button]) {
                        if ($control.Tag -eq "btnMacAddress") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                            Write-Host "  ✓ Bouton MAC Address mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "btnDeleteStorage") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]
                            Write-Host "  ✓ Bouton Delete Storage mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "btnExecuteAll") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"]
                            Write-Host "  ✓ Bouton Execute All mis à jour" -ForegroundColor Green
                        }
                        elseif ($control.Tag -eq "btnExit") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnExit"]
                            Write-Host "  ✓ Bouton Exit mis à jour" -ForegroundColor Green
                        }
                    }
                    # Mise à jour des contrôles dans les panneaux
                    elseif ($control -is [System.Windows.Forms.Panel]) {
                        foreach ($subControl in $control.Controls) {
                            if ($subControl -is [System.Windows.Forms.Label]) {
                                if ($subControl.Font.Size -eq 20) {  # Label de l'adresse MAC
                                    # Mettre à jour uniquement l'adresse MAC
                                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                                    if ($adapter) {
                                        $subControl.Text = $adapter.MacAddress
                                        Write-Host "  ✓ Adresse MAC mise à jour" -ForegroundColor Green
                                    }
                                }
                                elseif ($subControl.Font.Size -eq 10) {  # Label des informations réseau
                                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                                    if ($adapter) {
                                        $subControl.Text = "$($global:Translations[$global:CurrentLanguage]['NetworkCard']): $($adapter.Name)`n$($global:Translations[$global:CurrentLanguage]['MacAddress']):"
                                        Write-Host "  ✓ Informations réseau mises à jour" -ForegroundColor Green
                                    }
                                    else {
                                        $subControl.Text = $global:Translations[$global:CurrentLanguage]["NoNetwork"]
                                        Write-Host "  ✓ Message réseau mis à jour" -ForegroundColor Green
                                    }
                                }
                            }
                        }
                    }
                }
                Write-Host "✅ Changement de langue terminé" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Erreur lors du changement de langue: $_" -ForegroundColor Red
            }
        })

        # Initialisation des informations réseau
        try {
            $adapter = Get-NetworkAdapters | Select-Object -First 1
            if ($adapter) {
                # Label principal pour le texte descriptif
                $macInfoLabel.Text = "$($global:Translations[$global:CurrentLanguage]['NetworkCard']): $($adapter.Name)`n$($global:Translations[$global:CurrentLanguage]['MacAddress']):"
                $macInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
                $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleRight
                $macInfoLabel.Size = New-Object System.Drawing.Size(200,60)
                $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
                
                # Label pour l'adresse MAC en orange
                $macAddressLabel = New-Object System.Windows.Forms.Label
                $macAddressLabel.Text = $adapter.MacAddress
                $macAddressLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20)
                $macAddressLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)
                $macAddressLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
                $macAddressLabel.Size = New-Object System.Drawing.Size(350,30)
                $macAddressLabel.Location = New-Object System.Drawing.Point(220,30)
                $macInfoPanel.Controls.Add($macAddressLabel)
            } else {
                $macInfoLabel.Text = $global:Translations[$global:CurrentLanguage]["NoNetwork"]
                $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
                $macInfoLabel.Size = New-Object System.Drawing.Size(480,60)
                $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
            }
        } catch {
            $macInfoLabel.Text = $global:Translations[$global:CurrentLanguage]["NetworkError"]
            $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
            $macInfoLabel.Size = New-Object System.Drawing.Size(480,60)
            $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
        }

        Write-Host "✓ Événements configurés" -ForegroundColor Green

        # Retourner l'interface avec tous les contrôles
        return @{
            Form = $mainForm
            LanguageButton = $btnLang
            MacAddressButton = $btnMacAddress
            DeleteStorageButton = $btnDeleteStorage
            ExecuteAllButton = $btnExecuteAll
            ExitButton = $btnExit
            ProgressBar = $progressBar
            StatusLabel = $statusLabel
            MacInfoLabel = $macInfoLabel
        }
    }
    catch {
        Write-Host "❌ Erreur lors de l'initialisation de l'interface: $_" -ForegroundColor Red
        throw
    }
}

# Si le script est exécuté directement, créer et afficher l'interface
if ($MyInvocation.InvocationName -ne '.') {
    $interface = Initialize-MainWindow
    $interface.Form.ShowDialog()
} 





