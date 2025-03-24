# =================================================================
# Fichier     : start.ps1
# Role        : Point d'entrée principal de l'application
# Description : Charge les modules et initialise l'application
# =================================================================

# Configuration initiale
$ErrorActionPreference = "Stop"
$script:scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Mode debug pour voir les erreurs
if ($env:DEBUG_MODE -eq "1") {
    Write-Host "[DEBUG] Mode debug activé - toutes les erreurs seront affichées en détail" -ForegroundColor Magenta
    $DebugPreference = "Continue"
    $VerbosePreference = "Continue"
}

# Fonction d'affichage des messages de console
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

# Chargement des assemblies Windows Forms avant toute autre chose
try {
    # Charger Windows Forms et configuration
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    
    # Configuration de Windows Forms avant de créer des objets de fenêtre
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
    
    # Importer les fonctions Windows pour manipuler la console
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '
    
    if ($env:DEBUG_MODE -eq "1") { 
        Write-Host "[DEBUG] Assemblies Windows Forms chargées avec succès" -ForegroundColor Magenta 
        Write-Host "[DEBUG] Configuration de Windows Forms réussie" -ForegroundColor Magenta
        Write-Host "[DEBUG] Fonctions Windows importées avec succès" -ForegroundColor Magenta
    }
}
catch {
    if ($env:DEBUG_MODE -eq "1") {
        Write-Host "[DEBUG] Erreur lors du chargement des assemblies: $_" -ForegroundColor Magenta
    }
}

# Fonction pour charger les modules
function Import-StepModule {
    param(
        [Parameter(Mandatory=$true)]
        [string]$ModulePath
    )
    
    $fullPath = Join-Path -Path $script:scriptPath -ChildPath $ModulePath
    
    if ($env:DEBUG_MODE -eq "1") {
        Write-Host "[DEBUG] Tentative de chargement du module: $fullPath" -ForegroundColor Magenta
    }
    
    if (Test-Path -Path $fullPath) {
        try {
            Write-ConsoleLog "🔍 Chargement du module: $ModulePath" -Color Cyan
            
            # Charger le module mais rendre les fonctions accessibles globalement
            # en utilisant le dot sourcing dans le script global
            . $fullPath
            
            # Exporter toutes les fonctions dans le scope global
            # Obtenir toutes les fonctions qui ont été définies dans le module
            $functions = Get-Item function:* | Where-Object { $_.ScriptBlock.File -eq $fullPath }
            
            # Pour chaque fonction trouvée, la réexporter dans le scope global
            foreach ($function in $functions) {
                $functionName = $function.Name
                # Vérifier si la fonction existe déjà dans l'espace global
                if (!(Get-Command "global:$functionName" -ErrorAction SilentlyContinue)) {
                    # Création de la fonction globale
                    Set-Item -Path "function:global:$functionName" -Value $function.ScriptBlock
                    if ($env:DEBUG_MODE -eq "1") {
                        Write-Host "[DEBUG] Fonction exportée globalement: $functionName" -ForegroundColor Magenta
                    }
                }
            }
            
            Write-ConsoleLog "✅ Module chargé avec succès: $ModulePath" -Color Green
            return $true
        }
        catch {
            $errorMsg = "❌ Erreur lors du chargement du module $ModulePath : $_"
            Write-ConsoleLog $errorMsg -Color Red
            
            if ($env:DEBUG_MODE -eq "1") {
                Write-Host "[DEBUG] ERREUR DÉTAILLÉE:" -ForegroundColor Magenta
                Write-Host "Exception: $($_.Exception.GetType().FullName)" -ForegroundColor Magenta
                Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Magenta
                Write-Host "Ligne: $($_.InvocationInfo.ScriptLineNumber)" -ForegroundColor Magenta
                Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Magenta
            }
            
            return $false
        }
    }
    else {
        $errorMsg = "❌ Module non trouvé: $fullPath"
        Write-ConsoleLog $errorMsg -Color Red
        return $false
    }
}

# Liste des modules à charger, dans l'ordre
$modules = @(
    "Step1_AdminCheck.ps1",
    "Step2_Logging.ps1",
    "Step3_Configuration.ps1",
    "Step4_Storage.ps1",
    "Step5_NetworkAdapter.ps1",
    "Step7_MachineGuid.ps1",
    "Step9_Initialization.ps1",
    "Step10_ProgressBar.ps1",
    "Step11_ExecuteAll.ps1",
    "Step12_Visuals.ps1",
    "Step13_Interface.ps1"
)

# Afficher un message de démarrage
Write-ConsoleLog "=== Démarrage de l'application Unlocker Free Trial ===" -Color Cyan
Write-ConsoleLog "Vous pouvez utiliser ce terminal pour voir les logs" -Color Green

# Vérifier les droits administrateur et relancer si nécessaire
$adminCheckResult = Import-StepModule -ModulePath "Step1_AdminCheck.ps1"
if ($adminCheckResult) {
    $isAdmin = Test-AdminRights
    if (-not $isAdmin) {
        # Le script s'arrête ici si Test-AdminRights a relancé l'application
        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "[DEBUG] Application relancée avec des droits administrateur" -ForegroundColor Magenta
        }
        exit 0
    }
    else {
        Write-ConsoleLog "Interface lancée en mode administrateur" -Color Green
    }
}
else {
    Write-ConsoleLog "❌ Impossible de vérifier les droits administrateur. L'application pourrait ne pas fonctionner correctement." -Color Red
}

# Charger tous les autres modules dans l'ordre
$failedModules = @()
foreach ($module in $modules | Where-Object { $_ -ne "Step1_AdminCheck.ps1" }) {
    $loadResult = Import-StepModule -ModulePath $module
    if (-not $loadResult) {
        Write-ConsoleLog "⚠️ Échec du chargement du module: $module" -Color Yellow
        $failedModules += $module
    }
}

if ($failedModules.Count -gt 0) {
    Write-ConsoleLog "⚠️ Les modules suivants n'ont pas pu être chargés:" -Color Yellow
    foreach ($module in $failedModules) {
        Write-ConsoleLog "  - $module" -Color Yellow
    }
    Write-ConsoleLog "⚠️ L'application pourrait ne pas fonctionner correctement." -Color Yellow
}

# Point d'entrée principal
if ($MyInvocation.InvocationName -ne '.') {
    # Ne pas cacher la fenêtre console en mode test ou debug
    if (-not $env:TEST_MODE -and -not $env:DEBUG_MODE) {
        try {
            # Obtenir le handle de la fenêtre console
            $consolePtr = [Console.Window]::GetConsoleWindow()
            # Constante pour ShowWindow (0 = SW_HIDE)
            [Console.Window]::ShowWindow($consolePtr, 0)
        }
        catch {
            Write-ConsoleLog "⚠️ Impossible de cacher la fenêtre console: $_" -Color Yellow
        }
    }
    else {
        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "[DEBUG] Console maintenue visible (mode test/debug)" -ForegroundColor Magenta
        }
    }
    
    try {
        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "[DEBUG] Configuration Windows Forms déjà effectuée" -ForegroundColor Magenta
        }
        
        # Vérification que Initialize-Interface existe
        if (-not (Get-Command "Initialize-Interface" -ErrorAction SilentlyContinue)) {
            Write-ConsoleLog "❌ La fonction Initialize-Interface n'est pas définie. Vérifiez que Step13_Interface.ps1 est correctement chargé." -Color Red
            throw "La fonction Initialize-Interface n'est pas définie. Vérifiez que Step13_Interface.ps1 est correctement chargé."
        }
        
        # Initialiser et afficher l'interface utilisateur
        Write-ConsoleLog "🚀 Initialisation de l'interface utilisateur..." -Color Cyan

        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "Debug: Appel de la fonction Initialize-Interface"
        }

        $form = Initialize-Interface
        
        if ($null -ne $form) {
            if ($env:DEBUG_MODE -eq "1") {
                Write-Host "Debug: Formulaire créé avec succès"
                Write-Host "Debug: Type de l'objet retourné: $($form.GetType().FullName)"
            }
            
            # Configuration de l'événement Load
            $form.Add_Load({
                $this.Activate()
                $this.BringToFront()
                $this.Focus()
            })
            
            # Démarrer la boucle de messages Windows Forms
            [System.Windows.Forms.Application]::Run($form)
            
            # Quitter proprement après la fermeture de l'interface
            exit
        } else {
            $errorMessage = "❌ Échec de l'initialisation de l'interface"
            Write-Log $errorMessage -Level "ERROR"
            Write-ConsoleLog $errorMessage -Color Red
            
            if ($env:DEBUG_MODE -eq "1") {
                throw "Debug: Initialize-Interface a retourné null"
            }
        }
    }
    catch {
        $errorMsg = "❌ ERREUR CRITIQUE: $_"
        Write-ConsoleLog $errorMsg -Color Red
        
        if ($env:DEBUG_MODE -eq "1") {
            Write-Host "[DEBUG] ERREUR FATALE:" -ForegroundColor Magenta
            Write-Host "Exception: $($_.Exception.GetType().FullName)" -ForegroundColor Magenta
            Write-Host "Message: $($_.Exception.Message)" -ForegroundColor Magenta
            Write-Host "Position: $($_.InvocationInfo.PositionMessage)" -ForegroundColor Magenta
            Write-Host "Stack trace: $($_.ScriptStackTrace)" -ForegroundColor Magenta
        }
    }
} 