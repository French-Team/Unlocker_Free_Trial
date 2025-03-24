# =================================================================
# Fichier     : Step9_Initialization.ps1
# Role        : Initialisation du système
# Description : Gère l'initialisation coordonnée de tous les modules du système
# =================================================================

# Vérifie si tous les modules système sont présents
function Test-RequiredModules {
    Write-ConsoleLog "🔍 Vérification des modules requis..." -Color Cyan
    
    try {
        # Appel au module de test des fichiers
        $testResult = Test-AllRequiredFiles
        
        if ($testResult.Success) {
            Write-Log "Tous les modules requis sont présents" -Level "SUCCESS"
            Write-ConsoleLog "✅ Tous les modules requis sont présents" -Color Green
            return $true
        } else {
            $missingFiles = $testResult.MissingFiles -join ", "
            Write-Log "Modules manquants: $missingFiles" -Level "ERROR"
            Write-ConsoleLog "❌ Modules manquants: $missingFiles" -Color Red
            return $false
        }
    } 
    catch {
        $errorMessage = "Erreur lors de la vérification des modules requis: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        return $false
    }
}

# Vérifie si le système dispose des privilèges administrateur
function Test-AdminPrivileges {
    Write-ConsoleLog "🔍 Vérification des privilèges administrateur..." -Color Cyan
    
    try {
        $isAdmin = Test-Administrator
        
        if ($isAdmin) {
            Write-Log "L'application s'exécute avec des privilèges administrateur" -Level "SUCCESS"
            Write-ConsoleLog "✅ Privilèges administrateur confirmés" -Color Green
            return $true
        } else {
            Write-Log "L'application s'exécute sans privilèges administrateur" -Level "WARNING"
            Write-ConsoleLog "⚠️ Absence de privilèges administrateur" -Color Yellow
            return $false
        }
    }
    catch {
        $errorMessage = "Erreur lors de la vérification des privilèges administrateur: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        return $false
    }
}

# Initialise le système réseau
function Initialize-NetworkSystem {
    param (
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Initialisation du système réseau..." -Color Cyan
    
    try {
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du réseau..." -PercentComplete 25
        }
        
        # Initialisation du module de gestion des adaptateurs réseau
        $networkAdapterInitialized = Initialize-NetworkAdapter
        
        if ($networkAdapterInitialized) {
            Write-Log "Module de gestion des adaptateurs réseau initialisé avec succès" -Level "SUCCESS"
            Write-ConsoleLog "✅ Module de gestion des adaptateurs réseau initialisé" -Color Green
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Suite de l'initialisation..." -PercentComplete 50
            }
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Système réseau initialisé" -PercentComplete 100
            }
            
            return $true
        } else {
            Write-Log "Échec de l'initialisation du module de gestion des adaptateurs réseau" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'initialisation du module de gestion des adaptateurs réseau" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur d'initialisation" -PercentComplete 100
            }
            
            return $false
        }
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du système réseau: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
        }
        
        return $false
    }
}

# Initialise le système de gestion d'identité
function Initialize-IdentitySystem {
    param (
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Initialisation du système d'identité..." -Color Cyan
    
    try {
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du gestionnaire GUID..." -PercentComplete 25
        }
        
        # Initialisation du module de gestion du GUID machine
        $guidInitialized = Initialize-MachineGuidManager
        
        if ($guidInitialized) {
            Write-Log "Module de gestion du GUID machine initialisé avec succès" -Level "SUCCESS"
            Write-ConsoleLog "✅ Module de gestion du GUID machine initialisé" -Color Green
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du gestionnaire de fichiers..." -PercentComplete 50
            }
            
            # Initialisation du module de gestion des fichiers
            $fileManagerInitialized = Initialize-FileManager
            
            if ($fileManagerInitialized) {
                Write-Log "Module de gestion des fichiers initialisé avec succès" -Level "SUCCESS"
                Write-ConsoleLog "✅ Module de gestion des fichiers initialisé" -Color Green
                
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Système d'identité initialisé" -PercentComplete 100
                }
                
                return $true
            } else {
                Write-Log "Échec de l'initialisation du module de gestion des fichiers" -Level "ERROR"
                Write-ConsoleLog "❌ Échec de l'initialisation du module de gestion des fichiers" -Color Red
                
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur d'initialisation" -PercentComplete 100
                }
                
                return $false
            }
        } else {
            Write-Log "Échec de l'initialisation du module de gestion du GUID machine" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'initialisation du module de gestion du GUID machine" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur d'initialisation" -PercentComplete 100
            }
            
            return $false
        }
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du système d'identité: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
        }
        
        return $false
    }
}

# Initialisation complète du système
function Initialize-System {
    param (
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Initialisation complète du système..." -Color Cyan
    
    try {
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Vérification des modules..." -PercentComplete 10
        }
        
        # Vérification des modules requis
        $modulesChecked = Test-RequiredModules
        
        if (-not $modulesChecked) {
            $errorMessage = "Modules requis manquants, initialisation impossible"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec - Modules manquants" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Vérification des privilèges..." -PercentComplete 20
        }
        
        # Vérification des privilèges administrateur
        $hasAdminRights = Test-AdminPrivileges
        
        if (-not $hasAdminRights) {
            $warningMessage = "L'application s'exécute sans privilèges administrateur. Certaines fonctionnalités peuvent être limitées."
            Write-Log $warningMessage -Level "WARNING"
            Write-ConsoleLog "⚠️ $warningMessage" -Color Yellow
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du système réseau..." -PercentComplete 30
        }
        
        # Initialisation du système réseau
        $networkInitialized = Initialize-NetworkSystem -ProgressBar $ProgressBar
        
        if (-not $networkInitialized) {
            $errorMessage = "Échec de l'initialisation du système réseau"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec - Système réseau" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du système d'identité..." -PercentComplete 60
        }
        
        # Initialisation du système d'identité
        $identityInitialized = Initialize-IdentitySystem -ProgressBar $ProgressBar
        
        if (-not $identityInitialized) {
            $errorMessage = "Échec de l'initialisation du système d'identité"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec - Système d'identité" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation terminée" -PercentComplete 100
        }
        
        Write-Log "Initialisation du système terminée avec succès" -Level "SUCCESS"
        Write-ConsoleLog "✅ Système initialisé avec succès" -Color Green
        
        return @{
            Success = $true
            AdminRights = $hasAdminRights
            Message = "Système initialisé avec succès"
        }
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du système: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur d'initialisation" -PercentComplete 100
        }
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
} 