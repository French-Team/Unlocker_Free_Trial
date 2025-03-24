# =================================================================
# Fichier     : Step7_MachineGuid.ps1
# Role        : Gestion du GUID machine
# Description : Gère la récupération, la génération et la modification du GUID de la machine
# =================================================================

# Récupérer le GUID actuel de la machine
function Get-CurrentMachineGuid {
    Write-ConsoleLog "🔍 Récupération du GUID machine actuel..." -Color Cyan
    
    try {
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        
        if (Test-Path $registryPath) {
            $currentGuid = Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop
            
            if ($currentGuid) {
                Write-Log "GUID machine actuel récupéré: $($currentGuid.MachineGuid)" -Level "INFO"
                Write-ConsoleLog "✅ GUID machine actuel: $($currentGuid.MachineGuid)" -Color Green
                return $currentGuid.MachineGuid
            } 
            else {
                Write-Log "Clé MachineGuid non trouvée dans le registre" -Level "WARNING"
                Write-ConsoleLog "⚠️ Clé MachineGuid non trouvée dans le registre" -Color Yellow
                return $null
            }
        } 
        else {
            Write-Log "Chemin de registre non trouvé: $registryPath" -Level "WARNING"
            Write-ConsoleLog "⚠️ Chemin de registre non trouvé: $registryPath" -Color Yellow
            return $null
        }
    }
    catch {
        Write-Log "Erreur lors de la récupération du GUID machine: $_" -Level "ERROR"
        Write-ConsoleLog "❌ Erreur lors de la récupération du GUID machine: $_" -Color Red
        return $null
    }
}

# Générer un nouveau GUID pour la machine
function New-MachineGuid {
    Write-ConsoleLog "🔍 Génération d'un nouveau GUID machine..." -Color Cyan
    
    try {
        # Ajouter un peu d'entropie supplémentaire avant de générer le GUID
        $randomBytes = New-Object byte[] 16
        $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
        $rng.GetBytes($randomBytes)
        
        # Générer un GUID basé sur cette entropie supplémentaire
        $guid = New-Object System.Guid @(,$randomBytes)
        $newGuid = $guid.ToString()
        
        # Alternative: générer un GUID standard si la méthode ci-dessus échoue
        if ([string]::IsNullOrEmpty($newGuid)) {
            $newGuid = [System.Guid]::NewGuid().ToString()
        }
        
        Write-Log "Nouveau GUID machine généré: $newGuid" -Level "INFO"
        Write-ConsoleLog "✅ Nouveau GUID machine généré: $newGuid" -Color Green
        return $newGuid
    }
    catch {
        # En cas d'erreur, revenir à la méthode standard
        try {
            $newGuid = [System.Guid]::NewGuid().ToString()
            Write-Log "Nouveau GUID machine généré avec méthode alternative: $newGuid" -Level "INFO"
            Write-ConsoleLog "✅ Nouveau GUID machine généré avec méthode alternative: $newGuid" -Color Green
            return $newGuid
        }
        catch {
            Write-Log "Erreur lors de la génération d'un nouveau GUID machine: $_" -Level "ERROR"
            Write-ConsoleLog "❌ Erreur lors de la génération d'un nouveau GUID machine: $_" -Color Red
            return $null
        }
    }
}

# Modifier le GUID de la machine dans le registre
function Set-MachineGuid {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NewGuid,
        
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Modification du GUID machine..." -Color Cyan
    
    try {
        # Valider le format du GUID
        if (-not ($NewGuid -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')) {
            $errorMessage = "Format de GUID invalide: $NewGuid"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        Write-Log "Format de GUID valide: $NewGuid" -Level "DEBUG"
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Récupération du GUID actuel..." -PercentComplete 10
        }
        
        # Obtenir l'ancienne valeur avant modification
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        $oldGuid = $null
        
        try {
            $oldGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
            Write-Log "GUID machine actuel: $oldGuid" -Level "INFO"
        }
        catch {
            Write-Log "Impossible de lire la valeur actuelle du GUID machine: $_" -Level "WARNING"
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Sauvegarde du registre..." -PercentComplete 20
        }
        
        # Créer un répertoire de sauvegarde
        $backupDir = Join-Path -Path $env:USERPROFILE -ChildPath "MachineGuid_Backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        $backupFile = Join-Path -Path $backupDir -ChildPath "MachineGuid_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
        Write-Log "Création d'une sauvegarde du registre: $backupFile" -Level "INFO"
        
        # Sauvegarder la clé de registre
        try {
            $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography"
            $exportCommand = "reg.exe export `"$regPath`" `"$backupFile`" /y"
            $backupResult = Start-Process -FilePath "powershell" -ArgumentList "-Command", $exportCommand -NoNewWindow -Wait -PassThru
            
            if ($backupResult.ExitCode -eq 0 -and (Test-Path $backupFile)) {
                Write-Log "Sauvegarde du registre créée avec succès: $backupFile" -Level "SUCCESS"
            } else {
                Write-Log "Échec de la sauvegarde du registre (code $($backupResult.ExitCode))" -Level "WARNING"
            }
        }
        catch {
            Write-Log "Erreur lors de la sauvegarde du registre: $_" -Level "WARNING"
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Modification du registre..." -PercentComplete 40
        }
        
        # Créer un script temporaire pour modifier le registre avec privilèges élevés
        $tempScript = @"
# Script d'élévation pour modifier le MachineGuid
try {
    # Vérifier si on peut accéder à la clé
    `$regPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
    if (-not (Test-Path `$regPath)) {
        throw "Chemin de registre non trouvé: `$regPath"
    }
    
    # Vérifier si la propriété existe
    `$currentProps = Get-ItemProperty -Path `$regPath -ErrorAction Stop
    if (-not (`$currentProps.PSObject.Properties.Name -contains "MachineGuid")) {
        throw "La propriété MachineGuid n'existe pas"
    }
    
    # Afficher les valeurs
    Write-Host "Ancienne valeur: `$(`$currentProps.MachineGuid)"
    Write-Host "Nouvelle valeur à appliquer: $NewGuid"
    
    # Modifier la valeur
    Set-ItemProperty -Path `$regPath -Name "MachineGuid" -Value "$NewGuid" -Type String -Force
    
    # Vérifier que la modification a été appliquée
    `$newProps = Get-ItemProperty -Path `$regPath -ErrorAction Stop
    if (`$newProps.MachineGuid -eq "$NewGuid") {
        Write-Host "RESULT:SUCCESS:Modification réussie: Nouvelle valeur = `$(`$newProps.MachineGuid)"
        exit 0
    } else {
        Write-Host "RESULT:FAILURE:Échec de vérification: Valeur attendue = $NewGuid, Valeur actuelle = `$(`$newProps.MachineGuid)"
        exit 1
    }
}
catch {
    Write-Host "RESULT:ERROR:Erreur lors de la modification: `$_"
    exit 2
}
"@

        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $tempScript | Out-File -FilePath $tempFile -Encoding ASCII
        
        Write-Log "Script temporaire créé: $tempFile" -Level "DEBUG"
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Exécution du script de modification..." -PercentComplete 60
        }
        
        # Exécuter le script avec élévation de privilèges
        Write-ConsoleLog "⏳ Exécution du script de modification du registre..." -Color Yellow
        $process = Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru -WindowStyle Hidden
        
        # Nettoyer le fichier temporaire
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Vérification des modifications..." -PercentComplete 80
        }
        
        if ($process.ExitCode -ne 0) {
            $errorMessage = "Échec de la modification du registre (code $($process.ExitCode))"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Vérification après modification
        Start-Sleep -Seconds 2  # Attendre que les modifications du registre soient prises en compte
        $verifyGuid = $null
        
        try {
            $verifyGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
            
            if ($verifyGuid -eq $NewGuid) {
                Write-Log "Modification du GUID machine vérifiée avec succès: $verifyGuid" -Level "SUCCESS"
                Write-ConsoleLog "✅ GUID machine modifié avec succès" -Color Green
            } else {
                Write-Log "La valeur modifiée ($verifyGuid) ne correspond pas à la nouvelle valeur attendue ($NewGuid)" -Level "WARNING"
                Write-ConsoleLog "⚠️ La valeur modifiée ne correspond pas à celle attendue" -Color Yellow
            }
        }
        catch {
            Write-Log "Impossible de vérifier la nouvelle valeur: $_" -Level "WARNING"
            Write-ConsoleLog "⚠️ Impossible de vérifier la nouvelle valeur" -Color Yellow
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Terminé" -PercentComplete 100
        }
        
        return @{
            Success = $true
            OldValue = $oldGuid
            NewValue = $verifyGuid
            BackupFile = $backupFile
            Message = "GUID machine modifié avec succès"
        }
    }
    catch {
        $errorMessage = "Erreur lors de la modification du GUID machine: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Tenter de restaurer en cas d'erreur si une sauvegarde existe
        if ($backupFile -and (Test-Path $backupFile)) {
            Write-Log "Tentative de restauration à partir de la sauvegarde: $backupFile" -Level "WARNING"
            Write-ConsoleLog "⏳ Tentative de restauration..." -Color Yellow
            
            try {
                $restoreCommand = "reg.exe import `"$backupFile`""
                $restoreResult = Start-Process -FilePath "powershell" -ArgumentList "-Command", $restoreCommand -Verb RunAs -Wait -PassThru
                
                if ($restoreResult.ExitCode -eq 0) {
                    Write-Log "Restauration de la sauvegarde réussie" -Level "SUCCESS"
                    Write-ConsoleLog "✅ Restauration réussie" -Color Green
                } else {
                    Write-Log "Échec de la restauration automatique (code $($restoreResult.ExitCode))" -Level "ERROR"
                    Write-ConsoleLog "❌ Échec de la restauration automatique" -Color Red
                }
            }
            catch {
                Write-Log "Erreur lors de la restauration: $_" -Level "ERROR"
                Write-ConsoleLog "❌ Erreur lors de la restauration" -Color Red
            }
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
        }
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
}

# Réinitialiser le GUID de la machine (génération et application)
function Reset-MachineGuid {
    param (
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Réinitialisation du GUID machine..." -Color Cyan
    
    try {
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Récupération du GUID actuel..." -PercentComplete 10
        }
        
        # Lecture de la valeur actuelle
        $currentGuid = Get-CurrentMachineGuid
        if (-not $currentGuid) {
            $errorMessage = "Impossible de lire la valeur actuelle du GUID machine"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        Write-Log "GUID machine actuel: $currentGuid" -Level "INFO"
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Génération d'un nouveau GUID..." -PercentComplete 20
        }
        
        # Génération d'un nouveau GUID qui doit être différent de l'actuel
        $newGuid = $currentGuid
        $maxAttempts = 10  # Augmenter le nombre de tentatives
        $attempts = 0
        
        while ($newGuid -eq $currentGuid -and $attempts -lt $maxAttempts) {
            $newGuid = New-MachineGuid
            $attempts++
            
            if ($newGuid -eq $currentGuid) {
                Write-Log "Le nouveau GUID est identique à l'ancien, nouvelle tentative ($attempts/$maxAttempts)..." -Level "WARNING"
                Write-ConsoleLog "⚠️ Le nouveau GUID est identique à l'ancien, nouvelle tentative ($attempts/$maxAttempts)..." -Color Yellow
                # Attendre un peu avant de réessayer pour augmenter l'entropie
                Start-Sleep -Milliseconds 50
            }
        }
        
        if ($newGuid -eq $currentGuid) {
            # Si toujours égal après toutes les tentatives, forcer un GUID différent
            Write-Log "Impossible de générer naturellement un GUID différent, forçage d'un GUID différent..." -Level "WARNING"
            
            # Prendre l'ancien GUID et modifier un caractère pour forcer la différence
            $guidChars = $currentGuid.ToCharArray()
            $posToChange = Get-Random -Minimum 0 -Maximum $guidChars.Length
            $originalChar = $guidChars[$posToChange]
            
            # Trouver un caractère différent (hexadécimal)
            $hexChars = "0123456789abcdef".ToCharArray()
            $newChar = $originalChar
            while ($newChar -eq $originalChar) {
                $newChar = $hexChars[$(Get-Random -Minimum 0 -Maximum $hexChars.Length)]
            }
            
            $guidChars[$posToChange] = $newChar
            $newGuid = -join $guidChars
            
            Write-Log "GUID forcé manuellement à être différent: $newGuid" -Level "WARNING"
            Write-ConsoleLog "⚠️ GUID forcé manuellement à être différent" -Color Yellow
        }
        
        Write-Log "Nouveau GUID machine généré: $newGuid" -Level "INFO"
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Application du nouveau GUID..." -PercentComplete 30
        }
        
        # Application du nouveau GUID
        $result = Set-MachineGuid -NewGuid $newGuid -ProgressBar $ProgressBar
        
        if ($result.Success) {
            Write-ConsoleLog "✅ Réinitialisation du GUID machine réussie" -Color Green
            Write-Log "Réinitialisation du GUID machine réussie" -Level "SUCCESS"
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Réinitialisation réussie" -PercentComplete 100
            }
            
            return @{
                Success = $true
                OldValue = $currentGuid
                NewValue = $result.NewValue
                BackupFile = $result.BackupFile
                Message = "GUID machine réinitialisé avec succès"
            }
        } 
        else {
            Write-ConsoleLog "❌ Échec de la réinitialisation du GUID machine: $($result.Message)" -Color Red
            Write-Log "Échec de la réinitialisation du GUID machine: $($result.Message)" -Level "ERROR"
            
            # Mettre à jour la barre de progression si elle est fournie
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = "Échec de la réinitialisation du GUID machine: $($result.Message)"
            }
        }
    }
    catch {
        $errorMessage = "Erreur lors de la réinitialisation du GUID machine: $_"
        Write-Log $errorMessage -Level "ERROR"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
        }
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
}

# Initialiser le module de gestion du GUID machine
function Initialize-MachineGuidManager {
    Write-ConsoleLog "🔍 Initialisation du module de gestion du GUID machine..." -Color Cyan
    
    try {
        # Vérifier qu'on peut accéder au GUID de la machine
        $currentGuid = Get-CurrentMachineGuid
        
        if ($currentGuid) {
            Write-ConsoleLog "✅ Module de gestion du GUID machine initialisé avec succès" -Color Green
            Write-Log "Module de gestion du GUID machine initialisé avec succès. GUID actuel: $currentGuid" -Level "SUCCESS"
            return $true
        } 
        else {
            Write-ConsoleLog "⚠️ Module de gestion du GUID machine initialisé avec avertissement: Impossible de lire le GUID actuel" -Color Yellow
            Write-Log "Module de gestion du GUID machine initialisé avec avertissement: Impossible de lire le GUID actuel" -Level "WARNING"
            return $true # On retourne quand même true car ce n'est pas une erreur critique
        }
    }
    catch {
        Write-ConsoleLog "❌ Erreur lors de l'initialisation du module de gestion du GUID machine: $_" -Color Red
        Write-Log "Erreur lors de l'initialisation du module de gestion du GUID machine: $_" -Level "ERROR"
        return $false
    }
} 