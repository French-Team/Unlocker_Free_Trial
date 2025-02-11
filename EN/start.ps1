# =================================================================
# File       : start.ps1
# Role       : Main entry point of the application
# Connection : Uses Step*.ps1 files for functionalities
# =================================================================

# Initial configuration
$ErrorActionPreference = "Stop"
$script:scriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

# Check for administrator rights
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    try {
        # Start PowerShell hidden with admin rights
        Start-Process pwsh.exe -ArgumentList "-WindowStyle Hidden -NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -Wait
        exit 0
    }
    catch {
        Write-Host "❌ Error during administrator restart: $_" -ForegroundColor Red
        exit 1
    }
}

# Message display function
function global:Write-ConsoleLog {
    param(
        [Parameter(Mandatory=$true)]
        [string]$Message,
        
        [Parameter(Mandatory=$false)]
        [ValidateSet("Black", "DarkBlue", "DarkGreen", "DarkCyan", "DarkRed", "DarkMagenta", "DarkYellow", "Gray", "DarkGray", "Blue", "Green", "Cyan", "Red", "Magenta", "Yellow", "White")]
        [string]$Color = "White"
    )
    
    Write-Host $Message -ForegroundColor $Color
    return $Message
}

# Loading Windows Forms assemblies
Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Importing necessary modules
. "$PSScriptRoot\Step1_AdminCheck.ps1"
. "$PSScriptRoot\Step2_UTF8.ps1"
. "$PSScriptRoot\Step3_MacInfo.ps1"
. "$PSScriptRoot\Step3_Interface.ps1"
. "$PSScriptRoot\Step4_MacAddress.ps1"
. "$PSScriptRoot\Step4_MacAddressGUI.ps1"

# Main entry point
if ($MyInvocation.InvocationName -ne '.' -and -not $env:TEST_MODE) {
    # ===== START CODE TO HIDE LOGS WINDOW =====
    # Import required Windows functions
    Add-Type -Name Window -Namespace Console -MemberDefinition '
    [DllImport("Kernel32.dll")]
    public static extern IntPtr GetConsoleWindow();
    [DllImport("user32.dll")]
    public static extern bool ShowWindow(IntPtr hWnd, Int32 nCmdShow);
    '

    # Get console window handle
    $consolePtr = [Console.Window]::GetConsoleWindow()

    # Constants for ShowWindow
    $SW_HIDE = 0
    $SW_SHOW = 5

    # Hide console window immediately
    [Console.Window]::ShowWindow($consolePtr, $SW_HIDE)
    # ===== END CODE TO HIDE LOGS WINDOW =====

    # Windows Forms configuration
    [System.Windows.Forms.Application]::EnableVisualStyles()
    [System.Windows.Forms.Application]::SetCompatibleTextRenderingDefault($false)

    # Interface initialization and display
    $interface = Initialize-MainWindow
    if ($interface -and $interface.Form) {
        # Window configuration
        $interface.Form.Add_Load({
            $this.Activate()
            $this.BringToFront()
            $this.Focus()
        })
        
        # Start Windows Forms message loop
        [System.Windows.Forms.Application]::Run($interface.Form)
    }
}

# Utility functions
function global:Get-NetworkAdapters {
    return Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
}

function global:Set-MacAddress {
    param(
        [Parameter(Mandatory=$true)]
        [string]$AdapterName,
        [Parameter(Mandatory=$true)]
        [string]$NewMacAddress
    )
    
    try {
        Set-NetAdapter -Name $AdapterName -MacAddress $NewMacAddress -Confirm:$false
        return $true
    }
    catch {
        Write-ConsoleLog "Error modifying MAC address: $_" -Color Red
        return $false
    }
} 