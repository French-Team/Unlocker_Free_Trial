# =================================================================
# File       : Step1_AdminCheck.ps1
# Role       : Checks if the script is running with administrator privileges 
#              and restarts it with admin rights if necessary.
# Connection : Used by the main script (start.ps1)
# Note       : This file is intended to work on Windows 10
# =================================================================

# Check for administrative privileges
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# In test mode, simply return the status without restarting
if ($env:TEST_MODE) {
    return $isAdmin
}

# In normal mode, restart if necessary
if (-not $isAdmin) {
    Write-Warning "The script must be run as administrator. Restarting..."
    try {
        if ($PSVersionTable.PSEdition -eq "Core") {
            Start-Process pwsh -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath'`"" -Wait
        } else {
            Start-Process powershell -Verb RunAs -ArgumentList "-NoProfile -ExecutionPolicy Bypass -Command `"cd '$pwd'; & '$PSCommandPath'`"" -Wait
        }
        exit 0
    }
    catch {
        Write-Host "❌ Error during administrator restart: $_" -ForegroundColor Red
        exit 1
    }
}

# If we are here, we have administrator rights
return $true 