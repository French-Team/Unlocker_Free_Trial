# =================================================================
# Fichier     : Step3_MacInfo.Tests.ps1
# Role        : Tests unitaires pour Step3_MacInfo.ps1
# Connection  : Teste les fonctions de Step3_MacInfo.ps1
# =================================================================

Describe "Tests des fonctions d'information MAC" {
    BeforeAll {
        # Importer le module à tester
        . $PSScriptRoot\Step3_MacInfo.ps1
        Add-Type -AssemblyName System.Windows.Forms
    }

    Context "Get-CurrentMacInfo" {
        It "Doit retourner un objet avec la propriété Success" {
            $result = Get-CurrentMacInfo
            $result.Success | Should -BeIn @($true, $false)
        }

        It "Doit retourner les informations complètes si un adaptateur est trouvé" {
            $result = Get-CurrentMacInfo
            if ($result.Success) {
                $result.AdapterName | Should -Not -BeNullOrEmpty
                $result.Description | Should -Not -BeNullOrEmpty
                $result.MacAddress | Should -Not -BeNullOrEmpty
                $result.Status | Should -Not -BeNullOrEmpty
            }
        }

        It "Doit retourner un message si aucun adaptateur n'est trouvé" {
            # Mock Get-NetAdapter pour simuler aucun adaptateur
            Mock Get-NetAdapter { return $null }
            $result = Get-CurrentMacInfo
            $result.Success | Should -Be $false
            $result.Message | Should -Be "Aucun adaptateur réseau actif trouvé"
        }
    }

    Context "Update-MacInfoLabel" {
        It "Doit mettre à jour le texte du label avec les informations MAC" {
            # Créer un label de test
            $testLabel = New-Object System.Windows.Forms.Label

            # Exécuter la mise à jour
            $result = Update-MacInfoLabel -Label $testLabel

            # Vérifier que le label a été mis à jour
            $testLabel.Text | Should -Not -BeNullOrEmpty
        }

        It "Doit gérer le cas où aucun adaptateur n'est trouvé" {
            # Créer un label de test
            $testLabel = New-Object System.Windows.Forms.Label
            
            # Mock Get-NetAdapter pour simuler aucun adaptateur
            Mock Get-NetAdapter { return $null }
            
            # Exécuter la mise à jour
            $result = Update-MacInfoLabel -Label $testLabel
            
            # Vérifier que le message d'erreur est affiché
            $testLabel.Text | Should -Be "Aucun adaptateur réseau actif trouvé"
        }
    }
} 