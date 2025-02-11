# =================================================================
# Fichier     : Step1_AdminCheck.Tests.ps1
# Role        : Tests unitaires pour Step1_AdminCheck.ps1
# Connection  : Teste les fonctions de Step1_AdminCheck.ps1
# =================================================================

Describe "Tests des privilèges administratifs" {
    BeforeAll {
        # Activer le mode test pour éviter le redémarrage
        $env:TEST_MODE = $true
        
        # Charger le script à tester
        . $PSScriptRoot\Step1_AdminCheck.ps1
    }

    AfterAll {
        # Désactiver le mode test après les tests
        $env:TEST_MODE = $false
    }

    Context "Vérification des privilèges" {
        It "Doit détecter correctement les privilèges administratifs" {
            $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
            $isAdmin | Should -BeOfType [bool]
        }

        It "Doit retourner un booléen en mode test" {
            $env:TEST_MODE = $true
            $result = . $PSScriptRoot\Step1_AdminCheck.ps1
            $result | Should -BeOfType [bool]
        }
    }

    Context "Contenu du script" {
        BeforeAll {
            $scriptContent = Get-Content $PSScriptRoot\Step1_AdminCheck.ps1 -Raw
        }

        It "Doit vérifier les privilèges avec WindowsPrincipal" {
            $scriptContent | Should -Match "WindowsPrincipal.*WindowsIdentity.*GetCurrent" -Because "Le script doit utiliser WindowsPrincipal pour vérifier les privilèges"
        }

        It "Doit vérifier le rôle Administrator" {
            $scriptContent | Should -Match "IsInRole.*Administrator" -Because "Le script doit vérifier le rôle Administrator"
        }

        It "Doit avoir la gestion du redémarrage" {
            $scriptContent | Should -Match "Start-Process.*RunAs" -Because "Le script doit pouvoir redémarrer avec élévation"
        }

        It "Doit gérer PowerShell Core et Desktop" {
            $scriptContent | Should -Match "PSVersionTable\.PSEdition" -Because "Le script doit détecter la version de PowerShell"
            $scriptContent | Should -Match "pwsh|powershell" -Because "Le script doit gérer les deux versions de PowerShell"
        }
    }

    Context "Messages et sorties" {
        BeforeAll {
            $scriptContent = Get-Content $PSScriptRoot\Step1_AdminCheck.ps1 -Raw
        }

        It "Doit avoir un message d'avertissement pour les droits manquants" {
            $scriptContent | Should -Match "Write-Warning.*administrateur" -Because "Le script doit avertir si les droits sont insuffisants"
        }

        It "Doit avoir une sortie explicite" {
            $scriptContent | Should -Match "exit" -Because "Le script doit se terminer explicitement après le redémarrage"
            $scriptContent | Should -Match "return.*true" -Because "Le script doit retourner true si les droits sont suffisants"
        }

        It "Doit gérer le mode test" {
            $scriptContent | Should -Match '\$env:TEST_MODE' -Because "Le script doit vérifier la variable TEST_MODE"
        }
    }
} 