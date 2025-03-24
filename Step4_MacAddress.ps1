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
        # Récupérer uniquement les adaptateurs physiques
        $adapters = Get-NetAdapter | Where-Object { 
            $_.PhysicalMediaType -ne 'Unspecified' -and 
            $_.PhysicalMediaType -ne '' -and 
            -not $_.Virtual -and 
            $_.MediaConnectionState -eq 'Connected'
        }
        
        if (-not $adapters) {
            Write-Host "Aucun adaptateur réseau physique trouvé." -ForegroundColor Yellow
            return $null
        }
        
        # Enrichir les informations des adaptateurs
        $enrichedAdapters = $adapters | ForEach-Object {
            $driverInfo = Get-NetAdapterAdvancedProperty -Name $_.Name -ErrorAction SilentlyContinue
            $regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4d36e972-e325-11ce-bfc1-08002be10318}"
            $driverDesc = $_.InterfaceDescription
            $driverVersion = "N/A"
            
            # Rechercher dans toutes les sous-clés pour trouver l'adaptateur
            Get-ChildItem -Path $regPath -ErrorAction SilentlyContinue | ForEach-Object {
                $key = $_
                try {
                    $properties = Get-ItemProperty -Path $key.PSPath -ErrorAction SilentlyContinue
                    if ($properties.DriverDesc -eq $driverDesc) {
                        $driverVersion = $properties.DriverVersion
                    }
                } catch { }
            }
            
            [PSCustomObject]@{
                Name = $_.Name
                MacAddress = $_.MacAddress
                Status = $_.Status
                Speed = $_.LinkSpeed
                ProductName = $_.InterfaceDescription
                DriverVersion = $driverVersion
            }
        }
        
        Write-Host "Adaptateurs réseau trouvés :" -ForegroundColor Green
        foreach ($adapter in $enrichedAdapters) {
            Write-Host "     - $(Format-NetworkAdapter $adapter)" -ForegroundColor Green
        }
        
        return $enrichedAdapters
    }
    catch {
        Write-Host "Erreur lors de la récupération des adaptateurs : $_" -ForegroundColor Red
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

        # Nous ne désactivons plus l'adaptateur ici, car cela nécessite des privilèges administrateur
        # Cette opération sera gérée par le script d'élévation

        # Rayon modification registre avec élévation de privilèges
        Write-Host "  🔧 Modification du registre..." -ForegroundColor Gray
        
        # Version améliorée du script temporaire pour la modification du registre
        $tempScript = @"
# Définir les variables nécessaires
`$success = `$false
`$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
`$targetAdapter = "$($adapter.InterfaceDescription)"
`$newMacValue = "$($MacAddress.Replace("-", ""))"
`$adapterName = "$AdapterName"

# Journalisation
Write-Host "Recherche de l'adaptateur dans le registre : `$targetAdapter"
Write-Host "Nouvelle adresse MAC (sans tirets) : `$newMacValue"
Write-Host "Nom de l'adaptateur pour activation/désactivation : `$adapterName"

# Désactivation de l'adaptateur avec privilèges administrateur
Write-Host "Désactivation de l'adaptateur..."
try {
    Disable-NetAdapter -Name `$adapterName -Confirm:`$false
    Start-Sleep -Seconds 2
    Write-Host "Adaptateur désactivé avec succès"
} catch {
    Write-Host "Erreur lors de la désactivation de l'adaptateur : `$_"
    # Continuer malgré l'erreur, car la modification du registre peut toujours fonctionner
}

# Parcourir les sous-clés du registre
`$subKeys = Get-ChildItem -Path `$regPath | Where-Object { `$_.PSPath -notmatch "Properties" }
Write-Host "Nombre de sous-clés trouvées : `$(`$subKeys.Count)"

foreach (`$key in `$subKeys) {
    try {
        `$properties = Get-ItemProperty -Path `$key.PSPath -ErrorAction SilentlyContinue
        
        # Vérifier si la propriété DriverDesc existe et correspond
        if (`$properties.DriverDesc -ne `$null) {
            if (`$properties.DriverDesc -eq `$targetAdapter) {
                Write-Host "Adaptateur trouvé dans le registre : `$(`$key.PSPath)"
                
                # Modifier l'adresse MAC
                Set-ItemProperty -Path `$key.PSPath -Name "NetworkAddress" -Value `$newMacValue -Force
                Write-Host "Adresse MAC modifiée avec succès"
                `$success = `$true
                break
            }
        }
    }
    catch {
        Write-Host "Erreur lors de l'accès à une sous-clé : `$_"
    }
}

# Si l'adaptateur n'a pas été trouvé par description, essayer de le trouver par indice de composant
if (-not `$success) {
    Write-Host "Tentative de recherche par indice de composant..."
    foreach (`$key in `$subKeys) {
        try {
            `$properties = Get-ItemProperty -Path `$key.PSPath -ErrorAction SilentlyContinue
            if (`$properties.NetCfgInstanceId -ne `$null) {
                `$netAdapter = Get-NetAdapter | Where-Object { `$_.InterfaceGuid -eq `$properties.NetCfgInstanceId }
                if (`$netAdapter -and `$netAdapter.InterfaceDescription -eq `$targetAdapter) {
                    Write-Host "Adaptateur trouvé via NetCfgInstanceId dans : `$(`$key.PSPath)"
                    Set-ItemProperty -Path `$key.PSPath -Name "NetworkAddress" -Value `$newMacValue -Force
                    Write-Host "Adresse MAC modifiée avec succès"
                    `$success = `$true
                    break
                }
            }
        }
        catch {
            Write-Host "Erreur lors de la recherche par indice : `$_"
        }
    }
}

# Réactivation de l'adaptateur avec privilèges administrateur
Write-Host "Réactivation de l'adaptateur..."
try {
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name `$adapterName -Confirm:`$false
    Write-Host "Adaptateur réactivé avec succès"
} catch {
    Write-Host "Erreur lors de la réactivation de l'adaptateur : `$_"
}

if (-not `$success) {
    throw "Adaptateur non trouvé dans le registre. Vérifiez les permissions ou essayez avec un autre adaptateur."
}

exit `$success.ToString()
"@

        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        # Utiliser l'encodage ASCII pour éviter tous problèmes d'encodage
        $tempScript | Out-File -FilePath $tempFile -Encoding ASCII

        # Exécution du script avec élévation de privilèges et fenêtre cachée
        Write-Host "  📄 Exécution du script d'élévation : $tempFile" -ForegroundColor Gray
        $process = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru -WindowStyle Hidden
        
        # Journalisation du résultat
        Write-Host "  🔢 Code de sortie : $($process.ExitCode)" -ForegroundColor Gray
        
        # Nettoyage
        Remove-Item $tempFile -Force
        Write-Host "  🧹 Fichier temporaire supprimé : $tempFile" -ForegroundColor Gray

        if ($process.ExitCode -ne 0) {
            throw "Échec de la modification du registre (code $($process.ExitCode))"
        }

        Write-Host "  ✓ Registre modifié" -ForegroundColor Green
        Write-Host "  ✓ Adaptateur désactivé et réactivé" -ForegroundColor Green

        return $true
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la modification: $_" -ForegroundColor Red
        Write-Error "Error lors de la modification de l'adresse MAC: $_"
        # Nous ne tentons plus de réactiver l'adaptateur ici, car cette opération est désormais
        # gérée entièrement dans le script d'élévation
        return $false
    }
}

# Fonction pour formater les informations de l'adaptateur réseau
function Format-NetworkAdapter {
    param (
        [Parameter(Mandatory=$true)]
        [PSCustomObject]$Adapter
    )
    
    try {
        # Extraire la vitesse numérique de la chaîne (par exemple, "1 Gbps" -> 1)
        $speedMatch = $Adapter.Speed -match '(\d+)\s*Gbps'
        $speedValue = if ($matches) { $matches[1] } else { "N/A" }
        
        # Retourner la chaîne formatée
        return "$($Adapter.ProductName) - $speedValue Gbps"
    }
    catch {
        Write-Host "Erreur lors du formatage de l'adaptateur : $_" -ForegroundColor Red
        return $Adapter.ProductName
    }
}





