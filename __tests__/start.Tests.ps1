# =================================================================
# Fichier     : start.Tests.ps1
# Role        : Tests unitaires pour le script de démarrage
# Connection  : Teste les fonctions de start.ps1
# =================================================================

Describe "Tests du script de démarrage" {
    BeforeAll {
        # Vérifier le contenu du script
        $script:scriptContent = Get-Content $PSScriptRoot\start.ps1 -Raw
    }

    Context "Configuration Windows Forms" {
        It "Doit avoir les imports Windows Forms" {
            $scriptContent | Should -Match "Add-Type.*System\.Windows\.Forms"
            $scriptContent | Should -Match "Add-Type.*System\.Drawing"
        }

        It "Doit avoir la configuration visuelle" {
            $scriptContent | Should -Match "EnableVisualStyles"
            $scriptContent | Should -Match "SetCompatibleTextRenderingDefault"
        }
    }

    Context "Fonction Write-ConsoleLog" {
        BeforeAll {
            $pattern = "(?ms)function.*?Write-ConsoleLog.*?\{(.*?)\}"
            if ($scriptContent -match $pattern) {
                $script:functionContent = $matches[0]
            }
        }

        It "Doit avoir la déclaration de la fonction" {
            $scriptContent | Should -Match "function\s+global:Write-ConsoleLog" -Because "La fonction Write-ConsoleLog doit être déclarée"
        }

        It "Doit avoir les paramètres requis" {
            $scriptContent | Should -Match '\[string\]\s*\$Message' -Because "Le paramètre Message doit être de type string"
            $scriptContent | Should -Match '\[string\]\s*\$Color' -Because "Le paramètre Color doit être de type string"
        }

        It "Doit avoir la validation des couleurs" {
            $scriptContent | Should -Match "ValidateSet" -Because "Les couleurs doivent être validées"
        }

        It "Doit utiliser Write-Host" {
            $scriptContent | Should -Match "Write-Host.*-ForegroundColor" -Because "Write-Host doit être utilisé avec -ForegroundColor"
        }
    }

    Context "Vérification des chemins" {
        It "Doit définir le chemin du script" {
            $scriptContent | Should -Match '\$script:scriptPath = Split-Path -Parent \$MyInvocation\.MyCommand\.Path'
        }

        It "Doit avoir les fichiers requis" {
            $requiredFiles = @(
                "Step1_AdminCheck.ps1",
                "Step2_UTF8.ps1",
                "Step3_MacInfo.ps1",
                "Step3_Interface.ps1"
            )

            foreach ($file in $requiredFiles) {
                Test-Path (Join-Path $PSScriptRoot $file) | Should -Be $true
            }
        }
    }

    Context "Gestion des erreurs" {
        It "Doit avoir ErrorActionPreference défini sur Stop" {
            $scriptContent | Should -Match '\$ErrorActionPreference = "Stop"'
        }

        It "Doit gérer les erreurs avec try-catch" {
            $scriptContent | Should -Match "try\s*{"
            $scriptContent | Should -Match "catch\s*{"
        }
    }
} 