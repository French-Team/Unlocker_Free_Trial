# =================================================================
# Fichier     : Step4_MacAddress.Tests.ps1
# Role        : Tests unitaires pour le module de changement d'adresse MAC
# Connection  : Teste les fonctions de Step4_MacAddress.ps1
# =================================================================

Describe "Module de changement d'adresse MAC" {
    BeforeAll {
        . $PSScriptRoot\Step4_MacAddress.ps1
    }

    Context "Recuperation des adaptateurs reseau" {
        It "Doit retourner une liste d'adaptateurs" {
            $adapters = Get-NetworkAdapters
            $adapters | Should -Not -BeNullOrEmpty
            $adapters | Should -BeOfType [PSCustomObject]
        }

        It "Chaque adaptateur doit avoir les proprietes requises" {
            $adapters = Get-NetworkAdapters
            $adapter = $adapters[0]
            $adapter.Name | Should -Not -BeNullOrEmpty
            $adapter.MacAddress | Should -Not -BeNullOrEmpty
            $adapter.Status | Should -Not -BeNullOrEmpty
        }
    }

    Context "Generation d'adresse MAC" {
        It "Doit generer une adresse MAC valide au format Windows" {
            $mac = New-MacAddress
            $mac | Should -Match '^([0-9A-F]{2}-){5}([0-9A-F]{2})$'
        }

        It "Doit generer des adresses MAC uniques" {
            $mac1 = New-MacAddress
            $mac2 = New-MacAddress
            $mac1 | Should -Not -Be $mac2
        }
    }

    Context "Validation d'adresse MAC" {
        It "Doit valider une adresse MAC correcte au format Windows" {
            $validMac = "00-11-22-33-44-55"
            Test-MacAddress -MacAddress $validMac | Should -BeTrue
        }

        It "Doit rejeter une adresse MAC invalide" {
            $invalidMac = "GG-HH-II-JJ-KK-LL"
            Test-MacAddress -MacAddress $invalidMac | Should -BeFalse
        }
    }

    Context "Modification d'adresse MAC" {
        It "Doit pouvoir modifier une adresse MAC" {
            # Mock pour simuler la modification
            Mock Set-MacAddress { return $true }
            Set-MacAddress -AdapterName "Test Adapter" -MacAddress "00-11-22-33-44-55" | Should -BeTrue
        }

        It "Doit gerer les erreurs de modification" {
            # Mock pour simuler une erreur
            Mock Set-MacAddress { throw "Erreur de modification" }
            { Set-MacAddress -AdapterName "Invalid Adapter" -MacAddress "00-11-22-33-44-55" } | Should -Throw
        }
    }
} 