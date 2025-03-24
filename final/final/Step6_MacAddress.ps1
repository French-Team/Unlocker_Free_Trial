# Modifier l'adresse MAC d'une carte réseau
function Set-MacAddress {
    param (
        [Parameter(Mandatory=$true, ParameterSetName='ByName')]
        [string]$AdapterName,
        
        [Parameter(Mandatory=$true, ParameterSetName='ByObject')]
        [PSObject]$NetworkAdapter,
        
        [Parameter(Mandatory=$true)]
        [string]$MacAddress,
        
        [Parameter(Mandatory=$false)]
        $ProgressBar = $null
    )
    
    Write-ConsoleLog "🔍 Modification de l'adresse MAC..." -Color Cyan
    
    try {
        # Déterminer quel adaptateur utiliser
        $adapter = $null
        $adapterToUseName = ""
        
        if ($NetworkAdapter) {
            $adapter = $NetworkAdapter
            $adapterToUseName = $adapter.Name
            Write-ConsoleLog "Utilisation de l'objet adaptateur fourni: $adapterToUseName" -Color Cyan
            Write-Log "Information de l'adaptateur: ID=$($adapter.InterfaceIndex), Description=$($adapter.InterfaceDescription), Status=$($adapter.Status)" -Level "DEBUG"
        } else {
            # On utilise directement le nom fourni
            $adapterToUseName = $AdapterName
            # Vérifier que l'adaptateur existe
            $adapter = Get-NetworkAdapters | Where-Object Name -eq $AdapterName
            if (-not $adapter) {
                $errorMessage = "Adaptateur réseau non trouvé: $AdapterName"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                Write-Log $errorMessage -Level "ERROR"
                return @{
                    Success = $false
                    Message = $errorMessage
                }
            }
            Write-Log "Adaptateur réseau trouvé: $AdapterName" -Level "INFO"
        }
        
        # Valider l'adresse MAC
        if (-not (Test-MacAddress $MacAddress)) {
            $errorMessage = "Format d'adresse MAC invalide: $MacAddress"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Mettre à jour la barre de progression si elle est fournie
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Préparation de la modification..." -PercentComplete 20
        }
        
        # Sauvegarder l'adresse MAC actuelle
        $currentMac = $adapter.MacAddress
        Write-Log "Adresse MAC actuelle: $currentMac" -Level "INFO"
        
        # Créer un script utilisant netsh
        $tempScript = @"
# Configurer la journalisation
`$logFile = "`$env:TEMP\mac_change_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
function WriteLog {
    param (`$message)
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[`$timestamp] `$message" | Out-File -FilePath `$logFile -Append
    Write-Host `$message
}

WriteLog "=== Début du script de modification d'adresse MAC ==="
WriteLog "Adaptateur: $adapterToUseName"
WriteLog "Nouvelle adresse MAC: $($MacAddress.Replace('-', ''))"

try {
    # Récupérer les détails de l'interface
    `$interface = Get-NetAdapter -Name "$adapterToUseName" -ErrorAction Stop
    WriteLog "Interface trouvée: ID=`$(`$interface.InterfaceIndex), Description=`$(`$interface.InterfaceDescription)"
    `$connectionAlias = `$interface.InterfaceAlias
    WriteLog "Alias d'interface: `$connectionAlias"
    
    # Désactiver l'adaptateur
    WriteLog "Désactivation de l'adaptateur..."
    Disable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    Start-Sleep -Seconds 2
    
    # Essayer avec netsh
    WriteLog "Tentative avec netsh..."
    `$macWithoutDashes = "$($MacAddress.Replace('-', ''))"
    
    `$netshCommand = "netsh interface set interface name=`"`$connectionAlias`" newmac=`$macWithoutDashes"
    WriteLog "Commande: `$netshCommand"
    Invoke-Expression `$netshCommand 2>&1 | ForEach-Object { WriteLog "  > `$_" }
    
    # Réactiver l'adaptateur
    WriteLog "Réactivation de l'adaptateur..."
    Start-Sleep -Seconds 2
    Enable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    
    # Vérifier que la modification a été appliquée
    Start-Sleep -Seconds 3
    `$updatedAdapter = Get-NetAdapter -Name "$adapterToUseName" -ErrorAction Stop
    WriteLog "Adresse MAC après modification: `$(`$updatedAdapter.MacAddress)"
    
    # Vérifier en ignorant le format (tirets ou deux-points)
    `$newMacClean = `$updatedAdapter.MacAddress.Replace("-", "").Replace(":", "").ToUpper()
    `$targetMacClean = "$($MacAddress.Replace('-', ''))".ToUpper()
    
    if (`$newMacClean -eq `$targetMacClean) {
        WriteLog "Modification de l'adresse MAC réussie!"
        exit 0
    } else {
        WriteLog "L'adresse MAC n'a pas été modifiée comme prévu."
        
        # Essayer avec le registre en dernier recours
        WriteLog "Tentative avec le registre..."
        
        # Rechercher la clé de registre correspondante
        `$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
        `$interfaceGuid = `$interface.InterfaceGuid
        `$success = `$false
        
        WriteLog "GUID de l'interface: `$interfaceGuid"
        
        Get-ChildItem -Path `$regPath | ForEach-Object {
            try {
                `$key = `$_
                `$props = Get-ItemProperty -Path `$key.PSPath -ErrorAction SilentlyContinue
                
                if (`$props.NetCfgInstanceId -eq `$interfaceGuid) {
                    WriteLog "Clé de registre trouvée: `$(`$key.PSPath)"
                    Set-ItemProperty -Path `$key.PSPath -Name "NetworkAddress" -Value `$macWithoutDashes -Force
                    WriteLog "Adresse MAC définie dans le registre"
                    `$success = `$true
                }
            } catch {
                WriteLog "Erreur avec la clé `$(`$key.PSPath): `$_"
            }
        }
        
        if (`$success) {
            # Réactiver l'adaptateur
            Disable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
            Start-Sleep -Seconds 2
            Enable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
            Start-Sleep -Seconds 2
            
            # Vérifier à nouveau
            `$finalAdapter = Get-NetAdapter -Name "$adapterToUseName" -ErrorAction Stop
            WriteLog "Adresse MAC finale: `$(`$finalAdapter.MacAddress)"
            
            `$finalMacClean = `$finalAdapter.MacAddress.Replace("-", "").Replace(":", "").ToUpper()
            
            if (`$finalMacClean -eq `$targetMacClean) {
                WriteLog "Modification avec le registre réussie!"
                exit 0
            } else {
                WriteLog "La modification a échoué même avec le registre."
                exit 1
            }
        } else {
            WriteLog "Impossible de trouver la clé de registre correspondante."
            exit 1
        }
    }
} 
catch {
    WriteLog "ERREUR: `$_"
    exit 2
}
"@

        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Création du script temporaire..." -PercentComplete 40
        }
        
        # Créer le fichier temporaire
        $tempFile = [System.IO.Path]::GetTempFileName() + ".ps1"
        $tempScript | Out-File -FilePath $tempFile -Encoding ASCII
        Write-Log "Script temporaire créé: $tempFile" -Level "DEBUG"
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Exécution avec privilèges administrateur..." -PercentComplete 60
        }
        
        # Exécuter le script avec élévation de privilèges
        Write-ConsoleLog "⏳ Exécution du script de modification..." -Color Yellow
        $process = Start-Process powershell.exe -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$tempFile`"" -Verb RunAs -Wait -PassThru -WindowStyle Hidden
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Finalisation..." -PercentComplete 80
        }
        
        # Conserver une copie pour débogage
        $debugFolder = Join-Path $env:TEMP "MacAddressDebug"
        if (-not (Test-Path $debugFolder)) {
            New-Item -ItemType Directory -Path $debugFolder | Out-Null
        }
        $debugFile = Join-Path $debugFolder "last_mac_script.ps1"
        Copy-Item $tempFile $debugFile -Force
        
        # Nettoyer le fichier temporaire
        Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        
        # Vérifier le résultat
        if ($process.ExitCode -eq 0) {
            Write-ConsoleLog "✅ Adresse MAC modifiée avec succès" -Color Green
            Write-Log "Adresse MAC modifiée avec succès pour $adapterToUseName : $MacAddress" -Level "SUCCESS"
            
            # Mettre à jour la barre de progression
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Modification réussie" -PercentComplete 100
            }
            
            return @{
                Success = $true
                Message = "Adresse MAC modifiée avec succès"
                OldValue = $currentMac
                NewValue = $MacAddress
            }
        } else {
            # Récupérer le fichier de journal
            $logFiles = Get-ChildItem -Path $env:TEMP -Filter "mac_change_log_*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
            $logContent = if ($logFiles) { 
                try { Get-Content -Path $logFiles.FullName -Raw -ErrorAction SilentlyContinue } catch { "Impossible de lire le journal" }
            } else { "Aucun journal trouvé" }
            
            # Journaliser pour débogage
            Write-Log "Journal de modification MAC: $($logFiles.FullName)" -Level "DEBUG"
            Write-Log "Contenu du journal: $logContent" -Level "DEBUG"
            
            # Préparer le message d'erreur
            $errorMessage = "Échec de la modification de l'adresse MAC (code $($process.ExitCode))"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            
            # Mettre à jour la barre de progression
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec de la modification" -PercentComplete 100
            }
            
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
    }
    catch {
        $errorMessage = "Erreur lors de la modification de l'adresse MAC: $_"
        Write-ConsoleLog "❌ $errorMessage" -Color Red
        Write-Log $errorMessage -Level "ERROR"
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
        }
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
} 