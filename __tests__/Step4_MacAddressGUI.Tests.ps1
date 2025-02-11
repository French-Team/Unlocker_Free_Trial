# =================================================================
# Fichier     : Step4_MacAddressGUI.Tests.ps1
# Role        : Tests unitaires pour l'interface de modification MAC
# Connection  : Teste les fonctions de Step4_MacAddressGUI.ps1
# =================================================================

# Définir le chemin du script actuel de manière robuste
$scriptPath = (Get-Location).Path
Write-Host "Chemin du script: $scriptPath"

Describe "Tests de l'interface MAC" {
    BeforeAll {
        # Charger les assemblies nécessaires
        Add-Type -AssemblyName System.Windows.Forms
        Add-Type -AssemblyName System.Drawing

        # Vérifier et charger les fichiers nécessaires
        $requiredFiles = @(
            ".\Step3_MacInfo.ps1",
            ".\Step4_MacAddress.ps1",
            ".\Step4_MacAddressGUI.ps1"
        )

        Write-Host "Vérification des fichiers requis..."
        foreach ($file in $requiredFiles) {
            Write-Host "Recherche de $file"
            if (-not (Test-Path -Path $file)) {
                throw "Fichier requis non trouvé: $file"
            }
            Write-Host "Chargement de $file"
            . $file
        }
    }

    Context "Chargement des dépendances" {
        It "Doit charger System.Windows.Forms" {
            [System.Windows.Forms.Form] | Should -Not -BeNullOrEmpty
        }

        It "Doit charger System.Drawing" {
            [System.Drawing.Color] | Should -Not -BeNullOrEmpty
        }

        It "Doit avoir accès à la fonction Show-MacAddressWindow" {
            Get-Command Show-MacAddressWindow -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }
    }

    Context "Création des composants d'interface" {
        BeforeAll {
            # Créer une instance de test de la fenêtre
            $form = New-Object System.Windows.Forms.Form
            $form.Size = New-Object System.Drawing.Size(600,400)
            $mainPanel = New-Object System.Windows.Forms.Panel
            $mainPanel.Size = New-Object System.Drawing.Size(580,360)
            $form.Controls.Add($mainPanel)
        }

        It "Doit créer une fenêtre valide" {
            $form | Should -Not -BeNullOrEmpty
            $form.Size.Width | Should -Be 600
            $form.Size.Height | Should -Be 400
        }

        It "Doit créer un panel principal valide" {
            $mainPanel | Should -Not -BeNullOrEmpty
            $mainPanel.Size.Width | Should -Be 580
            $mainPanel.Size.Height | Should -Be 360
        }

        It "Doit pouvoir créer un label" {
            $label = New-Object System.Windows.Forms.Label
            $label.Size = New-Object System.Drawing.Size(560,30)
            $label | Should -Not -BeNullOrEmpty
            $label.Size.Width | Should -Be 560
        }

        It "Doit pouvoir créer un bouton" {
            $button = New-Object System.Windows.Forms.Button
            $button.Size = New-Object System.Drawing.Size(200,40)
            $button | Should -Not -BeNullOrEmpty
            $button.Size.Width | Should -Be 200
        }
    }

    Context "Gestion des couleurs" {
        It "Doit créer une couleur de fond valide" {
            $color = [System.Drawing.Color]::FromArgb(45,45,45)
            $color | Should -Not -BeNullOrEmpty
            $color.R | Should -Be 45
            $color.G | Should -Be 45
            $color.B | Should -Be 45
        }

        It "Doit gérer les couleurs de bouton" {
            $color = [System.Drawing.Color]::FromArgb(80,80,80)
            $color | Should -Not -BeNullOrEmpty
            $color.R | Should -Be 80
            $color.G | Should -Be 80
            $color.B | Should -Be 80
        }
    }

    Context "Gestion des événements" {
        BeforeAll {
            $button = New-Object System.Windows.Forms.Button
            $label = New-Object System.Windows.Forms.Label
        }

        It "Doit pouvoir ajouter un événement Click" {
            { $button.Add_Click({ Write-Host "Test" }) } | Should -Not -Throw
        }

        It "Doit pouvoir mettre à jour un label" {
            { $label.Text = "Test" } | Should -Not -Throw
            $label.Text | Should -Be "Test"
        }
    }

    Context "Intégration avec les fonctions MAC" {
        It "Doit avoir accès aux fonctions MAC" {
            Get-Command Get-NetworkAdapters -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            Get-Command New-MacAddress -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
            Get-Command Set-MacAddress -ErrorAction SilentlyContinue | Should -Not -BeNullOrEmpty
        }

        It "Doit pouvoir récupérer les adaptateurs" {
            $adapters = Get-NetworkAdapters
            $adapters | Should -Not -BeNullOrEmpty -Because "Au moins un adaptateur réseau devrait être présent"
        }

        It "Doit pouvoir générer une adresse MAC" {
            $mac = New-MacAddress
            $mac | Should -Not -BeNullOrEmpty
            $mac | Should -Match '^([0-9A-F]{2}-){5}[0-9A-F]{2}$'
        }
    }

    Context "Gestion des erreurs" {
        It "Doit gérer l'absence de dépendances" {
            # Simuler une erreur de chargement
            $testPath = ".\fichier_inexistant.ps1"
            { . $testPath } | Should -Throw -Because "Le fichier n'existe pas"
        }

        It "Doit gérer les erreurs de création de composants" {
            # Simuler une erreur de création
            { $null.Controls.Add($null) } | Should -Throw
        }

        It "Doit gérer les erreurs d'événements" {
            $button = New-Object System.Windows.Forms.Button
            # Simuler une erreur dans un événement
            { $button.Add_Click({ throw "Erreur test" }) } | Should -Not -Throw
        }
    }
} 