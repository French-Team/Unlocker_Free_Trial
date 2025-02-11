# =================================================================
# File       : Step4_MacAddress.ps1
# Role       : Shopping mall for MAC addresses
# Shops      : - Adapters shop (search and listing)
#              - MAC addresses shop (generation and validation)
#              - Modifications shop (address change)
# =================================================================

# ===== Network adapters shop =====
function Get-NetworkAdapters {
    Write-Host "🏪 Accessing adapters shop..." -ForegroundColor Cyan
    
    try {
        # Search section
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

        # Results section
        if ($adapters) {
            Write-Host "  ✓ Adapters found: $($adapters.Count)" -ForegroundColor Green
            return $adapters
        } else {
            Write-Host "  ⚠️ No adapter found" -ForegroundColor Yellow
            return $null
        }
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error during search: $_" -ForegroundColor Red
        Write-Error "Error retrieving adapters: $_"
        return $null
    }
}

# ===== MAC addresses shop =====
function New-MacAddress {
    Write-Host "🏪 Accessing MAC addresses shop..." -ForegroundColor Cyan
    
    try {
        # Generation section
        Write-Host "  🎲 Generating new address..." -ForegroundColor Gray
        
        # First byte (universal/local bit to 0)
        $firstByte = '{0:X2}' -f ((Get-Random -Minimum 0 -Maximum 255) -band 0xFE)
        
        # Generate other 5 bytes
        $otherBytes = 2..6 | ForEach-Object {
            '{0:X2}' -f (Get-Random -Minimum 0 -Maximum 255)
        }
        
        # Final assembly
        $macAddress = "$firstByte-$($otherBytes -join '-')"
        Write-Host "  ✓ Address generated: $macAddress" -ForegroundColor Green
        return $macAddress
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error during generation: $_" -ForegroundColor Red
        Write-Error "Error generating MAC address: $_"
        return $null
    }
}

function Test-MacAddress {
    param ([string]$MacAddress)
    
    Write-Host "🏪 Accessing validation shop..." -ForegroundColor Cyan
    
    try {
        # Verification section
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
        # Error checkout
        Write-Host "  ❌ Error during validation: $_" -ForegroundColor Red
        return $false
    }
}

# ===== Modifications shop =====
function Set-MacAddress {
    param (
        [string]$AdapterName,
        [string]$MacAddress
    )
    
    Write-Host "🏪 Accessing modifications shop..." -ForegroundColor Cyan
    
    try {
        # Adapter verification section
        Write-Host "  🔍 Searching for adapter..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | Where-Object Name -eq $AdapterName
        if (-not $adapter) {
            throw "Adapter not found: $AdapterName"
        }
        Write-Host "  ✓ Adapter found" -ForegroundColor Green

        # MAC validation section
        Write-Host "  🔍 Validating MAC address..." -ForegroundColor Gray
        if (-not (Test-MacAddress $MacAddress)) {
            throw "Invalid MAC address format"
        }
        Write-Host "  ✓ Valid MAC address" -ForegroundColor Green

        # Disable section
        Write-Host "  🔌 Disabling adapter..." -ForegroundColor Gray
        Disable-NetAdapter -Name $AdapterName -Confirm:$false
        Start-Sleep -Seconds 2
        Write-Host "  ✓ Adapter disabled" -ForegroundColor Green

        # Registry modification section with privilege elevation
        Write-Host "  🔧 Modifying registry..." -ForegroundColor Gray
        
        # Create temporary script for registry modification
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

        # Execute script with elevated privileges
        $process = Start-Process pwsh.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru
        Remove-Item $tempFile -Force

        if ($process.ExitCode -ne 0) {
            throw "Failed to modify registry"
        }

        Write-Host "  ✓ Registry modified" -ForegroundColor Green

        # Enable section
        Write-Host "  🔌 Enabling adapter..." -ForegroundColor Gray
        Start-Sleep -Seconds 2
        Enable-NetAdapter -Name $AdapterName -Confirm:$false
        Write-Host "  ✓ Adapter enabled" -ForegroundColor Green

        return $true
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error during modification: $_" -ForegroundColor Red
        Write-Error "Error modifying MAC address: $_"
        # Try to re-enable on error
        try { 
            Enable-NetAdapter -Name $AdapterName -Confirm:$false 
            Write-Host "  ⚠️ Adapter re-enabled after error" -ForegroundColor Yellow
        } catch { }
        return $false
    }
} 