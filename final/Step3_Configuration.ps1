# =================================================================
# Fichier     : Step3_Configuration.ps1
# Role        : Configuration globale de l'application
# Description : Gère les paramètres globaux de l'application
# =================================================================

# Fonction pour obtenir le chemin du script de manière fiable
function Get-ScriptPath {
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

# Configuration globale de l'application
$script:Config = @{
    # Informations de l'application
    AppName = "Unlocker Free Trial"
    Version = "1.0.0"
    
    # Paramètres techniques
    MaxRetries = 3
    RetryDelay = 2  # secondes
    
    # Chemins importants
    StoragePath = Join-Path -Path $env:APPDATA -ChildPath "Cursor\User\globalStorage\storage.json"
    ScriptPath = Get-ScriptPath  # Utiliser la fonction pour déterminer le chemin du script
    
    # Configuration de l'interface
    ProgressBarColor = "Blue"
    
    # Fonctionnalités
    EnableLogging = $true
    TestMode = $false
    
    # Configuration d'encodage
    DefaultEncoding = "UTF8"
    FallbackEncoding = "Windows-1252"
    DetectEncodingFromByteOrderMarks = $true
}

# Obtenir la configuration complète
function Get-AppConfig {
    return $script:Config
}

# Obtenir une valeur spécifique de la configuration
function Get-ConfigValue {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Key
    )
    
    if ($script:Config.ContainsKey($Key)) {
        return $script:Config[$Key]
    }
    else {
        Write-Log "Clé de configuration inconnue: $Key" -Level "WARNING"
        return $null
    }
}

# Mettre à jour un paramètre de configuration
function Update-ConfigValue {
    param (
        [Parameter(Mandatory=$true)]
        [string]$Key,
        
        [Parameter(Mandatory=$true)]
        $Value
    )
    
    if ($script:Config.ContainsKey($Key)) {
        $oldValue = $script:Config[$Key]
        $script:Config[$Key] = $Value
        Write-Log "Configuration mise à jour: $Key = $Value (ancienne valeur: $oldValue)" -Level "CONFIG"
        return $true
    }
    else {
        Write-Log "Tentative de mise à jour d'une clé de configuration inconnue: $Key" -Level "WARNING"
        return $false
    }
}

# Obtenir l'encodage à utiliser pour les opérations de fichier
function Get-FileEncoding {
    param (
        [Parameter(Mandatory=$false)]
        [string]$EncodingName = $null
    )
    
    try {
        # Si un nom d'encodage spécifique est fourni, l'utiliser
        if ($EncodingName) {
            switch ($EncodingName.ToLower()) {
                "utf8" { 
                    return [System.Text.UTF8Encoding]::new($true) 
                }
                "utf8nobom" { 
                    return [System.Text.UTF8Encoding]::new($false) 
                }
                "unicode" { 
                    return [System.Text.UnicodeEncoding]::new() 
                }
                "ascii" { 
                    return [System.Text.ASCIIEncoding]::new() 
                }
                "windows-1252" { 
                    return [System.Text.Encoding]::GetEncoding(1252) 
                }
                default {
                    Write-Log "Encodage non reconnu: $EncodingName, utilisation de l'encodage par défaut" -Level "WARNING"
                    return Get-FileEncoding -EncodingName $script:Config.DefaultEncoding
                }
            }
        }
        # Sinon, utiliser l'encodage par défaut défini dans la configuration
        else {
            return Get-FileEncoding -EncodingName $script:Config.DefaultEncoding
        }
    }
    catch {
        Write-Log "Erreur lors de la récupération de l'encodage: $_" -Level "ERROR"
        # En cas d'erreur, utiliser UTF8 par défaut
        return [System.Text.UTF8Encoding]::new($true)
    }
}

# Lire le contenu d'un fichier avec gestion de l'encodage
function Read-FileWithEncoding {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$false)]
        [string]$EncodingName = $null,
        
        [Parameter(Mandatory=$false)]
        [switch]$Raw = $false
    )
    
    try {
        # Vérifier que le fichier existe
        if (-not (Test-Path -Path $FilePath)) {
            Write-Log "Fichier introuvable: $FilePath" -Level "ERROR"
            return $null
        }
        
        # Obtenir l'encodage à utiliser
        $encoding = Get-FileEncoding -EncodingName $EncodingName
        
        # Lire le fichier avec l'encodage spécifié
        if ($Raw) {
            $content = [System.IO.File]::ReadAllText($FilePath, $encoding)
        } else {
            $content = [System.IO.File]::ReadAllLines($FilePath, $encoding)
        }
        
        Write-Log "Fichier lu avec succès: $FilePath (Encodage: $($encoding.WebName))" -Level "DEBUG"
        return $content
    }
    catch {
        Write-Log "Erreur lors de la lecture du fichier $FilePath : $_" -Level "ERROR"
        return $null
    }
}

# Écrire du contenu dans un fichier avec gestion de l'encodage
function Write-FileWithEncoding {
    param (
        [Parameter(Mandatory=$true)]
        [string]$FilePath,
        
        [Parameter(Mandatory=$true)]
        $Content,
        
        [Parameter(Mandatory=$false)]
        [string]$EncodingName = $null,
        
        [Parameter(Mandatory=$false)]
        [switch]$Append = $false
    )
    
    try {
        # Obtenir l'encodage à utiliser
        $encoding = Get-FileEncoding -EncodingName $EncodingName
        
        # Créer le répertoire parent si nécessaire
        $directory = [System.IO.Path]::GetDirectoryName($FilePath)
        if (-not [string]::IsNullOrEmpty($directory) -and -not (Test-Path -Path $directory)) {
            New-Item -Path $directory -ItemType Directory -Force | Out-Null
            Write-Log "Répertoire créé: $directory" -Level "DEBUG"
        }
        
        # Écrire le contenu avec l'encodage spécifié
        if ($Content -is [array]) {
            if ($Append) {
                [System.IO.File]::AppendAllLines($FilePath, $Content, $encoding)
            } else {
                [System.IO.File]::WriteAllLines($FilePath, $Content, $encoding)
            }
        } else {
            if ($Append) {
                [System.IO.File]::AppendAllText($FilePath, $Content, $encoding)
            } else {
                [System.IO.File]::WriteAllText($FilePath, $Content, $encoding)
            }
        }
        
        Write-Log "Fichier écrit avec succès: $FilePath (Encodage: $($encoding.WebName))" -Level "DEBUG"
        return $true
    }
    catch {
        Write-Log "Erreur lors de l'écriture du fichier $FilePath : $_" -Level "ERROR"
        return $false
    }
}

# Initialiser la configuration
function Initialize-Configuration {
    Write-ConsoleLog "🔍 Initialisation de la configuration..." -Color Cyan
    
    # Mettre à jour le chemin du script dans la configuration
    $script:Config.ScriptPath = Get-ScriptPath
    
    # Journaliser les informations de configuration
    Write-Log "Configuration initialisée - Version: $($script:Config.Version)" -Level "CONFIG"
    Write-Log "Chemin du script: $($script:Config.ScriptPath)" -Level "CONFIG"
    Write-Log "Chemin du fichier de stockage: $($script:Config.StoragePath)" -Level "CONFIG"
    Write-Log "Encodage par défaut: $($script:Config.DefaultEncoding)" -Level "CONFIG"
    
    Write-ConsoleLog "✅ Configuration initialisée" -Color Green
    return $true
} 