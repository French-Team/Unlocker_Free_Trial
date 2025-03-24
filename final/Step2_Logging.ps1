# =================================================================
# Fichier     : Step2_Logging.ps1
# Role        : Système de journalisation
# Description : Gère l'écriture des logs dans un fichier et dans la console
# =================================================================

# Définir le chemin du fichier de log
$script:LogFilePath = Join-Path -Path $PSScriptRoot -ChildPath "unlocker.log"

# Initialiser le fichier de log s'il n'existe pas
function Initialize-LogFile {
    if (-not (Test-Path -Path $script:LogFilePath)) {
        try {
            $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
            "[$timestamp] === Démarrage du journal Unlocker Free Trial ===" | Out-File -FilePath $script:LogFilePath -Encoding utf8
            Write-ConsoleLog "✅ Fichier de log initialisé à: $script:LogFilePath" -Color Green
            return $true
        }
        catch {
            Write-ConsoleLog "❌ Erreur lors de l'initialisation du fichier de log: $_" -Color Red
            return $false
        }
    }
    else {
        Write-ConsoleLog "ℹ️ Fichier de log existant: $script:LogFilePath" -Color Cyan
        return $true
    }
}

# Écrire un message dans le fichier de log
function Write-Log {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "CONFIG")]
        [string]$Level = "INFO"
    )
    
    try {
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        "[$timestamp] [$Level] $Message" | Out-File -FilePath $script:LogFilePath -Append -Encoding utf8
        
        # Déterminer la couleur en fonction du niveau
        $color = switch ($Level) {
            "INFO"    { "White" }
            "WARNING" { "Yellow" }
            "ERROR"   { "Red" }
            "SUCCESS" { "Green" }
            "DEBUG"   { "Gray" }
            "CONFIG"  { "Cyan" }
            default   { "White" }
        }
        
        # Afficher également le message dans la console (sauf si c'est un message de débogage)
        if ($Level -ne "DEBUG" -or $env:DEBUG_MODE) {
            Write-ConsoleLog "[$Level] $Message" -Color $color
        }
        
        return $true
    }
    catch {
        Write-ConsoleLog "❌ Erreur lors de l'écriture dans le fichier de log: $_" -Color Red
        return $false
    }
}

# Obtenir le chemin du fichier de log
function Get-LogFilePath {
    return $script:LogFilePath
}

# Initialiser le système de journalisation
function Initialize-Logging {
    Write-ConsoleLog "🔍 Initialisation du système de journalisation..." -Color Cyan
    
    $result = Initialize-LogFile
    if ($result) {
        Write-Log "Système de journalisation initialisé" -Level "INFO"
        Write-Log "Version de PowerShell: $($PSVersionTable.PSVersion)" -Level "INFO"
        Write-Log "Système d'exploitation: $([System.Environment]::OSVersion.VersionString)" -Level "INFO"
        return $true
    }
    else {
        Write-ConsoleLog "❌ Échec de l'initialisation du système de journalisation" -Color Red
        return $false
    }
} 