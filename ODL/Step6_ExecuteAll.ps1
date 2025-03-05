# =================================================================
# File       : Step6_ExecuteAll.ps1
# Role       : Main commercial center for executing all actions
# Stores     : - Function store (copy of necessary functions)
#              - Execution store (action sequence)
# =================================================================

# ===== Imported functions store =====

# ----- MAC Functions -----
function Get-NetworkAdapters {
    Write-Host "🏪 Accessing adapters store..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Searching for active adapters..." -ForegroundColor Gray
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq 'Up' } | Select-Object @{
            Name = 'Name'; Expression = { $_.Name }
        }, @{
            Name = 'MacAddress'; Expression = { $_.MacAddress }
        }, @{
            Name = 'Status'; Expression = { $_.Status }
        }, @{
            Name = 'InterfaceDescription'; Expression = { $_.InterfaceDescription }
        }

        if ($adapters) {
            Write-Host "  ✓ Adapters found: $($adapters.Count)" -ForegroundColor Green
            return $adapters
        } else {
            Write-Host "  ⚠️ No adapters found" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Host "  ❌ Error during search: $_" -ForegroundColor Red
        Write-Error "Error while retrieving adapters: $_"
        return $null
    }
}

function New-MacAddress {
    Write-Host "🏪 Accessing MAC addresses store..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🎲 Generating a new address..." -ForegroundColor Gray
        $firstByte = '{0:X2}' -f ((Get-Random -Minimum 0 -Maximum 255) -band 0xFE)
        $otherBytes = 2..6 | ForEach-Object {
            '{0:X2}' -f (Get-Random -Minimum 0 -Maximum 255)
        }
        $macAddress = "$firstByte-$($otherBytes -join '-')"
        Write-Host "  ✓ Address generated: $macAddress" -ForegroundColor Green
        return $macAddress
    }
    catch {
        Write-Host "  ❌ Error during generation: $_" -ForegroundColor Red
        Write-Error "Error generating MAC address: $_"
        return $null
    }
}

function Test-MacAddress {
    param ([string]$MacAddress)
    
    Write-Host "🏪 Accessing validation store..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Checking format..." -ForegroundColor Gray
        $isValid = $MacAddress -match '^([0-9A-F]{2}-){5}([0-9A-F]{2})$'
        
        if ($isValid) {
            Write-Host "  ✓ Valid format" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️ Invalid format" -ForegroundColor Yellow
        }
        
        return $isValid
    }
    catch {
        Write-Host "  ❌ Error during validation: $_" -ForegroundColor Red
        return $false
    }
}

function Set-MacAddress {
    param (
        [string]$AdapterName,
        [string]$MacAddress
    )
    
    Write-Host "🏪 Accessing modifications store..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Searching for adapter..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | Where-Object Name -eq $AdapterName
        if (-not $adapter) {
            throw "Adapter not found: $AdapterName"
        }
        Write-Host "  ✓ Adapter found" -ForegroundColor Green

        Write-Host "  🔍 Validating MAC address..." -ForegroundColor Gray
        if (-not (Test-MacAddress $MacAddress)) {
            throw "Invalid MAC address format"
        }
        Write-Host "  ✓ Valid MAC address" -ForegroundColor Green

        Write-Host "  🔌 Disabling adapter..." -ForegroundColor Gray
        Disable-NetAdapter -Name $AdapterName -Confirm:$false
        Start-Sleep -Seconds 2
        Write-Host "  ✓ Adapter disabled" -ForegroundColor Green

        Write-Host "  🔧 Modifying registry..." -ForegroundColor Gray
        
        $tempScript = @"
`$regPath = "HKLM:SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
`$success = `$false

Get-ChildItem -Path `$regPath | ForEach-Object {
    `$driverDesc = (Get-ItemProperty -Path `$_.PSPath).DriverDesc
    if (`$driverDesc -eq '$($adapter.InterfaceDescription)') {
        Set-ItemProperty -Path `$_.PSPath -Name "NetworkAddress" -Value '$($MacAddress.Replace("-", ""))' -Force
        `$success = `$true
        Write-Host "Registry modification completed successfully"
    }
}

if (-not `$success) {
    throw "Failed to modify registry"
}
"@

        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $tempScript | Out-File -FilePath $tempFile -Encoding UTF8

        $process = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru
        Remove-Item $tempFile -Force

        if ($process.ExitCode -ne 0) {
            throw "Failed to modify registry"
        }

        Write-Host "  ✓ Registry modified" -ForegroundColor Green

        Write-Host "  🔌 Reactivating adapter..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "  ✓ Adapter reactivated" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "  ❌ Error during modification: $_" -ForegroundColor Red
        Write-Error "Error modifying MAC address: $_"
        try { 
            Enable-NetAdapter -Name $AdapterName -Confirm:$false 
            Write-Host "  ⚠️ Adapter reactivated after error" -ForegroundColor Yellow
        } catch { }
        return $false
    }
}

# ----- Storage Functions -----
function Get-CursorStoragePath {
    Write-Host "🏪 Accessing paths store..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Building path..." -ForegroundColor Gray
        $username = $env:USERNAME
        $storagePath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        
        Write-Host "  ✓ Path built: $storagePath" -ForegroundColor Green
        return $storagePath
    }
    catch {
        Write-Host "  ❌ Error while building path: $_" -ForegroundColor Red
        throw "Error while building path: $_"
    }
}

function Test-CursorStorageExists {
    try {
        $storagePath = Get-CursorStoragePath
        if (Test-Path $storagePath) {
            return @{
                Success = $true
                Message = "Le fichier storage.json existe"
                Path = $storagePath
            }
        } else {
            return @{
                Success = $false
                Message = "Le fichier storage.json n'existe pas"
                Path = $storagePath
            }
        }
    }
    catch {
        return @{
            Success = $false
            Message = "Erreur lors de la vérification du fichier storage.json: $_"
            Path = $null
        }
    }
}

function Remove-CursorStorage {
    try {
        # Vérifier d'abord si le fichier existe
        $exists = Test-CursorStorageExists
        if (-not $exists.Success) {
            return @{
                Success = $false
                Message = $exists.Message
            }
        }

        $storagePath = $exists.Path
        if (Test-Path $storagePath) {
            Remove-Item -Path $storagePath -Force
            return @{
                Success = $true
                Message = "Le fichier storage.json a été supprimé avec succès"
            }
        } else {
            return @{
                Success = $false
                Message = "Le fichier storage.json n'existe pas"
            }
        }
    }
    catch {
        return @{
            Success = $false
            Message = "Erreur lors de la suppression du fichier storage.json: $_"
        }
    }
}

# ===== Execution store =====
function Start-AllActions {
    Write-Host "`n🏪 Starting all actions..." -ForegroundColor Cyan
    $results = @{
        MAC = $false
        Storage = $false
        Browser = $false
    }
    
    try {
        # Step 1: Change MAC address
        Write-Host "`n=== Step 1: Change MAC address ===" -ForegroundColor Yellow
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        if ($adapter) {
            $newMac = New-MacAddress
            if ($newMac) {
                $results.MAC = Set-MacAddress -AdapterName $adapter.Name -MacAddress $newMac
                if ($results.MAC) {
                    Write-Host "  ⏳ Waiting for network reconnection (10 seconds)..." -ForegroundColor Yellow
                    Start-Sleep -Seconds 10
                }
            }
        }

        # Step 2: Delete storage.json file
        Write-Host "`n=== Step 2: Delete storage.json file ===" -ForegroundColor Yellow
        $storageResult = Remove-CursorStorage
        $results.Storage = $storageResult.Success

        # Summary
        Write-Host "`n=== Action Summary ===" -ForegroundColor Cyan
        Write-Host "MAC modification: $(if($results.MAC){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.MAC){'Green'}else{'Red'})
        Write-Host "storage.json deletion: $(if($results.Storage){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.Storage){'Green'}else{'Red'})

        return $results
    }
    catch {
        Write-Host "`n❌ Error during action execution: $_" -ForegroundColor Red
        return $results
    }
}

function Execute-AllActions {
    param (
        [Parameter(Mandatory=$false)]
        [switch]$ShowProgress = $true
    )
    
    try {
        # List of actions to perform
        $actions = @(
            @{ Name = "Retrieving network adapters"; Action = { Get-NetworkAdapters } },
            @{ Name = "Generating new MAC address"; Action = { New-MacAddress } },
            @{ Name = "Changing MAC address"; Action = { param($adapter, $mac) Set-MacAddress -AdapterName $adapter.Name -NewMacAddress $mac } },
            @{ Name = "Deleting storage.json file"; Action = { Remove-CursorStorage } }
        )
        
        $totalActions = $actions.Count
        $currentAction = 0
        
        # Getting necessary data
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        $newMac = New-MacAddress
        
        foreach ($actionItem in $actions) {
            $currentAction++
            $actionName = $actionItem.Name
            $actionScript = $actionItem.Action
            
            # Display progress
            if ($ShowProgress) {
                $percentComplete = ($currentAction / $totalActions) * 100
                Write-Progress -Activity "Executing actions" -Status $actionName -PercentComplete $percentComplete
            }
            
            # Write to logs
            Write-Host "🔄 $actionName" -ForegroundColor Cyan
            
            # Execute action with appropriate parameters if needed
            switch ($actionName) {
                "Changing MAC address" {
                    & $actionScript $adapter $newMac
                }
                default {
                    & $actionScript
                }
            }
            
            # Pause to see the progress (remove in production)
            if ($ShowProgress) {
                Start-Sleep -Milliseconds 500
            }
        }
        
        # Complete the progress bar
        if ($ShowProgress) {
            Write-Progress -Activity "Executing actions" -Completed
        }
        
        Write-Host "✅ All actions executed successfully!" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "❌ Error during action execution: $_" -ForegroundColor Red
        return $false
    }
}

# Interface for the "Execute all actions" button
function Initialize-ExecuteAllButton {
    param (
        [System.Windows.Forms.Form]$Form
    )
    
    $button = New-Object System.Windows.Forms.Button
    $button.Text = "Execute all actions"
    $button.Width = 200
    $button.Height = 40
    # Set other button properties
    
    $button.Add_Click({
        $result = Execute-AllActions
        if ($result) {
            [System.Windows.Forms.MessageBox]::Show("All actions executed successfully!", "Success", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
        }
        else {
            [System.Windows.Forms.MessageBox]::Show("An error occurred during action execution.", "Error", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        }
    })
    
    return $button
}

# Function export
Export-ModuleMember -Function Execute-AllActions, Initialize-ExecuteAllButton 