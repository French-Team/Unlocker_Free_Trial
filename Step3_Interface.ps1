# =================================================================
# Fichier     : Step3_Interface.ps1
# Role        : Galerie marchande de l'interface graphique
# Magasins    : - Magasin des composants (fenêtres, panels)
#               - Magasin des styles (boutons, labels)
#               - Magasin des événements (clicks, survols)
# =================================================================

function Initialize-MainWindow {
    try {
        # ===== Magasin des composants principaux =====
        Write-Host "🏪 Création des composants principaux..." -ForegroundColor Cyan
        
        # Rayon fenêtre principale
        $mainForm = New-Object System.Windows.Forms.Form
        $mainForm.Text = "Unlocker - Free Trial"
        $mainForm.Size = New-Object System.Drawing.Size(800,600)
        $mainForm.StartPosition = "CenterScreen"
        $mainForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)  # Gris foncé
        $mainForm.ForeColor = [System.Drawing.Color]::White
        $mainForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $mainForm.MaximizeBox = $false
        $mainForm.TopMost = $true  # Force la fenêtre en avant-plan
        $mainForm.Focus()          # Donner le focus à la fenêtre
        $mainForm.BringToFront()
        $mainForm.Activate()       # Activer la fenêtre

        # Gestion de la fermeture de la fenêtre principale
        $mainForm.Add_FormClosing({
            param($sender, $e)
            Write-Host "Closing application..." -ForegroundColor Yellow
            [System.Windows.Forms.Application]::Exit()
            [Environment]::Exit(0)
        })
        Write-Host "✓ Fenêtre principale créée" -ForegroundColor Green

        # Rayon panel principal
        $mainPanel = New-Object System.Windows.Forms.Panel
        $mainPanel.Size = New-Object System.Drawing.Size(780,560)
        $mainPanel.Location = New-Object System.Drawing.Point(10,10)
        $mainPanel.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)  # Gris foncé
        $mainForm.Controls.Add($mainPanel)
        Write-Host "✓ Panel principal créé" -ForegroundColor Green

        # ===== Magasin des étiquettes =====
        Write-Host "`n🏪 Création des étiquettes..." -ForegroundColor Cyan
        
        # Rayon titre
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = "Unlocker Free Trial"
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 32)
        $titleLabel.ForeColor = [System.Drawing.Color]::White
        $titleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $titleLabel.Size = New-Object System.Drawing.Size(780,50)
        $titleLabel.Location = New-Object System.Drawing.Point(0,20)
        $mainPanel.Controls.Add($titleLabel)

        # Sous-titre
        $subtitleLabel = New-Object System.Windows.Forms.Label
        $subtitleLabel.Text = "pour Cursor"
        $subtitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Light", 16)
        $subtitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(150,150,150)  # Gris plus clair
        $subtitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $subtitleLabel.Size = New-Object System.Drawing.Size(780,30)
        $subtitleLabel.Location = New-Object System.Drawing.Point(0,70)
        $mainPanel.Controls.Add($subtitleLabel)
        Write-Host "✓ Titres créés" -ForegroundColor Green

        # Rayon informations MAC
        $macInfoPanel = New-Object System.Windows.Forms.Panel
        $macInfoPanel.Location = New-Object System.Drawing.Point(90,110)
        $macInfoPanel.Size = New-Object System.Drawing.Size(600,80)
        $macInfoPanel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)  # Gris légèrement plus clair
        
        # Ajout des coins arrondis pour le panel MAC
        $macInfoPanel.Add_Paint({
            param($sender, $e)
            
            $diameter = 10
            $arc = New-Object System.Drawing.Drawing2D.GraphicsPath
            
            # Coins arrondis
            $arc.AddArc(0, 0, $diameter, $diameter, 180, 90)
            $arc.AddArc($sender.Width - $diameter, 0, $diameter, $diameter, 270, 90)
            $arc.AddArc($sender.Width - $diameter, $sender.Height - $diameter, $diameter, $diameter, 0, 90)
            $arc.AddArc(0, $sender.Height - $diameter, $diameter, $diameter, 90, 90)
            
            $arc.CloseFigure()
            $sender.Region = New-Object System.Drawing.Region($arc)
            
            # Bordure grise
            $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(60,60,60), 1)
            $e.Graphics.DrawPath($pen, $arc)
        })

        $mainPanel.Controls.Add($macInfoPanel)

        $macInfoLabel = New-Object System.Windows.Forms.Label
        $macInfoLabel.Location = New-Object System.Drawing.Point(10,10)
        $macInfoLabel.Size = New-Object System.Drawing.Size(580,60)
        $macInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $macInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)  # Plus lumineux
        $macInfoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $macInfoPanel.Controls.Add($macInfoLabel)
        Write-Host "✓ Panel MAC créé" -ForegroundColor Green

        # ===== Magasin des styles =====
        Write-Host "`n🏪 Configuration des styles..." -ForegroundColor Cyan
        
        # Rayon dimensions des boutons
        $buttonWidth = 600
        $buttonHeight = 35
        $buttonX = ($mainPanel.Width - $buttonWidth) / 2
        $buttonStartY = 230
        $buttonSpacing = 60

        # Rayon fabrique de boutons
        function Create-StyledButton {
            param(
                [string]$text,
                [int]$y,
                [System.Drawing.Color]$customBackColor = [System.Drawing.Color]::FromArgb(50,50,50)  # Gris clair pour les boutons
            )
            
            try {
                $button = New-Object System.Windows.Forms.Button
                $button.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
                $button.Location = New-Object System.Drawing.Point($buttonX, $y)
                $button.Text = $text
                $button.Font = New-Object System.Drawing.Font("Segoe UI Light", 11)
                $button.ForeColor = [System.Drawing.Color]::White  # Texte blanc
                $button.BackColor = $customBackColor
                $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
                $button.FlatAppearance.BorderSize = 1
                $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)  # Bordure grise
                $button.FlatAppearance.MouseOverBackColor = [System.Drawing.Color]::FromArgb(60,60,60)
                $button.FlatAppearance.MouseDownBackColor = [System.Drawing.Color]::FromArgb(70,70,70)
                $button.Cursor = [System.Windows.Forms.Cursors]::Hand

                # Effet de survol
                $button.Add_MouseEnter({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
                    }
                })
                
                $button.Add_MouseLeave({
                    if ($this.BackColor -eq [System.Drawing.Color]::FromArgb(50,50,50)) {
                        $this.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)  # Retour à gris
                    }
                })

                return $button
            }
            catch {
                Write-Host "  ❌ Error lors de la création du bouton: $_" -ForegroundColor Red
                throw
            }
        }

        # ===== Magasin des boutons =====
        Write-Host "`n🏪 Création des boutons..." -ForegroundColor Cyan
        
        # Rayon boutons standards
        # Déterminer le texte du bouton en fonction de l'emplacement actuel
        $currentPath = $PSScriptRoot
        $isInEnglishFolder = $currentPath.EndsWith('\EN')
        $languageButtonText = if ($isInEnglishFolder) { "Passer à la version française" } else { "Passer à la version anglaise" }
        $btnLanguage = Create-StyledButton $languageButtonText $buttonStartY
        $btnMacAddress = Create-StyledButton "1. Modifier l'adresse MAC d'un adaptateur réseau" ($buttonStartY + $buttonSpacing)
        $btnDeleteStorage = Create-StyledButton "2. Supprimer le fichier storage.json" ($buttonStartY + $buttonSpacing * 2)
        Write-Host "✓ Boutons standards créés" -ForegroundColor Green

        # Rayon boutons spéciaux
        $btnExecuteAll = Create-StyledButton "3. Exécuter toutes les actions" ($buttonStartY + $buttonSpacing * 3) ([System.Drawing.Color]::FromArgb(255,140,0))  # Orange
        $btnExit = Create-StyledButton "4. Quitter" ($buttonStartY + $buttonSpacing * 4) ([System.Drawing.Color]::FromArgb(185,45,45))  # Rouge
        Write-Host "✓ Boutons spéciaux créés" -ForegroundColor Green

        # ===== Magasin des événements =====
        Write-Host "`n🏪 Configuration des événements..." -ForegroundColor Cyan
        
        # Rayon événements de sortie
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
                Write-Host "❌ Error lors de la fermeture: $_" -ForegroundColor Red
                [Environment]::Exit(1)
            }
        })
        Write-Host "✓ Événement de sortie configuré" -ForegroundColor Green

        # Rayon événements MAC
        $btnMacAddress.Add_Click({
            try {
                Write-Host "🔄 Loading MAC interface..." -ForegroundColor Gray
                # Charger le script dans la portée actuelle
                . "$PSScriptRoot\Step4_MacAddressGUI.ps1"
                # Appeler la fonction
                Show-MacAddressWindow
                Write-Host "✓ MAC interface closed" -ForegroundColor Green
            }
            catch {
                Write-Host "❌ Error lors du chargement de l'interface MAC: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error lors du chargement de l'interface MAC: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Événement MAC configuré" -ForegroundColor Green

        # Rayon événements de suppression
        $btnDeleteStorage.Add_Click({
            try {
                Write-Host "🔄 Deleting storage.json file..." -ForegroundColor Gray
                # Charger le script dans la portée actuelle
                . "$PSScriptRoot\Step5_FileManager.ps1"
                
                # Appeler la fonction de suppression
                $result = Remove-CursorStorage
                
                if ($result.Success) {
                    [System.Windows.Forms.MessageBox]::Show(
                        "Le fichier storage.json a été supprimé avec succès.",
                        "Succès",
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
                Write-Host "❌ Error lors de la suppression du fichier: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error lors de la suppression du fichier: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Événement de suppression configuré" -ForegroundColor Green

        # Rayon événements d'exécution globale
        $btnExecuteAll.Add_Click({
            try {
                # Charger et exécuter le script
                . "$PSScriptRoot\Step6_ExecuteAll.ps1"
                $results = Start-AllActions
                
                # Afficher le résultat
                $message = @"
Résumé des actions :

Modification MAC : $(if($results.MAC){'✓ Réussi'}else{'❌ Échec'})
Suppression storage.json : $(if($results.Storage){'✓ Réussi'}else{'❌ Échec'})

Veuillez procéder à votre nouvelle inscription
sur cursor.com
"@
                
                if ((Show-CustomDialog -Message $message -Title "Résultat des actions") -eq [System.Windows.Forms.DialogResult]::OK) {
                    # Ouvrir le navigateur après que l'utilisateur ait cliqué on cursor.com
                    Write-Host "`n=== Ouverture du site Cursor ===" -ForegroundColor Yellow
                    try {
                        Start-Process "https://www.cursor.com/"
                        Write-Host "  ✓ Site web ouvert avec succès" -ForegroundColor Green
                    }
                    catch {
                        Write-Host "  ❌ Error lors de l'ouverture du site: $_" -ForegroundColor Red
                        [System.Windows.Forms.MessageBox]::Show(
                            "Erreur lors de l'ouverture du site: $_",
                            "Erreur",
                            [System.Windows.Forms.MessageBoxButtons]::OK,
                            [System.Windows.Forms.MessageBoxIcon]::Error
                        )
                    }
                }
                
                # Mettre à jour les informations MAC
                if ($macInfoLabel -and $macInfoLabel.IsHandleCreated) {
                    Write-Host "`n=== Mise à jour des informations MAC ===" -ForegroundColor Yellow
                    Start-Sleep -Seconds 2  # Attendre que la carte réseau soit bien réinitialisée
                    Update-MacInfoLabel -Label $macInfoLabel
                }
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "Erreur lors de l'exécution des actions: $_",
                    "Erreur",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Événement d'exécution globale configuré" -ForegroundColor Green

        # Rayon événements de langue
        $btnLanguage.Add_Click({
            try {
                $currentPath = $PSScriptRoot
                $isInEnglishFolder = $currentPath.EndsWith('\EN')
                
                # Déterminer le chemin du script à démarrer
                if ($isInEnglishFolder) {
                    # Si on est dans EN, on démarre la version FR à la racine
                    $startPath = Join-Path (Split-Path $currentPath -Parent) "start.ps1"
                } else {
                    # Si on est à la racine, on démarre la version EN
                    $startPath = Join-Path $currentPath "EN\start.ps1"
                }

                # Vérifier que le script existe
                if (-not (Test-Path $startPath)) {
                    throw "La version demandée n'existe pas. Veuillez vérifier que le dossier EN et ses fichiers sont présents."
                }

                Write-Host "Démarrage de la version dans $startPath..." -ForegroundColor Yellow
                
                # Démarrer la nouvelle instance en mode caché
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
                
                # Fermer l'instance actuelle
                $currentForm = $this.FindForm()
                if ($currentForm) {
                    $currentForm.Close()
                    [System.Windows.Forms.Application]::Exit()
                    [Environment]::Exit(0)
                }
            }
            catch {
                Write-Host "❌ Error lors du changement de langue: $_" -ForegroundColor Red
                [System.Windows.Forms.MessageBox]::Show(
                    "Error lors du changement de langue: $_",
                    "Error",
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
        })
        Write-Host "✓ Événement de langue configuré" -ForegroundColor Green

        # ===== Assemblage final =====
        Write-Host "`n🔧 Assemblage des composants..." -ForegroundColor Cyan
        
        # Rayon ajout des boutons
        $mainPanel.Controls.AddRange(@(
            $btnLanguage,
            $btnMacAddress,
            $btnDeleteStorage,
            $btnExecuteAll,
            $btnExit
        ))
        Write-Host "✓ Boutons assemblés" -ForegroundColor Green

        # Mise à jour des informations MAC
        try {
            Update-MacInfoLabel -Label $macInfoLabel
            Write-Host "✓ Informations MAC mises à jour" -ForegroundColor Green
        }
        catch {
            $macInfoLabel.Text = "Unable to retrieve network information"
            Write-Host "⚠️ Error lors de la mise à jour MAC" -ForegroundColor Yellow
        }

        # ===== Caisse finale =====
        Write-Host "`n Finalisation de l'interface..." -ForegroundColor Cyan
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
        Write-Host "`n❌ Error lors de la création de l'interface: $_" -ForegroundColor Red
        return $null
    }
}

function Show-MainInterface {
    try {
        # Configuration de la culture
        [System.Windows.Forms.Application]::CurrentCulture = [System.Globalization.CultureInfo]::GetCultureInfo('fr-FR')
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = [System.Globalization.CultureInfo]::GetCultureInfo('fr-FR')
        
        # Lancement de l'interface
        $interface = Initialize-MainWindow
        if ($interface -and $interface.Form) {
            # Configuration de la fenêtre
            $interface.Form.Add_Load({
                $this.Activate()
                $this.BringToFront()
                $this.Focus()
            })
            
            # Démarrage de la boucle de messages Windows Forms
            [System.Windows.Forms.Application]::Run($interface.Form)
            return $true
        } else {
            throw "Échec de l'initialisation de l'interface"
        }
    }
    catch {
        Write-Host "❌ Error lors du lancement de l'interface: $_" -ForegroundColor Red
        throw
    }
}

# Fonction pour afficher une boîte de dialogue personnalisée
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
    $form.TopMost = $true  # Forcer la fenêtre au premier plan
    $form.Focus()          # Donner le focus à la fenêtre
    $form.BringToFront()   # Forcer la fenêtre au premier plan
    $form.Activate()       # Activer la fenêtre

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
    $btnExtension.Text = "Installer l'extension Email Temporaire"
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
    $btnCancel.Text = "Annuler"
    $btnCancel.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $btnCancel.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
    $btnCancel.ForeColor = [System.Drawing.Color]::White
    $btnCancel.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $form.Controls.Add($btnCancel)

    $form.AcceptButton = $btnOK
    $form.CancelButton = $btnCancel

    # Ajouter un gestionnaire d'événements pour le chargement de la fenêtre
    $form.Add_Load({
        $this.Activate()
        $this.BringToFront()
        $this.Focus()
    })

    return $form.ShowDialog()
} 





