# =================================================================
# Fichier     : Step10_ProgressBar.ps1
# Role        : Gestion des barres de progression
# Description : Gère la création et la mise à jour des barres de progression
# =================================================================

# Créer une nouvelle barre de progression avec un style spécifique
function New-ProgressBar {
    param (
        [Parameter(Mandatory=$false)]
        [string]$LabelText = "Opération en cours...",
        
        [Parameter(Mandatory=$false)]
        [int]$Width = 300,
        
        [Parameter(Mandatory=$false)]
        [int]$Height = 23,
        
        [Parameter(Mandatory=$false)]
        [switch]$HidePercent,
        
        [Parameter(Mandatory=$false)]
        [switch]$HideStatus,
        
        [Parameter(Mandatory=$false)]
        [string]$BarColor = "Blue" # Bleu par défaut (options: Red, Green, Blue, Yellow, etc.)
    )
    
    Write-ConsoleLog "🔍 Création d'une barre de progression..." -Color Cyan
    
    try {
        # Créer un contrôle ProgressBar
        $progressBar = New-Object System.Windows.Forms.ProgressBar
        $progressBar.Name = "ProgressBar"
        $progressBar.Value = 0
        $progressBar.Style = "Continuous" # Style continu (vs. Marquee)
        $progressBar.Width = $Width
        $progressBar.Height = 23 # Hauteur standard
        $progressBar.Anchor = 3 # Left | Right
        
        # Essayer de définir la couleur de la barre (si possible)
        if ($BarColor) {
            try {
                # Tenter de définir la couleur via la propriété ForeColor
                $color = [System.Drawing.Color]::FromName($BarColor)
                $progressBar.ForeColor = $color
                
                # Tenter d'utiliser un style visuel en fonction de la couleur
                if ($BarColor -eq "Blue") {
                    # Utiliser un style visuel bleu si disponible
                }
            } catch {
                Write-Log "Impossible de définir la couleur de la barre de progression: $_" -Level "WARNING"
            }
        }
        
        # Créer un panel pour contenir la barre de progression et les labels
        $panel = New-Object System.Windows.Forms.Panel
        $panel.Width = $Width
        $panel.Height = if ($HideStatus -and $HidePercent) { $Height } else { $Height + 20 }
        $panel.Anchor = 3 # Left | Right
        
        # Ajouter la barre de progression au panel
        $progressBar.Location = New-Object System.Drawing.Point(0, 0)
        $panel.Controls.Add($progressBar)
        
        # Créer un label pour le texte descriptif
        $label = New-Object System.Windows.Forms.Label
        $label.Text = $LabelText
        $label.AutoSize = $true
        $label.Location = New-Object System.Drawing.Point(0, $Height + 2)
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $panel.Controls.Add($label)
        
        # Créer un label pour le pourcentage (si non masqué)
        $percentLabel = $null
        if (-not $HidePercent) {
            $percentLabel = New-Object System.Windows.Forms.Label
            $percentLabel.Text = "0%"
            $percentLabel.AutoSize = $true
            $percentLabel.Location = New-Object System.Drawing.Point($Width - 30, $Height + 2)
            $percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
            $panel.Controls.Add($percentLabel)
        }
        
        # Créer un label pour le statut (si non masqué)
        $statusLabel = $null
        if (-not $HideStatus) {
            $statusLabel = New-Object System.Windows.Forms.Label
            $statusLabel.Text = "Initialisation..."
            $statusLabel.AutoSize = $true
            $statusLabel.Location = New-Object System.Drawing.Point(($Width / 2) - 40, $Height + 2)
            $statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
            $panel.Controls.Add($statusLabel)
        }
        
        # Créer un objet personnalisé pour retourner tous les éléments
        $progressBarObject = [PSCustomObject]@{
            Panel = $panel
            ProgressBar = $progressBar
            Label = $label
            StatusLabel = $statusLabel
            PercentLabel = $percentLabel
            ShowPercent = (-not $HidePercent)
            ShowStatus = (-not $HideStatus)
        }
        
        Write-Log "Barre de progression créée avec succès" -Level "SUCCESS"
        Write-ConsoleLog "✅ Barre de progression créée" -Color Green
        
        # Vérifier que l'objet est valide avant de le retourner
        if (-not $progressBarObject.Panel -or -not $progressBarObject.ProgressBar) {
            throw "L'objet barre de progression n'a pas été correctement créé"
        }
        
        return $progressBarObject
    }
    catch {
        $errorMessage = "Erreur lors de la création de la barre de progression: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Créer un objet de secours minimal pour éviter les erreurs null
        $fallbackPanel = New-Object System.Windows.Forms.Panel
        $fallbackPanel.Width = $Width
        $fallbackPanel.Height = $Height
        
        $fallbackProgressBar = New-Object System.Windows.Forms.ProgressBar
        $fallbackProgressBar.Width = $Width
        $fallbackProgressBar.Height = $Height
        $fallbackProgressBar.Value = 0
        
        $fallbackPanel.Controls.Add($fallbackProgressBar)
        
        $fallbackObject = [PSCustomObject]@{
            Panel = $fallbackPanel
            ProgressBar = $fallbackProgressBar
            Label = $null
            StatusLabel = $null
            PercentLabel = $null
            ShowPercent = $false
            ShowStatus = $false
            IsErrorFallback = $true
        }
        
        Write-Log "Utilisation d'une barre de progression de secours suite à une erreur" -Level "WARNING"
        
        return $fallbackObject
    }
}

# Mettre à jour l'état d'une barre de progression
function Update-ProgressBar {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ProgressBar,
        
        [Parameter(Mandatory=$false)]
        [string]$Status = $null,
        
        [Parameter(Mandatory=$false)]
        [int]$PercentComplete = -1,
        
        [Parameter(Mandatory=$false)]
        [string]$LabelText = $null,
        
        [Parameter(Mandatory=$false)]
        [switch]$EnableControl = $false,
        
        [Parameter(Mandatory=$false)]
        [switch]$DisableControl = $false
    )
    
    try {
        # Vérifier que l'objet barre de progression est valide
        if (-not $ProgressBar) {
            Write-Log "Tentative de mise à jour d'une barre de progression null" -Level "ERROR"
            return $false
        }
        
        # Vérifier si c'est un objet de secours (fallback)
        $isFallback = $false
        if ($ProgressBar.PSObject.Properties.Name -contains "IsErrorFallback") {
            $isFallback = $ProgressBar.IsErrorFallback
        }
        
        # Vérifier les propriétés essentielles
        if (-not $ProgressBar.ProgressBar) {
            Write-Log "La propriété ProgressBar est manquante dans l'objet barre de progression" -Level "ERROR"
            return $false
        }
        
        if (-not $ProgressBar.Panel) {
            Write-Log "La propriété Panel est manquante dans l'objet barre de progression" -Level "ERROR"
            return $false
        }
        
        # Mise à jour de la valeur de la barre de progression
        if ($PercentComplete -ge 0 -and $PercentComplete -le 100) {
            $ProgressBar.ProgressBar.Value = $PercentComplete
            
            # Mise à jour du label de pourcentage si présent
            if (-not $isFallback -and $ProgressBar.ShowPercent -and $ProgressBar.PercentLabel) {
                $ProgressBar.PercentLabel.Text = "$PercentComplete%"
            }
            
            Write-Log "Barre de progression mise à jour: $PercentComplete%" -Level "DEBUG"
        }
        
        # Mise à jour du texte de statut si fourni et si le label de statut existe
        if ($Status -and -not $isFallback -and $ProgressBar.ShowStatus -and $ProgressBar.StatusLabel) {
            $ProgressBar.StatusLabel.Text = $Status
            Write-Log "Statut de la barre de progression mis à jour: $Status" -Level "DEBUG"
        }
        
        # Mise à jour du texte du label principal si fourni
        if ($LabelText -and -not $isFallback -and $ProgressBar.Label) {
            $ProgressBar.Label.Text = $LabelText
            Write-Log "Texte de la barre de progression mis à jour: $LabelText" -Level "DEBUG"
        }
        
        # Activer ou désactiver le contrôle si demandé
        if ($EnableControl) {
            $ProgressBar.Panel.Enabled = $true
            Write-Log "Barre de progression activée" -Level "DEBUG"
        }
        elseif ($DisableControl) {
            $ProgressBar.Panel.Enabled = $false
            Write-Log "Barre de progression désactivée" -Level "DEBUG"
        }
        
        # Forcer la mise à jour visuelle
        $ProgressBar.Panel.Refresh()
        
        return $true
    }
    catch {
        $errorMessage = "Erreur lors de la mise à jour de la barre de progression: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        return $false
    }
}

# Réinitialiser une barre de progression
function Reset-ProgressBar {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ProgressBar,
        
        [Parameter(Mandatory=$false)]
        [string]$Status = "En attente...",
        
        [Parameter(Mandatory=$false)]
        [string]$LabelText = $null
    )
    
    try {
        # Vérifier que l'objet barre de progression est valide
        if (-not $ProgressBar -or -not $ProgressBar.ProgressBar -or -not $ProgressBar.Panel) {
            Write-Log "Tentative de réinitialisation d'une barre de progression non valide" -Level "ERROR"
            return $false
        }
        
        # Réinitialiser la valeur à 0
        $ProgressBar.ProgressBar.Value = 0
        
        # Réinitialiser le label de pourcentage si présent
        if ($ProgressBar.ShowPercent -and $ProgressBar.PercentLabel) {
            $ProgressBar.PercentLabel.Text = "0%"
        }
        
        # Réinitialiser le texte de statut si présent
        if ($ProgressBar.ShowStatus -and $ProgressBar.StatusLabel) {
            $ProgressBar.StatusLabel.Text = $Status
        }
        
        # Réinitialiser le texte principal si demandé
        if ($LabelText -and $ProgressBar.Label) {
            $ProgressBar.Label.Text = $LabelText
        }
        
        # Forcer la mise à jour visuelle
        $ProgressBar.Panel.Refresh()
        
        Write-Log "Barre de progression réinitialisée" -Level "DEBUG"
        
        return $true
    }
    catch {
        $errorMessage = "Erreur lors de la réinitialisation de la barre de progression: $_"
        Write-Log $errorMessage -Level "ERROR"
        
        return $false
    }
}

# Exécute une opération avec barre de progression
function Invoke-WithProgress {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$ProgressBar,
        
        [Parameter(Mandatory=$true)]
        [scriptblock]$ScriptBlock,
        
        [Parameter(Mandatory=$false)]
        [string]$LabelText = "Opération en cours...",
        
        [Parameter(Mandatory=$false)]
        [string]$InitialStatus = "Démarrage...",
        
        [Parameter(Mandatory=$false)]
        [hashtable]$Parameters = @{}
    )
    
    Write-ConsoleLog "🔍 Exécution d'une opération avec barre de progression..." -Color Cyan
    
    try {
        # Préparer la barre de progression
        Update-ProgressBar -ProgressBar $ProgressBar -LabelText $LabelText -Status $InitialStatus -PercentComplete 0
        
        # Ajouter la barre de progression aux paramètres du script
        $Parameters['ProgressBar'] = $ProgressBar
        
        # Exécuter le script avec les paramètres
        $result = & $ScriptBlock @Parameters
        
        # Finaliser la barre de progression en fonction du résultat
        if ($result -and $result.Success) {
            $statusMessage = if ($result.Message) { $result.Message } else { "Opération terminée avec succès" }
            Update-ProgressBar -ProgressBar $ProgressBar -Status $statusMessage -PercentComplete 100
            Write-Log "Opération avec barre de progression terminée avec succès" -Level "SUCCESS"
            Write-ConsoleLog "✅ Opération terminée avec succès" -Color Green
        } else {
            $errorMessage = if ($result -and $result.Message) { $result.Message } else { "Échec de l'opération" }
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur: $errorMessage" -PercentComplete 100
            Write-Log "Échec de l'opération avec barre de progression: $errorMessage" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'opération: $errorMessage" -Color Red
        }
        
        return $result
    }
    catch {
        $errorMessage = "Erreur lors de l'exécution de l'opération avec barre de progression: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression en cas d'erreur
        Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur: $_" -PercentComplete 100
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
}

# Initialiser le module de gestion des barres de progression
function Initialize-ProgressBarManager {
    Write-ConsoleLog "🔍 Initialisation du module de gestion des barres de progression..." -Color Cyan
    
    try {
        # Vérifier que les assemblies Windows Forms sont chargées
        if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.Form').Type) {
            # Tenter de charger l'assembly
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            
            Write-Log "Assemblies Windows Forms chargées" -Level "INFO"
        }
        
        Write-Log "Module de gestion des barres de progression initialisé avec succès" -Level "SUCCESS"
        Write-ConsoleLog "✅ Module de gestion des barres de progression initialisé" -Color Green
        
        return $true
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du module de gestion des barres de progression: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        return $false
    }
} 