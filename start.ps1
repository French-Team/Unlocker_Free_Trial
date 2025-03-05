# =================================================================
# Fichier     : start.ps1
# Role        : Point d'entrée principal de l'application
# Connection  : Utilise les fichiers Step*.ps1 pour les fonctionnalités
# =================================================================

# Configuration initiale
$ErrorActionPreference = "Stop"
$script:scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Importer les fonctions Windows nécessaires pour cacher la console
Add-Type -Name Window -Namespace Console -MemberDefinition '
[DllImport("Kernel32.dll")]
public static extern IntPtr GetConsoleWindow();
[DllImport("user32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
'

# Vérification des droits administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    try {
        # Démarrer PowerShell en mode caché avec les droits admin
        Start-Process pwsh.exe -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        exit 0
    }
    catch {
        Write-Host "❌ Error lors du redémarrage en mode administrateur: $_" -ForegroundColor Red
        exit 1
    }
}

# Cacher la fenêtre console immédiatement après vérification des droits admin
if (-not $env:TEST_MODE) {
    # Obtenir le handle de la fenêtre console
    $consolePtr = [Console.Window]::GetConsoleWindow()
    # Constante pour ShowWindow (0 = SW_HIDE)
    [Console.Window]::ShowWindow($consolePtr, 0)
}

Write-Host "Interface lancée en mode administrateur"
Write-Host "Vous pouvez utiliser ce terminal pour voir les logs"

# Fonction d'affichage des messages
function global:Write-ConsoleLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$Color = "White"
    )
    
    Write-Host $Message -ForegroundColor $Color
    return $Message
}

# Chargement des assemblies Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Importation des modules nécessaires
. "$PSScriptRoot\Step1_AdminCheck.ps1"
. "$PSScriptRoot\Step2_UTF8.ps1"
. "$PSScriptRoot\Step4_MacAddress.ps1"
. "$PSScriptRoot\Step3_MacInfo.ps1"
. "$PSScriptRoot\Step3_Interface.ps1"
. "$PSScriptRoot\Step4_MacAddressGUI.ps1"

# Point d'entrée principal
if ($MyInvocation.InvocationName -ne '.' -and -not $env:TEST_MODE) {
    # Configuration de Windows Forms
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

    # Initialisation et affichage de l'interface
    $interface = Initialize-MainWindow
    if ($interface -and $interface.Form) {
        # Configuration de la fenêtre
        $interface.Form.Add_Load({
            $this.Activate()
            $this.BringToFront()
            $this.Focus()
        })
        
        # Démarrage de la boucle de messages Windows Forms
        [System.Windows.Forms.Application]::Run($interface.Form)
    }
}

# Fonctions utilitaires
function global:Get-NetworkAdapters {
    return Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
}

function global:Set-MacAddress {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterName,
        [Parameter(Mandatory=$true)]
        [string]$NewMacAddress
    )
    
    try {
        Set-NetAdapter -Name $AdapterName -MacAddress $NewMacAddress -Confirm:$false
        return $true
    }
    catch {
        Write-ConsoleLog "Error lors de la modification de l'adresse MAC: $_" -Color Red
        return $false
    }
}





