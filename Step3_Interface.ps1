# =================================================================
# Fichier     : Step3_Interface.ps1
# Role        : Boutique spécialisée de l'interface utilisateur
# Magasins    : - Magasin des composants (fenêtres, panneaux)
#               - Magasin des styles (boutons, étiquettes)
#               - Magasin des événements (clics, survols)
# =================================================================

# Variables de script pour les contrôles globaux
$script:progressBar = $null
$script:statusLabel = $null

# Charger l'encodage Unicode uniquement pour l'interface, sans l'appliquer globalement
if (Test-Path "$PSScriptRoot\Step2_UTF8.ps1") {
    . "$PSScriptRoot\Step2_UTF8.ps1"
    # Réactiver l'encodage Unicode pour l'interface
    Set-ConsoleEncoding
}

# Charger les dépendances seulement si on n'est pas en mode test
if (-not $env:TEST_MODE) {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
}

# Variables globales pour la langue
$global:CurrentLanguage = "FR"
$global:Translations = @{
    "FR" = @{
        "WindowTitle" = "Unlocker 3.2 - Essai gratuit"
        "MainTitle" = "Unlocker"
        "numTitle" = "3.2" 
        "freeTitle" = "Essai gratuit"
        "Subtitle" = "Renouveler" 
        "iconTitle" = "👻"  # Remise de l'emoji fantôme
        "CursorTitle" = "Cursor"
        "BtnMacAddress" = "1. Modifier l'adresse MAC"
        "BtnDeleteStorage" = "2. Supprimer storage.json"
        "BtnMachineGuid" = "3. Modifier MachineGuid"
        "BtnExecuteAll" = "4. Exécuter toutes les actions"
        "BtnExit" = "5. Quitter"
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
        "MachineGuidSuccess" = "✓ MachineGuid modifié"
        "MachineGuidFailure" = "❌ Échec modification MachineGuid"
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
        "ChangingMAC" = "Modification de l'adresse MAC"
        "ChangingMachineGuid" = "Modification de MachineGuid"
        "Completed" = "Terminé"
        "WaitingForNetwork" = "Attente du réseau..."
        "StorageNotFound" = "Le fichier storage.json n'existe pas."
    }
    "EN" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker"
        "numTitle" = "3.2" 
        "freeTitle" = "Free Trial"
        "Subtitle" = "Renew" 
        "iconTitle" = "👻"  # Remise de l'emoji fantôme
        "CursorTitle" = "Cursor"
        "BtnMacAddress" = "1. Change MAC Address"
        "BtnDeleteStorage" = "2. Delete storage.json"
        "BtnMachineGuid" = "3. Change MachineGuid"
        "BtnExecuteAll" = "4. Execute All Actions"
        "BtnExit" = "5. Exit"
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
        "MachineGuidSuccess" = "✓ MachineGuid changed"
        "MachineGuidFailure" = "❌ MachineGuid change failed"
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
        "ChangingMAC" = "Modifying MAC address"
        "ChangingMachineGuid" = "Modifying MachineGuid"
        "Completed" = "Completed"
        "WaitingForNetwork" = "Waiting for network..."
        "StorageNotFound" = "The storage.json file does not exist."
    }
}

# Importer les scripts nécessaires
try {
    . "$PSScriptRoot\Step4_MacAddress.ps1"
    . "$PSScriptRoot\Step3_NetworkInfoPanel.ps1"
    . "$PSScriptRoot\Step7_RegistryManager.ps1"  # Gestionnaire de registre pour le MachineGuid

    # Chargement explicite du gestionnaire de barre de progression
    $step8Path = Join-Path -Path $PSScriptRoot -ChildPath "Step8_ProgressBar.ps1"
    if (Test-Path $step8Path) {
        . $step8Path
        Write-Host "✅ Gestionnaire de barre de progression chargé avec succès" -ForegroundColor Green
        # Vérifier que les fonctions sont disponibles
        if (Get-Command -Name "Update-ProgressBar" -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ Fonction Update-ProgressBar disponible" -ForegroundColor Green
        }
        if (Get-Command -Name "Reset-ProgressBar" -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ Fonction Reset-ProgressBar disponible" -ForegroundColor Green
        }
        if (Get-Command -Name "Update-StepProgress" -ErrorAction SilentlyContinue) {
            Write-Host "  ✓ Fonction Update-StepProgress disponible" -ForegroundColor Green
        }
    } else {
        Write-Host "❌ Gestionnaire de barre de progression non trouvé: $step8Path" -ForegroundColor Red
        throw "Le fichier Step8_ProgressBar.ps1 est requis mais n'a pas été trouvé."
    }
} catch {
    Write-Host "⚠️ Attention : Certains scripts n'ont pas pu être chargés. L'application continuera avec des fonctionnalités limitées." -ForegroundColor Yellow
    Write-Host "Détails de l'erreur : $_" -ForegroundColor Red
} 

# Variables globales pour les styles des valeurs spécifiques uniquement
$global:ValueDisplayStyle = @{
    MacAddress = @{
        TextColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        FontFamily = "Consolas"
        FontSize = 10
        FontStyle = [System.Drawing.FontStyle]::Bold
    }
    MachineGuid = @{
        TextColor = [System.Drawing.Color]::FromArgb(255,140,0)  # Orange
        FontFamily = "Consolas"
        FontSize = 14
        FontStyle = [System.Drawing.FontStyle]::Bold
    }
}

# Importer les fonctions depuis Step6_ExecuteAll.ps1
$step6Path = Join-Path -Path $PSScriptRoot -ChildPath "Step6_ExecuteAll.ps1"
if (Test-Path $step6Path) {
    . $step6Path
    Write-Host "✓ Module d'exécution globale chargé (pour résumé d'actions)" -ForegroundColor Green
} else {
    Write-Host "❌ Module d'exécution globale non trouvé: $step6Path" -ForegroundColor Red
}

# Fonction pour exécuter toutes les actions
function Execute-AllActions {
    param (
        [string]$MacAddress,
        [bool]$ShouldResetMachineGuid,
        [bool]$ShouldDeleteStorageFile,
        [System.Windows.Forms.ProgressBar]$ProgressControl,
        [System.Windows.Forms.Label]$StatusLabel
    )
    
    $results = @{
        MAC = $false
        Storage = $false
        MachineGuid = $false
        StorageMessage = ""
    }
    
    try {
        # 1. Modification de l'adresse MAC
        if ($ProgressControl) { 
            $ProgressControl.Value = 25
            $StatusLabel.Text = $global:Translations[$global:CurrentLanguage]["ChangingMAC"]
        }
        
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        if ($adapter) {
            $results.MAC = Set-MacAddress -AdapterName $adapter.Name -MacAddress $MacAddress
        }
        
        # 2. Suppression du fichier storage.json
        if ($ShouldDeleteStorageFile) {
            if ($ProgressControl) { 
                $ProgressControl.Value = 50
                $StatusLabel.Text = $global:Translations[$global:CurrentLanguage]["DeletingStorage"]
            }
            
            $storageResult = Remove-CursorStorage
            $results.Storage = $storageResult.Success
            $results.StorageMessage = $storageResult.Message
            
            # Mettre à jour le statut de l'interface utilisateur avec le message exact
            if ($StatusLabel) {
                $StatusLabel.Text = $storageResult.Message
            }
        }
        
        # 3. Réinitialisation du MachineGuid
        if ($ShouldResetMachineGuid) {
            if ($ProgressControl) { 
                $ProgressControl.Value = 75
                $StatusLabel.Text = $global:Translations[$global:CurrentLanguage]["ChangingMachineGuid"]
            }
            
            $guidResult = Reset-MachineGuid
            $results.MachineGuid = $guidResult.Success
        }
        
        # Finalisation
        if ($ProgressControl) { 
            $ProgressControl.Value = 100
            $StatusLabel.Text = $global:Translations[$global:CurrentLanguage]["Completed"]
        }
        
        return @{
            Success = $true
            Results = $results
            StorageMessage = $results.StorageMessage
        }
    }
    catch {
        Write-Host "❌ Erreur lors de l'exécution des actions: $_" -ForegroundColor Red
        return @{
            Success = $false
            Error = $_
            Results = $results
            StorageMessage = $results.StorageMessage
        }
    }
}

# Fonction pour mettre à jour les informations réseau avec formatage spécifique
function Update-NetworkInfo {
    param (
        [System.Windows.Forms.RichTextBox]$infoLabel = $macInfoLabel,
        [System.Windows.Forms.RichTextBox]$guidLabel = $machineGuidLabel
    )
    
    try {
        # Récupérer les informations réseau via la fonction testée
        $networkInfo = Get-NetworkInformation
        
        if ($networkInfo.Success) {
            # Mise à jour du RichTextBox pour l'adaptateur et l'adresse MAC
            $infoLabel.Clear()
            $infoLabel.Text = "- $($global:Translations[$global:CurrentLanguage]['NetworkCard']) : "
            $infoLabel.SelectionStart = $infoLabel.TextLength
            $infoLabel.SelectionLength = 0
            $infoLabel.SelectionColor = $global:ValueDisplayStyle['MacAddress']['TextColor']
            $infoLabel.SelectionFont = New-Object System.Drawing.Font(
                $global:ValueDisplayStyle['MacAddress']['FontFamily'],
                $global:ValueDisplayStyle['MacAddress']['FontSize'],
                $global:ValueDisplayStyle['MacAddress']['FontStyle']
            )
            # Utiliser le nom complet de l'adaptateur avec sa vitesse et sa version de pilote
            $infoLabel.SelectedText = "$($networkInfo.Data.AdapterName)`n"
            
            # Ajouter l'adresse MAC avec le style approprié
            $infoLabel.SelectionStart = $infoLabel.TextLength
            $infoLabel.SelectionColor = [System.Drawing.Color]::FromArgb(200,200,200)
            $infoLabel.SelectionFont = New-Object System.Drawing.Font("Segoe UI", 10)
            $infoLabel.SelectedText = "- $($global:Translations[$global:CurrentLanguage]['MacAddress']) : "
            
            $infoLabel.SelectionStart = $infoLabel.TextLength
            $infoLabel.SelectionColor = $global:ValueDisplayStyle['MacAddress']['TextColor']
            $infoLabel.SelectionFont = New-Object System.Drawing.Font(
                $global:ValueDisplayStyle['MacAddress']['FontFamily'],
                $global:ValueDisplayStyle['MacAddress']['FontSize'],
                $global:ValueDisplayStyle['MacAddress']['FontStyle']
            )
            $infoLabel.SelectedText = $networkInfo.Data.MacAddress

            # Mettre à jour le MachineGuid
            $guidLabel.Clear()
            $guidLabel.Text = "- MachineGuid : "
            $guidLabel.SelectionStart = $guidLabel.TextLength
            $guidLabel.SelectionLength = 0
            $guidLabel.SelectionColor = $global:ValueDisplayStyle['MachineGuid']['TextColor']
            $guidLabel.SelectionFont = New-Object System.Drawing.Font(
                $global:ValueDisplayStyle['MachineGuid']['FontFamily'],
                $global:ValueDisplayStyle['MachineGuid']['FontSize'],
                $global:ValueDisplayStyle['MachineGuid']['FontStyle']
            )
            $guidLabel.SelectedText = $networkInfo.Data.MachineGuid
        } else {
            $infoLabel.Text = $global:Translations[$global:CurrentLanguage][$networkInfo.Message]
            $guidLabel.Text = ""
        }
    }
    catch {
        Write-Host "Erreur lors de la mise à jour des informations réseau : $_" -ForegroundColor Red
        $infoLabel.Text = $global:Translations[$global:CurrentLanguage]["NetworkError"]
        $guidLabel.Text = ""
    }
}

# Renommer la fonction Update-ProgressBar locale pour éviter les conflits avec Step8_ProgressBar.ps1
function Update-InterfaceProgressBar {
    param (
        [int]$step,
        [int]$totalSteps = 4
    )
    
    try {
        Write-Host "🔄 Mise à jour de la barre de progression locale: $step/$totalSteps" -ForegroundColor Cyan
        $progressValue = [Math]::Round(($step / $totalSteps) * 100)
        
        if ($script:progressBar -ne $null) {
            $script:progressBar.Value = $progressValue
            Write-Host "  ✓ ProgressBar.Value mis à jour: $progressValue" -ForegroundColor Green
        } else {
            Write-Host "  ❌ ProgressBar est null!" -ForegroundColor Red
        }
        
        if ($script:statusLabel -ne $null) {
            switch ($step) {
                1 { $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["ChangingMAC"] }
                2 { $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["ChangingMachineGuid"] }
                3 { $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["DeletingStorage"] }
                4 { 
                    $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Completed"]
                    if ($script:progressBar -ne $null) { 
                        $script:progressBar.Value = 100 
                    }
                }
                default { $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"] }
            }
            Write-Host "  ✓ StatusLabel.Text mis à jour: $($script:statusLabel.Text)" -ForegroundColor Green
        } else {
            Write-Host "  ❌ StatusLabel est null!" -ForegroundColor Red
        }
    }
    catch {
        Write-Host "❌ Erreur lors de la mise à jour de la barre de progression : $_" -ForegroundColor Red
    }
}

# Fonction pour afficher le résumé des actions
function Show-ActionSummary {
    param (
        [bool]$MacSuccess,
        [bool]$StorageSuccess,
        [bool]$MachineGuidSuccess,
        [string]$StorageMessage,
        [System.Windows.Forms.Form]$Owner = $null
    )
    
    # Créer un formulaire personnalisé pour le résumé
    $formSummary = New-Object System.Windows.Forms.Form
    $formSummary.Text = "Résumé des actions"
    if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["ActionSummaryTitle"]) {
        $formSummary.Text = $global:Translations[$global:CurrentLanguage]["ActionSummaryTitle"]
    }
    
    $formSummary.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Process -Id $pid).Path)
    $formSummary.Size = New-Object System.Drawing.Size(450, 350)
    $formSummary.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $formSummary.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
    $formSummary.MaximizeBox = $false
    $formSummary.MinimizeBox = $false
    $formSummary.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
    $formSummary.ForeColor = [System.Drawing.Color]::White
    
    # Définir le propriétaire de la fenêtre pour qu'elle reste au-dessus
    if ($Owner -ne $null) {
        $formSummary.Owner = $Owner
        # Centrer par rapport au propriétaire
        $formSummary.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterParent
    }
    
    # S'assurer que la fenêtre reste au-dessus de toutes les autres
    $formSummary.TopMost = $true
    
    # Éviter que la fenêtre n'apparaisse dans la barre des tâches
    $formSummary.ShowInTaskbar = $false
    
    # Créer un titre pour le formulaire
    $lblTitle = New-Object System.Windows.Forms.Label
    $lblTitle.Text = "Résumé des actions"
    if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["ActionSummaryHeader"]) {
        $lblTitle.Text = $global:Translations[$global:CurrentLanguage]["ActionSummaryHeader"]
    }
    
    $lblTitle.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
    $lblTitle.ForeColor = [System.Drawing.Color]::White
    $lblTitle.Location = New-Object System.Drawing.Point(20, 20)
    $lblTitle.Size = New-Object System.Drawing.Size(410, 30)
    $lblTitle.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $formSummary.Controls.Add($lblTitle)
    
    # Créer des labels pour chaque action
    $lblMAC = New-Object System.Windows.Forms.Label
    $lblMAC.Text = "MAC Address: " + $(if ($MacSuccess) { "✅" } else { "❌" })
    $lblMAC.ForeColor = [System.Drawing.Color]::White
    $lblMAC.Location = New-Object System.Drawing.Point(20, 70)
    $lblMAC.Size = New-Object System.Drawing.Size(410, 20)
    $formSummary.Controls.Add($lblMAC)
    
    $lblStorage = New-Object System.Windows.Forms.Label
    # Utiliser le message spécifique retourné par Remove-CursorStorage
    $lblStorage.Text = "Storage: " + $(if ($StorageSuccess) { "✅ " + $StorageMessage } else { "❌ " + $StorageMessage })
    $lblStorage.ForeColor = [System.Drawing.Color]::White
    $lblStorage.Location = New-Object System.Drawing.Point(20, 100)
    $lblStorage.Size = New-Object System.Drawing.Size(410, 20)
    $formSummary.Controls.Add($lblStorage)
    
    $lblMachineGuid = New-Object System.Windows.Forms.Label
    $lblMachineGuid.Text = "Machine GUID: " + $(if ($MachineGuidSuccess) { "✅" } else { "❌" })
    $lblMachineGuid.ForeColor = [System.Drawing.Color]::White
    $lblMachineGuid.Location = New-Object System.Drawing.Point(20, 130)
    $lblMachineGuid.Size = New-Object System.Drawing.Size(410, 20)
    $formSummary.Controls.Add($lblMachineGuid)
    
    # Ajouter un message global sur le résultat
    $lblOverall = New-Object System.Windows.Forms.Label
    if ($MacSuccess -and $StorageSuccess -and $MachineGuidSuccess) {
        $lblOverall.Text = "Toutes les actions ont été exécutées avec succès!"
        if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["AllActionsSuccessful"]) {
            $lblOverall.Text = $global:Translations[$global:CurrentLanguage]["AllActionsSuccessful"]
        }
        $lblOverall.ForeColor = [System.Drawing.Color]::Green
    } else {
        $lblOverall.Text = "Certaines actions ont échoué."
        if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["SomeActionsFailed"]) {
            $lblOverall.Text = $global:Translations[$global:CurrentLanguage]["SomeActionsFailed"]
        }
        $lblOverall.ForeColor = [System.Drawing.Color]::Red
    }
    $lblOverall.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $lblOverall.Location = New-Object System.Drawing.Point(20, 170)
    $lblOverall.Size = New-Object System.Drawing.Size(410, 20)
    $lblOverall.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $formSummary.Controls.Add($lblOverall)
    
    # Ajouter un message pour l'inscription
    $lblInscription = New-Object System.Windows.Forms.Label
    $lblInscription.Text = "Veuillez procéder à votre nouvelle inscription sur cursor.com"
    if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["RegistrationPrompt"]) {
        $lblInscription.Text = $global:Translations[$global:CurrentLanguage]["RegistrationPrompt"]
    }
    $lblInscription.ForeColor = [System.Drawing.Color]::White
    $lblInscription.Location = New-Object System.Drawing.Point(20, 200)
    $lblInscription.Size = New-Object System.Drawing.Size(410, 20)
    $lblInscription.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $formSummary.Controls.Add($lblInscription)
    
    # Ajouter un bouton pour aller sur cursor.com
    $btnCursor = New-Object System.Windows.Forms.Button
    $btnCursor.Text = "Aller sur cursor.com"
    if ($global:Translations -and $global:CurrentLanguage -and $global:Translations[$global:CurrentLanguage]["GoToCursor"]) {
        $btnCursor.Text = $global:Translations[$global:CurrentLanguage]["GoToCursor"]
    }
    $btnCursor.Location = New-Object System.Drawing.Point(125, 240)
    $btnCursor.Size = New-Object System.Drawing.Size(200, 30)
    $btnCursor.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
    $btnCursor.ForeColor = [System.Drawing.Color]::White
    $btnCursor.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $btnCursor.FlatAppearance.BorderSize = 1
    $btnCursor.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
    $btnCursor.Cursor = [System.Windows.Forms.Cursors]::Hand
    $btnCursor.Add_Click({ Start-Process "https://cursor.com" })
    $formSummary.Controls.Add($btnCursor)
    
    # Afficher le formulaire de façon modale
    $formSummary.ShowDialog() | Out-Null
}

function global:Initialize-MainWindow {
    try {
        # ===== Magasin des composants principaux =====
        Write-Host "🏪 Création des composants principaux..." -ForegroundColor Cyan
        
        # Section fenêtre principale
        $mainForm = New-Object System.Windows.Forms.Form
        $mainForm.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
        $mainForm.Size = New-Object System.Drawing.Size(700,650) 
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
        $mainPanel.Size = New-Object System.Drawing.Size(680,670)
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
        $buttonStartY = 300  # Nouvelle position après le panneau MAC
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

        
        # Sous-titre ligne (Renouveler 👻 Cursor)
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
        $iconTitleLabel.Text = [System.Text.Encoding]::UTF8.GetString([System.Text.Encoding]::UTF8.GetBytes("👻"))
        $iconTitleLabel.Font = New-Object System.Drawing.Font("Segoe UI Emoji", 25)
        $iconTitleLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)
        $iconTitleLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $iconTitleLabel.Size = New-Object System.Drawing.Size(50,50)
        $iconTitleLabel.Location = New-Object System.Drawing.Point(320,110)
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
        $macInfoPanel.Location = New-Object System.Drawing.Point(40, 175)
        $macInfoPanel.Size = New-Object System.Drawing.Size(600, 100)
        $macInfoPanel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $mainPanel.Controls.Add($macInfoPanel)


        # Label MAC
        $macInfoLabel = New-Object System.Windows.Forms.RichTextBox
        $macInfoLabel.Location = New-Object System.Drawing.Point(10, 10)
        $macInfoLabel.Size = New-Object System.Drawing.Size(530, 50)
        $macInfoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $macInfoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
        $macInfoLabel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $macInfoLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $macInfoLabel.ReadOnly = $true
        $macInfoLabel.Multiline = $true
        $macInfoPanel.Controls.Add($macInfoLabel)

        # Label MachineGuid
        $machineGuidLabel = New-Object System.Windows.Forms.RichTextBox
        $machineGuidLabel.Location = New-Object System.Drawing.Point(10, 60)
        $machineGuidLabel.Size = New-Object System.Drawing.Size(480, 50)
        $machineGuidLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $machineGuidLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
        $machineGuidLabel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
        $machineGuidLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::None
        $machineGuidLabel.ReadOnly = $true
        $machineGuidLabel.Multiline = $true
        $macInfoPanel.Controls.Add($machineGuidLabel)

        # Initialisation des informations réseau avec les valeurs actuelles
        try {
            $currentAdapter = Get-NetworkAdapters | Select-Object -First 1
            $currentGuid = Get-MachineGuid
            
            if ($currentAdapter) {
                $macInfoLabel.Clear()
                $macInfoLabel.Text = "- $($global:Translations[$global:CurrentLanguage]['NetworkCard']) : "
                $macInfoLabel.SelectionStart = $macInfoLabel.TextLength
                $macInfoLabel.SelectionLength = 0
                $macInfoLabel.SelectionColor = $global:ValueDisplayStyle['MacAddress']['TextColor']
                $macInfoLabel.SelectionFont = New-Object System.Drawing.Font(
                    $global:ValueDisplayStyle['MacAddress']['FontFamily'],
                    $global:ValueDisplayStyle['MacAddress']['FontSize'],
                    $global:ValueDisplayStyle['MacAddress']['FontStyle']
                )
                $macInfoLabel.SelectedText = "$(Format-NetworkAdapter $currentAdapter)`n"
                
                $macInfoLabel.SelectionStart = $macInfoLabel.TextLength
                $macInfoLabel.SelectionColor = [System.Drawing.Color]::FromArgb(200,200,200)
                $macInfoLabel.SelectionFont = New-Object System.Drawing.Font("Segoe UI", 10)
                $macInfoLabel.SelectedText = "- $($global:Translations[$global:CurrentLanguage]['MacAddress']) : "
                
                $macInfoLabel.SelectionStart = $macInfoLabel.TextLength
                $macInfoLabel.SelectionColor = $global:ValueDisplayStyle['MacAddress']['TextColor']
                $macInfoLabel.SelectionFont = New-Object System.Drawing.Font(
                    $global:ValueDisplayStyle['MacAddress']['FontFamily'],
                    $global:ValueDisplayStyle['MacAddress']['FontSize'],
                    $global:ValueDisplayStyle['MacAddress']['FontStyle']
                )
                $macInfoLabel.SelectedText = $currentAdapter.MacAddress
            }
            
            if ($currentGuid) {
                $machineGuidLabel.Clear()
                $machineGuidLabel.Text = "- MachineGuid : "
                $machineGuidLabel.SelectionStart = $machineGuidLabel.TextLength
                $machineGuidLabel.SelectionLength = 0
                $machineGuidLabel.SelectionColor = $global:ValueDisplayStyle['MachineGuid']['TextColor']
                $machineGuidLabel.SelectionFont = New-Object System.Drawing.Font(
                    $global:ValueDisplayStyle['MachineGuid']['FontFamily'],
                    $global:ValueDisplayStyle['MachineGuid']['FontSize'],
                    $global:ValueDisplayStyle['MachineGuid']['FontStyle']
                )
                $machineGuidLabel.SelectedText = $currentGuid
            }
        }
        catch {
            Write-Host "❌ Erreur lors de l'initialisation des informations : $_" -ForegroundColor Red
        }

        # Boutons principaux
        $btnMacAddress = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnMacAddress"] -y $buttonStartY -fontFamily "consolas"
        $btnMacAddress.Tag = "btnMacAddress"
        $btnDeleteStorage = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"] -y ($buttonStartY + $buttonSpacing) -fontFamily "consolas"
        $btnDeleteStorage.Tag = "btnDeleteStorage"
        $btnMachineGuid = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnMachineGuid"] -y ($buttonStartY + $buttonSpacing * 2) -fontFamily "consolas"
        $btnMachineGuid.Tag = "btnMachineGuid"
        $btnExecuteAll = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"] -y ($buttonStartY + $buttonSpacing * 3) -fontFamily "consolas"
        $btnExecuteAll.Tag = "btnExecuteAll"
        $btnExit = Create-StyledButton -text $global:Translations[$global:CurrentLanguage]["BtnExit"] -y ($buttonStartY + $buttonSpacing * 4) -customBackColor ([System.Drawing.Color]::FromArgb(255,140,0)) -fontFamily "consolas"
        $btnExit.Tag = "btnExit"

        # Barre de progression
        $script:progressBar = New-Object System.Windows.Forms.ProgressBar
        $script:progressBar.Location = New-Object System.Drawing.Point($buttonX, ($buttonStartY + $buttonSpacing * 5))
        $script:progressBar.Size = New-Object System.Drawing.Size($buttonWidth, 20)
        $script:progressBar.Style = 'Continuous'
        $script:progressBar.Value = 0
        $script:progressBar.BackColor = [System.Drawing.Color]::FromArgb(20,20,20)
        $script:progressBar.ForeColor = [System.Drawing.Color]::FromArgb(0,120,215)  # Bleu standard Windows
        $script:progressBar.Visible = $true
        $mainPanel.Controls.Add($script:progressBar)

        # Label de statut
        $script:statusLabel = New-Object System.Windows.Forms.Label
        $script:statusLabel.Location = New-Object System.Drawing.Point($buttonX, ($buttonStartY + $buttonSpacing * 5))
        $script:statusLabel.Size = New-Object System.Drawing.Size($buttonWidth, 20)
        $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $script:statusLabel.ForeColor = [System.Drawing.Color]::White
        $script:statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $script:statusLabel.BackColor = [System.Drawing.Color]::Transparent
        $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
        $mainPanel.Controls.Add($script:statusLabel)

        # Nettoyer les contrôles existants
        $mainPanel.Controls.Clear()

        # 1. Ajouter les contrôles dans l'ordre (du fond vers l'avant)
        # Panneau MAC (fond)
        $mainPanel.Controls.Add($macInfoPanel)
        $macInfoPanel.Controls.Add($macInfoLabel)
        $macInfoPanel.Controls.Add($machineGuidLabel)

        # 2. Boutons principaux
        $mainPanel.Controls.Add($btnMacAddress)
        $mainPanel.Controls.Add($btnDeleteStorage)
        $mainPanel.Controls.Add($btnMachineGuid)
        $mainPanel.Controls.Add($btnExecuteAll)
        $mainPanel.Controls.Add($btnExit)

        # 3. Barre de progression et statut
        $mainPanel.Controls.Add($script:progressBar)
        $mainPanel.Controls.Add($script:statusLabel)

        # 4. Bouton de langue (premier plan)
        $mainPanel.Controls.Add($btnLang)

        # 5. Titres et sous-titres (dernier plan pour être au-dessus)
        $mainPanel.Controls.Add($freeTitleLabel)
        $mainPanel.Controls.Add($subtitleLabel2)       
        $mainPanel.Controls.Add($iconTitleLabel)     
        $mainPanel.Controls.Add($numTitleLabel)
        $mainPanel.Controls.Add($titleLabel)
        $mainPanel.Controls.Add($subtitleLabel1)

        # 6. Réassigner tous les gestionnaires d'événements après l'ajout des contrôles
        # Événement de fermeture
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

        # Événement MAC Address
        $btnMacAddress.Add_Click({
            try {
                Write-Host "🖱️ Clic sur Modifier l'adresse MAC" -ForegroundColor Cyan
                
                # Désactiver le bouton pendant le traitement
                $this.Enabled = $false
                
                # Réinitialiser la barre de progression manuellement
                if ($script:progressBar -ne $null) {
                    $script:progressBar.Value = 0
                    Write-Host "  ✓ ProgressBar réinitialisée" -ForegroundColor Green
                }
                
                if ($script:statusLabel -ne $null) {
                    $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Initializing"]
                    Write-Host "  ✓ StatusLabel mis à jour: Initialisation" -ForegroundColor Green
                }
                
                # Récupérer le panneau MAC et ses contrôles
                $form = $this.FindForm()
                $macPanel = $null
                if ($form -ne $null) {
                    $macPanel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Panel] -and $_.BackColor.R -eq 45 }
                    Write-Host "  ✓ Référence au panneau MAC trouvée" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Formulaire parent non trouvé!" -ForegroundColor Red
                }
                
                $macInfoLabelObj = $null
                $machineGuidLabelObj = $null
                
                if ($macPanel) {
                    $macInfoLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 10 }
                    $machineGuidLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 60 }
                    
                    if ($macInfoLabelObj) { Write-Host "  ✓ Label MAC trouvé" -ForegroundColor Green }
                    if ($machineGuidLabelObj) { Write-Host "  ✓ Label GUID trouvé" -ForegroundColor Green }
                }
                    
                    # Charger et exécuter le script MAC
                $step4Path = Join-Path -Path $PSScriptRoot -ChildPath "Step4_MacAddress.ps1"
                if (Test-Path $step4Path) {
                    . $step4Path
                    Write-Host "✅ Script MAC chargé avec succès" -ForegroundColor Green
                    
                    # Mise à jour de la barre de progression - 25%
                    if ($script:progressBar -ne $null) {
                        $script:progressBar.Value = 25
                    }
                    if ($script:statusLabel -ne $null) {
                        $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["LoadingMacScript"]
                    }
                    
                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                    if ($adapter) {
                        Write-Host "  ✓ Adaptateur réseau trouvé: $($adapter.Name)" -ForegroundColor Green
                        
                        # Mise à jour de la barre de progression - 50%
                        if ($script:progressBar -ne $null) {
                            $script:progressBar.Value = 50
                        }
                        if ($script:statusLabel -ne $null) {
                            $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["GeneratingMacAddress"]
                        }
                        
                        $newMac = New-MacAddress
                        if ($newMac) {
                            Write-Host "  ✓ Nouvelle adresse MAC générée: $newMac" -ForegroundColor Green
                            
                            # Mise à jour de la barre de progression - 75%
                            if ($script:progressBar -ne $null) {
                                $script:progressBar.Value = 75
                            }
                            if ($script:statusLabel -ne $null) {
                                $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["ApplyingMacAddress"]
                            }
                            
                            $result = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                            if ($result) {
                                Write-Host "  ✓ Adresse MAC modifiée avec succès" -ForegroundColor Green
                                
                                # Mise à jour de la barre de progression - 100%
                                if ($script:progressBar -ne $null) {
                                    $script:progressBar.Value = 100
                                }
                                if ($script:statusLabel -ne $null) {
                                    $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["MacAddressModified"]
                                }
                                
                                [System.Windows.Forms.MessageBox]::Show(
                                    $global:Translations[$global:CurrentLanguage]["MacSuccessMsg"],
                                    $global:Translations[$global:CurrentLanguage]["SuccessTitle"],
                                    [System.Windows.Forms.MessageBoxButtons]::OK,
                                    [System.Windows.Forms.MessageBoxIcon]::Information
                                )
                                
                                # Attendre que la carte réseau soit de nouveau disponible
                                if ($script:statusLabel -ne $null) {
                                    $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["WaitingForNetwork"]
                                }
                                
                                # Attendre que la carte redémarre
                                Write-Host "  ⏱️ Attente du redémarrage de la carte réseau (10 secondes)..." -ForegroundColor Yellow
                                Start-Sleep -Seconds 10
                                
                                # Réessayer plusieurs fois
                                $maxRetries = 5
                                $retryCount = 0
                                $updateSuccess = $false
                                
                                while ($retryCount -lt $maxRetries -and -not $updateSuccess) {
                                    Write-Host "  🔄 Tentative de mise à jour des informations réseau ($($retryCount + 1)/$maxRetries)..." -ForegroundColor Gray
                                    try {
                                        # Mettre à jour les informations réseau après la modification
                                        if ($macInfoLabelObj -and $machineGuidLabelObj) {
                                            Update-NetworkInfo -infoLabel $macInfoLabelObj -guidLabel $machineGuidLabelObj
                                            $updateSuccess = $true
                                            Write-Host "  ✓ Informations réseau mises à jour avec succès" -ForegroundColor Green
                                        }
                                    } catch {
                                        Write-Host "  ⚠️ Échec de la mise à jour, nouvel essai dans 3 secondes... ($_)" -ForegroundColor Yellow
                                        Start-Sleep -Seconds 3
                                    }
                                    $retryCount++
                                }
                            } else {
                                Write-Host "  ❌ Échec de la modification de l'adresse MAC" -ForegroundColor Red
                            }
                        } else {
                            Write-Host "❌ Aucun adaptateur réseau trouvé" -ForegroundColor Red
                        }
                    } else {
                        Write-Host "❌ Script MAC non trouvé: $step4Path" -ForegroundColor Red
                        throw "Script MAC non trouvé: $step4Path"
                    }
                }
                
                # Restaurer après quelques secondes
                Start-Sleep -Seconds 2
                if ($script:progressBar -ne $null) {
                    $script:progressBar.Value = 0
                }
                if ($script:statusLabel -ne $null) {
                    $script:statusLabel.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
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
            finally {
                # Réactiver le bouton
                $this.Enabled = $true
            }
        })

        # Événement Delete Storage
        $btnDeleteStorage.Add_Click({
            try {
                Write-Host "🔄 Suppression du fichier storage.json..." -ForegroundColor Gray
                
                # Réinitialiser la barre de progression
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                }
                
                # Mettre à jour le statut et initialiser la barre de progression
                Update-StepProgress -Step "Initialization" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                    
                    # Déterminer le chemin du script
                $scriptPath = Join-Path -Path $PSScriptRoot -ChildPath "Step5_FileManager.ps1"
                    Write-Host "PSScriptRoot: $PSScriptRoot" -ForegroundColor Gray
                    Write-Host "Chemin complet du script: $scriptPath" -ForegroundColor Gray
                    
                    # Vérifier si le fichier existe
                    if (Test-Path $scriptPath) {
                        Write-Host "Le fichier existe, tentative de chargement..." -ForegroundColor Gray
                        . $scriptPath
                        Write-Host "Script chargé avec succès" -ForegroundColor Green
                        
                    # Mise à jour de la barre de progression - Storage (50-75%)
                    Update-StepProgress -Step "Storage" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                    
                    # Appeler Remove-CursorStorage dans tous les cas
                    $storageResult = Remove-CursorStorage
                    
                    # Toujours considérer comme un succès, qu'il s'agisse d'un fichier supprimé ou qui n'existe pas déjà
                    # Et utiliser le message exact retourné par Remove-CursorStorage
                    Update-ProgressBar -Progress 100 -Message $storageResult.Message -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                    
                    # Le message et le titre dépendent du résultat de l'opération
                    $icon = [System.Windows.Forms.MessageBoxIcon]::Information
                    $title = $global:Translations[$global:CurrentLanguage]["SuccessTitle"]
                    
                    if (-not $storageResult.Success) {
                        $icon = [System.Windows.Forms.MessageBoxIcon]::Error
                        $title = $global:Translations[$global:CurrentLanguage]["ErrorTitle"]
                    }
                    
                    [System.Windows.Forms.MessageBox]::Show(
                        $storageResult.Message,
                        $title,
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        $icon
                    )
                    } else {
                        Write-Host "❌ Le fichier n'existe pas à l'emplacement: $scriptPath" -ForegroundColor Red
                        throw "Le fichier Step5_FileManager.ps1 n'existe pas à l'emplacement: $scriptPath"
                    }
                    
                # Restaurer le texte du label de statut après quelques secondes
                Start-Sleep -Seconds 2
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
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

        # Événement Execute All
        $btnExecuteAll.Add_Click({
            # Désactiver le bouton actuel pendant l'exécution
            $this.Enabled = $false
            
            try {
                # Récupérer la référence au formulaire et aux contrôles
                $form = $this.FindForm()
                $macPanel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Panel] -and $_.BackColor.R -eq 45 }
                
                # Récupérer les labels d'informations réseau
                if ($macPanel) {
                    $macInfoLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 10 }
                    $machineGuidLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 60 }
                }
                
                # Réinitialiser la barre de progression
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                }
                
                # Vérifier si tous les scripts nécessaires sont disponibles
                $step4Path = Join-Path -Path $PSScriptRoot -ChildPath "Step4_MacAddress.ps1"
                $step5Path = Join-Path -Path $PSScriptRoot -ChildPath "Step5_FileManager.ps1"
                $step7Path = Join-Path -Path $PSScriptRoot -ChildPath "Step7_RegistryManager.ps1"
                
                # Vérifier et charger chaque script
                $scriptOk = $true
                
                if (-not (Test-Path $step4Path)) {
                    Write-Host "❌ Script MAC non trouvé: $step4Path" -ForegroundColor Red
                    $scriptOk = $false
                } else {
                    . $step4Path
                    Write-Host "✓ Script MAC chargé" -ForegroundColor Green
                }
                
                if (-not (Test-Path $step5Path)) {
                    Write-Host "❌ Script FileManager non trouvé: $step5Path" -ForegroundColor Red
                    $scriptOk = $false
                } else {
                    . $step5Path
                    Write-Host "✓ Script FileManager chargé" -ForegroundColor Green
                }
                
                if (-not (Test-Path $step7Path)) {
                    Write-Host "❌ Script RegistryManager non trouvé: $step7Path" -ForegroundColor Red
                    $scriptOk = $false
                } else {
                    . $step7Path
                    Write-Host "✓ Script RegistryManager chargé" -ForegroundColor Green
                }
                
                if (-not $scriptOk) {
                    throw "Un ou plusieurs scripts nécessaires sont manquants"
                }
                
                # Exécuter les actions avec la barre de progression
                $macSuccess = $false
                $storageSuccess = $false
                $machineGuidSuccess = $false
                $storageMessage = ""
                
                # Initialisation et suppression du fichier storage.json
                Update-StepProgress -Step "Storage" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                $storageResult = Remove-CursorStorage
                $storageSuccess = $storageResult.Success
                $storageMessage = $storageResult.Message
                
                # Mise à jour du statut dans l'interface utilisateur
                if ($script:statusLabel -ne $null) {
                    $script:statusLabel.Text = $storageResult.Message
                }
                
                # Modification de l'adresse MAC
                Update-StepProgress -Step "MAC" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                
                # Générer une nouvelle adresse MAC et l'appliquer
                $adapter = Get-NetworkAdapters | Select-Object -First 1
                if ($adapter) {
                    $newMac = New-MacAddress
                    if (Test-MacAddress -MacAddress $newMac) {
                        $macSuccess = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                    }
                }
                
                # 3. Modification MachineGuid
                Update-StepProgress -Step "MachineGuid" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                $guidResult = Reset-MachineGuid
                $machineGuidSuccess = $guidResult.Success
                
                # Finaliser avec un message et 100%
                Update-ProgressBar -Progress 100 -Message $global:Translations[$global:CurrentLanguage]["Completed"] -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                
                # Attendre pour que la carte réseau redémarre (comme pour le bouton 1)
                Start-Sleep -Seconds 10
                
                # Mise à jour des informations réseau avec réessais
                $maxRetries = 5
                $retryCount = 0
                $updateSuccess = $false
                
                while ($retryCount -lt $maxRetries -and -not $updateSuccess) {
                    try {
                        if ($macInfoLabelObj -and $machineGuidLabelObj) {
                            Update-NetworkInfo -infoLabel $macInfoLabelObj -guidLabel $machineGuidLabelObj
                            $updateSuccess = $true
                        }
                    } catch {
                        Write-Host "  ⚠️ Échec de la mise à jour des informations réseau, nouvel essai dans 3 secondes..." -ForegroundColor Yellow
                        Start-Sleep -Seconds 3
                    }
                    $retryCount++
                }
                
                # Afficher le résumé des actions
                Show-ActionSummary -MacSuccess $macSuccess -StorageSuccess $storageSuccess -MachineGuidSuccess $machineGuidSuccess -StorageMessage $storageMessage -Owner $form
            }
            catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "$($global:Translations[$global:CurrentLanguage["ErrorOccurred"]]): $_",
                    $global:Translations[$global:CurrentLanguage]["ErrorTitle"],
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
            }
            finally {
                # Réactiver le bouton actuel
                    $this.Enabled = $true
                
                # Réinitialiser la barre de progression
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                }
            }
        })

        # Événement Machine Guid
        $btnMachineGuid.Add_Click({
            Write-Host "🖱️ Clic sur le bouton Modifier MachineGuid" -ForegroundColor Cyan
            try {
                # Réinitialiser la barre de progression
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                }
                
                # Récupérer le panneau MAC et ses contrôles
                $form = $this.FindForm()
                $macPanel = $form.Controls[0].Controls | Where-Object { $_ -is [System.Windows.Forms.Panel] -and $_.BackColor.R -eq 45 }
                
                if ($macPanel) {
                    $macInfoLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 10 }
                    $machineGuidLabelObj = $macPanel.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 60 }
                }
                
                # Initialiser et mettre à jour la barre de progression
                Update-StepProgress -Step "Storage" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                
                Write-Host "  🔄 Modification du MachineGuid..." -ForegroundColor Gray
                
                # Mise à jour de la barre de progression - MachineGuid (75-100%)
                Update-StepProgress -Step "MachineGuid" -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                
                $result = Reset-MachineGuid
                if ($result.Success) {
                    # Finaliser la barre de progression
                    Update-ProgressBar -Progress 100 -Message $global:Translations[$global:CurrentLanguage]["Completed"] -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                    
                    [System.Windows.Forms.MessageBox]::Show(
                        "MachineGuid modifié avec succès.`nAncien: $($result.OldValue)`nNouveau: $($result.NewValue)",
                        $global:Translations[$global:CurrentLanguage]["SuccessTitle"],
                        [System.Windows.Forms.MessageBoxButtons]::OK,
                        [System.Windows.Forms.MessageBoxIcon]::Information
                    )
                    Write-Host "  ✓ MachineGuid modifié avec succès" -ForegroundColor Green
                    # Mettre à jour les informations réseau après la modification
                    if ($macInfoLabelObj -and $machineGuidLabelObj) {
                        Update-NetworkInfo -infoLabel $macInfoLabelObj -guidLabel $machineGuidLabelObj
                    }
                } else {
                    throw $result.Message
                }
                
                # Restaurer le texte du label de statut après quelques secondes
                Start-Sleep -Seconds 2
                if ($script:progressBar -ne $null -and $script:statusLabel -ne $null) {
                    Reset-ProgressBar -ProgressBar $script:progressBar -MessageLabel $script:statusLabel -PercentLabel $null
                }
            } catch {
                [System.Windows.Forms.MessageBox]::Show(
                    "$($global:Translations[$global:CurrentLanguage['ErrorOccurred']])$_",
                    $global:Translations[$global:CurrentLanguage]["ErrorTitle"],
                    [System.Windows.Forms.MessageBoxButtons]::OK,
                    [System.Windows.Forms.MessageBoxIcon]::Error
                )
                Write-Host "  ❌ Erreur lors de la modification du MachineGuid: $_" -ForegroundColor Red
            }
        })

        # Événement de langue
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
                        }
                        elseif ($control.Tag -eq "numTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["numTitle"]
                        }
                        elseif ($control.Tag -eq "freeTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["freeTitle"]
                        }
                        elseif ($control.Tag -eq "subtitleLabel1") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["Subtitle"]
                        }
                        elseif ($control.Tag -eq "subtitleLabel2") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["CursorTitle"]
                        }
                        elseif ($control.Tag -eq "iconTitleLabel") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["iconTitle"]
                        }
                        elseif ($control.Font.Size -eq 12) {  # Status label
                            $control.Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                        }
                    }
                    elseif ($control -is [System.Windows.Forms.Button]) {
                        if ($control.Tag -eq "btnMacAddress") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                        }
                        elseif ($control.Tag -eq "btnDeleteStorage") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]
                        }
                        elseif ($control.Tag -eq "btnMachineGuid") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnMachineGuid"]
                        }
                        elseif ($control.Tag -eq "btnExecuteAll") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"]
                        }
                        elseif ($control.Tag -eq "btnExit") {
                            $control.Text = $global:Translations[$global:CurrentLanguage]["BtnExit"]
                        }
                    }
                    elseif ($control -is [System.Windows.Forms.Panel]) {
                        foreach ($subControl in $control.Controls) {
                            if ($subControl -is [System.Windows.Forms.RichTextBox]) {
                                # Mettre à jour les informations réseau avec les RichTextBox
                                $macInfoLabel = $control.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 10 }
                                $machineGuidLabel = $control.Controls | Where-Object { $_ -is [System.Windows.Forms.RichTextBox] -and $_.Location.Y -eq 60 }
                                if ($macInfoLabel -and $machineGuidLabel) {
                                    Update-NetworkInfo -infoLabel $macInfoLabel -guidLabel $machineGuidLabel
                                    break
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

        # Mettre à jour les informations réseau
        Update-NetworkInfo -infoLabel $macInfoLabel -guidLabel $machineGuidLabel

        # Réactiver le layout
        $mainPanel.ResumeLayout($true)

        # Retourner l'interface avec tous les contrôles
        return @{
            Form = $mainForm
            LanguageButton = $btnLang
            MacAddressButton = $btnMacAddress
            DeleteStorageButton = $btnDeleteStorage
            ExecuteAllButton = $btnExecuteAll
            ExitButton = $btnExit
            ProgressBar = $script:progressBar
            StatusLabel = $script:statusLabel
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
    try {
        # Forcer l'encodage UTF-8 avant de créer l'interface
        if (Test-Path "$PSScriptRoot\Step2_UTF8.ps1") {
            . "$PSScriptRoot\Step2_UTF8.ps1"
            Set-ConsoleEncoding
        }
        
        # Créer et afficher l'interface
    $interface = Initialize-MainWindow
        [System.Windows.Forms.Application]::EnableVisualStyles()
        [System.Windows.Forms.Application]::Run($interface.Form)
    }
    catch {
        Write-Host "❌ Erreur lors du lancement de l'interface: $_" -ForegroundColor Red
    }
} 





