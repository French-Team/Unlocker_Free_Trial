# =================================================================
# Fichier     : Step12_Visuals.ps1
# Role        : Module des éléments visuels
# Description : Gère les éléments visuels de l'interface utilisateur
# =================================================================

# Fonction pour créer un bouton stylisé
function New-StyledButton {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$false)]
        [int]$Width = 150,
        
        [Parameter(Mandatory=$false)]
        [int]$Height = 40,
        
        [Parameter(Mandatory=$false)]
        [switch]$Primary
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = $Text
    $button.Width = $Width
    $button.Height = $Height
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    
    if ($Primary) {
        $button.BackColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
        $button.ForeColor = [System.Drawing.Color]::White
    }
    else {
        $button.BackColor = [System.Drawing.Color]::FromArgb(240, 240, 240)
        $button.ForeColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
    }
    
    return $button
}

# Fonction pour créer un label d'en-tête
function New-HeaderLabel {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Text,
        
        [Parameter(Mandatory=$false)]
        [int]$Width = 300,
        
        [Parameter(Mandatory=$false)]
        [switch]$SubHeader
    )
    
    $label = New-Object System.Windows.Forms.Label
    $label.Text = $Text
    $label.Width = $Width
    $label.AutoSize = $false
    
    if ($SubHeader) {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 12)
        $label.ForeColor = [System.Drawing.Color]::FromArgb(80, 80, 80)
    }
    else {
        $label.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
        $label.ForeColor = [System.Drawing.Color]::FromArgb(0, 120, 215)
    }
    
    return $label
}

# Fonction pour créer un panneau d'action
function New-ActionPanel {
    param (
        [Parameter(Mandatory=$false)]
        [string]$Title = "",
        
        [Parameter(Mandatory=$false)]
        [string]$Description = "",
        
        [Parameter(Mandatory=$false)]
        [int]$Width = 760,
        
        [Parameter(Mandatory=$false)]
        [int]$Height = 120
    )
    
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Width = $Width
    $panel.Height = $Height
    $panel.BackColor = [System.Drawing.Color]::FromArgb(245, 245, 245)
    $panel.BorderStyle = [System.Windows.Forms.BorderStyle]::FixedSingle
    
    # Créer un panel pour le contenu
    $contentPanel = New-Object System.Windows.Forms.Panel
    $contentPanel.Width = $Width - 20
    $contentPanel.Height = $Height - 60
    $contentPanel.Location = New-Object System.Drawing.Point(10, 50)
    $contentPanel.BackColor = [System.Drawing.Color]::Transparent
    $panel.Controls.Add($contentPanel)
    
    if ($Title -ne "") {
        $titleLabel = New-Object System.Windows.Forms.Label
        $titleLabel.Text = $Title
        $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
        $titleLabel.ForeColor = [System.Drawing.Color]::FromArgb(60, 60, 60)
        $titleLabel.Location = New-Object System.Drawing.Point(10, 10)
        $titleLabel.AutoSize = $true
        $panel.Controls.Add($titleLabel)
    }
    
    if ($Description -ne "") {
        $descriptionLabel = New-Object System.Windows.Forms.Label
        $descriptionLabel.Text = $Description
        $descriptionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
        $descriptionLabel.ForeColor = [System.Drawing.Color]::FromArgb(100, 100, 100)
        $descriptionLabel.Location = New-Object System.Drawing.Point(10, 30)
        $descriptionLabel.AutoSize = $true
        $panel.Controls.Add($descriptionLabel)
    }
    
    return @{
        Panel = $panel
        ContentPanel = $contentPanel
    }
}

# Fonction pour ajouter un contrôle à un panneau d'action
function Add-ControlToActionPanel {
    param (
        [Parameter(Mandatory=$true)]
        [PSObject]$ActionPanel,
        
        [Parameter(Mandatory=$true)]
        [System.Windows.Forms.Control]$Control,
        
        [Parameter(Mandatory=$false)]
        [int]$X = 20,
        
        [Parameter(Mandatory=$false)]
        [int]$Y = 0
    )
    
    $Control.Location = New-Object System.Drawing.Point($X, $Y)
    $ActionPanel.ContentPanel.Controls.Add($Control)
    
    return $ActionPanel
}

# Initialiser le module des éléments visuels
function Initialize-VisualsManager {
    Write-Host "🔍 Initialisation du module des éléments visuels..." -ForegroundColor Cyan
    
    try {
        # Vérifier que les assemblies Windows Forms sont chargées
        if (-not ([System.Management.Automation.PSTypeName]'System.Windows.Forms.Form').Type) {
            # Tenter de charger l'assembly
            Add-Type -AssemblyName System.Windows.Forms
        }
        
        # Vérifier que les assemblies Drawing sont chargées
        if (-not ([System.Management.Automation.PSTypeName]'System.Drawing.Bitmap').Type) {
            # Tenter de charger l'assembly
            Add-Type -AssemblyName System.Drawing
        }
        
        Write-Host "Module des éléments visuels initialisé avec succès" -ForegroundColor Green
        Write-Host "✅ Module des éléments visuels initialisé" -ForegroundColor Green
        
        return $true
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du module des éléments visuels: $_"
        Write-Host $errorMessage -ForegroundColor Red
        Write-Host "❌ $errorMessage" -ForegroundColor Red
        
        return $false
    }
} 