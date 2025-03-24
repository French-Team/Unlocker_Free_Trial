# =================================================================
# Fichier     : Step8_ProgressBar.ps1
# Role        : Gestionnaire de la barre de progression
# =================================================================

# Variables globales pour les étapes de progression
$global:ProgressSteps = @{
    "Initialization" = @{
        Start = 0
        End = 25
        Message = "Initialisation..."
    }
    "MacAddress" = @{
        Start = 25
        End = 50
        Message = "Modification de l'adresse MAC..."
    }
    "Storage" = @{
        Start = 50
        End = 75
        Message = "Suppression du fichier storage.json..."
    }
    "MachineGuid" = @{
        Start = 75
        End = 100
        Message = "Modification du MachineGuid..."
    }
}

function Update-ProgressBar {
    param (
        [int]$Progress,
        [string]$Message = "",
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$MessageLabel,
        [System.Windows.Forms.Label]$PercentLabel
    )
    
    try {
        # Mise à jour de la barre de progression
        if ($ProgressBar) {
            # S'assurer que la progression est entre 0 et 100
            $Progress = [Math]::Min(100, [Math]::Max(0, $Progress))
            $ProgressBar.Value = $Progress
        }
        
        # Mise à jour du message
        if ($MessageLabel) {
            $MessageLabel.Text = if ($Message) { $Message } else { "Progression: $Progress%" }
        }
        
        # Mise à jour du pourcentage
        if ($PercentLabel) {
            $PercentLabel.Text = "$Progress%"
        }
        
        # Forcer la mise à jour de l'interface
        [System.Windows.Forms.Application]::DoEvents()
    }
    catch {
        Write-Host "Erreur lors de la mise à jour de la barre de progression : $_" -ForegroundColor Red
    }
}

function Reset-ProgressBar {
    param (
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$MessageLabel,
        [System.Windows.Forms.Label]$PercentLabel
    )
    
    try {
        if ($ProgressBar) {
            $ProgressBar.Value = 0
        }
        if ($MessageLabel) {
            $MessageLabel.Text = "Prêt"
        }
        if ($PercentLabel) {
            $PercentLabel.Text = "0%"
        }
    }
    catch {
        Write-Host "Erreur lors de la réinitialisation de la barre de progression : $_" -ForegroundColor Red
    }
}

function Update-StepProgress {
    param (
        [string]$Step,  # Pour la compatibilité avec les appels dans Step3_Interface.ps1
        [string]$StepName, # Pour la compatibilité avec les appels dans Step6_ExecuteAll.ps1
        [int]$Progress = -1, # Pour la compatibilité avec les appels dans Step6_ExecuteAll.ps1
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$MessageLabel,
        [System.Windows.Forms.Label]$StatusLabel = $null, # Pour la compatibilité avec les appels dans Step6_ExecuteAll.ps1
        [System.Windows.Forms.Label]$PercentLabel = $null
    )
    
    # Harmoniser les paramètres
    if ([string]::IsNullOrEmpty($Step) -and -not [string]::IsNullOrEmpty($StepName)) {
        $Step = $StepName
    }
    
    if ($StatusLabel -ne $null -and $MessageLabel -eq $null) {
        $MessageLabel = $StatusLabel
    }
    
    # Si un pourcentage spécifique est fourni, l'utiliser
    if ($Progress -ge 0) {
        Update-ProgressBar -Progress $Progress -ProgressBar $ProgressBar -MessageLabel $MessageLabel -PercentLabel $PercentLabel
        return
    }
    
    # Sinon utiliser l'étape prédéfinie
    if ($global:ProgressSteps.ContainsKey($Step)) {
        $stepInfo = $global:ProgressSteps[$Step]
        
        # Progression fluide de la valeur de début à la valeur de fin
        for ($i = $stepInfo.Start; $i -le $stepInfo.End; $i += 5) {
            Update-ProgressBar -Progress $i -Message $stepInfo.Message -ProgressBar $ProgressBar -MessageLabel $MessageLabel -PercentLabel $PercentLabel
            Start-Sleep -Milliseconds 100
        }
        
        # S'assurer que la valeur finale est atteinte
        Update-ProgressBar -Progress $stepInfo.End -Message $stepInfo.Message -ProgressBar $ProgressBar -MessageLabel $MessageLabel -PercentLabel $PercentLabel
    }
} 