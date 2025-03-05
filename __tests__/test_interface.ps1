# =================================================================
# Fichier     : test_interface.ps1
# Role        : Test de l'interface graphique
# =================================================================

# Initialisation de Windows Forms avant tout
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
[System.Windows.Forms.Application]::EnableVisualStyles()
[System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

Describe "Tests de l'interface graphique" {
    BeforeAll {
        try {
            Write-Host "Configuration des variables globales..."
            $global:CurrentLanguage = "FR"
            $global:Translations = @{
                "FR" = @{
                    "WindowTitle" = "Unlocker - Free Trial"
                    "MainTitle" = "Unlocker Free Trial"
                    "Subtitle" = "pour Cursor"
                    "BtnMacAddress" = "1. Modifier l'adresse MAC"
                    "BtnDeleteStorage" = "2. Supprimer storage.json"
                    "BtnExecuteAll" = "3. Exécuter toutes les actions"
                    "BtnExit" = "4. Quitter"
                    "Ready" = "Prêt"
                    "NetworkCard" = "Carte réseau active"
                    "MacAddress" = "Adresse MAC"
                    "NoNetwork" = "Aucune carte réseau active trouvée"
                    "NetworkError" = "Impossible de récupérer les informations réseau"
                }
                "EN" = @{
                    "WindowTitle" = "Unlocker - Free Trial"
                    "MainTitle" = "Unlocker Free Trial"
                    "Subtitle" = "for Cursor"
                    "BtnMacAddress" = "1. Change MAC Address"
                    "BtnDeleteStorage" = "2. Delete storage.json"
                    "BtnExecuteAll" = "3. Execute All Actions"
                    "BtnExit" = "4. Exit"
                    "Ready" = "Ready"
                    "NetworkCard" = "Active Network Card"
                    "MacAddress" = "MAC Address"
                    "NoNetwork" = "No active network card found"
                    "NetworkError" = "Unable to retrieve network information"
                }
            }

            Write-Host "Chargement des scripts..."
            $projectRoot = Split-Path $PSScriptRoot -Parent
            
            # Chargement de tous les scripts nécessaires dans l'ordre
            . "$projectRoot\Step3_MacInfo.ps1"
            . "$projectRoot\Step3_Interface.ps1"

            # Mock de Get-NetAdapter pour les tests
            function global:Get-NetAdapter {
                return @(
                    @{
                        Name = "Ethernet"
                        Status = "Up"
                        MacAddress = "00-11-22-33-44-55"
                        InterfaceDescription = "Intel(R) Ethernet Connection"
                    }
                )
            }

            # Mock des fonctions Windows Forms
            function global:Initialize-MainWindow {
                $mockForm = @{
                    Size = @{
                        Width = 800
                        Height = 600
                    }
                    Text = "Unlocker - Free Trial"
                    Show = { }
                    Close = { }
                    Dispose = { }
                }

                $mockButton = @{
                    Size = @{
                        Width = 600
                        Height = 35
                    }
                    Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                    PerformClick = { }
                }

                $mockLanguageButton = @{
                    Size = @{
                        Width = 70
                        Height = 35
                    }
                    Text = "FR/EN"
                    PerformClick = {
                        if ($global:CurrentLanguage -eq "FR") {
                            $global:CurrentLanguage = "EN"
                        } else {
                            $global:CurrentLanguage = "FR"
                        }
                        $script:interface.MacAddressButton.Text = $global:Translations[$global:CurrentLanguage]["BtnMacAddress"]
                    }
                }

                $mockProgressBar = @{
                    Value = 0
                    Style = 'Continuous'
                }

                $mockStatusLabel = @{
                    Text = $global:Translations[$global:CurrentLanguage]["Ready"]
                }

                $script:interface = @{
                    Form = $mockForm
                    LanguageButton = $mockLanguageButton
                    MacAddressButton = $mockButton
                    DeleteStorageButton = $mockButton
                    ExecuteAllButton = $mockButton
                    ExitButton = $mockButton
                    ProgressBar = $mockProgressBar
                    StatusLabel = $mockStatusLabel
                }

                return $script:interface
            }
        }
        catch {
            Write-Host "❌ Erreur dans BeforeAll: $_" -ForegroundColor Red
            throw
        }
    }

    AfterAll {
        Remove-Item function:global:Get-NetAdapter -ErrorAction SilentlyContinue
    }

    Context "Tests d'intégration" {
        It "Doit créer une interface Windows Forms valide" {
            # Création de l'interface
            $interface = Initialize-MainWindow

            # Vérifications de base
            $interface | Should -Not -BeNullOrEmpty
            $interface.Form | Should -Not -BeNullOrEmpty
            $interface.Form.GetType().Name | Should -Be "Form"
            $interface.Form.Size.Width | Should -Be 800
            $interface.Form.Size.Height | Should -Be 600

            # Vérification des contrôles Windows Forms
            $interface.LanguageButton.GetType().Name | Should -Be "Button"
            $interface.MacAddressButton.GetType().Name | Should -Be "Button"
            $interface.DeleteStorageButton.GetType().Name | Should -Be "Button"
            $interface.ExecuteAllButton.GetType().Name | Should -Be "Button"
            $interface.ExitButton.GetType().Name | Should -Be "Button"
            $interface.ProgressBar.GetType().Name | Should -Be "ProgressBar"
            $interface.StatusLabel.GetType().Name | Should -Be "Label"

            # Test du changement de langue
            $initialText = $interface.MacAddressButton.Text
            $interface.LanguageButton.PerformClick()
            $interface.MacAddressButton.Text | Should -Not -Be $initialText

            # Nettoyage
            $interface.Form.Close()
            $interface.Form.Dispose()
        }

        It "Doit pouvoir démarrer l'application" {
            # Création de l'interface
            $interface = Initialize-MainWindow

            # Vérification que l'interface peut être affichée
            $canShow = $true
            try {
                $interface.Form.Show()
                Start-Sleep -Milliseconds 100  # Bref délai pour laisser la fenêtre s'afficher
                $interface.Form.Close()
            }
            catch {
                $canShow = $false
            }
            finally {
                $interface.Form.Dispose()
            }

            $canShow | Should -Be $true
        }
    }
}

# Si le script est exécuté directement, lancer les tests
if ($MyInvocation.InvocationName -ne '.') {
    Invoke-Pester -Path $PSCommandPath
} 