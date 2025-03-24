# =================================================================
# TestStep6.ps1 - Script de test pour vérifier le résumé et les timeouts
# =================================================================

Add-Type -AssemblyName System.Windows.Forms

# Définir la variable pour indiquer que nous sommes en mode test
$env:TEST_MODE = $true

# Charger explicitement le script Step6_ExecuteAll.ps1
try {
    $step6Path = Join-Path -Path $PSScriptRoot -ChildPath "Step6_ExecuteAll.ps1"
    if (Test-Path $step6Path) {
        Write-Host "Chargement de $step6Path..." -ForegroundColor Green
        . $step6Path -TestMode
        Write-Host "Step6_ExecuteAll.ps1 chargé avec succès." -ForegroundColor Green
    } else {
        Write-Host "ERREUR: Le fichier $step6Path n'existe pas!" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "ERREUR lors du chargement de Step6_ExecuteAll.ps1: $_" -ForegroundColor Red
    exit 1
}

# Fonction de simulation pour le test
function Get-NetworkAdapters {
    # Retourne un objet simulé d'adaptateur réseau
    return @(
        [PSCustomObject]@{
            Name = "Ethernet"
            MacAddress = "00-11-22-33-44-55"
            Status = "Up"
            Speed = "1 Gbps"
            ProductName = "Realtek PCIe GbE Family Controller"
            DriverVersion = "10.0.0.1"
        }
    )
}

function Format-NetworkAdapter {
    param ([PSCustomObject]$Adapter)
    return "$($Adapter.ProductName) - 1 Gbps"
}

function New-MacAddress {
    return "AA-BB-CC-DD-EE-FF"
}

function Set-MacAddress {
    param ([string]$AdapterName, [string]$MacAddress)
    Write-Host "Simulation: Modification de l'adresse MAC de $AdapterName à $MacAddress" -ForegroundColor Green
    return $true
}

function Remove-CursorStorage {
    Write-Host "Simulation: Suppression du fichier storage.json" -ForegroundColor Green
    return @{ Success = $true; Message = "Fichier supprimé" }
}

function Get-MachineGuid {
    return "00000000-0000-0000-0000-000000000000"
}

function New-MachineGuid {
    return "11111111-1111-1111-1111-111111111111"
}

function Set-MachineGuid {
    param ([string]$CurrentGuid, [string]$NewGuid)
    Write-Host "Simulation: Modification du MachineGuid de $CurrentGuid à $NewGuid" -ForegroundColor Green
    return $true
}

function Reset-MachineGuid {
    return @{ 
        Success = $true
        OldValue = "00000000-0000-0000-0000-000000000000"
        NewValue = "11111111-1111-1111-1111-111111111111"
    }
}

function Get-NetworkInformation {
    # Simulation de la fonction réseau
    return @{
        Success = $true
        Data = @{
            AdapterName = "Realtek PCIe GbE Family Controller - 1 Gbps"
            MacAddress = "AA-BB-CC-DD-EE-FF"
            MachineGuid = "11111111-1111-1111-1111-111111111111"
        }
    }
}

function Update-NetworkInfo {
    param (
        [System.Windows.Forms.RichTextBox]$infoLabel,
        [System.Windows.Forms.RichTextBox]$guidLabel
    )
    
    Write-Host "Simulation: Mise à jour des informations réseau" -ForegroundColor Cyan
    Write-Host "infoLabel: $($infoLabel -ne $null)" -ForegroundColor Gray
    Write-Host "guidLabel: $($guidLabel -ne $null)" -ForegroundColor Gray
    
    $networkInfo = Get-NetworkInformation
    
    if ($networkInfo.Success -and $infoLabel -and $guidLabel) {
        Write-Host "MAC Address: $($networkInfo.Data.MacAddress)" -ForegroundColor Green
        Write-Host "MachineGuid: $($networkInfo.Data.MachineGuid)" -ForegroundColor Green
    }
}

# Simulation de la fonction Execute-AllActions si non définie dans Step6_ExecuteAll.ps1
if (-not (Get-Command "Execute-AllActions" -ErrorAction SilentlyContinue)) {
    function Execute-AllActions {
        param (
            [string]$MacAddress,
            [bool]$ShouldResetMachineGuid,
            [bool]$ShouldDeleteStorageFile,
            [System.Windows.Forms.ProgressBar]$ProgressControl,
            [System.Windows.Forms.Label]$StatusLabel
        )
        
        Write-Host "Simulation de l'exécution des actions..." -ForegroundColor Cyan
        
        # Mise à jour de la progression
        if ($ProgressControl) {
            $ProgressControl.Value = 30
            if ($StatusLabel) {
                $StatusLabel.Text = "Modification de l'adresse MAC"
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        Start-Sleep -Seconds 1
        
        # Modifications simulées
        Set-MacAddress -AdapterName "Ethernet" -MacAddress "AA-BB-CC-DD-EE-FF"
        
        if ($ProgressControl) {
            $ProgressControl.Value = 60
            if ($StatusLabel) {
                $StatusLabel.Text = "Suppression du fichier storage.json"
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        Start-Sleep -Seconds 1
        Remove-CursorStorage
        
        if ($ProgressControl) {
            $ProgressControl.Value = 90
            if ($StatusLabel) {
                $StatusLabel.Text = "Réinitialisation du MachineGuid"
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        Start-Sleep -Seconds 1
        $guidResult = Reset-MachineGuid
        
        if ($ProgressControl) {
            $ProgressControl.Value = 100
            if ($StatusLabel) {
                $StatusLabel.Text = "Terminé"
            }
            [System.Windows.Forms.Application]::DoEvents()
        }
        
        return @{
            Success = $true
            Results = @{
                MAC = $true
                Storage = $true
                MachineGuid = $true
            }
            StorageMessage = "Fichier supprimé avec succès"
        }
    }
}

# Fonction Show-ActionSummary simulée pour le test si non définie
if (-not (Get-Command "Show-ActionSummary" -ErrorAction SilentlyContinue)) {
    function Show-ActionSummary {
        param (
            [Parameter(Mandatory=$true)]
            [bool]$MacSuccess,
            [Parameter(Mandatory=$true)]
            [bool]$StorageSuccess,
            [Parameter(Mandatory=$true)]
            [bool]$MachineGuidSuccess,
            [Parameter(Mandatory=$false)]
            [string]$StorageMessage = ""
        )
        
        Write-Host "=== Affichage du résumé avec Show-ActionSummary ===" -ForegroundColor Green
        Write-Host "MAC Address: $(if($MacSuccess){"✅ Modifiée avec succès"}else{"❌ Échec"})" -ForegroundColor $(if($MacSuccess){"Green"}else{"Red"})
        Write-Host "MachineGuid: $(if($MachineGuidSuccess){"✅ Réinitialisé avec succès"}else{"❌ Échec"})" -ForegroundColor $(if($MachineGuidSuccess){"Green"}else{"Red"})
        Write-Host "Storage: $(if($StorageSuccess){"✅ Fichier supprimé avec succès"}else{"❌ Échec - $StorageMessage"})" -ForegroundColor $(if($StorageSuccess){"Green"}else{"Red"})
        
        Write-Host "`n[NOTE] Dans un environnement réel, une fenêtre avec les boutons suivants s'affiche :" -ForegroundColor Yellow
        Write-Host "  - Bouton 'Aller sur cursor.com'" -ForegroundColor Yellow
        Write-Host "  - Bouton 'Emails Temporaires'" -ForegroundColor Yellow
        Write-Host "  (Ces boutons ne sont pas visibles dans la console)" -ForegroundColor Yellow
        
        # Simuler l'affichage d'une fenêtre de résumé
        $resumeMessage = @"
Résumé des actions :

$(if($MacSuccess){"✅"}else{"❌"}) MAC Address: $(if($MacSuccess){"Modifiée avec succès"}else{"Échec"})
$(if($MachineGuidSuccess){"✅"}else{"❌"}) MachineGuid: $(if($MachineGuidSuccess){"Réinitialisé avec succès"}else{"Échec"})
$(if($StorageSuccess){"✅"}else{"❌"}) Storage: $(if($StorageSuccess){"Fichier supprimé avec succès"}else{"Échec - $StorageMessage"})

Veuillez procéder à votre nouvelle inscription sur cursor.com

[Dans cette fenêtre se trouvent également deux boutons :
 - "Aller sur cursor.com"
 - "Emails Temporaires"]
"@
        
        [System.Windows.Forms.MessageBox]::Show(
            $resumeMessage,
            "Résumé",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Information
        )
    }
}

# Création d'une interface de test
$form = New-Object System.Windows.Forms.Form
$form.Text = "Test de Step6_ExecuteAll"
$form.Size = New-Object System.Drawing.Size(400, 300)
$form.StartPosition = "CenterScreen"

# Créer les éléments de l'interface
$button = New-Object System.Windows.Forms.Button
$button.Text = "Tester Execute-All"
$button.Location = New-Object System.Drawing.Point(20, 20)
$button.Size = New-Object System.Drawing.Size(150, 30)
$form.Controls.Add($button)

$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(20, 60)
$progressBar.Size = New-Object System.Drawing.Size(350, 20)
$progressBar.Value = 0
$form.Controls.Add($progressBar)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Location = New-Object System.Drawing.Point(20, 90)
$statusLabel.Size = New-Object System.Drawing.Size(350, 40)
$statusLabel.Text = "Prêt"
$form.Controls.Add($statusLabel)

# Ajouter des RichTextBox pour simuler l'affichage des informations réseau
$macInfoLabel = New-Object System.Windows.Forms.RichTextBox
$macInfoLabel.Location = New-Object System.Drawing.Point(20, 140)
$macInfoLabel.Size = New-Object System.Drawing.Size(350, 50)
$macInfoLabel.ReadOnly = $true
$macInfoLabel.Text = "Informations MAC"
$form.Controls.Add($macInfoLabel)

$machineGuidLabel = New-Object System.Windows.Forms.RichTextBox
$machineGuidLabel.Location = New-Object System.Drawing.Point(20, 200)
$machineGuidLabel.Size = New-Object System.Drawing.Size(350, 50)
$machineGuidLabel.ReadOnly = $true
$machineGuidLabel.Text = "Informations MachineGuid"
$form.Controls.Add($machineGuidLabel)

# Gestionnaire d'événements pour le bouton de test
$button.Add_Click({
    $button.Enabled = $false
    $progressBar.Value = 0
    $statusLabel.Text = "Initialisation..."
    
    try {
        # Test 1: Exécution des actions
        Write-Host "=== Test 1: Exécution de toutes les actions ===" -ForegroundColor Magenta
        $results = Execute-AllActions -MacAddress (New-MacAddress) -ShouldResetMachineGuid $true -ShouldDeleteStorageFile $true -ProgressControl $progressBar -StatusLabel $statusLabel
        
        # Test 2: Affichage du résumé des actions
        Write-Host "=== Test 2: Affichage du résumé ===" -ForegroundColor Magenta
        
        $failedActions = @()
        if (-not $results.Results.MAC) { $failedActions += "Modification MAC" }
        if (-not $results.Results.Storage) { $failedActions += "Suppression storage.json" }
        if (-not $results.Results.MachineGuid) { $failedActions += "Réinitialisation MachineGuid" }
        
        if ($failedActions.Count -eq 0) {
            $statusLabel.Text = "Terminé avec succès"
            
            # Utiliser notre fonction Show-ActionSummary pour afficher le résumé
            Show-ActionSummary -MacSuccess $results.Results.MAC -StorageSuccess $results.Results.Storage -MachineGuidSuccess $results.Results.MachineGuid -StorageMessage $results.StorageMessage
        }
        else {
            $statusLabel.Text = "Terminé avec des erreurs"
            
            # Résumé avec indication de ce qui a échoué
            $failedMessage = "Certaines actions ont échoué:`n- $($failedActions -join "`n- ")"
            
            [System.Windows.Forms.MessageBox]::Show(
                $failedMessage,
                "Erreur",
                [System.Windows.Forms.MessageBoxButtons]::OK,
                [System.Windows.Forms.MessageBoxIcon]::Error
            )
        }
        
        # Test 3: Test du timeout et de la mise à jour des informations réseau
        Write-Host "=== Test 3: Test du timeout et Update-NetworkInfo ===" -ForegroundColor Magenta
        Write-Host "Attente de la reconnexion réseau (2 secondes)..." -ForegroundColor Yellow
        # Réduire le timeout à 2 secondes pour le test
        Start-Sleep -Seconds 2
        
        Write-Host "Mise à jour des informations réseau..." -ForegroundColor Cyan
        Update-NetworkInfo -infoLabel $macInfoLabel -guidLabel $machineGuidLabel
    }
    catch {
        $statusLabel.Text = "Erreur lors du test"
        [System.Windows.Forms.MessageBox]::Show(
            "Une erreur est survenue: $_",
            "Erreur",
            [System.Windows.Forms.MessageBoxButtons]::OK,
            [System.Windows.Forms.MessageBoxIcon]::Error
        )
    }
    finally {
        $button.Enabled = $true
        $progressBar.Value = 0
        $statusLabel.Text = "Prêt"
    }
})

# Affichage du formulaire
Write-Host "==============================================" -ForegroundColor Cyan
Write-Host "Démarrage du test de Step6_ExecuteAll" -ForegroundColor Cyan
Write-Host "==============================================" -ForegroundColor Cyan
$form.ShowDialog() 