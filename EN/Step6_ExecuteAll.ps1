# =================================================================
# File       : Step6_ExecuteAll.ps1
# Role       : Main shopping mall for executing all actions
# Shops      : - Functions shop (copy of necessary functions)
#              - Executions shop (action sequence)
# =================================================================

# ===== Imported functions shop =====

# ----- MAC functions -----
function Get-NetworkAdapters {
    Write-Host "🏪 Accessing adapters shop..." -ForegroundColor Cyan
    
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
            Write-Host "  ⚠️ No adapter found" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        Write-Host "  ❌ Error during search: $_" -ForegroundColor Red
        Write-Error "Error retrieving adapters: $_"
        return $null
    }
}

function New-MacAddress {
    Write-Host "🏪 Accessing MAC addresses shop..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🎲 Generating new address..." -ForegroundColor Gray
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
    
    Write-Host "🏪 Accessing validation shop..." -ForegroundColor Cyan
    
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
    
    Write-Host "🏪 Accessing modifications shop..." -ForegroundColor Cyan
    
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

        Write-Host "  🔌 Enabling adapter..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "  ✓ Adapter enabled" -ForegroundColor Green

        return $true
    }
    catch {
        Write-Host "  ❌ Error during modification: $_" -ForegroundColor Red
        Write-Error "Error modifying MAC address: $_"
        try { 
            Enable-NetAdapter -Name $AdapterName -Confirm:$false 
            Write-Host "  ⚠️ Adapter re-enabled after error" -ForegroundColor Yellow
        } catch { }
        return $false
    }
}

# ----- Storage functions -----
function Get-CursorStoragePath {
    Write-Host "🏪 Accessing paths shop..." -ForegroundColor Cyan
    
    try {
        Write-Host "  🔍 Building path..." -ForegroundColor Gray
        $username = $env:USERNAME
        $storagePath = Join-Path $env:APPDATA "Cursor\User\globalStorage\storage.json"
        
        Write-Host "  ✓ Path built: $storagePath" -ForegroundColor Green
        return $storagePath
    }
    catch {
        Write-Host "  ❌ Error building path: $_" -ForegroundColor Red
        throw "Error building path: $_"
    }
}

function Remove-CursorStorage {
    Write-Host "🏪 Accessing deletions shop..." -ForegroundColor Cyan
    
    try {
        $filePath = Get-CursorStoragePath
        Write-Host "  🔍 Searching for file: $filePath" -ForegroundColor Gray
        
        if (Test-Path $filePath) {
            Write-Host "  🗑️ Deleting file..." -ForegroundColor Yellow
            Remove-Item -Path $filePath -Force
            Write-Host "  ✓ File successfully deleted" -ForegroundColor Green
            return @{
                Success = $true
                Message = "File successfully deleted"
            }
        } else {
            Write-Host "  ⚠️ File not found" -ForegroundColor Yellow
            return @{
                Success = $false
                Message = "File does not exist"
            }
        }
    }
    catch {
        Write-Host "  ❌ Error during deletion: $_" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error during deletion: $_"
        }
    }
}

# ===== Executions shop =====
function Start-AllActions {
    Write-Host "`n🏪 Starting all actions..." -ForegroundColor Cyan
    $results = @{
        MAC = $false
        Storage = $false
        Browser = $false
    }
    
    try {
        # Step 1: MAC address modification
        Write-Host "`n=== Step 1: MAC Address Modification ===" -ForegroundColor Yellow
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

        # Step 2: storage.json file deletion
        Write-Host "`n=== Step 2: storage.json File Deletion ===" -ForegroundColor Yellow
        $storageResult = Remove-CursorStorage
        $results.Storage = $storageResult.Success

        # Summary
        Write-Host "`n=== Actions Summary ===" -ForegroundColor Cyan
        Write-Host "MAC modification: $(if($results.MAC){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.MAC){'Green'}else{'Red'})
        Write-Host "storage.json deletion: $(if($results.Storage){'✓ Success'}else{'❌ Failed'})" -ForegroundColor $(if($results.Storage){'Green'}else{'Red'})

        return $results
    }
    catch {
        Write-Host "`n❌ Error executing actions: $_" -ForegroundColor Red
        return $results
    }
} 