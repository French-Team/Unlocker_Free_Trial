# =================================================================
# Fichier     : Step3_NetworkInfoPanel.ps1
# Role        : Gestion du panneau d'informations réseau
# =================================================================

function Get-CurrentMacAddress {
    try {
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        if ($adapter) {
            return $adapter.MacAddress
        }
        return $null
    }
    catch {
        Write-Host "Erreur lors de la récupération de l'adresse MAC : $_" -ForegroundColor Red
        return $null
    }
}

function Get-NetworkInformation {
    try {
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        if ($adapter) {
            $machineGuid = Get-MachineGuid
            return @{
                Success = $true
                Data = @{
                    AdapterName = Format-NetworkAdapter $adapter
                    MacAddress = $adapter.MacAddress
                    MachineGuid = $machineGuid
                }
            }
        } else {
            return @{
                Success = $false
                Message = "NoNetwork"
            }
        }
    }
    catch {
        Write-ConsoleLog "Erreur lors de la récupération des informations réseau : $_" -Color Red
        return @{
            Success = $false
            Message = "NetworkError"
        }
    }
}

function Update-NetworkInfoPanel {
    param (
        [System.Windows.Forms.Label]$infoLabel,
        [hashtable]$translations,
        [string]$currentLanguage
    )

    try {
        $networkInfo = Get-NetworkInformation

        if ($networkInfo.Success) {
            $infoText = @"
$($translations[$currentLanguage]['NetworkCard']): $($networkInfo.Data.AdapterName)
$($translations[$currentLanguage]['MacAddress']): $($networkInfo.Data.MacAddress)
MachineGuid: $($networkInfo.Data.MachineGuid)
"@
            $infoLabel.Text = $infoText
            $infoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
            $infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleLeft
        }
        else {
            $infoLabel.Text = $translations[$currentLanguage][$networkInfo.Message]
            $infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
        }
    }
    catch {
        Write-Host "Erreur lors de la mise à jour du panneau : $_" -ForegroundColor Red
        $infoLabel.Text = $translations[$currentLanguage]["NetworkError"]
        $infoLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
    }
}

# Fonction de test du panneau
function Test-NetworkInfoPanel {
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    # Charger les scripts nécessaires
    try {
        . "$PSScriptRoot\Step4_MacAddress.ps1"
        . "$PSScriptRoot\Step7_RegistryManager.ps1"  # Gestionnaire de registre pour le MachineGuid
    } catch {
        Write-Host "⚠️ Attention : Certains scripts n'ont pas pu être chargés." -ForegroundColor Yellow
        Write-Host "Détails de l'erreur : $_" -ForegroundColor Red
        return
    }

    # Créer les traductions minimales pour le test
    $global:CurrentLanguage = "FR"
    $global:Translations = @{
        "FR" = @{
            "NetworkCard" = "Carte réseau active"
            "MacAddress" = "Adresse MAC"
            "NoNetwork" = "Aucune carte réseau active trouvée"
            "NetworkError" = "Impossible de récupérer les informations réseau"
            "NoMacAddress" = "Impossible de récupérer l'adresse MAC"
        }
    }

    $testForm = New-Object System.Windows.Forms.Form
    $testForm.Text = "Test du panneau d'informations réseau"
    $testForm.Size = New-Object System.Drawing.Size(600,400)
    $testForm.StartPosition = "CenterScreen"
    $testForm.BackColor = [System.Drawing.Color]::FromArgb(30,30,30)

    $infoPanel = New-Object System.Windows.Forms.Panel
    $infoPanel.Location = New-Object System.Drawing.Point(50,50)
    $infoPanel.Size = New-Object System.Drawing.Size(500,120)
    $infoPanel.BackColor = [System.Drawing.Color]::FromArgb(45,45,45)
    $testForm.Controls.Add($infoPanel)

    $infoLabel = New-Object System.Windows.Forms.Label
    $infoLabel.Location = New-Object System.Drawing.Point(10,10)
    $infoLabel.Size = New-Object System.Drawing.Size(480,100)
    $infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $infoLabel.ForeColor = [System.Drawing.Color]::FromArgb(200,200,200)
    $infoPanel.Controls.Add($infoLabel)

    # Bouton de rafraîchissement
    $refreshButton = New-Object System.Windows.Forms.Button
    $refreshButton.Text = "Rafraîchir"
    $refreshButton.Location = New-Object System.Drawing.Point(50,200)
    $refreshButton.Size = New-Object System.Drawing.Size(500,30)
    $refreshButton.BackColor = [System.Drawing.Color]::FromArgb(50,50,50)
    $refreshButton.ForeColor = [System.Drawing.Color]::White
    $refreshButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
    $testForm.Controls.Add($refreshButton)

    # Événement de rafraîchissement
    $refreshButton.Add_Click({
        Update-NetworkInfoPanel -infoLabel $infoLabel -translations $global:Translations -currentLanguage $global:CurrentLanguage
    })

    # Mise à jour initiale
    Update-NetworkInfoPanel -infoLabel $infoLabel -translations $global:Translations -currentLanguage $global:CurrentLanguage

    $testForm.ShowDialog()
}

# Si le script est exécuté directement, lancer le test
function Test-NetworkInfoDisplay {
    param (
        [switch]$Verbose
    )

    Write-Host "🧪 Démarrage des tests d'affichage réseau..." -ForegroundColor Cyan

    # Charger les dépendances nécessaires
    Write-Host "`n📚 Chargement des dépendances..." -ForegroundColor White
    try {
        . "$PSScriptRoot\Step4_MacAddress.ps1"
        . "$PSScriptRoot\Step7_RegistryManager.ps1"
        Write-Host "  ✓ Dépendances chargées avec succès" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ Erreur lors du chargement des dépendances : $_" -ForegroundColor Red
        return @{
            Success = $false
            TestsPassed = 0
            TotalTests = 1
            Error = "Erreur de chargement des dépendances"
        }
    }

    $testsPassed = 0
    $totalTests = 0

    # Test 1 : Vérification de la récupération des informations réseau
    $totalTests++
    Write-Host "`n📋 Test 1 : Récupération des informations réseau" -ForegroundColor White
    $networkInfo = Get-NetworkInformation
    if ($networkInfo.Success) {
        Write-Host "  ✓ Les informations réseau ont été récupérées avec succès" -ForegroundColor Green
        if ($Verbose) {
            Write-Host "    - Carte réseau : $($networkInfo.Data.AdapterName)" -ForegroundColor Gray
            Write-Host "    - Adresse MAC : $($networkInfo.Data.MacAddress)" -ForegroundColor Gray
            Write-Host "    - MachineGuid : $($networkInfo.Data.MachineGuid)" -ForegroundColor Gray
        }
        $testsPassed++
    } else {
        Write-Host "  ❌ Échec de la récupération des informations réseau" -ForegroundColor Red
        Write-Host "    Message d'erreur : $($networkInfo.Message)" -ForegroundColor Red
    }

    # Test 2 : Vérification du format d'affichage
    $totalTests++
    Write-Host "`n📋 Test 2 : Vérification du format d'affichage" -ForegroundColor White
    if ($networkInfo.Success) {
        $adapterName = $networkInfo.Data.AdapterName
        if ($adapterName -match "\[.*\]" -and $adapterName -match "Gbps" -and $adapterName -match "Pilote v") {
            Write-Host "  ✓ Le format d'affichage est correct" -ForegroundColor Green
            Write-Host "    Format : [Nom] - Vitesse - Version du pilote" -ForegroundColor Gray
            $testsPassed++
        } else {
            Write-Host "  ❌ Le format d'affichage n'est pas conforme" -ForegroundColor Red
            Write-Host "    Format attendu : [Nom] - Vitesse - Version du pilote" -ForegroundColor Red
            Write-Host "    Format reçu : $adapterName" -ForegroundColor Red
        }
    } else {
        Write-Host "  ⚠️ Test ignoré car les informations réseau n'ont pas pu être récupérées" -ForegroundColor Yellow
    }

    # Test 3 : Vérification de l'interface graphique
    $totalTests++
    Write-Host "`n📋 Test 3 : Vérification de l'interface graphique" -ForegroundColor White
    try {
        Add-Type -AssemblyName System.Windows.Forms
        $testLabel = New-Object System.Windows.Forms.Label
        $translations = @{
            "FR" = @{
                "NetworkCard" = "Carte réseau active"
                "MacAddress" = "Adresse MAC"
                "NetworkError" = "Erreur réseau"
                "NoNetwork" = "Aucune carte réseau active trouvée"
                "NoMacAddress" = "Impossible de récupérer l'adresse MAC"
            }
        }
        
        Update-NetworkInfoPanel -infoLabel $testLabel -translations $translations -currentLanguage "FR"
        
        if ($testLabel.Text -match "Carte réseau active" -and $testLabel.Text -match "Adresse MAC") {
            Write-Host "  ✓ L'interface graphique affiche correctement les informations" -ForegroundColor Green
            if ($Verbose) {
                Write-Host "    Contenu de l'étiquette :" -ForegroundColor Gray
                Write-Host "    $($testLabel.Text)" -ForegroundColor Gray
            }
            $testsPassed++
        } else {
            Write-Host "  ❌ Problème d'affichage dans l'interface graphique" -ForegroundColor Red
            Write-Host "    Contenu de l'étiquette :" -ForegroundColor Red
            Write-Host "    $($testLabel.Text)" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ❌ Erreur lors du test de l'interface graphique : $_" -ForegroundColor Red
    }

    # Résumé des tests
    Write-Host "`n📊 Résumé des tests" -ForegroundColor Cyan
    Write-Host "  Tests réussis : $testsPassed / $totalTests" -ForegroundColor $(if ($testsPassed -eq $totalTests) { "Green" } else { "Yellow" })
    
    return @{
        Success = $testsPassed -eq $totalTests
        TestsPassed = $testsPassed
        TotalTests = $totalTests
    }
}

if ($MyInvocation.InvocationName -ne '.') {
    # Lancer les tests avec affichage détaillé
    $testResults = Test-NetworkInfoDisplay -Verbose
    
    # Si tous les tests sont passés, lancer l'interface de test
    if ($testResults.Success) {
        Write-Host "`n🚀 Tous les tests sont passés, lancement de l'interface de test..." -ForegroundColor Green
        Test-NetworkInfoPanel
    } else {
        Write-Host "`n⚠️ Certains tests ont échoué. Correction nécessaire avant de lancer l'interface." -ForegroundColor Yellow
    }
} 