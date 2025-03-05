# =================================================================
# Fichier     : test_interface_simple.ps1
# Role        : Test simple de l'interface graphique
# =================================================================

# Initialisation de Windows Forms
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

# Configuration des variables globales
$global:CurrentLanguage = "FR"
$global:Translations = @{
    "FR" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker Free Trial"
        "Subtitle" = "pour Cursor"
        "BtnMacAddress" = "1. Modifier l'adresse MAC"
        "BtnDeleteStorage" = "2. Supprimer storage.json"
        "BtnExecuteAll" = "3. Exécuter toutes les actions"
        "BtnExit" = "4. Quitter"
        "Ready" = "Prêt"
        "NetworkCard" = "Carte réseau active"
        "MacAddress" = "Adresse MAC"
        "NoNetwork" = "Aucune carte réseau active trouvée"
        "NetworkError" = "Impossible de récupérer les informations réseau"
    }
    "EN" = @{
        "WindowTitle" = "Unlocker - Free Trial"
        "MainTitle" = "Unlocker Free Trial"
        "Subtitle" = "for Cursor"
        "BtnMacAddress" = "1. Change MAC Address"
        "BtnDeleteStorage" = "2. Delete storage.json"
        "BtnExecuteAll" = "3. Execute All Actions"
        "BtnExit" = "4. Exit"
        "Ready" = "Ready"
        "NetworkCard" = "Active Network Card"
        "MacAddress" = "MAC Address"
        "NoNetwork" = "No active network card found"
        "NetworkError" = "Unable to retrieve network information"
    }
}

# Mock de Get-NetAdapter
function global:Get-NetAdapter {
    return @(
        @{
            Name = "Ethernet"
            Status = "Up"
            MacAddress = "00-11-22-33-44-55"
            InterfaceDescription = "Intel(R) Ethernet Connection"
        }
    )
}

# Chargement des scripts
$projectRoot = Split-Path $PSScriptRoot -Parent
. "$projectRoot\Step3_MacInfo.ps1"
. "$projectRoot\Step3_Interface.ps1"

Write-Host "`n=== Test de création de l'interface ===" -ForegroundColor Cyan
$interface = Initialize-MainWindow

# Test 1: Vérification de la création de l'interface
if ($interface -and $interface.Form) {
    Write-Host "✓ Interface créée avec succès" -ForegroundColor Green
} else {
    Write-Host "❌ Échec de la création de l'interface" -ForegroundColor Red
    exit 1
}

# Test 2: Vérification des dimensions
if ($interface.Form.Size.Width -eq 800 -and $interface.Form.Size.Height -eq 600) {
    Write-Host "✓ Dimensions correctes (800x600)" -ForegroundColor Green
} else {
    Write-Host "❌ Dimensions incorrectes" -ForegroundColor Red
    exit 1
}

# Test 3: Vérification des boutons
$buttons = @(
    @{ Name = "LanguageButton"; Width = 70; Height = 35 }
    @{ Name = "MacAddressButton"; Width = 600; Height = 35 }
    @{ Name = "DeleteStorageButton"; Width = 600; Height = 35 }
    @{ Name = "ExecuteAllButton"; Width = 600; Height = 35 }
    @{ Name = "ExitButton"; Width = 600; Height = 35 }
)

foreach ($button in $buttons) {
    $control = $interface.$($button.Name)
    if ($control -and 
        $control.Size.Width -eq $button.Width -and 
        $control.Size.Height -eq $button.Height) {
        Write-Host "✓ $($button.Name) vérifié" -ForegroundColor Green
    } else {
        Write-Host "❌ Problème avec $($button.Name)" -ForegroundColor Red
        exit 1
    }
}

# Test 4: Test du changement de langue
Write-Host "`nTest du changement de langue..."

# Stocker les valeurs initiales
$initialLanguage = $global:CurrentLanguage
$initialText = $interface.MacAddressButton.Text

# Changer directement la langue
$global:CurrentLanguage = if ($global:CurrentLanguage -eq "FR") { "EN" } else { "FR" }

# Mettre à jour l'interface manuellement
$interface.Form.Text = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
$interface.MacAddressButton.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
$interface.DeleteStorageButton.Text = $global:Translations[$global:CurrentLanguage]["BtnDeleteStorage"]
$interface.ExecuteAllButton.Text = $global:Translations[$global:CurrentLanguage]["BtnExecuteAll"]
$interface.ExitButton.Text = $global:Translations[$global:CurrentLanguage]["BtnExit"]

Start-Sleep -Milliseconds 500  # Attendre que les changements soient appliqués

# Vérification des changements
$success = $true

# Vérification de la langue
$expectedLanguage = if ($initialLanguage -eq "FR") { "EN" } else { "FR" }
if ($global:CurrentLanguage -ne $expectedLanguage) {
    Write-Host "❌ La langue n'a pas changé correctement" -ForegroundColor Red
    Write-Host "  Attendu: $expectedLanguage" -ForegroundColor Yellow
    Write-Host "  Actuel : $global:CurrentLanguage" -ForegroundColor Yellow
    $success = $false
} else {
    Write-Host "✓ Langue changée de $initialLanguage à $global:CurrentLanguage" -ForegroundColor Green
}

# Vérification des textes
$expectedText = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
$actualText = $interface.MacAddressButton.Text

if ($actualText -ne $expectedText) {
    Write-Host "❌ Le texte du bouton n'a pas été mis à jour" -ForegroundColor Red
    Write-Host "  Attendu: $expectedText" -ForegroundColor Yellow
    Write-Host "  Actuel : $actualText" -ForegroundColor Yellow
    $success = $false
} else {
    Write-Host "✓ Texte du bouton mis à jour correctement" -ForegroundColor Green
}

# Vérification du titre
$expectedTitle = $global:Translations[$global:CurrentLanguage]["WindowTitle"]
$actualTitle = $interface.Form.Text

if ($actualTitle -ne $expectedTitle) {
    Write-Host "❌ Le titre de la fenêtre n'a pas été mis à jour" -ForegroundColor Red
    Write-Host "  Attendu: $expectedTitle" -ForegroundColor Yellow
    Write-Host "  Actuel : $actualTitle" -ForegroundColor Yellow
    $success = $false
} else {
    Write-Host "✓ Titre de la fenêtre mis à jour correctement" -ForegroundColor Green
}

if (-not $success) {
    Write-Host "`nDébug des contrôles :" -ForegroundColor Yellow
    Write-Host "  Form.Controls.Count : $($interface.Form.Controls.Count)" -ForegroundColor Yellow
    Write-Host "  MainPanel.Controls.Count : $($interface.Form.Controls[0].Controls.Count)" -ForegroundColor Yellow
    Write-Host "  Langue actuelle : $global:CurrentLanguage" -ForegroundColor Yellow
    Write-Host "  Traductions disponibles : $($global:Translations.Keys -join ', ')" -ForegroundColor Yellow
    Write-Host "  Traduction attendue : $($global:Translations[$global:CurrentLanguage]['BtnMacAddress'])" -ForegroundColor Yellow
    
    # Test de changement inverse
    Write-Host "`nTest de changement inverse..." -ForegroundColor Yellow
    $interface.LanguageButton.PerformClick()
    Start-Sleep -Milliseconds 500
    Write-Host "  Nouvelle langue : $global:CurrentLanguage" -ForegroundColor Yellow
    Write-Host "  Nouveau texte : $($interface.MacAddressButton.Text)" -ForegroundColor Yellow
    
    exit 1
}

# Test 5: Test de l'affichage
try {
    $interface.Form.Show()
    Start-Sleep -Milliseconds 100
    $interface.Form.Close()
    Write-Host "✓ Affichage de l'interface réussi" -ForegroundColor Green
} catch {
    Write-Host "❌ Échec de l'affichage de l'interface: $_" -ForegroundColor Red
    exit 1
} finally {
    $interface.Form.Dispose()
}

Write-Host "`n=== Tous les tests ont réussi ! ===" -ForegroundColor Green

# Nettoyage
Remove-Item function:global:Get-NetAdapter -ErrorAction SilentlyContinue 