# =================================================================
# Fichier     : Step1_AdminCheck.ps1
# Role        : Verifie si le script est lance en mode administrateur 
#               et le relance en mode admin si necessaire.
# Connection  : Utilise par le script principal (start.ps1)
# Remarque    : Ce fichier est destine a fonctionner sur Windows 10
# =================================================================

# Verification des privileges administratifs
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# En mode test, on retourne simplement le statut sans redémarrer
if ($env:TEST_MODE) {
    return $isAdmin
}

# En mode normal, on redémarre si nécessaire
if (-not $isAdmin) {
    Write-Warning "Le script doit être exécuté en tant qu'administrateur. Redémarrage..."
    try {
        if ($PSVersionTable.PSEdition -eq "Core") {
            Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath'`"" -Wait
        } else {
            Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath'`"" -Wait
        }
        exit 0
    }
    catch {
        Write-Host "❌ Error lors du redémarrage en mode administrateur: $_" -ForegroundColor Red
        exit 1
    }
}

# Si nous sommes ici, nous avons les droits administrateur
return $true 





