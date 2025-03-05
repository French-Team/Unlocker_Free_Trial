# =================================================================
# Fichier     : Step3_MacInfo.ps1
# Role        : Boutique spécialisée des informations réseau
# Magasins    : - Magasin des adaptateurs (recherche et info)
#               - Magasin d'affichage (mise en forme et labels)
# =================================================================

# ===== Magasin des adaptateurs réseau =====
function Get-CurrentMacInfo {
    Write-Host "🏪 Accès au magasin des adaptateurs..." -ForegroundColor Cyan
    
    try {
        # Rayon recherche d'adaptateurs
        Write-Host "  🔍 Recherche d'adaptateurs actifs..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | 
                  Where-Object { $_.Status -eq 'Up' } | 
                  Select-Object -First 1
        
        # Rayon informations
        if ($adapter) {
            Write-Host "  ✓ Adaptateur trouvé: $($adapter.Name)" -ForegroundColor Green
            return @{
                Success = $true
                AdapterName = $adapter.Name
                Description = $adapter.InterfaceDescription
                MacAddress = $adapter.MacAddress
                Status = $adapter.Status
            }
        }

        # Rayon erreurs
        Write-Host "  ⚠️ Aucun adaptateur actif trouvé" -ForegroundColor Yellow
        return @{
            Success = $false
            Message = "Aucun adaptateur réseau actif trouvé"
        }
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la recherche: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error: $($_.Exception.Message)"
        }
    }
}

# ===== Magasin d'affichage =====
function Update-MacInfoLabel {
    Write-Host "🏪 Accès au magasin d'affichage..." -ForegroundColor Cyan
    
    try {
        # Rayon mise en forme
        Write-Host "  🎨 Mise en forme des informations..." -ForegroundColor Gray
        $macInfo = Get-CurrentMacInfo
        
        if ($macInfo.Success) {
            # Rayon formatage réussi
            Write-Host "  ✓ Informations récupérées avec succès" -ForegroundColor Green
            return @{
                Success = $true
                Text = "$($global:Translations[$global:CurrentLanguage]['NetworkCard']) : $($macInfo.Description)`n$($global:Translations[$global:CurrentLanguage]['MacAddress']) : $($macInfo.MacAddress)"
            }
        } 
        else {
            # Rayon messages d'erreur
            Write-Host "  ⚠️ Erreur lors de la récupération des informations" -ForegroundColor Yellow
            return @{
                Success = $false
                Text = $global:Translations[$global:CurrentLanguage]['NoNetwork']
            }
        }
    }
    catch {
        # Caisse des erreurs d'affichage
        Write-Host "  ❌ Error lors de la mise à jour de l'affichage: $_" -ForegroundColor Red
        return @{
            Success = $false
            Text = $global:Translations[$global:CurrentLanguage]['NetworkError']
        }
    }
} 





