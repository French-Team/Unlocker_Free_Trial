# =================================================================
# Fichier     : Step4_Storage.ps1
# Role        : Gestion du stockage
# Description : Gère le fichier de stockage JSON
# =================================================================

# Obtenir le chemin du fichier de stockage
function Get-StoragePath {
    $storagePath = Get-ConfigValue -Key "StoragePath"
    
    if (-not $storagePath) {
        Write-Log "Impossible d'obtenir le chemin du fichier de stockage depuis la configuration" -Level "ERROR"
        throw "Chemin du fichier de stockage non disponible"
    }
    
    Write-Log "Chemin du fichier de stockage récupéré: $storagePath" -Level "DEBUG"
    return $storagePath
}

# Vérifier si le fichier de stockage existe
function Test-StorageExists {
    $storagePath = Get-StoragePath
    $exists = Test-Path -Path $storagePath
    
    if ($exists) {
        Write-Log "Le fichier de stockage existe: $storagePath" -Level "DEBUG"
    } else {
        Write-Log "Le fichier de stockage n'existe pas: $storagePath" -Level "DEBUG"
    }
    
    return $exists
}

# Supprimer le fichier de stockage, fonction renommée comme demandé
function DeleteStorageFile {
    Write-ConsoleLog "🔍 Suppression du fichier de stockage..." -Color Cyan
    
    try {
        # Obtenir directement le chemin du stockage depuis la configuration
        $storagePath = Get-ConfigValue -Key "StoragePath"
        
        if (-not $storagePath) {
            # Construire le chemin manuellement si non disponible dans la config
            $storagePath = Join-Path -Path $env:APPDATA -ChildPath "Cursor\User\globalStorage\storage.json"
            Write-Log "Utilisation du chemin de stockage par défaut: $storagePath" -Level "WARNING"
        }
        
        Write-Log "Tentative de suppression du fichier de stockage: $storagePath" -Level "INFO"
        
        if (Test-Path $storagePath) {
            # Le fichier existe, on le supprime
            Remove-Item -Path $storagePath -Force
            Write-Log "Fichier de stockage supprimé avec succès" -Level "SUCCESS"
            return @{
                Success = $true
                Message = "Fichier de stockage supprimé avec succès"
            }
        } else {
            # Le fichier n'existe pas, on le signale simplement
            Write-Log "Le fichier de stockage n'existe pas" -Level "INFO"
            return @{
                Success = $true  # Considéré comme un succès car l'objectif est déjà atteint
                Message = "Le fichier de stockage n'existe pas"
            }
        }
    }
    catch {
        Write-Log "Erreur lors de la suppression du fichier de stockage: $_" -Level "ERROR"
        return @{
            Success = $false
            Message = "Erreur lors de la suppression du fichier de stockage: $_"
        }
    }
}

# Obtenir le contenu du fichier de stockage
function Get-StorageContent {
    Write-ConsoleLog "🔍 Lecture du contenu du fichier de stockage..." -Color Cyan
    
    try {
        $storagePath = Get-StoragePath
        
        if (Test-Path $storagePath) {
            $content = Get-Content -Path $storagePath -Raw | ConvertFrom-Json
            Write-Log "Contenu du fichier de stockage récupéré avec succès" -Level "DEBUG"
            return $content
        } else {
            Write-Log "Le fichier de stockage n'existe pas, impossible de lire son contenu" -Level "WARNING"
            return $null
        }
    }
    catch {
        Write-Log "Erreur lors de la lecture du fichier de stockage: $_" -Level "ERROR"
        return $null
    }
}

# Initialiser le module de stockage
function Initialize-Storage {
    Write-ConsoleLog "🔍 Initialisation du module de stockage..." -Color Cyan
    
    try {
        $storagePath = Get-StoragePath
        Write-Log "Module de stockage initialisé - Chemin: $storagePath" -Level "INFO"
        Write-ConsoleLog "✅ Module de stockage initialisé" -Color Green
        return $true
    }
    catch {
        Write-Log "Erreur lors de l'initialisation du module de stockage: $_" -Level "ERROR"
        Write-ConsoleLog "❌ Erreur lors de l'initialisation du module de stockage" -Color Red
        return $false
    }
} 