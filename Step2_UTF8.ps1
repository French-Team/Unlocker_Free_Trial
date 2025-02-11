# =================================================================
# Fichier     : Step2_UTF8.ps1
# Rôle        : Configure l'encodage pour tous les scripts
# Connection  : Utilisé par le script principal (start.ps1)
# Remarque    : Utilise une combinaison d'encodages pour assurer la compatibilité
# =================================================================

function Set-ConsoleEncoding {
    try {
        # Définir la culture en français
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'fr-FR'
        [System.Threading.Thread]::CurrentThread.CurrentCulture = 'fr-FR'

        # Configurer l'encodage pour la console Windows
        $null = cmd /c '' # Vide le buffer de la console
        chcp 850 | Out-Null # IBM850 (Multilingual - Latin I)
        
        # Configurer les encodages PowerShell
        $OutputEncoding = [System.Text.Encoding]::GetEncoding(850)
        [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(850)
        [Console]::InputEncoding = [System.Text.Encoding]::GetEncoding(850)
        
        # Définir l'encodage par défaut pour les fichiers
        $PSDefaultParameterValues['Out-File:Encoding'] = 'Default'
        $PSDefaultParameterValues['Set-Content:Encoding'] = 'Default'
        
        # Nettoyer l'écran pour éviter les problèmes d'affichage
        Clear-Host
        
        return $true
    }
    catch {
        return $false
    }
} 





