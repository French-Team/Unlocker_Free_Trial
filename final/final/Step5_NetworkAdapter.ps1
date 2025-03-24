# =================================================================
# Fichier     : Step5_NetworkAdapter.ps1
# Role        : Gestion des adaptateurs réseau et adresses MAC
# Description : Module unifié pour gérer les adaptateurs réseau et les adresses MAC
# =================================================================

#region Informations réseau

# Récupérer la liste des adaptateurs réseau
function Get-NetworkAdapters {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$false)]
        [switch]$ActiveOnly = $false
    )
    
    Write-Log "Récupération des adaptateurs réseau" -Level "INFO"
    
    try {
        if ($ActiveOnly) {
            $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
            Write-Log "Nombre d'adaptateurs réseau actifs trouvés: $($adapters.Count)" -Level "DEBUG"
        } else {
            $adapters = Get-NetAdapter
            Write-Log "Nombre total d'adaptateurs réseau trouvés: $($adapters.Count)" -Level "DEBUG"
        }
        
        # Enrichir les informations des adaptateurs avec des propriétés supplémentaires
        $enrichedAdapters = @()
        foreach ($adapter in $adapters) {
            $enriched = [PSCustomObject]@{
                Name = $adapter.Name
                InterfaceDescription = $adapter.InterfaceDescription
                InterfaceIndex = $adapter.InterfaceIndex
                InterfaceGuid = $adapter.InterfaceGuid
                MacAddress = $adapter.MacAddress
                Status = $adapter.Status
                LinkSpeed = $adapter.LinkSpeed
                MediaType = $adapter.MediaType
                PhysicalMediaType = $adapter.PhysicalMediaType
                InterfaceAlias = $adapter.InterfaceAlias
                Virtual = $adapter.Virtual
                MediaConnectionState = $adapter.MediaConnectionState
                DriverVersion = $null
                DriverInformation = $null
            }
            
            # Obtenir la version du pilote si possible
            try {
                $driverInfo = Get-NetAdapterAdvancedProperty -Name $adapter.Name -ErrorAction SilentlyContinue | 
                        Where-Object { $_.RegistryKeyword -eq "DriverVersion" } | 
                        Select-Object -ExpandProperty RegistryValue -ErrorAction SilentlyContinue
                
                if ($driverInfo) {
                    $enriched.DriverVersion = $driverInfo
                    $enriched.DriverInformation = "Pilote v$driverInfo"
                }
            } catch {
                Write-Log "Impossible d'obtenir la version du pilote pour $($adapter.Name): $_" -Level "DEBUG"
            }
            
            $enrichedAdapters += $enriched
        }
        
        return $enrichedAdapters
    }
    catch {
        Write-Log "Erreur lors de la récupération des adaptateurs réseau: $_" -Level "ERROR"
        return @()
    }
}

# Formater l'information d'un adaptateur réseau pour l'affichage
function Format-NetworkAdapter {
    param (
        [Parameter(Mandatory=$true)]
        $Adapter
    )
    
    try {
        $speed = if ($Adapter.LinkSpeed) {
            [math]::Round(($Adapter.LinkSpeed -replace '[^0-9\.]', '') / 1000, 1)
        } else {
            "N/A"
        }
        
        $driverInfo = if ($Adapter.DriverInformation) {
            $Adapter.DriverInformation
        } elseif ($Adapter.DriverVersion) {
            "Pilote v$($Adapter.DriverVersion)"
        } else {
            "Pilote inconnu"
        }
        
        $formattedAdapter = "[$($Adapter.Name)] - $speed Gbps - $driverInfo"
        
        Write-Log "Adaptateur formaté: $formattedAdapter" -Level "DEBUG"
        return $formattedAdapter
    }
    catch {
        Write-Log "Erreur lors du formatage de l'adaptateur réseau: $_" -Level "ERROR"
        return $Adapter.Name
    }
}

# Obtenir les détails d'un adaptateur réseau spécifique
function Get-NetworkAdapterDetails {
    param (
        [Parameter(Mandatory=$true)]
        [string]$AdapterName
    )
    
    Write-ConsoleLog "🔍 Récupération des détails de l'adaptateur: $AdapterName" -Color Cyan
    
    try {
        $adapter = Get-NetAdapter -Name $AdapterName -ErrorAction Stop
        $ipConfiguration = Get-NetIPConfiguration -InterfaceIndex $adapter.ifIndex -ErrorAction SilentlyContinue
        
        $details = @{
            Name = $adapter.Name
            Description = $adapter.InterfaceDescription
            MacAddress = $adapter.MacAddress
            Status = $adapter.Status
            LinkSpeed = $adapter.LinkSpeed
            MediaType = $adapter.MediaType
            ConnectorPresent = $adapter.ConnectorPresent
            DriverVersion = (Get-NetAdapterAdvancedProperty -Name $adapter.Name -ErrorAction SilentlyContinue | 
                            Where-Object { $_.RegistryKeyword -eq "DriverVersion" } | 
                            Select-Object -ExpandProperty RegistryValue -ErrorAction SilentlyContinue)
            IPAddress = $ipConfiguration.IPv4Address.IPAddress
            DefaultGateway = $ipConfiguration.IPv4DefaultGateway.NextHop
            DNSServer = $ipConfiguration.DNSServer.ServerAddresses -join ", "
        }
        
        Write-Log "Détails récupérés pour l'adaptateur: $AdapterName" -Level "DEBUG"
        return $details
    }
    catch {
        Write-Log "Erreur lors de la récupération des détails de l'adaptateur $AdapterName : $_" -Level "ERROR"
        return $null
    }
}

# Récupérer les informations complètes sur le réseau
function Get-NetworkInformation {
    Write-ConsoleLog "🔍 Récupération des informations réseau..." -Color Cyan
    
    try {
        $adapters = Get-NetworkAdapters -ActiveOnly
        $adapter = $adapters | Select-Object -First 1
        
        if ($adapter) {
            Write-Log "Adaptateur réseau principal trouvé: $($adapter.Name)" -Level "INFO"
            
            $formattedAdapter = Format-NetworkAdapter -Adapter $adapter
            $macAddress = $adapter.MacAddress
            
            Write-Log "Adresse MAC actuelle: $macAddress" -Level "INFO"
            
            return @{
                Success = $true
                Data = @{
                    AdapterName = $formattedAdapter
                    MacAddress = $macAddress
                    RawAdapter = $adapter
                }
            }
        } 
        else {
            Write-Log "Aucun adaptateur réseau actif trouvé" -Level "WARNING"
            return @{
                Success = $false
                Message = "Aucun adaptateur réseau actif trouvé"
            }
        }
    }
    catch {
        Write-Log "Erreur lors de la récupération des informations réseau: $_" -Level "ERROR"
        return @{
            Success = $false
            Message = "Erreur lors de la récupération des informations réseau: $_"
        }
    }
}

# Attendre qu'une carte réseau soit disponible
function Wait-ForNetworkCard {
    param (
        [int]$Timeout = 30, # Timeout en secondes
        [int]$RetryInterval = 2 # Intervalle entre les essais en secondes
    )
    
    Write-ConsoleLog "⏳ Attente d'une carte réseau disponible..." -Color Cyan
    
    $startTime = Get-Date
    $endTime = $startTime.AddSeconds($Timeout)
    
    while ((Get-Date) -lt $endTime) {
        $adapters = Get-NetworkAdapters -ActiveOnly
        
        if ($adapters -and $adapters.Count -gt 0) {
            Write-ConsoleLog "✅ Carte réseau disponible: $($adapters[0].Name)" -Color Green
            Write-Log "Carte réseau disponible après $([math]::Round(((Get-Date) - $startTime).TotalSeconds, 1)) secondes" -Level "INFO"
            return $true
        }
        
        Write-ConsoleLog "🔄 Aucune carte réseau disponible, nouvelle tentative dans $RetryInterval secondes..." -Color Yellow
        Start-Sleep -Seconds $RetryInterval
    }
    
    Write-ConsoleLog "❌ Timeout atteint, aucune carte réseau disponible après $Timeout secondes" -Color Red
    Write-Log "Timeout atteint, aucune carte réseau disponible après $Timeout secondes" -Level "ERROR"
    return $false
}

#endregion

#region Gestion des adresses MAC

# Générer une nouvelle adresse MAC aléatoire
function New-MacAddress {
    Write-ConsoleLog "🔍 Génération d'une nouvelle adresse MAC..." -Color Cyan
    
    try {
        # Premier octet (bit universel/local à 0 pour garantir une adresse localement administrée)
        $firstByte = '{0:X2}' -f ((Get-Random -Minimum 0 -Maximum 255) -band 0xFE)
        
        # Génération des 5 autres octets
        $otherBytes = 2..6 | ForEach-Object {
            '{0:X2}' -f (Get-Random -Minimum 0 -Maximum 255)
        }
        
        # Assemblage de l'adresse MAC au format XX-XX-XX-XX-XX-XX
        $macAddress = "$firstByte-$($otherBytes -join '-')"
        
        # S'assurer que le type retourné est bien une chaîne de caractères
        $macAddress = [string]$macAddress
        
        Write-ConsoleLog "✅ Adresse MAC générée: $macAddress" -Color Green
        Write-Log "Nouvelle adresse MAC générée: $macAddress" -Level "INFO"
        
        # Vérifier et confirmer le type avant de retourner
        if ($macAddress -isnot [string]) {
            $macAddress = $macAddress.ToString()
            Write-Log "Conversion forcée de l'adresse MAC en chaîne (Type: $($macAddress.GetType().FullName))" -Level "WARNING"
        }
        
        return $macAddress
    }
    catch {
        Write-ConsoleLog "❌ Erreur lors de la génération de l'adresse MAC: $_" -Color Red
        Write-Log "Erreur lors de la génération de l'adresse MAC: $_" -Level "ERROR"
        
        # En cas d'erreur, retourner une chaîne vide plutôt que null
        return [string]::Empty
    }
}

# Valider une adresse MAC
function Test-MacAddress {
    param (
        [Parameter(Mandatory=$true)]
        [string]$MacAddress
    )
    
    Write-Log "Validation de l'adresse MAC: $MacAddress" -Level "DEBUG"
    
    try {
        # Vérifier le format de l'adresse MAC (XX-XX-XX-XX-XX-XX)
        $isValid = $MacAddress -match '^([0-9A-F]{2}-){5}([0-9A-F]{2})$'
        
        if ($isValid) {
            Write-Log "Adresse MAC valide: $MacAddress" -Level "DEBUG"
        } else {
            Write-Log "Adresse MAC invalide: $MacAddress" -Level "WARNING"
        }
        
        return $isValid
    }
    catch {
        Write-Log "Erreur lors de la validation de l'adresse MAC: $_" -Level "ERROR"
        return $false
    }
}

# Modifier l'adresse MAC d'un adaptateur réseau directement
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
            
            # Vérifier que l'adaptateur existe, en obtenant TOUS les adaptateurs (pas seulement ceux actifs)
            # car il est possible que l'adaptateur soit temporairement inactif
            $adapter = Get-NetworkAdapters | Where-Object Name -eq $AdapterName
            
            if (-not $adapter) {
                # Essai direct avec Get-NetAdapter au cas où
                try {
                    $adapter = Get-NetAdapter -Name $AdapterName -ErrorAction Stop
                    Write-Log "Adaptateur réseau trouvé directement: $AdapterName" -Level "INFO"
                } catch {
                    $errorMessage = "Adaptateur réseau non trouvé: $AdapterName"
                    Write-ConsoleLog "❌ $errorMessage" -Color Red
                    Write-Log $errorMessage -Level "ERROR"
                    return @{
                        Success = $false
                        Message = $errorMessage
                    }
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
        
        # Obtenir les détails complets de l'adaptateur avec Get-NetAdapter pour s'assurer d'avoir toutes les propriétés
        try {
            $fullAdapter = Get-NetAdapter -Name $adapterToUseName -ErrorAction Stop
            $interfaceAlias = $fullAdapter.InterfaceAlias
            $interfaceDescription = $fullAdapter.InterfaceDescription
            $interfaceGuid = $fullAdapter.InterfaceGuid
            
            Write-Log "Détails de l'adaptateur: Alias=$interfaceAlias, Description=$interfaceDescription, GUID=$interfaceGuid" -Level "DEBUG"
        } catch {
            $errorMessage = "Impossible d'obtenir les détails complets de l'adaptateur: $_"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Sauvegarder l'adresse MAC actuelle
        $currentMac = $fullAdapter.MacAddress
        Write-Log "Adresse MAC actuelle: $currentMac" -Level "INFO"
        
        # Créer un script qui essaiera plusieurs méthodes pour modifier l'adresse MAC
        $tempScript = @"
# Configurer la journalisation
`$logFile = "`$env:TEMP\mac_change_log_$(Get-Date -Format 'yyyyMMdd_HHmmss').txt"
function WriteLog {
    param (`$message, `$type = "INFO")
    `$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    "[`$timestamp] [`$type] `$message" | Out-File -FilePath `$logFile -Append
    Write-Host `$message
}

WriteLog "=== DÉBUT DU SCRIPT DE MODIFICATION D'ADRESSE MAC ===" "INFO"
WriteLog "Adaptateur: $adapterToUseName" "INFO"
WriteLog "Alias d'interface: $interfaceAlias" "INFO" 
WriteLog "Description: $interfaceDescription" "INFO"
WriteLog "GUID: $interfaceGuid" "INFO"
WriteLog "Nouvelle adresse MAC: $MacAddress" "INFO"
WriteLog "Adresse MAC sans tirets: $($MacAddress.Replace('-', ''))" "INFO"

# Fonction pour vérifier si l'adresse MAC a été modifiée
function Test-MacAddressChanged {
    param (`$expectedMac)
    
    try {
        Start-Sleep -Seconds 3
        `$updatedAdapter = Get-NetAdapter -Name "$adapterToUseName" -ErrorAction Stop
        `$newMac = `$updatedAdapter.MacAddress
        WriteLog "Adresse MAC après tentative: `$newMac" "INFO"
        
        # Normaliser les deux adresses pour comparaison (enlever tirets/deux-points et mettre en majuscule)
        `$expectedClean = `$expectedMac.Replace("-", "").Replace(":", "").ToUpper()
        `$actualClean = `$newMac.Replace("-", "").Replace(":", "").ToUpper()
        
        if (`$actualClean -eq `$expectedClean) {
            WriteLog "Vérification réussie! L'adresse MAC a été modifiée avec succès." "INFO"
            return `$true
        } else {
            WriteLog "L'adresse MAC n'a pas été modifiée comme prévu (`$actualClean vs `$expectedClean)." "WARNING"
            return `$false
        }
    } catch {
        WriteLog "Erreur lors de la vérification de l'adresse MAC: `$_" "ERROR"
        return `$false
    }
}

#region MÉTHODE 1: UTILISATION DE NETSH

WriteLog "===== MÉTHODE 1: UTILISATION DE NETSH =====" "INFO"

try {
    # Désactiver l'adaptateur
    WriteLog "Désactivation de l'adaptateur..." "INFO"
    Disable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    Start-Sleep -Seconds 2
    
    # Modifier avec netsh
    WriteLog "Modification avec netsh..." "INFO"
    `$macWithoutDashes = "$($MacAddress.Replace('-', ''))"
    
    # Utiliser l'alias d'interface pour netsh
    `$netshCommand = "netsh interface set interface name=`"`$interfaceAlias`" newmac=`$macWithoutDashes"
    WriteLog "Commande netsh: `$netshCommand" "INFO"
    
    `$netshOutput = Invoke-Expression `$netshCommand 2>&1
    `$netshOutput | ForEach-Object { WriteLog "  > `$_" "INFO" }
    
    # Réactiver l'adaptateur
    WriteLog "Réactivation de l'adaptateur..." "INFO"
    Enable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    
    # Vérifier si la modification a fonctionné
    if (Test-MacAddressChanged -expectedMac "$MacAddress") {
        WriteLog "Modification avec netsh réussie!" "INFO"
        exit 0  # Succès
    } else {
        WriteLog "Modification avec netsh a échoué, tentative de la méthode suivante..." "WARNING"
    }
} catch {
    WriteLog "Erreur avec la méthode netsh: `$_" "ERROR"
}

#endregion

#region MÉTHODE 2: MODIFICATION DU REGISTRE VIA GUID

WriteLog "===== MÉTHODE 2: MODIFICATION DU REGISTRE VIA GUID =====" "INFO"

try {
    # Désactiver l'adaptateur
    WriteLog "Désactivation de l'adaptateur..." "INFO"
    Disable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    Start-Sleep -Seconds 2
    
    # Chercher directement la clé de registre correspondante via le GUID
    `$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}"
    `$macWithoutDashes = "$($MacAddress.Replace('-', ''))"
    `$found = `$false
    
    WriteLog "Recherche de l'adaptateur dans le registre via GUID: $interfaceGuid" "INFO"
    
    Get-ChildItem -Path `$regPath | ForEach-Object {
        try {
            `$key = `$_
            `$props = Get-ItemProperty -Path `$key.PSPath -ErrorAction SilentlyContinue
            
            if (`$props.NetCfgInstanceId -eq "$interfaceGuid") {
                WriteLog "Clé de registre trouvée: `$(`$key.PSPath)" "INFO"
                
                # Modifier l'adresse MAC
                Set-ItemProperty -Path `$key.PSPath -Name "NetworkAddress" -Value `$macWithoutDashes -Force
                WriteLog "Adresse MAC définie dans le registre" "INFO"
                `$found = `$true
            }
        } catch {
            WriteLog "Erreur avec la clé `$(`$key.PSPath): `$_" "ERROR"
        }
    }
    
    if (-not `$found) {
        WriteLog "Aucune clé de registre trouvée pour le GUID: $interfaceGuid" "WARNING"
        WriteLog "Recherche par description: $interfaceDescription" "INFO"
        
        # Essayer de trouver par description si le GUID échoue
        Get-ChildItem -Path `$regPath | ForEach-Object {
            try {
                `$key = `$_
                `$props = Get-ItemProperty -Path `$key.PSPath -ErrorAction SilentlyContinue
                
                if (`$props.DriverDesc -eq "$interfaceDescription") {
                    WriteLog "Clé de registre trouvée via description: `$(`$key.PSPath)" "INFO"
                    
                    # Modifier l'adresse MAC
                    Set-ItemProperty -Path `$key.PSPath -Name "NetworkAddress" -Value `$macWithoutDashes -Force
                    WriteLog "Adresse MAC définie dans le registre" "INFO"
                    `$found = `$true
                }
            } catch {
                WriteLog "Erreur avec la clé `$(`$key.PSPath): `$_" "ERROR"
            }
        }
    }
    
    # Réactiver l'adaptateur
    WriteLog "Réactivation de l'adaptateur..." "INFO"
    Enable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    
    # Vérifier si la modification a fonctionné
    if (Test-MacAddressChanged -expectedMac "$MacAddress") {
        WriteLog "Modification avec le registre réussie!" "INFO"
        exit 0  # Succès
    } else {
        WriteLog "Modification avec le registre a échoué, tentative de la méthode suivante..." "WARNING"
    }
} catch {
    WriteLog "Erreur avec la méthode du registre: `$_" "ERROR"
}

#endregion

#region MÉTHODE 3: UTILISATION DE WMI

WriteLog "===== MÉTHODE 3: UTILISATION DE WMI =====" "INFO"

try {
    # Désactiver l'adaptateur
    WriteLog "Désactivation de l'adaptateur..." "INFO"
    Disable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    Start-Sleep -Seconds 2
    
    # Essayer via WMI
    WriteLog "Recherche de l'adaptateur via WMI..." "INFO"
    `$networkWmiAdapters = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { `$_.NetConnectionID -eq "$adapterToUseName" }
    
    if (-not `$networkWmiAdapters) {
        WriteLog "Aucun adaptateur trouvé via WMI avec NetConnectionID=$adapterToUseName" "WARNING"
    } else {
        foreach (`$wmiAdapter in `$networkWmiAdapters) {
            WriteLog "Adaptateur WMI trouvé: `$(`$wmiAdapter.Name) (DeviceID: `$(`$wmiAdapter.DeviceID))" "INFO"
            
            try {
                `$wmiConfig = Get-WmiObject -Class Win32_NetworkAdapterConfiguration | Where-Object { `$_.Index -eq `$wmiAdapter.DeviceID }
                
                if (`$wmiConfig) {
                    WriteLog "Configuration WMI trouvée, tentative de modification..." "INFO"
                    `$macWithoutDashes = "$($MacAddress.Replace('-', ''))"
                    `$result = `$wmiConfig.SetMACAddress(`$macWithoutDashes)
                    
                    WriteLog "Résultat de SetMACAddress: `$(`$result.ReturnValue)" "INFO"
                    
                    if (`$result.ReturnValue -eq 0) {
                        WriteLog "Modification avec WMI réussie" "INFO"
                    } else {
                        WriteLog "Échec de la modification avec WMI (code: `$(`$result.ReturnValue))" "WARNING"
                    }
                } else {
                    WriteLog "Pas de configuration WMI trouvée pour l'adaptateur" "WARNING"
                }
            } catch {
                WriteLog "Erreur lors de la modification via WMI: `$_" "ERROR"
            }
        }
    }
    
    # Réactiver l'adaptateur
    WriteLog "Réactivation de l'adaptateur..." "INFO"
    Enable-NetAdapter -Name "$adapterToUseName" -Confirm:`$false -ErrorAction Stop
    
    # Vérifier si la modification a fonctionné
    if (Test-MacAddressChanged -expectedMac "$MacAddress") {
        WriteLog "Modification avec WMI réussie!" "INFO"
        exit 0  # Succès
    } else {
        WriteLog "Modification avec WMI a échoué, toutes les méthodes ont échoué." "ERROR"
    }
} catch {
    WriteLog "Erreur avec la méthode WMI: `$_" "ERROR"
}

#endregion

WriteLog "===== TOUTES LES MÉTHODES ONT ÉCHOUÉ =====" "ERROR"
WriteLog "Impossible de modifier l'adresse MAC après avoir essayé toutes les méthodes" "ERROR"
WriteLog "Fichier journal: `$logFile" "INFO"
exit 1  # Échec
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
        Write-ConsoleLog "⏳ Exécution du script de modification (3 méthodes)..." -Color Yellow
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
        Write-Log "Copie du script conservée pour débogage: $debugFile" -Level "DEBUG"
        
        # Récupérer le fichier journal
        $logFiles = Get-ChildItem -Path $env:TEMP -Filter "mac_change_log_*.txt" | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        if ($logFiles) {
            Copy-Item $logFiles.FullName (Join-Path $debugFolder "last_mac_change.log") -Force
            Write-Log "Journal de modification copié: $(Join-Path $debugFolder "last_mac_change.log")" -Level "DEBUG"
        }
        
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
            # Loguer plus de détails pour le débogage
            if ($logFiles) {
                Write-Log "Voir le journal pour plus de détails: $($logFiles.FullName)" -Level "DEBUG"
            }
            
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

#endregion

#region Initialisation

# Initialiser le module d'informations réseau et de gestion MAC
function Initialize-NetworkAdapter {
    Write-ConsoleLog "🔍 Initialisation du module d'adaptateurs réseau..." -Color Cyan
    
    try {
        # Vérifier que des adaptateurs réseau sont disponibles
        $adapters = Get-NetworkAdapters
        
        if ($adapters -and $adapters.Count -gt 0) {
            Write-ConsoleLog "✅ Module d'adaptateurs réseau initialisé avec succès" -Color Green
            Write-Log "Module d'adaptateurs réseau initialisé avec succès. Nombre d'adaptateurs: $($adapters.Count)" -Level "SUCCESS"
            return $true
        } else {
            Write-ConsoleLog "⚠️ Module d'adaptateurs réseau initialisé avec avertissement: Aucun adaptateur réseau trouvé" -Color Yellow
            Write-Log "Module d'adaptateurs réseau initialisé avec avertissement: Aucun adaptateur réseau trouvé" -Level "WARNING"
            return $true # On retourne quand même true car l'absence d'adaptateur n'est pas une erreur critique
        }
    }
    catch {
        Write-ConsoleLog "❌ Erreur lors de l'initialisation du module d'adaptateurs réseau: $_" -Color Red
        Write-Log "Erreur lors de l'initialisation du module d'adaptateurs réseau: $_" -Level "ERROR"
        return $false
    }
}

# Fonctions maintenues pour la compatibilité
function Initialize-NetworkInfo {
    return Initialize-NetworkAdapter
}

function Initialize-MacAddressManager {
    return Initialize-NetworkAdapter
}

#endregion 