# =================================================================
# Fichier     : Step1_AdminCheck.ps1
# Role        : Vérification des droits administrateur
# Description : Vérifie si le script est lancé en mode administrateur
#               et le relance en mode admin si nécessaire.
# =================================================================

function Test-AdminRights {
    Write-ConsoleLog "🔍 Vérification des droits administrateur..." -Color Cyan
    
    # Vérifier si le script est exécuté en tant qu'administrateur
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    # En mode test, on retourne simplement le statut sans redémarrer
    if ($env:TEST_MODE) {
        return $isAdmin
    }
    
    if (-not $isAdmin) {
        Write-ConsoleLog "⚠️ Ce script nécessite des droits d'administrateur." -Color Yellow
        Write-ConsoleLog "Relancement du script avec les droits d'administrateur..." -Color Cyan
        
        try {
            # Obtenir le chemin complet du script principal
            $mainScriptPath = Join-Path -Path $PSScriptRoot -ChildPath "start.ps1"
            
            # Déterminer quelle version de PowerShell est utilisée
            if ($PSVersionTable.PSEdition -eq "Core") {
                # PowerShell Core (7+)
                Start-Process pwsh.exe -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$mainScriptPath`"" -Verb RunAs
            } else {
                # Windows PowerShell
                Start-Process powershell.exe -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$mainScriptPath`"" -Verb RunAs
            }
            
            # Quitter le script actuel après avoir lancé la nouvelle instance
            exit
        }
        catch {
            Write-ConsoleLog "❌ Erreur lors du redémarrage en mode administrateur: $_" -Color Red
            return $false
        }
    }
    else {
        Write-ConsoleLog "✅ Droits d'administrateur confirmés" -Color Green
        return $true
    }
} 