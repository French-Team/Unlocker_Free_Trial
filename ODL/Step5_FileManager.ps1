# =================================================================
# File       : Step5_FileManager.ps1
# Role       : File management shop
# Shops      : - Paths shop (path management)
#              - Deletions shop (file deletion)
# =================================================================

# ===== Paths shop =====
function Get-CursorStoragePath {
    Write-Host "🏪 Accessing paths shop..." -ForegroundColor Cyan
    
    try {
        # Path construction section
        Write-Host "  🔍 Building path..." -ForegroundColor Gray
        $username = $env:USERNAME
        $storagePath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        
        Write-Host "  ✓ Path built: $storagePath" -ForegroundColor Green
        return $storagePath
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error building path: $_" -ForegroundColor Red
        throw "Error building path: $_"
    }
}

# ===== Deletions shop =====
function Remove-CursorStorage {
    Write-Host "🏪 Accessing deletions shop..." -ForegroundColor Cyan
    
    try {
        # File search section
        $filePath = Get-CursorStoragePath
        Write-Host "  🔍 Searching for file: $filePath" -ForegroundColor Gray
        
        if (Test-Path $filePath) {
            # Deletion section
            Write-Host "  🗑️ Deleting file..." -ForegroundColor Yellow
            Remove-Item -Path $filePath -Force
            Write-Host "  ✓ File successfully deleted" -ForegroundColor Green
            return @{
                Success = $true
                Message = "File successfully deleted"
            }
        } else {
            # File not found section
            Write-Host "  ⚠️ File not found" -ForegroundColor Yellow
            return @{
                Success = $false
                Message = "File does not exist"
            }
        }
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error during deletion: $_" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error during deletion: $_"
        }
    }
} 