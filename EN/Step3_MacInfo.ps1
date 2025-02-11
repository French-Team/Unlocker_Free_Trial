# =================================================================
# File       : Step3_MacInfo.ps1
# Role       : Specialized shop for network information
# Shops      : - Adapters shop (search and info)
#              - Display shop (formatting and labels)
# =================================================================

# ===== Network adapters shop =====
function Get-CurrentMacInfo {
    Write-Host "🏪 Accessing adapters shop..." -ForegroundColor Cyan
    
    try {
        # Adapters search section
        Write-Host "  🔍 Searching for active adapters..." -ForegroundColor Gray
        $adapter = Get-NetAdapter | 
                  Where-Object { $_.Status -eq 'Up' } | 
                  Select-Object -First 1
        
        # Information section
        if ($adapter) {
            Write-Host "  ✓ Adapter found: $($adapter.Name)" -ForegroundColor Green
            return @{
                Success = $true
                AdapterName = $adapter.Name
                Description = $adapter.InterfaceDescription
                MacAddress = $adapter.MacAddress
                Status = $adapter.Status
            }
        }

        # Error section
        Write-Host "  ⚠️ No active adapter found" -ForegroundColor Yellow
        return @{
            Success = $false
            Message = "No active network adapter found"
        }
    }
    catch {
        # Error checkout
        Write-Host "  ❌ Error during search: $($_.Exception.Message)" -ForegroundColor Red
        return @{
            Success = $false
            Message = "Error: $($_.Exception.Message)"
        }
    }
}

# ===== Display shop =====
function Update-MacInfoLabel {
    param (
        [System.Windows.Forms.Label]$Label
    )
    
    Write-Host "🏪 Accessing display shop..." -ForegroundColor Cyan
    
    try {
        # Check if label exists
        if ($null -eq $Label) {
            Write-Host "  ⚠️ Label not defined" -ForegroundColor Yellow
            return
        }

        # Formatting section
        Write-Host "  🎨 Formatting information..." -ForegroundColor Gray
        $macInfo = Get-CurrentMacInfo
        
        if ($macInfo.Success) {
            # Successful formatting section
            $infoText = @"
Active adapter: $($macInfo.Description)
MAC address: $($macInfo.MacAddress)
Status: $($macInfo.Status)
"@
            # Safe text update
            if ($Label.IsHandleCreated) {
                $Label.Invoke([Action]{$Label.Text = $infoText})
            } else {
                $Label.Text = $infoText
            }
            Write-Host "  ✓ Information updated successfully" -ForegroundColor Green
        } 
        else {
            # Error messages section
            if ($Label.IsHandleCreated) {
                $Label.Invoke([Action]{$Label.Text = $macInfo.Message})
            } else {
                $Label.Text = $macInfo.Message
            }
            Write-Host "  ⚠️ Displaying error message" -ForegroundColor Yellow
        }
    }
    catch {
        # Display error checkout
        Write-Host "  ❌ Error updating display: $_" -ForegroundColor Red
        try {
            if ($Label.IsHandleCreated) {
                $Label.Invoke([Action]{$Label.Text = "Unable to retrieve network information"})
            } else {
                $Label.Text = "Unable to retrieve network information"
            }
        } catch { }
    }
} 