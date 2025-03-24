# =================================================================
# Fichier     : Step13_Interface.ps1
# Role        : Interface utilisateur principale
# Description : Gère la création et la gestion de l'interface utilisateur principale
# =================================================================

# Définir le thème global de l'application
$Global:AppTheme = @{
    BackgroundColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
    TextColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    PrimaryColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    SecondaryColor = [System.Drawing.Color]::FromArgb(0, 99, 177)
    SuccessColor = [System.Drawing.Color]::FromArgb(0, 177, 89)
    WarningColor = [System.Drawing.Color]::FromArgb(255, 185, 0)
    ErrorColor = [System.Drawing.Color]::FromArgb(232, 17, 35)
    NormalFont = New-Object System.Drawing.Font("Segoe UI", 9)
    BoldFont = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Bold)
    HeaderFont = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    SubHeaderFont = New-Object System.Drawing.Font("Segoe UI", 12)
    ButtonHeight = 40
    LargeButtonHeight = 50
}

# Fonction d'affichage des messages de console
function Write-ConsoleLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [string]$Color = "White"
    )
    
    Write-Host $Message -ForegroundColor $Color
}

# Fonction temporaire pour obtenir le chemin du script si le module de configuration n'est pas chargé
function Get-ScriptPathFallback {
    $scriptPath = $null
    
    # Méthode 1: Utiliser $MyInvocation.MyCommand.Path
    if ($null -ne $MyInvocation.MyCommand.Path -and $MyInvocation.MyCommand.Path -ne '') {
        $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
        if ($scriptPath -and (Test-Path $scriptPath)) {
            return $scriptPath
        }
    }
    
    # Méthode 2: Utiliser $PSScriptRoot (PowerShell 3.0+)
    if ($null -ne $PSScriptRoot -and $PSScriptRoot -ne '') {
        if (Test-Path $PSScriptRoot) {
            return $PSScriptRoot
        }
    }
    
    # Méthode 3: Utiliser $PSCommandPath
    if ($null -ne $PSCommandPath -and $PSCommandPath -ne '') {
        $scriptPath = Split-Path -Parent $PSCommandPath
        if ($scriptPath -and (Test-Path $scriptPath)) {
            return $scriptPath
        }
    }
    
    # Méthode 4: Utiliser le répertoire courant
    $currentDir = (Get-Location).Path
    if (Test-Path $currentDir) {
        return $currentDir
    }
    
    # Si toutes les méthodes échouent, retourner le répertoire temporaire
    return $env:TEMP
}

# Fonction pour charger tous les modules nécessaires
function Import-RequiredModules {
    Write-ConsoleLog "🔍 Chargement des modules nécessaires..." -Color Cyan
    
    # Obtenir le chemin du script de manière fiable (fallback temporaire)
    $scriptPath = Get-ScriptPathFallback
    if (-not $scriptPath) {
        Write-ConsoleLog "❌ Impossible de déterminer le chemin du script" -Color Red
        return $false
    }
    
    Write-ConsoleLog "📂 Chemin du script: $scriptPath" -Color Cyan
    
    $modulesToLoad = @{
        "Step3_Configuration.ps1" = @("Get-ScriptPath", "Initialize-Configuration")
        "Step2_Logging.ps1" = @("Write-Log")
        "Step4_Storage.ps1" = @("Get-StoragePath", "DeleteStorageFile")
        "Step5_NetworkAdapter.ps1" = @("Get-NetworkAdapters", "Set-MacAddress", "New-MacAddress")
        "Step7_MachineGuid.ps1" = @("Reset-MachineGuid")
        "Step9_Initialization.ps1" = @("Initialize-System")
        "Step10_ProgressBar.ps1" = @("New-ProgressBar", "Update-ProgressBar", "Reset-ProgressBar")
        "Step11_ExecuteAll.ps1" = @("Invoke-SpecificAction", "Invoke-AllActions")
        "Step12_Visuals.ps1" = @("New-HeaderLabel", "New-StyledButton", "New-ActionPanel", "Add-ControlToActionPanel")
    }
    
    $loadedModules = @()
    $failedModules = @()
    
    # Traiter le module de configuration en premier
    if ($modulesToLoad.ContainsKey("Step3_Configuration.ps1")) {
        $modulePath = "Step3_Configuration.ps1"
        $fullModulePath = Join-Path -Path $scriptPath -ChildPath $modulePath
        
        if (Test-Path $fullModulePath) {
            try {
                # Charger le module de configuration
                . $fullModulePath
                
                # Vérifier si les fonctions du module sont disponibles
                $allFunctionsAvailable = $true
                foreach ($function in $modulesToLoad[$modulePath]) {
                    if (-not (Get-Command $function -ErrorAction SilentlyContinue)) {
                        $allFunctionsAvailable = $false
                        break
                    }
                }
                
                if ($allFunctionsAvailable) {
                    $loadedModules += $modulePath
                    Write-ConsoleLog "✅ Module de configuration chargé: $modulePath" -Color Green
                    
                    # Utiliser la fonction Get-ScriptPath du module de configuration
                    $scriptPath = Get-ScriptPath
                    Write-ConsoleLog "📂 Chemin du script (via module de configuration): $scriptPath" -Color Cyan
                } else {
                    $failedModules += $modulePath
                    Write-ConsoleLog "❌ Certaines fonctions du module de configuration $modulePath n'ont pas été chargées" -Color Red
                }
            } catch {
                $errorDetails = $_.Exception.Message
                $failedModules += $modulePath
                Write-ConsoleLog "❌ Erreur lors du chargement du module de configuration $modulePath : ${errorDetails}" -Color Red
            }
        } else {
            $failedModules += $modulePath
            Write-ConsoleLog "❌ Module de configuration non trouvé: $modulePath" -Color Red
        }
        
        # Retirer le module de configuration du hashtable pour éviter de le traiter deux fois
        $modulesToLoad.Remove("Step3_Configuration.ps1")
    }
    
    # Traiter les autres modules
    foreach ($modulePath in $modulesToLoad.Keys) {
        # Construire le chemin complet du module
        $fullModulePath = Join-Path -Path $scriptPath -ChildPath $modulePath
        
        # Vérifier que le chemin est valide
        if (-not $fullModulePath -or -not (Test-Path $fullModulePath)) {
            Write-ConsoleLog "❌ Module non trouvé: $modulePath" -Color Red
            $failedModules += $modulePath
            continue
        }
        
        try {
            # Charger le module
            . $fullModulePath
            
            # Vérifier si les fonctions du module sont disponibles
            $allFunctionsAvailable = $true
            foreach ($function in $modulesToLoad[$modulePath]) {
                if (-not (Get-Command $function -ErrorAction SilentlyContinue)) {
                    $allFunctionsAvailable = $false
                    break
                }
            }
            
            if ($allFunctionsAvailable) {
                $loadedModules += $modulePath
                Write-ConsoleLog "✅ Module chargé: $modulePath" -Color Green
            } else {
                $failedModules += $modulePath
                Write-ConsoleLog "❌ Certaines fonctions du module $modulePath n'ont pas été chargées" -Color Red
            }
        } catch {
            $errorDetails = $_.Exception.Message
            $failedModules += $modulePath
            Write-ConsoleLog "❌ Erreur lors du chargement du module $modulePath : ${errorDetails}" -Color Red
        }
    }
    
    # Afficher un résumé
    if ($failedModules.Count -eq 0) {
        Write-ConsoleLog "✅ Tous les modules ont été chargés avec succès" -Color Green
        return $true
    } else {
        Write-ConsoleLog "⚠️ Certains modules n'ont pas pu être chargés: $($failedModules -join ', ')" -Color Yellow
        return $false
    }
}

# Fonction pour créer une barre de statut
function New-StatusBar {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Text = "Prêt",
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )
    
    $statusLabel = New-Object System.Windows.Forms.Label
    $statusLabel.Text = $Text
    $statusLabel.Height = 22
    $statusLabel.Dock = [System.Windows.Forms.DockStyle]::Bottom
    $statusLabel.BorderStyle = [System.Windows.Forms.BorderStyle]::Fixed3D
    $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    
    # Ajouter une propriété personnalisée pour stocker le type de statut
    $statusLabel | Add-Member -MemberType NoteProperty -Name "StatusType" -Value $Type
    
    # Définir la couleur en fonction du type
    switch ($Type) {
        "Success" {
            $statusLabel.ForeColor = $Global:AppTheme.SuccessColor
        }
        "Warning" {
            $statusLabel.ForeColor = $Global:AppTheme.WarningColor
        }
        "Error" {
            $statusLabel.ForeColor = $Global:AppTheme.ErrorColor
        }
        default {
            $statusLabel.ForeColor = $Global:AppTheme.TextColor
        }
    }
    
    return $statusLabel
}

# Fonction pour mettre à jour la barre de statut
function Update-StatusBar {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Label]$StatusBar,
        
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Info", "Success", "Warning", "Error")]
        [string]$Type = "Info"
    )
    
    $StatusBar.Text = $Text
    
    # Mettre à jour la propriété personnalisée
    $StatusBar.StatusType = $Type
    
    # Mettre à jour la couleur en fonction du type
    switch ($Type) {
        "Success" {
            $StatusBar.ForeColor = $Global:AppTheme.SuccessColor
        }
        "Warning" {
            $StatusBar.ForeColor = $Global:AppTheme.WarningColor
        }
        "Error" {
            $StatusBar.ForeColor = $Global:AppTheme.ErrorColor
        }
        default {
            $StatusBar.ForeColor = $Global:AppTheme.TextColor
        }
    }
}

# Fonction pour créer une zone de texte stylisée
function New-StyledTextBox {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Text = "",
        
        [Parameter(Mandatory=$false)]
        [int]$Width = 300,
        
        [Parameter(Mandatory=$false)]
        [int]$Height = 22,
        
        [Parameter(Mandatory=$false)]
        [switch]$ReadOnly,
        
        [Parameter(Mandatory=$false)]
        [switch]$Multiline
    )
    
    $textBox = New-Object System.Windows.Forms.TextBox
    $textBox.Text = $Text
    $textBox.Width = $Width
    $textBox.Height = $Height
    $textBox.ReadOnly = $ReadOnly
    $textBox.Multiline = $Multiline
    $textBox.Font = $Global:AppTheme.NormalFont
    $textBox.BackColor = if ($ReadOnly) { [System.Drawing.Color]::FromArgb(245, 245, 245) } else { [System.Drawing.Color]::White }
    $textBox.ForeColor = $Global:AppTheme.TextColor
    
    return $textBox
}

# Fonction utilitaire pour exécuter une action avec une interface utilisateur
function Invoke-ActionWithUI {
    param (
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Form]$Form,
        
        [Parameter(Mandatory=$true)]
        [string]$ActionType,
        
        [Parameter(Mandatory=$true)]
        [PSObject]$ActionPanel,
        
        [Parameter(Mandatory=$true)]
        [string]$ProgressBarLabel,
        
        [Parameter(Mandatory=$false)]
        [scriptblock]$SuccessMessageFormatter = { param($result) return $result.Message },
        
        [Parameter(Mandatory=$false)]
        [switch]$IsAllActions,
        
        [Parameter(Mandatory=$false)]
        [System.Windows.Forms.ProgressBar]$ExistingProgressBar,
        
        [Parameter(Mandatory=$false)]
        [scriptblock]$CustomResultHandler
    )
    
    try {
        # Vérifier que ActionPanel n'est pas null
        if ($null -eq $ActionPanel) {
            throw "Le paramètre ActionPanel ne peut pas être null"
        }
        
        # Vérifier que les modules nécessaires sont chargés
        $modulesLoaded = $true
        
        # Vérifier si la fonction New-ProgressBar existe
        if (-not (Get-Command "New-ProgressBar" -ErrorAction SilentlyContinue)) {
            Write-Log "La fonction New-ProgressBar n'est pas définie" -Level "ERROR"
            $modulesLoaded = $false
            
            # Essayer de charger le module Step10_ProgressBar.ps1
            $scriptPath = Get-ScriptPath
            $progressBarPath = Join-Path -Path $scriptPath -ChildPath "Step10_ProgressBar.ps1"
            
            if (Test-Path $progressBarPath) {
                Write-Log "Tentative de chargement du module Step10_ProgressBar.ps1" -Level "INFO"
                . $progressBarPath
                
                # Vérifier à nouveau si la fonction existe
                if (Get-Command "New-ProgressBar" -ErrorAction SilentlyContinue) {
                    $modulesLoaded = $true
                }
            }
        }
        
        # Vérifier les fonctions d'action appropriées selon le type d'action
        if ($IsAllActions) {
            # Vérifier si la fonction Invoke-AllActions existe
            if (-not (Get-Command "Invoke-AllActions" -ErrorAction SilentlyContinue)) {
                Write-Log "La fonction Invoke-AllActions n'est pas définie" -Level "ERROR"
                $modulesLoaded = $false
                
                # Essayer de charger le module Step11_ExecuteAll.ps1
                $scriptPath = Get-ScriptPath
                $executeAllPath = Join-Path -Path $scriptPath -ChildPath "Step11_ExecuteAll.ps1"
                
                if (Test-Path $executeAllPath) {
                    Write-Log "Tentative de chargement du module Step11_ExecuteAll.ps1" -Level "INFO"
                    . $executeAllPath
                    
                    # Vérifier à nouveau si la fonction existe
                    if (Get-Command "Invoke-AllActions" -ErrorAction SilentlyContinue) {
                        $modulesLoaded = $true
                    }
                }
            }
        } else {
            # Vérifier si la fonction Invoke-SpecificAction existe
            if (-not (Get-Command "Invoke-SpecificAction" -ErrorAction SilentlyContinue)) {
                Write-Log "La fonction Invoke-SpecificAction n'est pas définie" -Level "ERROR"
                $modulesLoaded = $false
                
                # Essayer de charger le module Step11_ExecuteAll.ps1
                $scriptPath = Get-ScriptPath
                $executeAllPath = Join-Path -Path $scriptPath -ChildPath "Step11_ExecuteAll.ps1"
                
                if (Test-Path $executeAllPath) {
                    Write-Log "Tentative de chargement du module Step11_ExecuteAll.ps1" -Level "INFO"
                    . $executeAllPath
                    
                    # Vérifier à nouveau si la fonction existe
                    if (Get-Command "Invoke-SpecificAction" -ErrorAction SilentlyContinue) {
                        $modulesLoaded = $true
                    }
                }
            }
        }
        
        if (-not $modulesLoaded) {
            throw "Impossible de charger les modules nécessaires pour l'opération"
        }
        
        # Préparer la barre de progression
        $progressBar = $ExistingProgressBar
        
        # Si on n'utilise pas une barre de progression existante, en créer une nouvelle
        if (-not $progressBar -and (Get-Command "New-ProgressBar" -ErrorAction SilentlyContinue)) {
            $progressBarObj = New-ProgressBar -LabelText $ProgressBarLabel -Width 510 -BarColor "Blue"
            
            # Vérifier que la barre de progression a été créée correctement
            if (-not $progressBarObj -or -not $progressBarObj.Panel -or -not $progressBarObj.ProgressBar) {
                Write-Log "La barre de progression n'a pas été créée correctement" -Level "WARNING"
                $progressBar = $null
            } else {
                $progressBar = $progressBarObj.ProgressBar
                
                # Ajouter la barre de progression au panel
                $ActionPanel.ContentPanel.Controls.Clear()
                $ActionPanel = Add-ControlToActionPanel -ActionPanel $ActionPanel -Control $progressBarObj.Panel
            }
        } elseif ($progressBar -and (Get-Command "Reset-ProgressBar" -ErrorAction SilentlyContinue)) {
            # Réinitialiser la barre de progression existante
            Reset-ProgressBar -ProgressBar @{ ProgressBar = $progressBar } -Status "Initialisation..." -LabelText $ProgressBarLabel
        }
        
        # Créer un objet pour la barre de progression si elle existe
        $progressBarParam = if ($progressBar) { @{ ProgressBar = $progressBar } } else { $null }
        
        # Exécuter l'action appropriée
        $result = if ($IsAllActions) {
            Invoke-AllActions -ProgressBar $progressBarParam
        } else {
            Invoke-SpecificAction -ActionType $ActionType -ProgressBar $progressBarParam
        }
        
        # Si un gestionnaire de résultat personnalisé est fourni, l'utiliser
        if ($CustomResultHandler) {
            & $CustomResultHandler $result $ActionPanel
        } else {
            # Traitement par défaut du résultat
            if ($result.Success) {
                $messageBoxTitle = "Succès"
                $messageBoxType = [System.Windows.Forms.MessageBoxIcon]::Information
                $message = & $SuccessMessageFormatter $result
            } else {
                $messageBoxTitle = if ($IsAllActions) { "Avertissement" } else { "Erreur" }
                $messageBoxType = if ($IsAllActions) { [System.Windows.Forms.MessageBoxIcon]::Warning } else { [System.Windows.Forms.MessageBoxIcon]::Error }
                $message = $result.Message
            }
            
            # Afficher le résultat
            [System.Windows.Forms.MessageBox]::Show($Form, $message, $messageBoxTitle, [System.Windows.Forms.MessageBoxButtons]::OK, $messageBoxType)
        }
        
        # Mise à jour de la barre de statut
        $statusBarControl = $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Dock -eq [System.Windows.Forms.DockStyle]::Bottom }
        if ($statusBarControl) {
            $statusType = if ($result.Success) { if ($IsAllActions -and $result.PartialSuccess) { "Warning" } else { "Success" } } else { if ($IsAllActions) { "Warning" } else { "Error" } }
            Update-StatusBar -StatusBar $statusBarControl -Text $message -Type $statusType
        }
        
        return $result
    }
    catch {
        $errorDetails = $_.Exception.Message
        $errorMessage = "Erreur lors de l'exécution de l'action $ActionType : ${errorDetails}"
        Write-Log $errorMessage -Level "ERROR"
        [System.Windows.Forms.MessageBox]::Show($Form, $errorMessage, "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        
        # Mise à jour de la barre de statut
        $statusBarControl = $Form.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Dock -eq [System.Windows.Forms.DockStyle]::Bottom }
        if ($statusBarControl) {
            Update-StatusBar -StatusBar $statusBarControl -Text $errorMessage -Type "Error"
        }
        
        return $null
    }
}

# Créer et afficher la fenêtre principale de l'application
function New-MainInterface {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$TestMode = $false
    )
    
    Write-ConsoleLog "🔍 Création de l'interface principale..." -Color Cyan
    
    try {
        # Vérifier que les assemblies Windows Forms sont chargées
        if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.Form').Type) {
            Write-ConsoleLog "📥 Chargement des assemblies Windows Forms..." -Color Cyan
            try {
                Add-Type -AssemblyName System.Windows.Forms
                Add-Type -AssemblyName System.Drawing
                Write-ConsoleLog "✅ Assemblies Windows Forms chargées" -Color Green
            } catch {
                $errorMessage = "Impossible de charger les assemblies Windows Forms: $_"
                Write-Log $errorMessage -Level "ERROR"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                throw $errorMessage
            }
        }
        
        # Charger tous les modules nécessaires
        try {
            $modulesLoaded = Import-RequiredModules
            if (-not $modulesLoaded) {
                Write-Log "Avertissement: Certains modules n'ont pas pu être chargés. L'application pourrait ne pas fonctionner correctement." -Level "WARNING"
                Write-ConsoleLog "⚠️ Certains modules n'ont pas pu être chargés. L'application pourrait ne pas fonctionner correctement." -Color Yellow
            }
        } catch {
            $errorMessage = "Erreur lors du chargement des modules: $_"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            # Continuer malgré l'erreur, nous essaierons de charger les modules individuellement plus tard
        }
        
        # Initialiser les modules nécessaires
        $initVisuals = $false
        try {
            if (Get-Command "Initialize-VisualsManager" -ErrorAction SilentlyContinue) {
                $initVisuals = Initialize-VisualsManager
            } else {
                # Essayer de charger le module Step12_Visuals.ps1
                $scriptPath = Get-ScriptPath
                if ($scriptPath) {
                    $visualsPath = Join-Path -Path $scriptPath -ChildPath "Step12_Visuals.ps1"
                    if (Test-Path $visualsPath) {
                        . $visualsPath
                        if (Get-Command "Initialize-VisualsManager" -ErrorAction SilentlyContinue) {
                            $initVisuals = Initialize-VisualsManager
                        }
                    }
                }
            }
        } catch {
            Write-Log "Erreur lors de l'initialisation du module des éléments visuels: $_" -Level "ERROR"
            Write-ConsoleLog "❌ Erreur lors de l'initialisation du module des éléments visuels" -Color Red
        }
        
        if (-not $initVisuals) {
            Write-Log "Échec de l'initialisation du module des éléments visuels" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'initialisation du module des éléments visuels" -Color Red
            # Continuer malgré l'erreur, nous utiliserons des fonctions de secours
        }
        
        $initProgress = $false
        try {
            if (Get-Command "Initialize-ProgressBarManager" -ErrorAction SilentlyContinue) {
                $initProgress = Initialize-ProgressBarManager
            } else {
                # Essayer de charger le module Step10_ProgressBar.ps1
                $scriptPath = Get-ScriptPath
                if ($scriptPath) {
                    $progressBarPath = Join-Path -Path $scriptPath -ChildPath "Step10_ProgressBar.ps1"
                    if (Test-Path $progressBarPath) {
                        . $progressBarPath
                        if (Get-Command "Initialize-ProgressBarManager" -ErrorAction SilentlyContinue) {
                            $initProgress = Initialize-ProgressBarManager
                        }
                    }
                }
            }
        } catch {
            Write-Log "Erreur lors de l'initialisation du module de gestion des barres de progression: $_" -Level "ERROR"
            Write-ConsoleLog "❌ Erreur lors de l'initialisation du module de gestion des barres de progression" -Color Red
        }
        
        if (-not $initProgress) {
            Write-Log "Échec de l'initialisation du module de gestion des barres de progression" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'initialisation du module de gestion des barres de progression" -Color Red
            # Continuer malgré l'erreur, nous utiliserons des fonctions de secours
        }
        
        $initAction = $false
        try {
            if (Get-Command "Initialize-ActionExecutor" -ErrorAction SilentlyContinue) {
                $initAction = Initialize-ActionExecutor
            } else {
                # Essayer de charger le module Step11_ExecuteAll.ps1
                $scriptPath = Get-ScriptPath
                if ($scriptPath) {
                    $executeAllPath = Join-Path -Path $scriptPath -ChildPath "Step11_ExecuteAll.ps1"
                    if (Test-Path $executeAllPath) {
                        . $executeAllPath
                        if (Get-Command "Initialize-ActionExecutor" -ErrorAction SilentlyContinue) {
                            $initAction = Initialize-ActionExecutor
                        }
                    }
                }
            }
        } catch {
            Write-Log "Erreur lors de l'initialisation du module d'exécution des actions: $_" -Level "ERROR"
            Write-ConsoleLog "❌ Erreur lors de l'initialisation du module d'exécution des actions" -Color Red
        }
        
        if (-not $initAction) {
            Write-Log "Échec de l'initialisation du module d'exécution des actions" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'initialisation du module d'exécution des actions" -Color Red
            # Continuer malgré l'erreur, nous utiliserons des fonctions de secours
        }
        
        # Créer la fenêtre principale
        $form = New-Object System.Windows.Forms.Form
        $form.Text = "Unlocker Free Trial"
        $form.Size = New-Object System.Drawing.Size(600, 800)
        $form.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        $form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedDialog
        $form.MaximizeBox = $false
        $form.MinimizeBox = $true
        
        # Définir l'icône - utiliser une approche plus sûre
        try {
            $iconPath = Join-Path $env:SystemRoot "System32\WindowsPowerShell\v1.0\powershell.exe"
            if (Test-Path $iconPath) {
                $form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon($iconPath)
            } else {
                Write-Log "Chemin d'icône PowerShell non trouvé, utilisation de l'icône par défaut" -Level "WARNING"
            }
        } catch {
            Write-Log "Impossible de charger l'icône PowerShell: $_" -Level "WARNING"
        }
        
        $form.BackColor = $Global:AppTheme.BackgroundColor
        
        # Titre principal
        $headerLabel = New-HeaderLabel -Text "Unlocker Free Trial" -Width 580
        $headerLabel.Location = New-Object System.Drawing.Point(10, 20)
        $form.Controls.Add($headerLabel)
        
        # Sous-titre
        $subHeaderLabel = New-HeaderLabel -Text "Réinitialisation des identifiants système" -Width 580 -SubHeader
        $subHeaderLabel.Location = New-Object System.Drawing.Point(10, 65)
        $form.Controls.Add($subHeaderLabel)
        
        # Description
        $descriptionLabel = New-Object System.Windows.Forms.Label
        $descriptionLabel.Text = "Cet outil vous permet de réinitialiser différents identifiants système pour recommencer une période d'essai. Il vous propose trois actions distinctes qui peuvent être exécutées séparément ou ensemble."
        $descriptionLabel.Location = New-Object System.Drawing.Point(10, 100)
        $descriptionLabel.Size = New-Object System.Drawing.Size(560, 40)
        $descriptionLabel.Font = $Global:AppTheme.NormalFont
        $descriptionLabel.ForeColor = $Global:AppTheme.TextColor
        $form.Controls.Add($descriptionLabel)
        
        # Barre de statut en bas (créée avant les panels pour être accessible dans les gestionnaires d'événements)
        $statusBar = New-StatusBar -Text "Prêt"
        $form.Controls.Add($statusBar)
        
        # Panel d'action 1: Suppression du fichier de stockage
        $script:storagePanel = New-ActionPanel -Title "Suppression du fichier de stockage" -Width 560 -Description "Supprime le fichier storage.json qui stocke les informations d'identification."
        $script:storagePanel.Panel.Location = New-Object System.Drawing.Point(10, 150)
        $form.Controls.Add($script:storagePanel.Panel)
        
        # Ajouter un bouton pour supprimer le fichier de stockage
        $storageButton = New-StyledButton -Text "Supprimer le fichier de stockage" -Width 240 -Primary
        # Capturer la référence au panel dans une variable locale pour le scriptblock
        $localStoragePanel = $script:storagePanel
        $storageButton.Add_Click({
            # Utiliser la variable locale capturée par le scriptblock
            if ($null -ne $localStoragePanel) {
                Invoke-ActionWithUI -Form $form -ActionType "Storage" -ActionPanel $localStoragePanel -ProgressBarLabel "Suppression du fichier de stockage"
            } else {
                [System.Windows.Forms.MessageBox]::Show($form, "Erreur: Le panel d'action est introuvable.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }.GetNewClosure())  # GetNewClosure capture les valeurs actuelles des variables
        
        $script:storagePanel = Add-ControlToActionPanel -ActionPanel $script:storagePanel -Control $storageButton
        
        # Panel d'action 2: Réinitialisation de l'adresse MAC
        $script:macPanel = New-ActionPanel -Title "Réinitialisation de l'adresse MAC" -Width 560 -Description "Modifie l'adresse MAC (Media Access Control) de votre carte réseau principale."
        $script:macPanel.Panel.Location = New-Object System.Drawing.Point(10, 280)
        $form.Controls.Add($script:macPanel.Panel)
        
        # Ajouter un bouton pour réinitialiser l'adresse MAC
        $macButton = New-StyledButton -Text "Réinitialiser l'adresse MAC" -Width 240 -Primary
        # Capturer la référence au panel dans une variable locale pour le scriptblock
        $localMacPanel = $script:macPanel
        $macButton.Add_Click({
            # Utiliser la variable locale capturée par le scriptblock
            if ($null -ne $localMacPanel) {
                Invoke-ActionWithUI -Form $form -ActionType "Mac" -ActionPanel $localMacPanel -ProgressBarLabel "Réinitialisation de l'adresse MAC" -SuccessMessageFormatter {
                    param($result)
                    if ($result.OldValue -and $result.NewValue) {
                        return "Adresse MAC modifiée avec succès:`nAncienne: $($result.OldValue)`nNouvelle: $($result.NewValue)"
                    } else {
                        return $result.Message
                    }
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show($form, "Erreur: Le panel d'action est introuvable.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }.GetNewClosure())  # GetNewClosure capture les valeurs actuelles des variables
        
        $script:macPanel = Add-ControlToActionPanel -ActionPanel $script:macPanel -Control $macButton
        
        # Panel d'action 3: Réinitialisation du GUID machine
        $script:guidPanel = New-ActionPanel -Title "Réinitialisation du GUID machine" -Width 560 -Description "Modifie l'identifiant unique global (GUID) de votre machine dans le registre Windows."
        $script:guidPanel.Panel.Location = New-Object System.Drawing.Point(10, 410)
        $form.Controls.Add($script:guidPanel.Panel)
        
        # Ajouter un bouton pour réinitialiser le GUID machine
        $guidButton = New-StyledButton -Text "Réinitialiser le GUID machine" -Width 240 -Primary
        # Capturer la référence au panel dans une variable locale pour le scriptblock
        $localGuidPanel = $script:guidPanel
        $guidButton.Add_Click({
            # Utiliser la variable locale capturée par le scriptblock
            if ($null -ne $localGuidPanel) {
                Invoke-ActionWithUI -Form $form -ActionType "Guid" -ActionPanel $localGuidPanel -ProgressBarLabel "Réinitialisation du GUID machine" -SuccessMessageFormatter {
                    param($result)
                    if ($result.OldValue -and $result.NewValue) {
                        return "GUID machine modifié avec succès:`nAncien: $($result.OldValue)`nNouveau: $($result.NewValue)"
                    } else {
                        return $result.Message
                    }
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show($form, "Erreur: Le panel d'action est introuvable.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }.GetNewClosure())  # GetNewClosure capture les valeurs actuelles des variables
        
        $script:guidPanel = Add-ControlToActionPanel -ActionPanel $script:guidPanel -Control $guidButton
        
        # Panel pour l'exécution de toutes les actions
        $script:allActionsPanel = New-ActionPanel -Title "Exécuter toutes les actions" -Width 560 -Description "Exécute les trois actions ci-dessus en une seule fois." -Height 200
        $script:allActionsPanel.Panel.Location = New-Object System.Drawing.Point(10, 540)
        $form.Controls.Add($script:allActionsPanel.Panel)
        
        # Créer un bouton pour exécuter toutes les actions
        $allActionsButton = New-StyledButton -Text "Exécuter toutes les actions" -Width 240 -Primary
        
        # Calculer la position X pour centrer le bouton (largeur du panneau - largeur du bouton) / 2
        $buttonX = ($script:allActionsPanel.Panel.Width - $allActionsButton.Width) / 2
        
        # Ajouter le bouton au panneau immédiatement après sa création avec un décalage vertical
        $script:allActionsPanel = Add-ControlToActionPanel -ActionPanel $script:allActionsPanel -Control $allActionsButton -X $buttonX -Y 20
        
        # Créer une barre de progression pour "Exécuter toutes les actions"
        $script:allProgressBar = New-ProgressBar -LabelText "Toutes les actions" -Width 510 -BarColor "Blue"
        $script:allActionsPanel = Add-ControlToActionPanel -ActionPanel $script:allActionsPanel -Control $script:allProgressBar.Panel -Y 60
        
        # Capturer les références dans des variables locales pour le scriptblock
        $localAllActionsPanel = $script:allActionsPanel
        $localAllProgressBar = $script:allProgressBar
        
        $allActionsButton.Add_Click({
            # Utiliser les variables locales capturées par le scriptblock
            if ($null -ne $localAllActionsPanel -and $null -ne $localAllProgressBar) {
                Invoke-ActionWithUI -Form $form -ActionType "All" -ActionPanel $localAllActionsPanel -ProgressBarLabel "Exécution de toutes les actions" -IsAllActions -ExistingProgressBar $localAllProgressBar.ProgressBar -CustomResultHandler {
                    param($result, $panel)
                    
                    # Traitement du résultat pour l'exécution de toutes les actions
                    if ($result.Success) {
                        $messageBoxTitle = "Succès"
                        $messageBoxType = [System.Windows.Forms.MessageBoxIcon]::Information
                    } else {
                        $messageBoxTitle = "Avertissement"
                        $messageBoxType = [System.Windows.Forms.MessageBoxIcon]::Warning
                    }
                    
                    # Créer une zone de texte pour le résumé
                    $summaryTextBox = New-StyledTextBox -Text $result.Results.Summary -Width 510 -Height 100 -ReadOnly -Multiline
                    
                    # Remplacer la barre de progression par le résumé
                    $panel.ContentPanel.Controls.Clear()
                    Add-ControlToActionPanel -ActionPanel $panel -Control $summaryTextBox
                    
                    # Afficher le message
                    [System.Windows.Forms.MessageBox]::Show($form, $result.Message, $messageBoxTitle, [System.Windows.Forms.MessageBoxButtons]::OK, $messageBoxType)
                    
                    # Mise à jour de la barre de statut
                    $statusBarControl = $form.Controls | Where-Object { $_ -is [System.Windows.Forms.Label] -and $_.Dock -eq [System.Windows.Forms.DockStyle]::Bottom }
                    if ($statusBarControl) {
                        Update-StatusBar -StatusBar $statusBarControl -Text $result.Message -Type $(if ($result.Success) { "Success" } else { "Warning" })
                    }
                }
            } else {
                [System.Windows.Forms.MessageBox]::Show($form, "Erreur: Le panel d'action ou la barre de progression est introuvable.", "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            }
        }.GetNewClosure())  # GetNewClosure capture les valeurs actuelles des variables
        
        # Ajouter un gestionnaire pour la fermeture de la fenêtre
        $form.Add_FormClosing({
            Write-Log "Fermeture de l'application" -Level "INFO"
            # S'assurer que l'application se ferme proprement
            [System.Windows.Forms.Application]::Exit()
        })
        
        # Ne plus afficher la fenêtre ici, juste la retourner
        # En mode test ou normal, simplement retourner le formulaire
        Write-Log "Interface principale créée avec succès" -Level "SUCCESS"
        Write-ConsoleLog "✅ Interface principale créée" -Color Green
        
        # Retourner le formulaire sans cast explicite
        return $form
    }
    catch {
        $errorDetails = $_.Exception.Message
        $errorMessage = "Erreur lors de la création de l'interface principale: $errorDetails"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        if (-not $TestMode) {
            [System.Windows.Forms.MessageBox]::Show($errorMessage, "Erreur", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
        
        return $null
    }
}

# Fonction pour initialiser l'interface (fonction appelée par start.ps1)
function Initialize-Interface {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$TestMode = $false
    )
    
    # Rediriger les sorties de log vers $null pour éviter quelles ne soient retournées
    Write-ConsoleLog "🔍 Initialisation de l'interface utilisateur..." -Color Cyan | Out-Null
    
    try {
        # Vérifier que les assemblies Windows Forms sont chargées
        if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.Form').Type) {
            try {
                Add-Type -AssemblyName System.Windows.Forms
                Add-Type -AssemblyName System.Drawing
                Write-ConsoleLog "✅ Assemblies Windows Forms chargées" -Color Green | Out-Null
            } catch {
                $errorDetails = $_.Exception.Message
                $errorMessage = "Impossible de charger les assemblies Windows Forms: $errorDetails"
                Write-ConsoleLog "❌ $errorMessage" -Color Red | Out-Null
                
                # Créer un formulaire d'erreur pour éviter un retour null
                $errorForm = New-Object System.Windows.Forms.Form
                $errorForm.Text = "Unlocker Free Trial - ERROR"
                $errorForm.Size = New-Object System.Drawing.Size(600, 200)
                $errorForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
                
                $errorLabel = New-Object System.Windows.Forms.Label
                $errorLabel.Text = $errorMessage
                $errorLabel.Location = New-Object System.Drawing.Point(20, 20)
                $errorLabel.Size = New-Object System.Drawing.Size(560, 100)
                $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
                $errorLabel.ForeColor = [System.Drawing.Color]::Red
                $errorForm.Controls.Add($errorLabel)
                
                return $errorForm
            }
        }
        
        # Variable pour stocker le formulaire
        $mainForm = $null
        
        # Créer l'interface principale dans un bloc try séparé
        try {
            # Obtenir le chemin du script de manière fiable
            $scriptPath = Get-ScriptPath
            if (-not $scriptPath) {
                throw "Impossible de déterminer le chemin du script"
            }
            
            # Créer l'interface principale sans redirection des sorties
            if ($TestMode) {
                $result = New-MainInterface -TestMode
            } else {
                $result = New-MainInterface
            }
            
            if ($env:DEBUG_MODE -eq "1") {
                Write-Host "Debug: Type du formulaire retourné par New-MainInterface: $($result.GetType().FullName)"
            }
            
            # Si le résultat est un tableau, essayer d'extraire le formulaire
            if ($result -is [System.Array]) {
                # Parcourir le tableau pour trouver un objet Form
                foreach ($item in $result) {
                    if ($item -is [System.Windows.Forms.Form]) {
                        $mainForm = $item
                        if ($env:DEBUG_MODE -eq "1") {
                            Write-Host "Debug: Formulaire trouvé dans le tableau retourné"
                        }
                        break
                    }
                }
                
                # Si aucun formulaire n'a été trouvé, utiliser le premier élément
                if ($null -eq $mainForm -and $result.Length -gt 0) {
                    $mainForm = $result[0]
                    if ($env:DEBUG_MODE -eq "1") {
                        Write-Host "Debug: Utilisation du premier élément du tableau comme formulaire"
                    }
                }
            } else {
                # Si ce n'est pas un tableau, utiliser directement le résultat
                $mainForm = $result
            }
        }
        catch {
            $errorDetails = $_.Exception.Message
            $errorMessage = "Erreur lors de la création de l'interface principale: $errorDetails"
            Write-Log $errorMessage -Level "ERROR" | Out-Null
            Write-ConsoleLog "❌ $errorMessage" -Color Red | Out-Null
            
            # Créer un formulaire d'erreur
            $mainForm = New-Object System.Windows.Forms.Form
            $mainForm.Text = "Unlocker Free Trial - ERROR"
            $mainForm.Size = New-Object System.Drawing.Size(600, 200)
            $mainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            
            $errorLabel = New-Object System.Windows.Forms.Label
            $errorLabel.Text = $errorMessage
            $errorLabel.Location = New-Object System.Drawing.Point(20, 20)
            $errorLabel.Size = New-Object System.Drawing.Size(560, 100)
            $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $errorLabel.ForeColor = [System.Drawing.Color]::Red
            $mainForm.Controls.Add($errorLabel)
        }
        
        # Vérifier que le formulaire est un type valide - utiliser l'opérateur -is qui est plus fiable
        $isValidForm = $false
        if ($null -ne $mainForm) {
            $isValidForm = $mainForm -is [System.Windows.Forms.Form]
            
            if ($env:DEBUG_MODE -eq "1") {
                Write-Host "Debug: Vérification du type de formulaire"
                Write-Host "Debug: Type attendu: System.Windows.Forms.Form"
                Write-Host "Debug: Type reçu: $($mainForm.GetType().FullName)"
                Write-Host "Debug: Est un Form: $isValidForm"
            }
        }
        
        if (-not $isValidForm) {
            Write-ConsoleLog "❌ Le résultat de New-MainInterface n'est pas un objet Form valide" -Color Red | Out-Null
            
            # Créer un formulaire de base comme fallback
            $mainForm = New-Object System.Windows.Forms.Form
            $mainForm.Text = "Unlocker Free Trial - ERROR"
            $mainForm.Size = New-Object System.Drawing.Size(600, 200)
            $mainForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
            
            $errorLabel = New-Object System.Windows.Forms.Label
            $errorLabel.Text = "Erreur: Le formulaire généré n'est pas valide"
            $errorLabel.Location = New-Object System.Drawing.Point(20, 20)
            $errorLabel.Size = New-Object System.Drawing.Size(560, 100)
            $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
            $errorLabel.ForeColor = [System.Drawing.Color]::Red
            $mainForm.Controls.Add($errorLabel)
        }
        
        Write-Log "Interface créée avec succès" -Level "SUCCESS" | Out-Null
        Write-ConsoleLog "✅ Interface créée avec succès" -Color Green | Out-Null
        
        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "Debug: Type final du formulaire: $($mainForm.GetType().FullName)"
        }
        
        # Retourner uniquement le formulaire, sans cast explicite qui pourrait causer des problèmes
        return $mainForm
    }
    catch {
        $errorDetails = $_.Exception.Message
        $errorMessage = "Erreur lors de l'initialisation de l'interface: $errorDetails"
        Write-Log $errorMessage -Level "ERROR" | Out-Null
        Write-ConsoleLog "❌ $errorMessage" -Color Red | Out-Null
        
        # Créer un formulaire d'erreur pour éviter un retour null
        $errorForm = New-Object System.Windows.Forms.Form
        $errorForm.Text = "Unlocker Free Trial - ERROR CRITIQUE"
        $errorForm.Size = New-Object System.Drawing.Size(600, 200)
        $errorForm.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
        
        $errorLabel = New-Object System.Windows.Forms.Label
        $errorLabel.Text = "Erreur critique: $_"
        $errorLabel.Location = New-Object System.Drawing.Point(20, 20)
        $errorLabel.Size = New-Object System.Drawing.Size(560, 100)
        $errorLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $errorLabel.ForeColor = [System.Drawing.Color]::Red
        $errorForm.Controls.Add($errorLabel)
        
        return $errorForm
    }
}

# Fonction pour vérifier que tous les fichiers requis sont présents
function Test-AllRequiredFiles {
    Write-ConsoleLog "🔍 Vérification des fichiers requis..." -Color Cyan
    
    try {
        # Obtenir le chemin du script via le module de configuration
        $scriptPath = Get-ScriptPath
        if (-not $scriptPath) {
            Write-ConsoleLog "❌ Impossible de déterminer le chemin du script" -Color Red
            return @{
                Success = $false
                MissingFiles = @("Chemin du script invalide")
            }
        }
        
        # Liste des fichiers requis
        $requiredFiles = @(
            "Step2_Logging.ps1",
            "Step3_Configuration.ps1",
            "Step4_Storage.ps1",
            "Step5_NetworkAdapter.ps1",
            "Step7_MachineGuid.ps1",
            "Step9_Initialization.ps1",
            "Step10_ProgressBar.ps1",
            "Step11_ExecuteAll.ps1",
            "Step12_Visuals.ps1",
            "Step13_Interface.ps1"
        )
        
        $missingFiles = @()
        
        foreach ($file in $requiredFiles) {
            $filePath = Join-Path -Path $scriptPath -ChildPath $file
            if (-not (Test-Path $filePath)) {
                $missingFiles += $file
                Write-ConsoleLog "❌ Fichier manquant: $file" -Color Red
            }
        }
        
        if ($missingFiles.Count -eq 0) {
            Write-ConsoleLog "✅ Tous les fichiers requis sont présents" -Color Green
            return @{
                Success = $true
                MissingFiles = @()
            }
        } else {
            Write-ConsoleLog "❌ Fichiers manquants: $($missingFiles -join ', ')" -Color Red
            return @{
                Success = $false
                MissingFiles = $missingFiles
            }
        }
    } catch {
        Write-ConsoleLog "❌ Erreur lors de la vérification des fichiers requis: $_" -Color Red
        return @{
            Success = $false
            MissingFiles = @("Erreur: $_")
        }
    }
} 