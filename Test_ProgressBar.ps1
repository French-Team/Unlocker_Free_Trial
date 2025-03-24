# =================================================================
# Fichier     : Test_ProgressBar.ps1
# Role        : Test de la barre de progression
# =================================================================

# Charger le gestionnaire de barre de progression
. "$PSScriptRoot\Step8_ProgressBar.ps1"

# Fonction de test pour vérifier les éléments
function Test-ProgressBarElements {
    param (
        [System.Windows.Forms.Form]$Form,
        [System.Windows.Forms.Panel]$ProgressPanel,
        [System.Windows.Forms.ProgressBar]$ProgressBar,
        [System.Windows.Forms.Label]$MessageLabel,
        [System.Windows.Forms.Label]$PercentLabel
    )
    
    # Vérifier la présence des éléments
    if (-not $ProgressPanel) { throw "Le panneau de progression est manquant" }
    if (-not $ProgressBar) { throw "La barre de progression est manquante" }
    if (-not $MessageLabel) { throw "Le label de message est manquant" }
    if (-not $PercentLabel) { throw "Le label de pourcentage est manquant" }
    
    # Vérifier la visibilité des éléments
    if (-not $ProgressPanel.Visible) { throw "Le panneau de progression n'est pas visible" }
    if (-not $ProgressBar.Visible) { throw "La barre de progression n'est pas visible" }
    if (-not $MessageLabel.Visible) { throw "Le label de message n'est pas visible" }
    if (-not $PercentLabel.Visible) { throw "Le label de pourcentage n'est pas visible" }
    
    # Vérifier que la barre de progression est au premier plan
    if ($ProgressBar.Parent.Controls.GetChildIndex($ProgressBar) -ne 0) {
        throw "La barre de progression n'est pas au premier plan"
    }
    
    # Vérifier que le label de message est au-dessus de la barre
    if ($MessageLabel.Parent.Controls.GetChildIndex($MessageLabel) -lt $ProgressBar.Parent.Controls.GetChildIndex($ProgressBar)) {
        throw "Le label de message n'est pas au-dessus de la barre de progression"
    }
    
    # Vérifier les positions
    if ($ProgressBar.Location.X -ne 0 -or $ProgressBar.Location.Y -ne 0) {
        throw "Position incorrecte de la barre de progression"
    }
    if ($MessageLabel.Location.X -ne 0 -or $MessageLabel.Location.Y -ne 35) {
        throw "Position incorrecte du label de message"
    }
    if ($PercentLabel.Location.X -ne 0 -or $PercentLabel.Location.Y -ne 70) {
        throw "Position incorrecte du label de pourcentage"
    }
    
    # Vérifier les tailles
    if ($ProgressBar.Size.Width -ne 300 -or $ProgressBar.Size.Height -ne 30) {
        throw "Taille incorrecte de la barre de progression"
    }
    if ($MessageLabel.Size.Width -ne 300 -or $MessageLabel.Size.Height -ne 30) {
        throw "Taille incorrecte du label de message"
    }
    if ($PercentLabel.Size.Width -ne 300 -or $PercentLabel.Size.Height -ne 20) {
        throw "Taille incorrecte du label de pourcentage"
    }
    
    # Vérifier les couleurs
    if ($ProgressBar.BackColor.R -ne 20 -or $ProgressBar.BackColor.G -ne 20 -or $ProgressBar.BackColor.B -ne 20) {
        throw "Couleur de fond incorrecte de la barre de progression"
    }
    if ($ProgressBar.ForeColor.R -ne 255 -or $ProgressBar.ForeColor.G -ne 140 -or $ProgressBar.ForeColor.B -ne 0) {
        throw "Couleur de progression incorrecte"
    }
    if ($MessageLabel.BackColor.A -ne 0) {
        throw "Le label de message n'est pas transparent"
    }
    if ($PercentLabel.BackColor.A -ne 0) {
        throw "Le label de pourcentage n'est pas transparent"
    }
    
    # Vérifier les polices
    if ($MessageLabel.Font.Name -ne "Segoe UI" -or $MessageLabel.Font.Size -ne 9) {
        throw "Police incorrecte pour le label de message"
    }
    if ($PercentLabel.Font.Name -ne "Segoe UI" -or $PercentLabel.Font.Size -ne 12 -or -not $PercentLabel.Font.Bold) {
        throw "Police incorrecte pour le label de pourcentage"
    }
    
    Write-Host "✓ Tests des éléments visuels réussis" -ForegroundColor Green
}

# Créer la fenêtre de test
$form = New-Object System.Windows.Forms.Form
$form.Text = "Test de la barre de progression"
$form.Size = New-Object System.Drawing.Size(400, 250)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)
$form.ForeColor = [System.Drawing.Color]::White

# Créer un panneau pour la barre de progression et ses labels
$progressPanel = New-Object System.Windows.Forms.Panel
$progressPanel.Location = New-Object System.Drawing.Point(50, 50)
$progressPanel.Size = New-Object System.Drawing.Size(300, 100)
$progressPanel.BackColor = [System.Drawing.Color]::Transparent
$form.Controls.Add($progressPanel)

# Créer la barre de progression
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Location = New-Object System.Drawing.Point(0, 0)
$progressBar.Size = New-Object System.Drawing.Size(300, 30)
$progressBar.Style = 'Continuous'
$progressBar.Value = 0
$progressBar.BackColor = [System.Drawing.Color]::FromArgb(20,20,20)
$progressBar.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)
$progressBar.Visible = $true
$progressPanel.Controls.Add($progressBar)

# Créer le label de message (sous la barre)
$messageLabel = New-Object System.Windows.Forms.Label
$messageLabel.Location = New-Object System.Drawing.Point(0, 35)
$messageLabel.Size = New-Object System.Drawing.Size(300, 30)
$messageLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$messageLabel.Text = "Prêt"
$messageLabel.ForeColor = [System.Drawing.Color]::White
$messageLabel.BackColor = [System.Drawing.Color]::Transparent
$messageLabel.Visible = $true
$messageLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$messageLabel.Parent = $progressPanel

# Créer le label de pourcentage (sous le message)
$percentLabel = New-Object System.Windows.Forms.Label
$percentLabel.Location = New-Object System.Drawing.Point(0, 70)
$percentLabel.Size = New-Object System.Drawing.Size(300, 20)
$percentLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
$percentLabel.Text = "0%"
$percentLabel.ForeColor = [System.Drawing.Color]::FromArgb(255,140,0)
$percentLabel.BackColor = [System.Drawing.Color]::Transparent
$percentLabel.Visible = $true
$percentLabel.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$percentLabel.Parent = $progressPanel

# Créer le bouton de test
$testButton = New-Object System.Windows.Forms.Button
$testButton.Location = New-Object System.Drawing.Point(150, 150)
$testButton.Size = New-Object System.Drawing.Size(100, 30)
$testButton.Text = "Tester"
$testButton.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
$testButton.ForeColor = [System.Drawing.Color]::White
$testButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
$testButton.FlatAppearance.BorderSize = 1
$testButton.FlatAppearance.BorderColor = [System.Drawing.Color]::FromArgb(60,60,60)
$form.Controls.Add($testButton)

# Gérer le clic sur le bouton
$testButton.Add_Click({
    # Désactiver le bouton pendant le test
    $this.Enabled = $false
    
    try {
        # Tester les éléments visuels
        Test-ProgressBarElements -Form $form -ProgressPanel $progressPanel -ProgressBar $progressBar -MessageLabel $messageLabel -PercentLabel $percentLabel
        
        # Réinitialiser la barre
        Reset-ProgressBar -ProgressBar $progressBar -MessageLabel $messageLabel -PercentLabel $percentLabel
        
        # Vérifier la réinitialisation
        if ($progressBar.Value -ne 0) { throw "La barre n'a pas été réinitialisée à 0" }
        if ($messageLabel.Text -ne "Prêt") { throw "Le message n'a pas été réinitialisé" }
        if ($percentLabel.Text -ne "0%") { throw "Le pourcentage n'a pas été réinitialisé" }
        
        # Tester chaque étape
        foreach ($step in $global:ProgressSteps.GetEnumerator()) {
            Write-Host "Test de l'étape: $($step.Key)" -ForegroundColor Cyan
            
            # Mettre à jour la progression
            Update-StepProgress -Step $step.Key -ProgressBar $progressBar -MessageLabel $messageLabel -PercentLabel $percentLabel
            
            # Vérifier la progression
            if ($progressBar.Value -lt $step.Value.Start -or $progressBar.Value -gt $step.Value.End) {
                throw "La progression est hors des limites pour l'étape $($step.Key)"
            }
            if ($messageLabel.Text -ne $step.Value.Message) {
                throw "Le message ne correspond pas pour l'étape $($step.Key)"
            }
            if ($percentLabel.Text -ne "$($progressBar.Value)%") {
                throw "Le pourcentage ne correspond pas pour l'étape $($step.Key)"
            }
        }
        
        # S'assurer que la progression atteint 100%
        Update-ProgressBar -Progress 100 -Message "Terminé" -ProgressBar $progressBar -MessageLabel $messageLabel -PercentLabel $percentLabel
        
        if ($progressBar.Value -ne 100) { throw "La barre n'a pas atteint 100%" }
        if ($messageLabel.Text -ne "Terminé") { throw "Le message final n'est pas correct" }
        if ($percentLabel.Text -ne "100%") { throw "Le pourcentage final n'est pas correct" }
        
        Write-Host "✓ Tests de fonctionnement réussis" -ForegroundColor Green
    }
    catch {
        Write-Host "❌ Erreur pendant le test: $_" -ForegroundColor Red
    }
    finally {
        # Réactiver le bouton
        $this.Enabled = $true
    }
})

# Afficher la fenêtre
$form.ShowDialog() 