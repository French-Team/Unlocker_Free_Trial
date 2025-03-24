# =================================================================
# Fichier     : Step11_ExecuteAll.ps1
# Role        : Exécution de toutes les actions
# Description : Gère l'exécution séquentielle de toutes les actions
# =================================================================

# Vérifier si la fonction Write-ConsoleLog est disponible
if (-not (Get-Command "Write-ConsoleLog" -ErrorAction SilentlyContinue)) {
    # Définir une fonction Write-ConsoleLog de secours
    function global:Write-ConsoleLog {
        param(
            [Parameter(Mandatory=$true)]
            [string]$Message,
            
            [Parameter(Mandatory=$false)]
            [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
            [string]$Color = "White"
        )
        
        Write-Host $Message -ForegroundColor $Color
        return $Message
    }
    
    Write-Host "⚠️ Fonction Write-ConsoleLog non trouvée, utilisation d'une version de secours" -ForegroundColor Yellow
}

# Vérifier si la fonction Write-Log est disponible
if (-not (Get-Command "Write-Log" -ErrorAction SilentlyContinue)) {
    # Définir une fonction Write-Log de secours
    function global:Write-Log {
        param (
            [Parameter(Mandatory=$true)]
            [string]$Message,
            
            [Parameter(Mandatory=$false)]
            [ValidateSet("INFO", "WARNING", "ERROR", "SUCCESS", "DEBUG", "CONFIG")]
            [string]$Level = "INFO"
        )
        
        $timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        $logMessage = "[$timestamp] [$Level] $Message"
        
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
        
        # Afficher le message dans la console
        if (Get-Command "Write-ConsoleLog" -ErrorAction SilentlyContinue) {
            Write-ConsoleLog "[$Level] $Message" -Color $color
        } else {
            Write-Host "[$Level] $Message" -ForegroundColor $color
        }
        
        # Essayer d'écrire dans un fichier de log
        try {
            $logFilePath = Join-Path -Path $PSScriptRoot -ChildPath "unlocker.log"
            $logMessage | Out-File -FilePath $logFilePath -Append -Encoding utf8
        } catch {
            # Ignorer les erreurs d'écriture dans le fichier
        }
    }
    
    Write-Host "⚠️ Fonction Write-Log non trouvée, utilisation d'une version de secours" -ForegroundColor Yellow
}

# Exécute toutes les actions dans l'ordre
function Invoke-AllActions {
    param (
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null,
        
        [Parameter(Mandatory=$false)]
        [switch]$SkipStorageRemoval = $false,
        
        [Parameter(Mandatory=$false)]
        [switch]$SkipMacReset = $false,
        
        [Parameter(Mandatory=$false)]
        [switch]$SkipGuidReset = $false
    )
    
    Write-ConsoleLog "🔍 Exécution de toutes les actions..." -Color Cyan
    
    try {
        # Tableau pour stocker les résultats de chaque action
        $results = @{
            Storage = $null
            Mac = $null
            Guid = $null
            Summary = ""
            AllSuccessful = $true
        }
        
        # Initialisation du système
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation du système..." -PercentComplete 0
        }
        
        $initResult = Initialize-System -ProgressBar $ProgressBar
        
        if (-not $initResult.Success) {
            $errorMessage = "Échec de l'initialisation du système: $($initResult.Message)"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur: $errorMessage" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
                Results = $results
            }
        }
        
        # Vérifier si nous avons les droits administrateur
        if (-not $initResult.AdminRights) {
            $warningMessage = "L'application s'exécute sans privilèges administrateur. Certaines actions peuvent échouer."
            Write-Log $warningMessage -Level "WARNING"
            Write-ConsoleLog "⚠️ $warningMessage" -Color Yellow
        }
        
        # 1. Nettoyage des fichiers temporaires (si non désactivé)
        if (-not $SkipStorageRemoval) {
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Nettoyage des fichiers temporaires..." -PercentComplete 20
            }
            
            Write-Log "Étape 1: Nettoyage des fichiers temporaires" -Level "INFO"
            
            # Vérifier si la fonction existe
            if (-not (Get-Command "Remove-TempFiles" -ErrorAction SilentlyContinue)) {
                Write-Log "La fonction de nettoyage des fichiers temporaires n'est pas définie" -Level "ERROR"
                Write-ConsoleLog "❌ La fonction de nettoyage des fichiers temporaires n'est pas définie" -Color Red
                
                # Essayer de charger le module Storage
                $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
                $storagePath = Join-Path -Path $scriptPath -ChildPath "Step4_Storage.ps1"
                
                if (Test-Path $storagePath) {
                    Write-Log "Tentative de chargement du module Step4_Storage.ps1" -Level "INFO"
                    . $storagePath
                    
                    if (-not (Get-Command "Remove-TempFiles" -ErrorAction SilentlyContinue)) {
                        $results.Storage = @{
                            Success = $false
                            Message = "La fonction de nettoyage des fichiers temporaires n'est pas disponible"
                            ActionType = "Storage"
                        }
                    }
                } else {
                    $results.Storage = @{
                        Success = $false
                        Message = "Module de gestion du stockage non trouvé"
                        ActionType = "Storage"
                    }
                }
            }
            
            if (Get-Command "Remove-TempFiles" -ErrorAction SilentlyContinue) {
                # Nettoyer les fichiers temporaires
                $storageResult = Remove-TempFiles -ProgressBar $ProgressBar
                
                # Mettre à jour le résultat
                $results.Storage = @{
                    Success = $storageResult.Success
                    Message = $storageResult.Message
                    FilesRemoved = $storageResult.FilesRemoved
                    ActionType = "Storage"
                }
                
                # Mettre à jour la barre de progression
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Nettoyage terminé" -PercentComplete 30
                }
            }
        }
        
        # 2. Réinitialisation de l'adresse MAC (si non désactivée)
        if (-not $SkipMacReset) {
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Réinitialisation de l'adresse MAC..." -PercentComplete 40
            }
            
            Write-Log "Étape 2: Réinitialisation de l'adresse MAC" -Level "INFO"
            
            # Vérifier si les fonctions nécessaires existent
            if (-not (Get-Command "Get-NetworkAdapters" -ErrorAction SilentlyContinue) -or 
                -not (Get-Command "Set-MacAddress" -ErrorAction SilentlyContinue)) {
                Write-Log "Les fonctions de gestion des adresses MAC ne sont pas définies" -Level "ERROR"
                Write-ConsoleLog "❌ Les fonctions de gestion des adresses MAC ne sont pas définies" -Color Red
                
                # Essayer de charger les modules nécessaires
                # Utiliser plusieurs méthodes pour déterminer le chemin du script
                $scriptPath = $null
                
                # Méthode 1: Utiliser Split-Path sur MyInvocation
                $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
                
                # Méthode 2: Utiliser PSScriptRoot si disponible
                if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                    $scriptPath = $PSScriptRoot
                }
                
                # Méthode 3: Utiliser Get-ScriptPath si disponible
                if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                    if (Get-Command "Get-ScriptPath" -ErrorAction SilentlyContinue) {
                        $scriptPath = Get-ScriptPath
                    }
                }
                
                # Méthode 4: Utiliser le répertoire courant
                if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                    $scriptPath = (Get-Location).Path
                }
                
                Write-Log "Tentative de chargement des modules depuis: $scriptPath" -Level "INFO"
                
                $networkAdapterPath = Join-Path -Path $scriptPath -ChildPath "Step5_NetworkAdapter.ps1"
                
                $networkAdapterLoaded = $false
                
                if (Test-Path $networkAdapterPath) {
                    Write-Log "Tentative de chargement du module Step5_NetworkAdapter.ps1" -Level "INFO"
                    . $networkAdapterPath
                    if ((Get-Command "Get-NetworkAdapters" -ErrorAction SilentlyContinue) -and 
                        (Get-Command "Set-MacAddress" -ErrorAction SilentlyContinue)) {
                        $networkAdapterLoaded = $true
                    }
                } else {
                    Write-Log "Module Step5_NetworkAdapter.ps1 non trouvé à: $networkAdapterPath" -Level "ERROR"
                }
                
                # Vérifier à nouveau si les fonctions existent
                if (-not $networkAdapterLoaded) {
                    $results.Mac = @{
                        Success = $false
                        Message = "Les fonctions de gestion des adresses MAC ne sont pas disponibles. Modules trouvés: " + 
                                 "NetworkAdapter: " + $networkAdapterLoaded
                        ActionType = "Mac"
                    }
                }
            }
            
            # Si les fonctions sont disponibles, procéder à la réinitialisation de l'adresse MAC
            if ((Get-Command "Get-NetworkAdapters" -ErrorAction SilentlyContinue) -and 
                (Get-Command "Set-MacAddress" -ErrorAction SilentlyContinue)) {
                
                # Obtenir les adaptateurs réseau
                $adapters = Get-NetworkAdapters
                
                if ($adapters.Count -eq 0) {
                    # Aucune carte réseau trouvée
                    $results.Mac = @{
                        Success = $false
                        Message = "Aucune carte réseau n'a été trouvée sur la machine."
                        ActionType = "Mac"
                    }
                } else {
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Préparation de la modification..." -PercentComplete 40
                    }
                    
                    # Vérifier que les cartes réseau sont valides
                    $adapter = $adapters[0]  # Utiliser la première carte réseau
                    
                    # Récupérer l'adresse MAC actuelle
                    $currentMac = $adapter.MacAddress
                    
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Génération d'une nouvelle adresse MAC..." -PercentComplete 60
                    }
                    
                    # Générer une nouvelle adresse MAC
                    $newMac = New-MacAddress
                    
                    # Vérifier que le résultat est une chaîne de caractères valide
                    if ($null -eq $newMac) {
                        Write-Log "Erreur: New-MacAddress a retourné une valeur nulle" -Level "ERROR"
                        Write-ConsoleLog "❌ Erreur lors de la génération de l'adresse MAC" -Color Red
                        $results.Mac = @{
                            Success = $false
                            Message = "Erreur lors de la génération de l'adresse MAC"
                            ActionType = "Mac"
                        }
                    } else {
                        # S'assurer que l'adresse MAC est bien une chaîne de caractères
                        if ($newMac -isnot [string]) {
                            Write-Log "Conversion de l'adresse MAC en chaîne de caractères (Type actuel: $($newMac.GetType().FullName))" -Level "WARNING"
                            $newMac = $newMac.ToString()
                        }
                        
                        # Mettre à jour la barre de progression si elle est fournie
                        if ($ProgressBar) {
                            Update-ProgressBar -ProgressBar $ProgressBar -Status "Application de la nouvelle adresse MAC..." -PercentComplete 80
                        }
                        
                        # Définir la nouvelle adresse MAC
                        $result = Set-MacAddress -NetworkAdapter $adapter -MacAddress $newMac
                        
                        # Mettre à jour le résultat
                        $results.Mac = @{
                            Success = $result.Success
                            Message = if ($result.Success) { "Adresse MAC modifiée avec succès: $currentMac -> $newMac" } else { $result.Message }
                            OldMac = $currentMac
                            NewMac = $newMac
                            ActionType = "Mac"
                        }
                        
                        # Mettre à jour la barre de progression si elle est fournie
                        if ($ProgressBar) {
                            Update-ProgressBar -ProgressBar $ProgressBar -Status "Adresse MAC modifiée" -PercentComplete 100
                        }
                    }
                }
            }
        }
        
        # 3. Réinitialisation du GUID machine (si non désactivée)
        if (-not $SkipGuidReset) {
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Réinitialisation du GUID machine..." -PercentComplete 60
            }
            
            Write-Log "Étape 3: Réinitialisation du GUID machine" -Level "INFO"
            
            # Essayer de charger le module Step7_MachineGuid.ps1
            # Utiliser plusieurs méthodes pour déterminer le chemin du script
            $scriptPath = $null
            
            # Méthode 1: Utiliser Split-Path sur MyInvocation
            $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
            
            # Méthode 2: Utiliser PSScriptRoot si disponible
            if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                $scriptPath = $PSScriptRoot
            }
            
            # Méthode 3: Utiliser Get-ScriptPath si disponible
            if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                if (Get-Command "Get-ScriptPath" -ErrorAction SilentlyContinue) {
                    $scriptPath = Get-ScriptPath
                }
            }
            
            # Méthode 4: Utiliser le répertoire courant
            if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                $scriptPath = (Get-Location).Path
            }
            
            Write-Log "Tentative de chargement des modules depuis: $scriptPath" -Level "INFO"
            $machineGuidPath = Join-Path -Path $scriptPath -ChildPath "Step7_MachineGuid.ps1"
            $machineGuidLoaded = $false
            
            if (Test-Path $machineGuidPath) {
                Write-Log "Tentative de chargement du module Step7_MachineGuid.ps1" -Level "INFO"
                . $machineGuidPath
                if (Get-Command "Reset-MachineGuid" -ErrorAction SilentlyContinue) {
                    $machineGuidLoaded = $true
                }
            } else {
                Write-Log "Module Step7_MachineGuid.ps1 non trouvé à: $machineGuidPath" -Level "ERROR"
            }
            
            # Vérifier à nouveau si la fonction existe
            if (-not $machineGuidLoaded) {
                return @{
                    Success = $false
                    Message = "La fonction de réinitialisation du GUID machine n'est pas disponible. Module trouvé: " + $machineGuidLoaded
                    ActionType = "Guid"
                }
            }
            
            # Réinitialiser le GUID machine
            $result = Reset-MachineGuid
            
            if (-not $result.Success) {
                $results.AllSuccessful = $false
                Write-Log "Échec de la réinitialisation du GUID machine: $($result.Message)" -Level "ERROR"
                Write-ConsoleLog "❌ Échec de la réinitialisation du GUID machine" -Color Red
            } else {
                Write-Log "Réinitialisation du GUID machine réussie" -Level "SUCCESS"
                Write-ConsoleLog "✅ GUID machine réinitialisé avec succès" -Color Green
            }
        } else {
            Write-Log "Étape 3: Réinitialisation du GUID machine (IGNORÉE)" -Level "INFO"
            $results.Guid = @{
                Success = $true
                Message = "Opération ignorée selon les paramètres"
            }
        }
        
        # Préparation du résumé des actions
        $summaryLines = @()
        
        # Ajouter le résultat de la suppression du fichier de stockage
        if ($SkipStorageRemoval) {
            $summaryLines += "⏩ Fichier de stockage: Opération ignorée"
        } else {
            if ($results.Storage.Success) {
                $summaryLines += "✅ Fichier de stockage: $($results.Storage.Message)"
            } else {
                $summaryLines += "❌ Fichier de stockage: $($results.Storage.Message)"
            }
        }
        
        # Ajouter le résultat de la réinitialisation de l'adresse MAC
        if ($SkipMacReset) {
            $summaryLines += "⏩ Adresse MAC: Opération ignorée"
        } else {
            if ($results.Mac.Success) {
                $macDetails = if ($results.Mac.OldMac -and $results.Mac.NewMac) {
                    "Changée de $($results.Mac.OldMac) à $($results.Mac.NewMac)"
                } else {
                    $results.Mac.Message
                }
                $summaryLines += "✅ Adresse MAC: $macDetails"
            } else {
                $summaryLines += "❌ Adresse MAC: $($results.Mac.Message)"
            }
        }
        
        # Ajouter le résultat de la réinitialisation du GUID machine
        if ($SkipGuidReset) {
            $summaryLines += "⏩ GUID machine: Opération ignorée"
        } else {
            if ($results.Guid.Success) {
                $guidDetails = if ($results.Guid.OldValue -and $results.Guid.NewValue) {
                    "Changé de $($results.Guid.OldValue) à $($results.Guid.NewValue)"
                } else {
                    $results.Guid.Message
                }
                $summaryLines += "✅ GUID machine: $guidDetails"
            } else {
                $summaryLines += "❌ GUID machine: $($results.Guid.Message)"
            }
        }
        
        # Compiler le résumé final
        $summary = $summaryLines -join "`n"
        $results.Summary = $summary
        
        # Déterminer le message global en fonction des résultats
        if ($results.AllSuccessful) {
            $finalMessage = "Toutes les actions ont été exécutées avec succès"
            Write-Log $finalMessage -Level "SUCCESS"
            Write-ConsoleLog "✅ $finalMessage" -Color Green
        } else {
            $failedActions = @()
            if (-not $SkipStorageRemoval -and -not $results.Storage.Success) { $failedActions += "suppression de fichier" }
            if (-not $SkipMacReset -and -not $results.Mac.Success) { $failedActions += "réinitialisation MAC" }
            if (-not $SkipGuidReset -and -not $results.Guid.Success) { $failedActions += "réinitialisation GUID" }
            
            $finalMessage = "Certaines actions ont échoué: $($failedActions -join ', ')"
            Write-Log $finalMessage -Level "WARNING"
            Write-ConsoleLog "⚠️ $finalMessage" -Color Yellow
        }
        
        # Mettre à jour la barre de progression finale
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status $finalMessage -PercentComplete 100
        }
        
        return @{
            Success = $results.AllSuccessful
            Message = $finalMessage
            Results = $results
        }
    }
    catch {
        $errorMessage = "Erreur lors de l'exécution des actions: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        return @{
            Success = $false
            Message = $errorMessage
            Storage = $results.Storage
            Mac = $results.Mac
            Guid = $results.Guid
            Summary = "Erreur critique lors de l'exécution des actions"
            AllSuccessful = $false
        }
    }
}

# Exécuter une action spécifique
function Invoke-SpecificAction {
    param (
        [Parameter(Mandatory=$true)]
        [ValidateSet("Storage", "Mac", "Guid")]
        [string]$ActionType,
        
        [Parameter(Mandatory=$false)]
        [PSObject]$ProgressBar = $null
    )
    
    try {
        Write-Log "Lancement de l'action spécifique: ${ActionType}" -Level "INFO"
        Write-ConsoleLog "🔍 Exécution de l'action ${ActionType}..." -Color Cyan
        
        # Vérifier que les modules nécessaires sont chargés
        $modulesLoaded = $true
        
        # Vérifier si la fonction Update-ProgressBar existe
        if ($ProgressBar -and -not (Get-Command "Update-ProgressBar" -ErrorAction SilentlyContinue)) {
            Write-Log "La fonction Update-ProgressBar n'est pas définie" -Level "ERROR"
            Write-ConsoleLog "❌ La fonction Update-ProgressBar n'est pas définie" -Color Red
            
            # Essayer de charger le module Step10_ProgressBar.ps1
            $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
            $progressBarPath = Join-Path -Path $scriptPath -ChildPath "Step10_ProgressBar.ps1"
            
            if (Test-Path $progressBarPath) {
                Write-Log "Tentative de chargement du module Step10_ProgressBar.ps1" -Level "INFO"
                . $progressBarPath
            }
            
            # Vérifier à nouveau si la fonction existe
            if (-not (Get-Command "Update-ProgressBar" -ErrorAction SilentlyContinue)) {
                $modulesLoaded = $false
                Write-Log "Impossible de charger le module de gestion des barres de progression" -Level "ERROR"
            }
        }
        
        # Si une barre de progression est fournie, l'initialiser
        if ($ProgressBar -and $modulesLoaded) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Initialisation..." -PercentComplete 0
        }
        
        # Exécuter l'action spécifique
        $result = switch ($ActionType) {
            "Storage" {
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar -and $modulesLoaded) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Recherche du fichier de stockage..." -PercentComplete 30
                }
                
                # Vérifier si DeleteStorageFile existe
                if (-not (Get-Command "DeleteStorageFile" -ErrorAction SilentlyContinue)) {
                    Write-ConsoleLog "❌ La fonction DeleteStorageFile n'est pas définie" -Color Red
                    
                    # Essayer de charger le module Step4_Storage.ps1
                    $scriptPath = if (Get-Command "Get-ScriptPath" -ErrorAction SilentlyContinue) {
                        Get-ScriptPath
                    } else {
                        $PSScriptRoot
                    }
                    
                    Write-Log "Tentative de chargement du module Step4_Storage.ps1 depuis: $scriptPath" -Level "INFO"
                    $storagePath = Join-Path -Path $scriptPath -ChildPath "Step4_Storage.ps1"
                    
                    if (Test-Path $storagePath) {
                        Write-Log "Tentative de chargement du module Step4_Storage.ps1" -Level "INFO"
                        . $storagePath
                        
                        # Vérifier à nouveau si la fonction existe
                        if (-not (Get-Command "DeleteStorageFile" -ErrorAction SilentlyContinue)) {
                            Write-Log "La fonction DeleteStorageFile n'est toujours pas disponible après chargement du module" -Level "ERROR"
                            return @{
                                Success = $false
                                Message = "La fonction de suppression du fichier de stockage n'est pas disponible"
                                ActionType = $ActionType
                            }
                        }
                    } else {
                        Write-Log "Module Step4_Storage.ps1 non trouvé à: $storagePath" -Level "ERROR"
                        return @{
                            Success = $false
                            Message = "Le module de gestion du stockage n'est pas disponible"
                            ActionType = $ActionType
                        }
                    }
                }
                
                # Utiliser DeleteStorageFile
                $result = DeleteStorageFile
                
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar -and $modulesLoaded) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status $(if ($result.Success) { "Suppression réussie" } else { "Échec de la suppression" }) -PercentComplete 100
                }
                
                $result
            }
            "Mac" {
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Recherche des adaptateurs réseau..." -PercentComplete 20
                }
                
                # Vérifier si les fonctions nécessaires existent
                if (-not (Get-Command "Get-NetworkAdapters" -ErrorAction SilentlyContinue) -or 
                    -not (Get-Command "Set-MacAddress" -ErrorAction SilentlyContinue)) {
                    Write-Log "Les fonctions de gestion des adresses MAC ne sont pas définies" -Level "ERROR"
                    Write-ConsoleLog "❌ Les fonctions de gestion des adresses MAC ne sont pas définies" -Color Red
                    
                    # Essayer de charger les modules nécessaires
                    # Utiliser plusieurs méthodes pour déterminer le chemin du script
                    $scriptPath = $null
                    
                    # Méthode 1: Utiliser Split-Path sur MyInvocation
                    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
                    
                    # Méthode 2: Utiliser PSScriptRoot si disponible
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        $scriptPath = $PSScriptRoot
                    }
                    
                    # Méthode 3: Utiliser Get-ScriptPath si disponible
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        if (Get-Command "Get-ScriptPath" -ErrorAction SilentlyContinue) {
                            $scriptPath = Get-ScriptPath
                        }
                    }
                    
                    # Méthode 4: Utiliser le répertoire courant
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        $scriptPath = (Get-Location).Path
                    }
                    
                    Write-Log "Tentative de chargement des modules depuis: $scriptPath" -Level "INFO"
                    
                    $networkAdapterPath = Join-Path -Path $scriptPath -ChildPath "Step5_NetworkAdapter.ps1"
                    
                    $networkAdapterLoaded = $false
                    
                    if (Test-Path $networkAdapterPath) {
                        Write-Log "Tentative de chargement du module Step5_NetworkAdapter.ps1" -Level "INFO"
                        . $networkAdapterPath
                        if ((Get-Command "Get-NetworkAdapters" -ErrorAction SilentlyContinue) -and 
                            (Get-Command "Set-MacAddress" -ErrorAction SilentlyContinue)) {
                            $networkAdapterLoaded = $true
                        }
                    } else {
                        Write-Log "Module Step5_NetworkAdapter.ps1 non trouvé à: $networkAdapterPath" -Level "ERROR"
                    }
                    
                    # Vérifier à nouveau si les fonctions existent
                    if (-not $networkAdapterLoaded) {
                        return @{
                            Success = $false
                            Message = "Les fonctions de gestion des adresses MAC ne sont pas disponibles. Modules trouvés: " + 
                                     "NetworkAdapter: " + $networkAdapterLoaded
                            ActionType = $ActionType
                        }
                    }
                }
                
                # Obtenir les adaptateurs réseau
                $adapters = Get-NetworkAdapters
                
                if ($adapters.Count -eq 0) {
                    # Aucune carte réseau trouvée
                    @{
                        Success = $false
                        Message = "Aucune carte réseau n'a été trouvée sur la machine."
                        ActionType = $ActionType
                    }
                } else {
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Préparation de la modification..." -PercentComplete 40
                    }
                    
                    # Vérifier que les cartes réseau sont valides
                    $adapter = $adapters[0]  # Utiliser la première carte réseau
                    
                    # Récupérer l'adresse MAC actuelle
                    $currentMac = $adapter.MacAddress
                    
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Génération d'une nouvelle adresse MAC..." -PercentComplete 60
                    }
                    
                    # Générer une nouvelle adresse MAC
                    $newMac = New-MacAddress
                    
                    # Vérifier que le résultat est une chaîne de caractères valide
                    if ($null -eq $newMac) {
                        Write-Log "Erreur: New-MacAddress a retourné une valeur nulle" -Level "ERROR"
                        Write-ConsoleLog "❌ Erreur lors de la génération de l'adresse MAC" -Color Red
                        return @{
                            Success = $false
                            Message = "Erreur lors de la génération de l'adresse MAC"
                            ActionType = $ActionType
                        }
                    }
                    
                    # S'assurer que l'adresse MAC est bien une chaîne de caractères
                    if ($newMac -isnot [string]) {
                        Write-Log "Conversion de l'adresse MAC en chaîne de caractères (Type actuel: $($newMac.GetType().FullName))" -Level "WARNING"
                        $newMac = $newMac.ToString()
                    }
                    
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Application de la nouvelle adresse MAC..." -PercentComplete 80
                    }
                    
                    # Définir la nouvelle adresse MAC
                    $result = Set-MacAddress -NetworkAdapter $adapter -MacAddress $newMac
                    
                    # Mettre à jour la barre de progression si elle est fournie
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status $(if ($result.Success) { "Modification réussie" } else { "Échec de la modification" }) -PercentComplete 100
                    }
                    
                    if ($result.Success) {
                        @{
                            Success = $true
                            Message = "Adresse MAC modifiée avec succès."
                            OldValue = $currentMac
                            NewValue = $newMac
                            ActionType = $ActionType
                        }
                    } else {
                        @{
                            Success = $false
                            Message = "Échec de la modification de l'adresse MAC: $($result.Message)"
                            ActionType = $ActionType
                        }
                    }
                }
            }
            "Guid" {
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status "Préparation de la réinitialisation du GUID..." -PercentComplete 20
                }
                
                # Vérifier si la fonction Reset-MachineGuid existe
                if (-not (Get-Command "Reset-MachineGuid" -ErrorAction SilentlyContinue)) {
                    Write-Log "La fonction Reset-MachineGuid n'est pas définie" -Level "ERROR"
                    Write-ConsoleLog "❌ La fonction Reset-MachineGuid n'est pas définie" -Color Red
                    
                    # Essayer de charger le module Step7_MachineGuid.ps1
                    $scriptPath = $null
                    
                    # Méthode 1: Utiliser Split-Path sur MyInvocation
                    $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
                    
                    # Méthode 2: Utiliser PSScriptRoot si disponible
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        $scriptPath = $PSScriptRoot
                    }
                    
                    # Méthode 3: Utiliser Get-ScriptPath si disponible
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        if (Get-Command "Get-ScriptPath" -ErrorAction SilentlyContinue) {
                            $scriptPath = Get-ScriptPath
                        }
                    }
                    
                    # Méthode 4: Utiliser le répertoire courant
                    if ([string]::IsNullOrEmpty($scriptPath) -or -not (Test-Path $scriptPath)) {
                        $scriptPath = (Get-Location).Path
                    }
                    
                    Write-Log "Tentative de chargement des modules depuis: $scriptPath" -Level "INFO"
                    $machineGuidPath = Join-Path -Path $scriptPath -ChildPath "Step7_MachineGuid.ps1"
                    $machineGuidLoaded = $false
                    
                    if (Test-Path $machineGuidPath) {
                        Write-Log "Tentative de chargement du module Step7_MachineGuid.ps1" -Level "INFO"
                        . $machineGuidPath
                        if (Get-Command "Reset-MachineGuid" -ErrorAction SilentlyContinue) {
                            $machineGuidLoaded = $true
                        }
                    } else {
                        Write-Log "Module Step7_MachineGuid.ps1 non trouvé à: $machineGuidPath" -Level "ERROR"
                    }
                    
                    # Vérifier à nouveau si la fonction existe
                    if (-not $machineGuidLoaded) {
                        return @{
                            Success = $false
                            Message = "La fonction de réinitialisation du GUID machine n'est pas disponible. Module trouvé: " + $machineGuidLoaded
                            ActionType = $ActionType
                        }
                    }
                }
                
                # Réinitialiser le GUID machine
                $result = Reset-MachineGuid
                
                # Mettre à jour la barre de progression si elle est fournie
                if ($ProgressBar) {
                    Update-ProgressBar -ProgressBar $ProgressBar -Status $(if ($result.Success) { "Réinitialisation réussie" } else { "Échec de la réinitialisation" }) -PercentComplete 100
                }
                
                $result
            }
            default {
                @{
                    Success = $false
                    Message = "Type d'action non reconnu: ${ActionType}"
                    ActionType = $ActionType
                }
            }
        }
        
        # Journaliser le résultat
        if ($result.Success) {
            Write-Log "Action ${ActionType} exécutée avec succès" -Level "SUCCESS"
            Write-ConsoleLog "✅ Action ${ActionType} exécutée avec succès" -Color Green
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar -and $modulesLoaded) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Action réussie: $($result.Message)" -PercentComplete 100
            }
        } else {
            Write-Log "Échec de l'action ${ActionType}: $($result.Message)" -Level "ERROR"
            Write-ConsoleLog "❌ Échec de l'action ${ActionType}" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar -and $modulesLoaded) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec: $($result.Message)" -PercentComplete 100
            }
        }
        
        return $result
    }
    catch {
        $errorMessage = "Erreur lors de l'exécution de l'action ${ActionType}: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar -and (Get-Command "Update-ProgressBar" -ErrorAction SilentlyContinue)) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur: $_" -PercentComplete 100
        }
        
        return @{
            Success = $false
            Message = $errorMessage
            ActionType = $ActionType
        }
    }
}

# Initialiser le gestionnaire d'actions
function Initialize-ActionExecutor {
    Write-ConsoleLog "🔍 Initialisation du module d'exécution des actions..." -Color Cyan
    
    try {
        # Vérifier que les modules requis sont initialisés
        $modulesToCheck = @{
            "Get-NetworkAdapters" = "Step5_NetworkAdapter.ps1"
            "Set-MacAddress" = "Step5_NetworkAdapter.ps1"
            "Reset-MachineGuid" = "Step7_MachineGuid.ps1"
            "DeleteStorageFile" = "Step4_Storage.ps1"
        }
        
        $missingFunctions = @()
        
        foreach ($function in $modulesToCheck.Keys) {
            if (-not (Get-Command $function -ErrorAction SilentlyContinue)) {
                $missingFunctions += $function
                $modulePath = $modulesToCheck[$function]
                
                Write-Log "Fonction $function non trouvée, tentative de chargement du module $modulePath" -Level "WARNING"
                
                # Essayer de charger le module
                $scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
                $fullModulePath = Join-Path -Path $scriptPath -ChildPath $modulePath
                
                if (Test-Path $fullModulePath) {
                    Write-Log "Chargement du module $modulePath" -Level "INFO"
                    . $fullModulePath
                    
                    # Vérifier si la fonction est maintenant disponible
                    if (Get-Command $function -ErrorAction SilentlyContinue) {
                        Write-Log "Fonction $function chargée avec succès" -Level "SUCCESS"
                    } else {
                        Write-Log "Impossible de charger la fonction $function depuis $modulePath" -Level "ERROR"
                    }
                } else {
                    Write-Log "Module $modulePath non trouvé à l'emplacement $fullModulePath" -Level "ERROR"
                }
            }
        }
        
        # Vérifier à nouveau les fonctions après les tentatives de chargement
        $stillMissingFunctions = @()
        foreach ($function in $modulesToCheck.Keys) {
            if (-not (Get-Command $function -ErrorAction SilentlyContinue)) {
                $stillMissingFunctions += $function
            }
        }
        
        if ($stillMissingFunctions.Count -gt 0) {
            $errorMessage = "Les fonctions suivantes ne sont pas disponibles: $($stillMissingFunctions -join ', ')"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            return $false
        }
        
        Write-Log "Module d'exécution des actions initialisé avec succès" -Level "SUCCESS"
        Write-ConsoleLog "✅ Module d'exécution des actions initialisé" -Color Green
        return $true
    }
    catch {
        $errorMessage = "Erreur lors de l'initialisation du module d'exécution des actions: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        return $false
    }
}

# Vérifie si tous les modules nécessaires à l'exécution des actions sont initialisés
function Test-ActionsModulesInitialized {
    # Implémentation de la vérification des modules nécessaires
    # Cette fonction doit être implémentée selon les besoins spécifiques de votre script
    return $true
} 