# =================================================================
# File       : Step2_UTF8.ps1
# Role       : Configures encoding for all scripts
# Connection : Used by the main script (start.ps1)
# Note       : Uses a combination of encodings to ensure compatibility
# =================================================================

function Set-ConsoleEncoding {
    try {
        # Set culture to English
        [System.Threading.Thread]::CurrentThread.CurrentUICulture = 'en-US'
        [System.Threading.Thread]::CurrentThread.CurrentCulture = 'en-US'

        # Configure encoding for Windows console
        $null = cmd /c '' # Clear console buffer
        chcp 850 | Out-Null # IBM850 (Multilingual - Latin I)
        
        # Configure PowerShell encodings
        $OutputEncoding = [System.Text.Encoding]::GetEncoding(850)
        [Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding(850)
        [Console]::InputEncoding = [System.Text.Encoding]::GetEncoding(850)
        
        # Set default encoding for files
        $PSDefaultParameterValues['Out-File:Encoding'] = 'Default'
        $PSDefaultParameterValues['Set-Content:Encoding'] = 'Default'
        
        # Clear screen to avoid display issues
        Clear-Host
        
        return $true
    }
    catch {
        return $false
    }
} 