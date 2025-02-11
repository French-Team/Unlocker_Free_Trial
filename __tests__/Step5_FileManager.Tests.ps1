# =================================================================
# Fichier     : Step5_FileManager.Tests.ps1
# Role        : Tests unitaires pour Step5_FileManager.ps1
# Connection  : Teste les fonctions de Step5_FileManager.ps1
# =================================================================

Describe "Tests de gestion des fichiers" {
    BeforeAll {
        # Charger le script à tester
        . $PSScriptRoot\Step5_FileManager.ps1
        
        # Créer le fichier de test
        $testPath = Get-CursorStoragePath
        $testDir = Split-Path -Parent $testPath
        
        if (-not (Test-Path $testDir)) {
            New-Item -ItemType Directory -Path $testDir -Force | Out-Null
        }
        
        # Créer un fichier de test avec du contenu
        @{
            "test" = "contenu"
        } | ConvertTo-Json | Out-File -FilePath $testPath -Encoding UTF8
    }

    Context "Get-CursorStoragePath" {
        It "Doit retourner un chemin valide" {
            $path = Get-CursorStoragePath
            $path | Should -Not -BeNullOrEmpty
            $path | Should -BeOfType [string]
            $path | Should -Match "\\Cursor\\User\\globalStorage\\storage\.json$"
        }

        It "Le chemin doit inclure le nom d'utilisateur actuel" {
            $path = Get-CursorStoragePath
            $path | Should -Match ([regex]::Escape($env:USERNAME))
        }
    }

    Context "Remove-CursorStorage" {
        It "Doit supprimer le fichier avec succès" {
            # Vérifier que le fichier existe
            $testPath = Get-CursorStoragePath
            Test-Path $testPath | Should -Be $true -Because "Le fichier de test doit exister avant la suppression"
            
            # Tenter de supprimer
            $result = Remove-CursorStorage
            $result.Success | Should -Be $true
            $result.Message | Should -Be "Fichier supprimé avec succès"
            
            # Vérifier que le fichier n'existe plus
            Test-Path $testPath | Should -Be $false -Because "Le fichier devrait être supprimé"
        }

        It "Doit gérer le cas où le fichier n'existe pas" {
            # S'assurer que le fichier n'existe pas
            $testPath = Get-CursorStoragePath
            if (Test-Path $testPath) {
                Remove-Item -Path $testPath -Force
            }
            
            # Tenter de supprimer
            $result = Remove-CursorStorage
            $result.Success | Should -Be $false
            $result.Message | Should -Be "Le fichier n'existe pas"
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