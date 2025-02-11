# =================================================================
# Fichier     : Step4_MacAddress.ps1
# Role        : Galerie marchande des adresses MAC
# Magasins    : - Magasin des adaptateurs (recherche et listing)
#               - Magasin des adresses MAC (génération et validation)
#               - Magasin des modifications (changement d'adresse)
# =================================================================

# ===== Magasin des adaptateurs réseau =====
function Get-NetworkAdapters {
    Write-Host "🏪 Accès au magasin des adaptateurs..." -ForegroundColor Cyan
    
    try {
        # Rayon recherche
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

        # Rayon résultats
        if ($adapters) {
            Write-Host "  ✓ Adaptateurs trouvés: $($adapters.Count)" -ForegroundColor Green
            return $adapters
        } else {
            Write-Host "  ⚠️ Aucun adaptateur trouvé" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la recherche: $_" -ForegroundColor Red
        Write-Error "Error lors de la récupération des adaptateurs: $_"
        return $null
    }
}

# ===== Magasin des adresses MAC =====
function New-MacAddress {
    Write-Host "🏪 Accès au magasin des adresses MAC..." -ForegroundColor Cyan
    
    try {
        # Rayon génération
        Write-Host "  🎲 Génération d'une nouvelle adresse..." -ForegroundColor Gray
        
        # Premier octet (bit universel/local à 0)
        $firstByte = '{0:X2}' -f ((Get-Random -Minimum 0 -Maximum 255) -band 0xFE)
        
        # Génération des 5 autres octets
        $otherBytes = 2..6 | ForEach-Object {
            '{0:X2}' -f (Get-Random -Minimum 0 -Maximum 255)
        }
        
        # Assemblage final
        $macAddress = "$firstByte-$($otherBytes -join '-')"
        Write-Host "  ✓ Adresse générée: $macAddress" -ForegroundColor Green
        return $macAddress
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la génération: $_" -ForegroundColor Red
        Write-Error "Error lors de la génération de l'adresse MAC: $_"
        return $null
    }
}

function Test-MacAddress {
    param ([string]$MacAddress)
    
    Write-Host "🏪 Accès au magasin de validation..." -ForegroundColor Cyan
    
    try {
        # Rayon vérification
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
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la validation: $_" -ForegroundColor Red
        return $false
    }
}

# ===== Magasin des modifications =====
function Set-MacAddress {
    param (
        [string]$AdapterName,
        [string]$MacAddress
    )
    
    Write-Host "🏪 Accès au magasin des modifications..." -ForegroundColor Cyan
    
    try {
        # Rayon vérification adaptateur
        Write-Host "  🔍 Recherche de l'adaptateur..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | Where-Object Name -eq $AdapterName
        if (-not $adapter) {
            throw "Adaptateur non trouvé: $AdapterName"
        }
        Write-Host "  ✓ Adaptateur trouvé" -ForegroundColor Green

        # Rayon validation MAC
        Write-Host "  🔍 Validation de l'adresse MAC..." -ForegroundColor Gray
        if (-not (Test-MacAddress $MacAddress)) {
            throw "Format d'adresse MAC invalide"
        }
        Write-Host "  ✓ Adresse MAC valide" -ForegroundColor Green

        # Rayon désactivation
        Write-Host "  🔌 Désactivation de l'adaptateur..." -ForegroundColor Gray
        Disable-NetAdapter -Name $AdapterName -Confirm:$false
        Start-Sleep -Seconds 2
        Write-Host "  ✓ Adaptateur désactivé" -ForegroundColor Green

        # Rayon modification registre avec élévation de privilèges
        Write-Host "  🔧 Modification du registre..." -ForegroundColor Gray
        
        # Création du script temporaire pour la modification du registre
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

        # Exécution du script avec élévation de privilèges
        $process = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru
        Remove-Item $tempFile -Force

        if ($process.ExitCode -ne 0) {
            throw "Échec de la modification du registre"
        }

        Write-Host "  ✓ Registre modifié" -ForegroundColor Green

        # Rayon réactivation
        Write-Host "  🔌 Réactivation de l'adaptateur..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "  ✓ Adaptateur réactivé" -ForegroundColor Green

        return $true
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la modification: $_" -ForegroundColor Red
        Write-Error "Error lors de la modification de l'adresse MAC: $_"
        # Tentative de réactivation en cas d'erreur
        try { 
            Enable-NetAdapter -Name $AdapterName -Confirm:$false 
            Write-Host "  ⚠️ Adaptateur réactivé après erreur" -ForegroundColor Yellow
        } catch { }
        return $false
    }
} 





