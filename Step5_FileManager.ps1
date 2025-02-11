# =================================================================
# Fichier     : Step5_FileManager.ps1
# Role        : Boutique de gestion des fichiers
# Magasins    : - Magasin des chemins (gestion des chemins)
#               - Magasin des suppressions (suppression des fichiers)
# =================================================================

# ===== Magasin des chemins =====
function Get-CursorStoragePath {
    Write-Host "🏪 Accès au magasin des chemins..." -ForegroundColor Cyan
    
    try {
        # Rayon construction du chemin
        Write-Host "  🔍 Construction du chemin..." -ForegroundColor Gray
        $username = $env:USERNAME
        $storagePath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        
        Write-Host "  ✓ Chemin construit: $storagePath" -ForegroundColor Green
        return $storagePath
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la construction du chemin: $_" -ForegroundColor Red
        throw "Error lors de la construction du chemin: $_"
    }
}

# ===== Magasin des suppressions =====
function Remove-CursorStorage {
    Write-Host "🏪 Accès au magasin des suppressions..." -ForegroundColor Cyan
    
    try {
        # Rayon recherche du fichier
        $filePath = Get-CursorStoragePath
        Write-Host "  🔍 Recherche du fichier: $filePath" -ForegroundColor Gray
        
        if (Test-Path $filePath) {
            # Rayon suppression
            Write-Host "  🗑️ Suppression du fichier..." -ForegroundColor Yellow
            Remove-Item -Path $filePath -Force
            Write-Host "  ✓ Fichier supprimé avec succès" -ForegroundColor Green
            return @{
                Success = $true
                Message = "Fichier supprimé avec succès"
            }
        } else {
            # Rayon fichier non trouvé
            Write-Host "  ⚠️ Fichier non trouvé" -ForegroundColor Yellow
            return @{
                Success = $false
                Message = "Le fichier n'existe pas"
            }
        }
    }
    catch {
        # Caisse des erreurs
        Write-Host "  ❌ Error lors de la suppression: $_" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error lors de la suppression: $_"
        }
    }
} 





