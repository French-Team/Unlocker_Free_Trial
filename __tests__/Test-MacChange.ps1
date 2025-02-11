# =================================================================
# Fichier     : Test-MacChange.ps1
# Role        : Script de test pour la modification d'adresse MAC
# =================================================================

# Importer les fonctions nécessaires
. "$PSScriptRoot\Step4_MacAddress.ps1"
. "$PSScriptRoot\Step4_MacAddressGUI.ps1"

Write-Host "`n=== Test de modification d'adresse MAC ===`n" -ForegroundColor Cyan

# 1. Sélection de l'adaptateur
$adapter = Get-NetAdapter | Select-Object -First 1
Write-Host "1. Carte sélectionnée:" -ForegroundColor Yellow
Write-Host "   - Nom: $($adapter.Name)"
Write-Host "   - Description: $($adapter.InterfaceDescription)"
Write-Host "   - Adresse MAC actuelle: $($adapter.MacAddress)"

# 2. Générer une nouvelle adresse MAC
$newMac = "02-11-22-33-44-55"
Write-Host "`n2. Nouvelle adresse MAC à appliquer: $newMac" -ForegroundColor Yellow

# 3. Créer et exécuter le script avec élévation
$modifyScript = @"
try {
    # Désactiver l'adaptateur
    Write-Host "- Désactivation de l'adaptateur..." -ForegroundColor Yellow
    Disable-NetAdapter -Name '$($adapter.Name)' -Confirm:`$false
    Start-Sleep -Seconds 2

    # Modifier l'adresse MAC
    Write-Host "- Modification de l'adresse MAC..." -ForegroundColor Yellow
    `$regPath = "HKLM:SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    `$success = `$false
    
    Get-ChildItem -Path `$regPath | ForEach-Object {
        `$props = Get-ItemProperty -Path `$_.PSPath
        if (`$props.DriverDesc -eq '$($adapter.InterfaceDescription)') {
            Set-ItemProperty -Path `$_.PSPath -Name "NetworkAddress" -Value '$($newMac.Replace("-", ""))'
            `$success = `$true
            Write-Host "- Adresse MAC modifiée dans le registre" -ForegroundColor Green
        }
    }

    if (-not `$success) {
        throw "Adaptateur non trouvé dans le registre"
    }

    # Réactiver l'adaptateur
    Write-Host "- Réactivation de l'adaptateur..." -ForegroundColor Yellow
    Enable-NetAdapter -Name '$($adapter.Name)' -Confirm:`$false
    Start-Sleep -Seconds 5

    # Vérifier le résultat
    `$updatedAdapter = Get-NetAdapter -Name '$($adapter.Name)'
    Write-Host "`nRésultats:" -ForegroundColor Cyan
    Write-Host "- Nouvelle adresse MAC: `$(`$updatedAdapter.MacAddress)"
    Write-Host "- État de l'adaptateur: `$(`$updatedAdapter.Status)"
    Write-Host "- Modification réussie: `$(if(`$updatedAdapter.MacAddress -eq '$newMac'){'Oui'}else{'Non'})"
}
catch {
    Write-Host "Erreur: `$(`$_.Exception.Message)" -ForegroundColor Red
    try { Enable-NetAdapter -Name '$($adapter.Name)' -Confirm:`$false } catch { }
}
"@

$tempScript = [System.IO.Path]::GetTempFileName() + ".ps1"
$modifyScript | Out-File -FilePath $tempScript -Encoding UTF8

Write-Host "`n3. Lancement de la modification..." -ForegroundColor Yellow
Start-Process "pwsh" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempScript`"" -Verb RunAs -Wait

Remove-Item $tempScript -Force -ErrorAction SilentlyContinue 