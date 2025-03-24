# =================================================================
# Fichier     : Step6_ExecuteAll.ps1 (v2)
# Role        : Orchestrateur pour l'exécution séquentielle des actions
# =================================================================

param(
    [switch]$TestMode
)

Write-Host "Démarrage du script Step6_ExecuteAll.ps1..." -ForegroundColor Cyan

# Charger le gestionnaire de progression
. "$PSScriptRoot\Step8_ProgressBar.ps1"

# En mode test, on simule les droits admin
if (-not $TestMode) {
# Vérification des droits d'administrateur
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️ Ce script nécessite des droits d'administrateur." -ForegroundColor Yellow
    Write-Host "Relancement du script avec les droits d'administrateur..." -ForegroundColor Cyan
    
    try {
        Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        exit
    }
    catch {
            Write-Host "❌ Impossible d'obtenir les droits d'administrateur: $($PSItem.Exception.Message)" -ForegroundColor Red
        exit 1
        }
    }
}

Write-Host "✓ Droits d'administrateur confirmés" -ForegroundColor Green

# Fonction pour exécuter un script et gérer son résultat
function Invoke-ScriptWithProgress {
    param (
        [string]$ScriptPath,
        [string]$ScriptName,
        [System.Windows.Forms.ProgressBar]$ProgressControl,
        [System.Windows.Forms.Label]$StatusLabel
    )
    
    if (-not (Test-Path $ScriptPath)) {
        Write-Host "❌ Script $ScriptName non trouvé: $ScriptPath" -ForegroundColor Red
        return $false
    }
    
    try {
        Write-Host "`n=== Exécution de $ScriptName ===" -ForegroundColor Yellow
        
        if ($TestMode) {
            # En mode test, on simule le succès
            Write-Host "Mode Test: Simulation de l'exécution de $ScriptName" -ForegroundColor Cyan
            Start-Sleep -Seconds 1
            $success = $true
        } else {
            # Charger le script
            . $ScriptPath
            
            # Exécuter la logique spécifique selon le script
            switch ($ScriptName) {
                "Modification MAC" {
                    # Trouver le premier adaptateur actif
                    Update-StepProgress -StepName "MacAddress" -Progress 10 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                    $adapter = Get-NetworkAdapters | Select-Object -First 1
                    
                    if ($adapter) {
                        # Générer une nouvelle adresse MAC
                        Update-StepProgress -StepName "MacAddress" -Progress 20 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                        $newMac = New-MacAddress
                        
                        if ($newMac) {
                            # Modifier l'adresse MAC
                            Update-StepProgress -StepName "MacAddress" -Progress 30 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                            $success = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                            Update-StepProgress -StepName "MacAddress" -Progress 40 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                        } else {
                            $success = $false
                        }
                    } else {
                        Write-Host "❌ Aucun adaptateur réseau actif trouvé" -ForegroundColor Red
                        $success = $false
                    }
                }
                "Suppression Storage" {
                    # Charger le script et appeler la fonction Remove-CursorStorage
                    Update-StepProgress -StepName "Storage" -Progress 40 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                    $result = Remove-CursorStorage
                    
                    # Si le fichier n'existe pas, c'est aussi un succès
                    $success = $result.Success -or $result.Message -eq "Le fichier n'existe pas"
                    
                    if ($success) {
                        Update-StepProgress -StepName "Storage" -Progress 70 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                        Write-Host "  ✓ $($result.Message)" -ForegroundColor Green
                        
                        # On a déjà affiché le message exact, pas besoin d'afficher un message générique pour ce cas
                        return $success
                            } else {
                        Write-Host "  ❌ $($result.Message)" -ForegroundColor Red
                    }
                }
                "Réinitialisation MachineGuid" {
                    # Charger le script et appeler la fonction Reset-MachineGuid
                    Update-StepProgress -StepName "MachineGuid" -Progress 70 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                    $result = Reset-MachineGuid
                    
                    if ($result.Success) {
                        Update-StepProgress -StepName "MachineGuid" -Progress 100 -ProgressBar $ProgressControl -StatusLabel $StatusLabel
                        $success = $true
                    } else {
                        Write-Host "  ❌ $($result.Message)" -ForegroundColor Red
                        $success = $false
                    }
                }
                default {
                    # Pour les autres scripts, exécuter normalement
                    $output = & $ScriptPath
                    $success = $LASTEXITCODE -eq 0
                }
            }
        }
        
        if ($success) {
            Write-Host "✓ $ScriptName exécuté avec succès" -ForegroundColor Green
        } else {
            Write-Host "❌ Échec de l'exécution de $ScriptName" -ForegroundColor Red
        }
        
        return $success
    }
    catch {
        Write-Host "❌ Erreur lors de l'exécution de $ScriptName : $($PSItem.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# Fonction pour créer l'interface graphique
function Initialize-ExecuteAllButton {
    param (
        [System.Windows.Forms.Form]$Form
    )
    
    Write-Host "Initialisation de l'interface graphique..." -ForegroundColor Cyan
    
    # Configuration de la fenêtre principale
    $Form.Text = "Unlocker Free Trial"
    $Form.Size = New-Object System.Drawing.Size(500, 200)
    $Form.StartPosition = "CenterScreen"
    $Form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
    $Form.ForeColor = [System.Drawing.Color]::White
    $Form.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
    $Form.MaximizeBox = $false
    $Form.TopMost = $true
    
    # Création du bouton
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Exécuter toutes les actions"
    $button.Location = New-Object System.Drawing.Point(150, 20)
    $button.Width = 200
    $button.Height = 40
    $button.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $button.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
    $button.ForeColor = [System.Drawing.Color]::White
    $button.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $button.FlatAppearance.BorderSize = 1
    $button.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
    $button.Cursor = [System.Windows.Forms.Cursors]::Hand
    
    # Création de la barre de progression
    $script:progressBar = New-Object System.Windows.Forms.ProgressBar
    $script:progressBar.Location = New-Object System.Drawing.Point(50, 80)
    $script:progressBar.Size = New-Object System.Drawing.Size(400, 20)
    $script:progressBar.Style = 'Continuous'
    $script:progressBar.Value = 0
    $Form.Controls.Add($script:progressBar)
    
    # Création du label de statut
    $script:statusLabel = New-Object System.Windows.Forms.Label
    $script:statusLabel.Location = New-Object System.Drawing.Point(50, 110)
    $script:statusLabel.Size = New-Object System.Drawing.Size(400, 40)
    $script:statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9, [System.Drawing.FontStyle]::Regular)
    $script:statusLabel.ForeColor = [System.Drawing.Color]::White
    $script:statusLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    $script:statusLabel.Text = "Prêt"
    $Form.Controls.Add($script:statusLabel)
    
    # En mode test, on clique automatiquement sur le bouton
    if ($TestMode) {
        $Form.Add_Shown({
            Write-Host "Mode Test: Clic automatique sur le bouton" -ForegroundColor Cyan
            $button.PerformClick()
        })
    }
    
    # Gestionnaire d'événements du bouton
    $button.Add_Click({
        Write-Host "Démarrage des actions..." -ForegroundColor Green
        $button.Enabled = $false
        
        # Réinitialiser la barre de progression
        Reset-ProgressBar -ProgressBar $script:progressBar -StatusLabel $script:statusLabel
        
        # 1. Exécuter Step4_MacAddress.ps1
        $macScript = Join-Path $PSScriptRoot "Step4_MacAddress.ps1"
        Write-Host "Exécution de $macScript..." -ForegroundColor Cyan
        $macSuccess = Invoke-ScriptWithProgress -ScriptPath $macScript -ScriptName "Modification MAC" -ProgressControl $script:progressBar -StatusLabel $script:statusLabel
        if (-not $macSuccess) {
            Write-Host "Échec de la modification MAC, arrêt des actions" -ForegroundColor Red
            if (-not $TestMode) { $button.Enabled = $true }
            if ($TestMode) { $Form.Close() }
            return
        }
        
        # 2. Exécuter Step5_FileManager.ps1
        $storageScript = Join-Path $PSScriptRoot "Step5_FileManager.ps1"
        Write-Host "Exécution de $storageScript..." -ForegroundColor Cyan
        $storageSuccess = Invoke-ScriptWithProgress -ScriptPath $storageScript -ScriptName "Suppression Storage" -ProgressControl $script:progressBar -StatusLabel $script:statusLabel
        if (-not $storageSuccess) {
            Write-Host "Échec de la suppression du storage, arrêt des actions" -ForegroundColor Red
            if (-not $TestMode) { $button.Enabled = $true }
            if ($TestMode) { $Form.Close() }
            return
        }
        
        # 3. Exécuter Step7_RegistryManager.ps1
        $guidScript = Join-Path $PSScriptRoot "Step7_RegistryManager.ps1"
        Write-Host "Exécution de $guidScript..." -ForegroundColor Cyan
        $guidSuccess = Invoke-ScriptWithProgress -ScriptPath $guidScript -ScriptName "Réinitialisation MachineGuid" -ProgressControl $script:progressBar -StatusLabel $script:statusLabel
        if (-not $guidSuccess) {
            Write-Host "Échec de la réinitialisation MachineGuid, arrêt des actions" -ForegroundColor Red
            if (-not $TestMode) { $button.Enabled = $true }
            if ($TestMode) { $Form.Close() }
            return
        }
        
        Write-Host "Toutes les actions ont réussi, affichage du résumé..." -ForegroundColor Green
        
        # En mode test, on ferme directement
        if ($TestMode) {
            Write-Host "Mode Test: Test terminé avec succès" -ForegroundColor Green
            $Form.Close()
            return
        }
        
        # Afficher le résumé
        $summaryForm = New-Object System.Windows.Forms.Form
        $summaryForm.Text = "Résumé"
        $summaryForm.Size = New-Object System.Drawing.Size(450, 350)
        $summaryForm.StartPosition = "CenterScreen"
        $summaryForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
        $summaryForm.ForeColor = [System.Drawing.Color]::White
        $summaryForm.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedSingle
        $summaryForm.MaximizeBox = $false
        $summaryForm.TopMost = $true
        
        # Récupérer le message exact du résultat de Remove-CursorStorage
        . $storageScript
        $storageResult = Remove-CursorStorage
        $storageMessage = $storageResult.Message

        $summaryLabel = New-Object System.Windows.Forms.Label
        $summaryLabel.Text = @"
Résumé des actions :

✅ MAC Address: Modifiée avec succès
✅ MachineGuid: Réinitialisé avec succès
✅ Storage: $storageMessage

Veuillez procéder à votre nouvelle inscription sur cursor.com
"@
        $summaryLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $summaryLabel.ForeColor = [System.Drawing.Color]::White
        $summaryLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        $summaryLabel.Size = New-Object System.Drawing.Size(430, 160)
        $summaryLabel.Location = New-Object System.Drawing.Point(10, 20)
        $summaryForm.Controls.Add($summaryLabel)
        
        # Bouton Cursor
        $btnCursor = New-Object System.Windows.Forms.Button
        $btnCursor.Text = "Aller sur cursor.com"
        $btnCursor.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $btnCursor.Size = New-Object System.Drawing.Size(200, 35)
        $btnCursor.Location = New-Object System.Drawing.Point(125, 190)
        $btnCursor.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
        $btnCursor.ForeColor = [System.Drawing.Color]::White
        $btnCursor.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnCursor.FlatAppearance.BorderSize = 1
        $btnCursor.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
        $btnCursor.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnCursor.Add_Click({
            Start-Process "https://cursor.com"
        })
        $summaryForm.Controls.Add($btnCursor)
        
        # Bouton Emails Temporaires
        $btnExtension = New-Object System.Windows.Forms.Button
        $btnExtension.Text = "Emails Temporaires"
        $btnExtension.Font = New-Object System.Drawing.Font("Segoe UI", 10)
        $btnExtension.Size = New-Object System.Drawing.Size(200, 35)
        $btnExtension.Location = New-Object System.Drawing.Point(125, 240)
        $btnExtension.BackColor = [System.Drawing.Color]::FromArgb(255,140,0)
        $btnExtension.ForeColor = [System.Drawing.Color]::White
        $btnExtension.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
        $btnExtension.FlatAppearance.BorderSize = 1
        $btnExtension.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(255,140,0)
        $btnExtension.Cursor = [System.Windows.Forms.Cursors]::Hand
        $btnExtension.Add_Click({
            Start-Process "https://chromewebstore.google.com/detail/temporary-email-emailonde/mkpcaklladfpajiaikehdinfaabmnajh"
        })
        $summaryForm.Controls.Add($btnExtension)
        
        $summaryForm.ShowDialog()
        $button.Enabled = $true
    })
    
    Write-Host "Interface graphique initialisée avec succès" -ForegroundColor Green
    return $button
}

# Si le script est exécuté directement, lancer l'interface
if ($MyInvocation.InvocationName -ne '.') {
    Write-Host "Initialisation de l'interface Windows Forms..." -ForegroundColor Cyan
        Add-Type -AssemblyName System.Windows.Forms
        $form = New-Object System.Windows.Forms.Form
        $button = Initialize-ExecuteAllButton -Form $form
        $form.Controls.Add($button)
    Write-Host "Affichage de la fenêtre principale..." -ForegroundColor Cyan
        $form.ShowDialog()
    Write-Host "Fermeture de l'application" -ForegroundColor Cyan
} 