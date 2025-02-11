# =================================================================
# Fichier     : test_interface.ps1
# Role        : Test de l'interface graphique
# =================================================================

# Chargement des assemblies Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# Chargement des scripts nécessaires
. "$PSScriptRoot\Step3_Interface.ps1"

# Test de l'interface
$interface = Initialize-MainWindow
if ($interface -and $interface.Form) {
    # Configuration de la fenêtre
    $interface.Form.Add_Load({
        $this.Activate()
        $this.BringToFront()
        $this.Focus()
    })
    
    # Affichage de la fenêtre
    [System.Windows.Forms.Application]::Run($interface.Form)
} 