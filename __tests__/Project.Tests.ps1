# =================================================================
# Fichier     : Project.Tests.ps1
# Role        : Tests d'intégration pour vérifier le démarrage du projet
# =================================================================

Describe "Tests de base du projet" {
    BeforeAll {
        $script:projectPath = $PSScriptRoot
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
            $startContent | Should -Match "function\s+global:Initialize-MainWindow"
            $startContent | Should -Match "function\s+global:Show-MainInterface"
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
        . $PSScriptRoot\start.ps1
        . "$PSScriptRoot\Step3_Interface.ps1"

        # Activation du mode test
        $env:TEST_MODE = $true
    }

    AfterAll {
        # Désactivation du mode test
        $env:TEST_MODE = $false
    }

    Context "Tests des fonctions de base" {
        It "Write-ConsoleLog doit fonctionner" {
            $message = "Test message"
            $result = Write-ConsoleLog -Message $message -Color "Green"
            $result | Should -Be $message
        }

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
    }
} 