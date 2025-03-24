# =================================================================
# Fichier     : Step14_FinalTester.ps1
# Role        : Test de fonctionnement complet de l'application
# Description : Vérifie le lancement et le fonctionnement de l'application
# =================================================================

# Configuration initiale
$ErrorActionPreference = "Stop"
$script:scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$env:TEST_MODE = "1" # Activer le mode test
$env:DEBUG_MODE = "1" # Activer le mode debug

Write-Host "=== TEST DE FONCTIONNEMENT DE L'APPLICATION (MODE DEBUG) ===" -ForegroundColor Cyan
Write-Host "Chemin du script: $script:scriptPath" -ForegroundColor Gray

# Test 1: Vérification des fichiers essentiels
Write-Host "`n[TEST 1] Vérification des fichiers essentiels..." -ForegroundColor Cyan
$files = @(
    "launcher.bat",
    "start.ps1",
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

$missingFiles = @()
foreach ($file in $files) {
    $filePath = Join-Path -Path $script:scriptPath -ChildPath $file
    if (Test-Path $filePath) {
        Write-Host "  [OK] $file est présent" -ForegroundColor Green
    } else {
        Write-Host "  [ERREUR] $file est manquant" -ForegroundColor Red
        $missingFiles += $file
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host "`n[ERREUR] Les fichiers suivants sont manquants:" -ForegroundColor Red
    $missingFiles | ForEach-Object { Write-Host "  - $_" -ForegroundColor Red }
    exit 1
}

# Test 2: Lancement direct de start.ps1 avec debug
Write-Host "`n[TEST 2] Lancement direct de start.ps1 avec debug activé..." -ForegroundColor Cyan
Write-Host "  Cela permettra de voir toutes les erreurs potentielles." -ForegroundColor Yellow
Write-Host "  Appuyez sur une touche pour continuer..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")

try {
    # Lancement direct de start.ps1
    $startPath = Join-Path -Path $script:scriptPath -ChildPath "start.ps1"
    
    # Appeler directement le script pour voir les erreurs
    Write-Host "`n=== DÉMARRAGE DE START.PS1 (Tous les messages d'erreur seront visibles) ===" -ForegroundColor Cyan
    . $startPath
    
    Write-Host "`n  [OK] start.ps1 a été exécuté" -ForegroundColor Green
} catch {
    $errorDetails = $_.Exception.Message
    $errorLine = $_.InvocationInfo.ScriptLineNumber
    $errorScript = $_.InvocationInfo.ScriptName
    
    Write-Host "`n  [ERREUR] Erreur lors de l'exécution de start.ps1:" -ForegroundColor Red
    Write-Host "  Message: $errorDetails" -ForegroundColor Red
    Write-Host "  Ligne: $errorLine dans $errorScript" -ForegroundColor Red
    Write-Host "  Stack Trace: $($_.ScriptStackTrace)" -ForegroundColor Red
}

# Instructions finales
Write-Host "`n=== RÉSULTATS DU TEST ===" -ForegroundColor Cyan
Write-Host "Si l'interface ne s'est pas affichée, examinez les messages d'erreur ci-dessus." -ForegroundColor Yellow
Write-Host "Fin du test. Appuyez sur une touche pour terminer..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
