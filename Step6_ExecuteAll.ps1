# =================================================================
# Fichier     : Step6_ExecuteAll.ps1
# Role        : Centre commercial principal pour l'exécution de toutes les actions
# Magasins    : - Magasin des fonctions (copie des fonctions nécessaires)
#               - Magasin des exécutions (séquence d'actions)
# =================================================================

# ===== Magasin des fonctions importées =====

# ----- Fonctions MAC -----
function Get-NetworkAdapters {
    Write-Host "🏪 Accès au magasin des adaptateurs..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Recherche des adaptateurs actifs..." -ForegroundColor Gray
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object @{
            Name = 'Name'; Expression = { $_.Name }
        }, @{
            Name = 'MacAddress'; Expression = { $_.MacAddress }
        }, @{
            Name = 'Status'; Expression = { $_.Status }
        }, @{
            Name = 'InterfaceDescription'; Expression = { $_.InterfaceDescription }
        }

        if ($adapters) {
            Write-Host "  ✓ Adaptateurs trouvés: $($adapters.Count)" -ForegroundColor Green
            return $adapters
        } else {
            Write-Host "  ⚠️ Aucun adaptateur trouvé" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Host "  ❌ Error lors de la recherche: $_" -ForegroundColor Red
        Write-Error "Error lors de la récupération des adaptateurs: $_"
        return $null
    }
}

function New-MacAddress {
    Write-Host "🏪 Accès au magasin des adresses MAC..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🎲 Génération d'une nouvelle adresse..." -ForegroundColor Gray
        $firstByte = '{0:X2}' -f ((Get-Random -Minimum 0 -Maximum 255) -band 0xFE)
        $otherBytes = 2..6 | ForEach-Object {
            '{0:X2}' -f (Get-Random -Minimum 0 -Maximum 255)
        }
        $macAddress = "$firstByte-$($otherBytes -join '-')"
        Write-Host "  ✓ Adresse générée: $macAddress" -ForegroundColor Green
        return $macAddress
    }
    catch {
        Write-Host "  ❌ Error lors de la génération: $_" -ForegroundColor Red
        Write-Error "Error lors de la génération de l'adresse MAC: $_"
        return $null
    }
}

function Test-MacAddress {
    param ([string]$MacAddress)
    
    Write-Host "🏪 Accès au magasin de validation..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Vérification du format..." -ForegroundColor Gray
        $isValid = $MacAddress -match '^([0-9A-F]{2}-){5}([0-9A-F]{2})$'
        
        if ($isValid) {
            Write-Host "  ✓ Format valide" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Format invalide" -ForegroundColor Yellow
        }
        
        return $isValid
    }
    catch {
        Write-Host "  ❌ Error lors de la validation: $_" -ForegroundColor Red
        return $false
    }
}

function Set-MacAddress {
    param (
        [string]$AdapterName,
        [string]$MacAddress
    )
    
    Write-Host "🏪 Accès au magasin des modifications..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Recherche de l'adaptateur..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | Where-Object Name -eq $AdapterName
        if (-not $adapter) {
            throw "Adaptateur non trouvé: $AdapterName"
        }
        Write-Host "  ✓ Adaptateur trouvé" -ForegroundColor Green

        Write-Host "  🔍 Validation de l'adresse MAC..." -ForegroundColor Gray
        if (-not (Test-MacAddress $MacAddress)) {
            throw "Format d'adresse MAC invalide"
        }
        Write-Host "  ✓ Adresse MAC valide" -ForegroundColor Green

        Write-Host "  🔌 Désactivation de l'adaptateur..." -ForegroundColor Gray
        Disable-NetAdapter -Name $AdapterName -Confirm:$false
        Start-Sleep -Seconds 2
        Write-Host "  ✓ Adaptateur désactivé" -ForegroundColor Green

        Write-Host "  🔧 Modification du registre..." -ForegroundColor Gray
        
        $tempScript = @"
`$regPath = "HKLM:SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
`$success = `$false

Get-ChildItem -Path `$regPath | ForEach-Object {
    `$driverDesc = (Get-ItemProperty -Path `$_.PSPath).DriverDesc
    if (`$driverDesc -eq '$($adapter.InterfaceDescription)') {
        Set-ItemProperty -Path `$_.PSPath -Name "NetworkAddress" -Value '$($MacAddress.Replace("-", ""))' -Force
        `$success = `$true
        Write-Host "Modification du registre effectuée avec succès"
    }
}

if (-not `$success) {
    throw "Échec de la modification dans le registre"
}
"@

        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $tempScript | Out-File -FilePath $tempFile -Encoding UTF8

        $process = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru
        Remove-Item $tempFile -Force

        if ($process.ExitCode -ne 0) {
            throw "Échec de la modification du registre"
        }

        Write-Host "  ✓ Registre modifié" -ForegroundColor Green

        Write-Host "  🔌 Réactivation de l'adaptateur..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "  ✓ Adaptateur réactivé" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "  ❌ Error lors de la modification: $_" -ForegroundColor Red
        Write-Error "Error lors de la modification de l'adresse MAC: $_"
        try { 
            Enable-NetAdapter -Name $AdapterName -Confirm:$false 
            Write-Host "  ⚠️ Adaptateur réactivé après erreur" -ForegroundColor Yellow
        } catch { }
        return $false
    }
}

# ----- Fonctions Storage -----
function Get-CursorStoragePath {
    Write-Host "🏪 Accès au magasin des chemins..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Construction du chemin..." -ForegroundColor Gray
        $username = $env:USERNAME
        $storagePath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        
        Write-Host "  ✓ Chemin construit: $storagePath" -ForegroundColor Green
        return $storagePath
    }
    catch {
        Write-Host "  ❌ Error lors de la construction du chemin: $_" -ForegroundColor Red
        throw "Error lors de la construction du chemin: $_"
    }
}

function Remove-CursorStorage {
    Write-Host "🏪 Accès au magasin des suppressions..." -ForegroundColor Cyan
    
    try {
        $filePath = Get-CursorStoragePath
        Write-Host "  🔍 Recherche du fichier: $filePath" -ForegroundColor Gray
        
        if (Test-Path $filePath) {
            Write-Host "  🗑️ Suppression du fichier..." -ForegroundColor Yellow
            Remove-Item -Path $filePath -Force
            Write-Host "  ✓ Fichier supprimé avec succès" -ForegroundColor Green
            return @{
                Success = $true
                Message = "Fichier supprimé avec succès"
            }
        } else {
            Write-Host "  ⚠️ Fichier non trouvé" -ForegroundColor Yellow
            return @{
                Success = $false
                Message = "Le fichier n'existe pas"
            }
        }
    }
    catch {
        Write-Host "  ❌ Error lors de la suppression: $_" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error lors de la suppression: $_"
        }
    }
}

# ===== Magasin des exécutions =====
function Start-AllActions {
    Write-Host "`n🏪 Démarrage de toutes les actions..." -ForegroundColor Cyan
    $results = @{
        MAC = $false
        Storage = $false
        Browser = $false
    }
    
    try {
        # Étape 1 : Modification de l'adresse MAC
        Write-Host "`n=== Étape 1: Modification de l'adresse MAC ===" -ForegroundColor Yellow
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        if ($adapter) {
            $newMac = New-MacAddress
            if ($newMac) {
                $results.MAC = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                if ($results.MAC) {
                    Write-Host "  ⏳ Attente de la reconnexion réseau (10 secondes)..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 10
                }
            }
        }

        # Étape 2 : Suppression du fichier storage.json
        Write-Host "`n=== Étape 2: Suppression du fichier storage.json ===" -ForegroundColor Yellow
        $storageResult = Remove-CursorStorage
        $results.Storage = $storageResult.Success

        # Résumé
        Write-Host "`n=== Résumé des actions ===" -ForegroundColor Cyan
        Write-Host "Modification MAC: $(if($results.MAC){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.MAC){'Green'}else{'Red'})
        Write-Host "Suppression storage.json: $(if($results.Storage){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.Storage){'Green'}else{'Red'})

        return $results
    }
    catch {
        Write-Host "`n❌ Error lors de l'exécution des actions: $_" -ForegroundColor Red
        return $results
    }
} 





