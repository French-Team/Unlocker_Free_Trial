# =================================================================
# Fichier     : Step2_UTF8.ps1
# Rôle        : Configure l'encodage pour tous les scripts
# Connection  : Utilisé par le script principal (start.ps1)
# Remarque    : Utilise une combinaison d'encodages pour assurer la compatibilité
# =================================================================

function Set-ConsoleEncoding {
    try {
        # Définir la culture en fonction de la langue sélectionnée
        $culture = if ($global:CurrentLanguage -eq "FR") { "fr-FR" } else { "en-US" }
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = $culture
        [System.Threading.Thread]::CurrentThread.CurrentCulture = $culture

        # Configurer l'encodage pour la console Windows
        $null = cmd /c '' # Vide le buffer de la console
        chcp 65001 | Out-Null # UTF-8
        
        # Configurer les encodages PowerShell
        $OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::OutputEncoding = [System.Text.Encoding]::UTF8
        [Console]::InputEncoding = [System.Text.Encoding]::UTF8
        
        # Définir l'encodage par défaut pour les fichiers
        $PSDefaultParameterValues['Out-File:Encoding'] = 'UTF8'
        $PSDefaultParameterValues['Set-Content:Encoding'] = 'UTF8'
        
        # Nettoyer l'écran pour éviter les problèmes d'affichage
        Clear-Host
        
        return $true
    }
    catch {
        return $false
    }
} 





