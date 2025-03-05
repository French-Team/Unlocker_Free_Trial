#Requires -Version 5.1
#Requires -Modules Pester

$here = Split-Path -Parent $MyInvocation.MyCommand.Path

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

Describe 'Progress Bar Functionality Tests' {
    . (Join-Path $here '..\Step6_ExecuteAll.ps1') -Force -ErrorAction Stop
    
    Context 'Progress Bar Initialization' {
        It 'Should create a ProgressBar control in the form' {
            $form = New-Object System.Windows.Forms.Form
            Initialize-ExecuteAllButton -Form $form
            $form.Controls | Where-Object { $_ -is [System.Windows.Forms.ProgressBar] } | Should -Not -Be $null
        }
    }

    Context 'Progress Reporting' {
        Mock Write-Progress -MockWith {}
        
        It 'Should report progress steps correctly' {
            $mockActions = @(
                @{ 
                    Name = "Test Action"
                    SubSteps = @(
                        @{ Name = "Step 1"; Action = { } },
                        @{ Name = "Step 2"; Action = { } }
                    )
                }
            )
            
            Execute-AllActions -ShowProgress $true
            
            Assert-MockCalled Write-Progress -Exactly 2 -Scope It
        }
    }

    Context 'ProgressBar Visibility' {
        It 'Should show/hide ProgressBar during execution' {
            $form = New-Object System.Windows.Forms.Form
            $button = Initialize-ExecuteAllButton -Form $form
            
            # Initial state
            $global:ProgressBar.Visible | Should -Be $false
            
            # Simulate click
            $button.PerformClick()
            
            # During execution
            $global:ProgressBar.Visible | Should -Be $true
            
            # After execution
            $global:ProgressBar.Visible | Should -Be $false
        }
    }

    Context 'Error Handling' {
        It 'Should handle progress reporting failures' {
            Mock Write-Progress { throw "Progress Error" }
            
            { Execute-AllActions -ShowProgress $true } | Should -Not -Throw
        }
    }

    Context 'Error Handling' {
        It 'Should hide ProgressBar on error' {
            Mock -CommandName Execute-AllActions -MockWith { throw 'Test error' }
            
            $form = New-Object System.Windows.Forms.Form
            $button = Initialize-ExecuteAllButton -Form $form
            
            {$button.PerformClick()} | Should -Throw
            $global:ProgressBar.Visible | Should -Be $false
        }
    }
}