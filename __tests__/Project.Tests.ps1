# =================================================================
# Fichier     : Project.Tests.ps1
# Role        : Tests d'intégration pour vérifier le démarrage du projet
# =================================================================

Describe "Tests de base du projet" {
    BeforeAll {
        $script:projectPath = Split-Path $PSScriptRoot -Parent
        $script:startScript = Join-Path $projectPath "start.ps1"
    }

    Context "Vérification des fichiers" {
        It "Doit avoir tous les fichiers requis" {
            $requiredFiles = @(
                "start.ps1",
                "Step1_AdminCheck.ps1",
                "Step2_UTF8.ps1",
                "Step3_MacInfo.ps1",
                "Step3_Interface.ps1",
                "Step4_MacAddress.ps1",
                "Step4_MacAddressGUI.ps1"
            )

            foreach ($file in $requiredFiles) {
                Test-Path (Join-Path $projectPath $file) | Should -Be $true -Because "Le fichier $file est requis"
            }
        }
    }

    Context "Vérification du contenu des scripts" {
        BeforeAll {
            $startContent = Get-Content $startScript -Raw
        }

        It "Le script principal doit contenir les éléments essentiels" {
            $startContent | Should -Match "function\s+global:Write-ConsoleLog"
            $startContent | Should -Match "function\s+global:Get-NetworkAdapters"
            $startContent | Should -Match "function\s+global:Set-MacAddress"
        }

        It "Le script doit gérer les droits administrateur" {
            $startContent | Should -Match "WindowsPrincipal.*WindowsIdentity.*GetCurrent"
            $startContent | Should -Match "IsInRole.*Administrator"
        }
    }
}

Describe "Tests de l'interface graphique" {
    BeforeAll {
        # Initialisation de Windows Forms
        if (-not ('System.Windows.Forms.Form' -as [Type])) {
            Add-Type -AssemblyName System.Windows.Forms
            Add-Type -AssemblyName System.Drawing
            [System.Windows.Forms.Application]::EnableVisualStyles()
            [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)
        }

        # Chargement des scripts nécessaires
        $projectRoot = Split-Path $PSScriptRoot -Parent
        . (Join-Path $projectRoot "start.ps1")
        . (Join-Path $projectRoot "Step3_Interface.ps1")
        . (Join-Path $projectRoot "Step4_MacAddress.ps1")
        . (Join-Path $projectRoot "Step6_ExecuteAll.ps1")

        # Activation du mode test
        $env:TEST_MODE = $true
    }

    AfterAll {
        # Désactivation du mode test
        $env:TEST_MODE = $false
    }

    Context "Tests des fonctions de base" {
        It "Get-NetworkAdapters doit retourner des données" {
            $adapters = Get-NetworkAdapters
            $adapters | Should -Not -BeNullOrEmpty
        }
    }

    Context "Tests de l'interface" {
        It "Initialize-MainWindow doit créer une interface valide" {
            $interface = Initialize-MainWindow
            $interface | Should -Not -BeNullOrEmpty
            $interface.Form | Should -Not -BeNullOrEmpty
            $interface.Form.Size.Width | Should -Be 800
            $interface.Form.Size.Height | Should -Be 600
            $interface.Form.Text | Should -Be "Unlocker - Free Trial"
        }

        It "L'interface doit avoir tous les boutons requis" {
            $interface = Initialize-MainWindow
            $interface | Should -Not -BeNullOrEmpty
            $interface.LanguageButton | Should -Not -BeNullOrEmpty
            $interface.MacAddressButton | Should -Not -BeNullOrEmpty
            $interface.DeleteStorageButton | Should -Not -BeNullOrEmpty
            $interface.ExecuteAllButton | Should -Not -BeNullOrEmpty
            $interface.ExitButton | Should -Not -BeNullOrEmpty
        }

        It "Le bouton de langue doit fonctionner correctement" {
            $interface = Initialize-MainWindow
            $interface.LanguageButton | Should -Not -BeNullOrEmpty
            $interface.LanguageButton.Text | Should -Be "FR/EN"
            
            # Test du changement de langue
            $currentLanguage = $global:CurrentLanguage
            $interface.LanguageButton.PerformClick()
            
            # Vérification du changement de langue
            $global:CurrentLanguage | Should -Not -Be $currentLanguage
            
            # Vérification des textes mis à jour
            if ($global:CurrentLanguage -eq "EN") {
                $interface.Form.Text | Should -Be "Unlocker - Free Trial"
                $interface.MacAddressButton.Text | Should -Be "1. Change MAC Address"
                $interface.DeleteStorageButton.Text | Should -Be "2. Delete storage.json"
                $interface.ExecuteAllButton.Text | Should -Be "3. Execute All Actions"
                $interface.ExitButton.Text | Should -Be "4. Exit"
            } else {
                $interface.Form.Text | Should -Be "Unlocker - Free Trial"
                $interface.MacAddressButton.Text | Should -Be "1. Modifier l'adresse MAC"
                $interface.DeleteStorageButton.Text | Should -Be "2. Supprimer storage.json"
                $interface.ExecuteAllButton.Text | Should -Be "3. Exécuter toutes les actions"
                $interface.ExitButton.Text | Should -Be "4. Quitter"
            }
        }
    }
} 