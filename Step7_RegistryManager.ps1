# =================================================================
# Fichier     : Step7_RegistryManager.ps1
# Role        : Boutique de gestion du registre Windows
# Magasins    : - Magasin des clés (lecture/écriture des clés de registre)
#               - Magasin des GUID (génération de nouveaux identifiants)
# =================================================================

# ===== Magasin des clés de registre =====
function Get-MachineGuid {
    Write-Host "🏪 Accès au magasin des identifiants machine..." -ForegroundColor Cyan
    
    try {
        # Rayon lecture de clé
        Write-Host "  🔍 Lecture de l'identifiant machine actuel..." -ForegroundColor Gray
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        
        if (Test-Path $registryPath) {
            $currentGuid = Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop
            if ($currentGuid) {
                Write-Host "  ✓ Identifiant machine trouvé: $($currentGuid.MachineGuid)" -ForegroundColor Green
                return $currentGuid.MachineGuid
            } else {
                Write-Host "  ⚠️ Clé MachineGuid non trouvée" -ForegroundColor Yellow
                return $null
            }
        } else {
            Write-Host "  ⚠️ Chemin de registre non trouvé: $registryPath" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Erreur lors de la lecture du registre: $_" -ForegroundColor Red
        throw "Erreur lors de la lecture du registre: $_"
    }
}

function New-MachineGuid {
    Write-Host "🏪 Accès au magasin des nouveaux identifiants..." -ForegroundColor Cyan
    
    try {
        # Rayon génération
        Write-Host "  🔧 Génération d'un nouvel identifiant machine..." -ForegroundColor Gray
        $newGuid = [System.Guid]::NewGuid().ToString()
        Write-Host "  ✓ Nouvel identifiant généré: $newGuid" -ForegroundColor Green
        return $newGuid
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Erreur lors de la génération du GUID: $_" -ForegroundColor Red
        throw "Erreur lors de la génération du GUID: $_"
    }
}

function Set-MachineGuid {
    param (
        [Parameter(Mandatory=$true)]
        [string]$NewGuid
    )
    
    Write-Host "🏪 Accès au magasin des modifications du registre..." -ForegroundColor Cyan
    
    try {
        # Rayon validation
        Write-Host "  🔍 Validation du nouveau GUID..." -ForegroundColor Gray
        if (-not ($NewGuid -match '^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$')) {
            throw "Format de GUID invalide: $NewGuid"
        }
        Write-Host "  ✓ Format de GUID valide" -ForegroundColor Green
        
        # Obtenir l'ancienne valeur avant modification
        $registryPath = "HKLM:\SOFTWARE\Microsoft\Cryptography"
        $oldGuid = $null
        
        try {
            $oldGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
            Write-Host "  📋 Valeur actuelle du MachineGuid: $oldGuid" -ForegroundColor Gray
        }
        catch {
            Write-Host "  ⚠️ Impossible de lire la valeur actuelle du MachineGuid: $_" -ForegroundColor Yellow
        }
        
        # Rayon sauvegarde
        $backupDir = "$env:USERPROFILE\MachineGuid_Backups"
        if (-not (Test-Path $backupDir)) {
            New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
        }
        
        $backupFile = "$backupDir\MachineGuid_$(Get-Date -Format 'yyyyMMdd_HHmmss').reg"
        Write-Host "  💾 Sauvegarde du registre en cours..." -ForegroundColor Gray
        
        # Utiliser une méthode plus fiable pour exporter la clé
        try {
            $regPath = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Cryptography"
            $exportCommand = "reg.exe export `"$regPath`" `"$backupFile`" /y"
            $backupResult = Start-Process -FilePath "powershell" -ArgumentList "-Command", $exportCommand -NoNewWindow -Wait -PassThru
            
            if ($backupResult.ExitCode -eq 0 -and (Test-Path $backupFile)) {
                Write-Host "  ✓ Sauvegarde créée: $backupFile" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️ Échec de la sauvegarde (code $($backupResult.ExitCode)), poursuite du processus..." -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  ⚠️ Erreur lors de la sauvegarde: $_" -ForegroundColor Yellow
        }
        
        # Rayon modification avec script temporaire pour privilèges élevés
        Write-Host "  🔧 Modification du registre en cours..." -ForegroundColor Gray
        
        $tempScript = @"
# Script d'élévation pour modifier le MachineGuid
Write-Host "Tentative de modification du MachineGuid..."
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
        Write-Host "Modification réussie: Nouvelle valeur = `$(`$newProps.MachineGuid)"
        exit 0
    } else {
        Write-Host "Échec de vérification: Valeur attendue = $NewGuid, Valeur actuelle = `$(`$newProps.MachineGuid)"
        exit 1
    }
}
catch {
    Write-Host "Erreur lors de la modification: `$_"
    exit 2
}
"@
        
        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $tempScript | Out-File -FilePath $tempFile -Encoding ASCII
        
        Write-Host "  📄 Exécution du script d'élévation pour modifier le registre..." -ForegroundColor Gray
        $process = Start-Process "powershell.exe" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru
        
        # Nettoyer le fichier temporaire
        if (Test-Path $tempFile) {
            Remove-Item $tempFile -Force
        }
        
        if ($process.ExitCode -ne 0) {
            throw "Échec de la modification du registre (code $($process.ExitCode))"
        }
        
        # Rayon vérification
        Start-Sleep -Seconds 2  # Attendre que les modifications du registre soient prises en compte
        $verifyGuid = $null
        
        try {
            $verifyGuid = (Get-ItemProperty -Path $registryPath -Name MachineGuid -ErrorAction Stop).MachineGuid
            Write-Host "  📋 Valeur après modification: $verifyGuid" -ForegroundColor Gray
            
            if ($verifyGuid -eq $NewGuid) {
                Write-Host "  ✓ Modification vérifiée avec succès" -ForegroundColor Green
            } else {
                Write-Host "  ⚠️ La valeur modifiée ($verifyGuid) ne correspond pas à la nouvelle valeur attendue ($NewGuid)" -ForegroundColor Yellow
            }
        }
        catch {
            Write-Host "  ⚠️ Impossible de vérifier la nouvelle valeur: $_" -ForegroundColor Yellow
        }
        
        Write-Host "  ✓ Opération terminée" -ForegroundColor Green
        return @{
            Success = $true
            OldValue = $oldGuid
            NewValue = $verifyGuid
            BackupFile = $backupFile
            Message = "MachineGuid modifié avec succès"
        }
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Erreur lors de la modification du registre: $_" -ForegroundColor Red
        
        # Rayon restauration en cas d'erreur
        if ($backupFile -and (Test-Path $backupFile)) {
            Write-Host "  🔄 Tentative de restauration..." -ForegroundColor Yellow
            try {
                $restoreCommand = "reg.exe import `"$backupFile`""
                $restoreResult = Start-Process -FilePath "powershell" -ArgumentList "-Command", $restoreCommand -Verb RunAs -Wait -PassThru
                
                if ($restoreResult.ExitCode -eq 0) {
                    Write-Host "  ✓ Restauration de la valeur d'origine réussie" -ForegroundColor Green
                } else {
                    Write-Host "  ❌ Échec de la restauration automatique (code $($restoreResult.ExitCode))" -ForegroundColor Red
                    Write-Host "  ℹ️ Pour restaurer manuellement, exécutez: reg import `"$backupFile`"" -ForegroundColor Cyan
                }
            }
            catch {
                Write-Host "  ❌ Erreur lors de la restauration: $_" -ForegroundColor Red
                Write-Host "  ℹ️ Pour restaurer manuellement, exécutez: reg import `"$backupFile`"" -ForegroundColor Cyan
            }
        }
        
        return @{
            Success = $false
            Message = "Erreur lors de la modification du registre: $_"
        }
    }
}

# ===== Magasin des opérations complètes =====
function Reset-MachineGuid {
    Write-Host "🏪 Accès au magasin de réinitialisation MachineGuid..." -ForegroundColor Cyan
    
    try {
        # Lecture de la valeur actuelle
        $currentGuid = Get-MachineGuid
        if (-not $currentGuid) {
            throw "Impossible de lire la valeur actuelle de MachineGuid"
        }
        Write-Host "  📋 MachineGuid actuel : $currentGuid" -ForegroundColor Gray
        
        # Génération d'un nouveau GUID qui doit être différent de l'actuel
        $newGuid = $currentGuid
        $maxAttempts = 5
        $attempts = 0
        
        while ($newGuid -eq $currentGuid -and $attempts -lt $maxAttempts) {
            $newGuid = New-MachineGuid
            $attempts++
            
            if ($newGuid -eq $currentGuid) {
                Write-Host "  ⚠️ Le nouveau GUID est identique à l'ancien, nouvelle tentative..." -ForegroundColor Yellow
            }
        }
        
        if ($newGuid -eq $currentGuid) {
            throw "Impossible de générer un GUID différent après $maxAttempts tentatives"
        }
        
        Write-Host "  📋 Nouveau MachineGuid généré : $newGuid" -ForegroundColor Green
        
        # Application du nouveau GUID
        $result = Set-MachineGuid -NewGuid $newGuid
        
        # Vérification supplémentaire après modification
        if ($result.Success) {
            # Relire la valeur du registre pour confirmation
            Start-Sleep -Seconds 1  # Attendre un peu pour que les changements de registre soient effectifs
            $verifyGuid = Get-MachineGuid
            
            if ($verifyGuid -eq $newGuid) {
                Write-Host "  ✅ Réinitialisation de MachineGuid réussie et vérifiée" -ForegroundColor Green
                Write-Host "      Ancien: $currentGuid" -ForegroundColor Gray
                Write-Host "      Nouveau: $verifyGuid" -ForegroundColor Green
                Write-Host "      Sauvegarde: $($result.BackupFile)" -ForegroundColor Gray
                
                # S'assurer que le résultat retourne les bonnes valeurs
                $result.OldValue = $currentGuid
                $result.NewValue = $verifyGuid
            } else {
                Write-Host "  ⚠️ La modification a été appliquée mais la vérification a échoué" -ForegroundColor Yellow
                Write-Host "      Valeur attendue: $newGuid" -ForegroundColor Gray
                Write-Host "      Valeur actuelle: $verifyGuid" -ForegroundColor Yellow
                
                # La modification a peut-être réussi partiellement, retourner les vraies valeurs
                $result.OldValue = $currentGuid
                $result.NewValue = $verifyGuid
                $result.Message = "Modification appliquée mais vérification incomplète"
            }
        } else {
            throw "Échec de la modification du registre: $($result.Message)"
        }
        
        return $result
    }
    catch {
        Write-Host "  ❌ Erreur lors de la réinitialisation: $_" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Erreur lors de la réinitialisation: $_"
        }
    }
} 