# =================================================================
# Fichier     : Step6_ExecuteAll.Tests.ps1
# Role        : Tests unitaires pour Step6_ExecuteAll.ps1
# Connection  : Teste les fonctions de Step6_ExecuteAll.ps1
# =================================================================

Describe "Tests d'exécution de toutes les actions" {
    BeforeAll {
        # Charger le script à tester
        . $PSScriptRoot\Step6_ExecuteAll.ps1
        
        # Créer le fichier storage.json pour les tests
        $testPath = Get-CursorStoragePath
        $testDir = Split-Path -Parent $testPath
        
        if (-not (Test-Path $testDir)) {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
        }
        
        @{
            "test" = "contenu"
        } | ConvertTo-Json | Out-File -FilePath $testPath -Encoding UTF8
    }

    Context "Fonctions importées" {
        It "Doit avoir accès aux fonctions MAC" {
            Get-Command Get-NetworkAdapters | Should -Not -BeNullOrEmpty
            Get-Command New-MacAddress | Should -Not -BeNullOrEmpty
            Get-Command Set-MacAddress | Should -Not -BeNullOrEmpty
            Get-Command Test-MacAddress | Should -Not -BeNullOrEmpty
        }

        It "Doit avoir accès aux fonctions Storage" {
            Get-Command Get-CursorStoragePath | Should -Not -BeNullOrEmpty
            Get-Command Remove-CursorStorage | Should -Not -BeNullOrEmpty
        }

        It "Doit avoir accès à la fonction principale" {
            Get-Command Start-AllActions | Should -Not -BeNullOrEmpty
        }
    }

    Context "Exécution des actions" {
        BeforeEach {
            # Recréer le fichier storage.json avant chaque test
            $testPath = Get-CursorStoragePath
            if (-not (Test-Path $testPath)) {
                @{
                    "test" = "contenu"
                } | ConvertTo-Json | Out-File -FilePath $testPath -Encoding UTF8
            }
        }

        It "Doit retourner un objet de résultats" {
            $results = Start-AllActions
            $results | Should -Not -BeNullOrEmpty
            $results.MAC | Should -BeIn @($true, $false)
            $results.Storage | Should -BeIn @($true, $false)
            $results.Browser | Should -BeIn @($true, $false)
        }

        It "Doit pouvoir supprimer le fichier storage.json" {
            $testPath = Get-CursorStoragePath
            Test-Path $testPath | Should -Be $true -Because "Le fichier doit exister avant le test"
            
            $results = Start-AllActions
            $results.Storage | Should -Be $true -Because "La suppression devrait réussir"
            
            Test-Path $testPath | Should -Be $false -Because "Le fichier devrait être supprimé"
        }

        It "Doit gérer le cas où le fichier n'existe pas" {
            $testPath = Get-CursorStoragePath
            if (Test-Path $testPath) {
                Remove-Item -Path $testPath -Force
            }
            
            $results = Start-AllActions
            $results.Storage | Should -Be $false -Because "Le fichier n'existe pas"
        }
    }

    AfterAll {
        # Nettoyage : supprimer le fichier de test s'il existe encore
        $testPath = Get-CursorStoragePath
        if (Test-Path $testPath) {
            Remove-Item -Path $testPath -Force
        }
    }
} 