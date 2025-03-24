# =================================================================
# Fichier     : Step5_NetworkAdapter.ps1
# Role        : Gestion des adaptateurs réseau et des adresses MAC
# Description : Gère la récupération des informations réseau et la modification des adresses MAC
# =================================================================

#region Fonctions de base pour les adaptateurs réseau

# Récupérer la liste des adaptateurs réseau actifs
function Get-NetworkAdapters {
    Write-Log "Récupération des adaptateurs réseau actifs" -Level "INFO"
    
    try {
        $adapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
        Write-Log "Nombre d'adaptateurs réseau actifs trouvés: $($adapters.Count)" -Level "DEBUG"
        return $adapters
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
        $speed = [math]::Round($Adapter.LinkSpeed / 1000, 1)
        $driverInfo = Get-NetAdapterAdvancedProperty -Name $Adapter.Name -ErrorAction SilentlyContinue | 
                     Where-Object { $_.RegistryKeyword -eq "DriverVersion" } | 
                     Select-Object -ExpandProperty RegistryValue -ErrorAction SilentlyContinue
        
        $driverVersion = if ($driverInfo) { "Pilote v$driverInfo" } else { "Pilote inconnu" }
        $formattedAdapter = "[$($Adapter.Name)] - $speed Gbps - $driverVersion"
        
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
        $adapter = Get-NetworkAdapters | Select-Object -First 1
        
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

#endregion

#region Fonctions de gestion des adresses MAC

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
    Write-Log "*********** DÉBUT DE LA MODIFICATION D'ADRESSE MAC ***********" -Level "INFO"
    
    try {
        # Déterminer quel adaptateur utiliser
        $adapter = $null
        $adapterToUseName = ""
        
        if ($NetworkAdapter) {
            # Vérifier que l'objet adaptateur est valide et contient un nom
            if (-not $NetworkAdapter.Name) {
                $errorMessage = "L'objet adaptateur fourni ne contient pas de nom"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                Write-Log $errorMessage -Level "ERROR"
                
                # Essayer de récupérer plus d'informations sur l'objet
                Write-Log "Propriétés de l'objet adaptateur: $($NetworkAdapter | Format-List | Out-String)" -Level "DEBUG"
                
                # Tenter d'extraire un identifiant d'adaptateur à partir d'autres propriétés si disponibles
                if ($NetworkAdapter.InterfaceDescription) {
                    $physicalAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.InterfaceDescription -eq $NetworkAdapter.InterfaceDescription }
                    if ($physicalAdapters -and $physicalAdapters.Count -gt 0) {
                        $adapter = $physicalAdapters[0]
                        $adapterToUseName = $adapter.Name
                        Write-Log "Adaptateur trouvé via la description: $adapterToUseName" -Level "INFO"
                    }
                } elseif ($NetworkAdapter.MacAddress) {
                    $physicalAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.MacAddress -eq $NetworkAdapter.MacAddress }
                    if ($physicalAdapters -and $physicalAdapters.Count -gt 0) {
                        $adapter = $physicalAdapters[0]
                        $adapterToUseName = $adapter.Name
                        Write-Log "Adaptateur trouvé via l'adresse MAC: $adapterToUseName" -Level "INFO"
                    }
                }
                
                # Si on n'a toujours pas d'adaptateur, utiliser le premier disponible comme solution de repli
                if (-not $adapter) {
                    $physicalAdapters = Get-NetAdapter -ErrorAction SilentlyContinue
                    if ($physicalAdapters -and $physicalAdapters.Count -gt 0) {
                        $adapter = $physicalAdapters[0]
                        $adapterToUseName = $adapter.Name
                        Write-Log "Utilisation de l'adaptateur par défaut: $adapterToUseName" -Level "WARNING"
                    } else {
                        return @{
                            Success = $false
                            Message = "Aucun adaptateur réseau disponible sur le système"
                        }
                    }
                }
            } else {
                $adapter = $NetworkAdapter
                $adapterToUseName = $adapter.Name
                Write-ConsoleLog "Utilisation de l'objet adaptateur fourni: $adapterToUseName" -Color Cyan
                Write-Log "Information de l'adaptateur: ID=$($adapter.InterfaceIndex), Description=$($adapter.InterfaceDescription), Status=$($adapter.Status)" -Level "DEBUG"
            }
        } else {
            # On utilise directement le nom fourni
            if ([string]::IsNullOrEmpty($AdapterName)) {
                $errorMessage = "Le nom de l'adaptateur fourni est vide ou null"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                Write-Log $errorMessage -Level "ERROR"
                
                # Utiliser le premier adaptateur disponible
                $physicalAdapters = Get-NetAdapter -ErrorAction SilentlyContinue
                if ($physicalAdapters -and $physicalAdapters.Count -gt 0) {
                    $adapter = $physicalAdapters[0]
                    $adapterToUseName = $adapter.Name
                    Write-Log "Utilisation de l'adaptateur par défaut: $adapterToUseName" -Level "WARNING"
                } else {
                    return @{
                        Success = $false
                        Message = "Aucun adaptateur réseau disponible sur le système"
                    }
                }
            } else {
                $adapterToUseName = $AdapterName
                
                # Vérifier que l'adaptateur existe
                try {
                    $adapter = Get-NetAdapter -Name $adapterToUseName -ErrorAction Stop
                    Write-Log "Adaptateur réseau trouvé: $adapterToUseName" -Level "INFO"
                } catch {
                    # Essayer de chercher par correspond partielle
                    $physicalAdapters = Get-NetAdapter -ErrorAction SilentlyContinue | Where-Object { $_.Name -like "*$AdapterName*" }
                    if ($physicalAdapters -and $physicalAdapters.Count -gt 0) {
                        $adapter = $physicalAdapters[0]
                        $adapterToUseName = $adapter.Name
                        Write-Log "Adaptateur trouvé via correspondance partielle: $adapterToUseName" -Level "INFO"
                    } else {
                        # Tenter de récupérer les adaptateurs actifs
                        $activeAdapters = Get-NetAdapter | Where-Object { $_.Status -eq "Up" }
                        if ($activeAdapters -and $activeAdapters.Count -gt 0) {
                            $adapter = $activeAdapters[0]
                            $adapterToUseName = $adapter.Name
                            Write-Log "Utilisation du premier adaptateur actif: $adapterToUseName" -Level "WARNING"
                        } else {
                            # En dernier recours, utiliser le premier adaptateur disponible
                            $allAdapters = Get-NetAdapter -ErrorAction SilentlyContinue
                            if ($allAdapters -and $allAdapters.Count -gt 0) {
                                $adapter = $allAdapters[0]
                                $adapterToUseName = $adapter.Name
                                Write-Log "Utilisation du premier adaptateur disponible: $adapterToUseName" -Level "WARNING"
                            } else {
                                $errorMessage = "Aucun adaptateur réseau disponible sur le système"
                                Write-ConsoleLog "❌ $errorMessage" -Color Red
                                Write-Log $errorMessage -Level "ERROR"
                                return @{
                                    Success = $false
                                    Message = $errorMessage
                                }
                            }
                        }
                    }
                }
            }
        }
        
        # Vérification finale que nous avons bien un nom d'adaptateur
        if ([string]::IsNullOrEmpty($adapterToUseName)) {
            $errorMessage = "Impossible de déterminer un nom d'adaptateur valide"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        Write-Log "Adaptateur réseau sélectionné pour modification: $adapterToUseName" -Level "INFO"
        
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
        
        # Vérifier que nous avons des droits administrateur
        $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
        Write-Log "Exécution avec privilèges administrateur: $isAdmin" -Level "INFO"
        
        if (-not $isAdmin) {
            $errorMessage = "Des privilèges administrateur sont requis pour modifier l'adresse MAC"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Obtenir les détails complets de l'adaptateur avec Get-NetAdapter
        try {
            $fullAdapter = Get-NetAdapter -Name $adapterToUseName -ErrorAction Stop
            $interfaceAlias = $fullAdapter.InterfaceAlias
            $interfaceDescription = $fullAdapter.InterfaceDescription
            $interfaceGuid = $fullAdapter.InterfaceGuid
            $currentMac = $fullAdapter.MacAddress
            
            Write-Log "Détails de l'adaptateur:" -Level "INFO"
            Write-Log "  Nom: $adapterToUseName" -Level "INFO"
            Write-Log "  Alias: $interfaceAlias" -Level "INFO"
            Write-Log "  Description: $interfaceDescription" -Level "INFO"
            Write-Log "  GUID: $interfaceGuid" -Level "INFO"
            Write-Log "  Adresse MAC actuelle: $currentMac" -Level "INFO"
        } catch {
            $errorMessage = "Impossible d'obtenir les détails complets de l'adaptateur: $_"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            return @{
                Success = $false
                Message = $errorMessage
            }
        }
        
        # Préparer l'adresse MAC sans tirets
        $macWithoutDashes = $MacAddress.Replace('-', '')
        Write-Log "Adresse MAC à définir (sans tirets): $macWithoutDashes" -Level "INFO"
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Désactivation forcée de l'adaptateur..." -PercentComplete 30
        }
        
        # ÉTAPE AMÉLIORÉE : Désactivation FORCÉE de l'adaptateur avant toute tentative de modification
        Write-ConsoleLog "⏳ Désactivation FORCÉE de l'adaptateur réseau..." -Color Yellow
        Write-Log "Désactivation FORCÉE de l'adaptateur réseau: $adapterToUseName" -Level "INFO"
        
        $disableSuccess = $false
        $maxDisableAttempts = 3
        
        for ($attempt = 1; $attempt -le $maxDisableAttempts; $attempt++) {
            Write-Log "Tentative $attempt/$maxDisableAttempts de désactivation de l'adaptateur" -Level "INFO"
            
            # Méthode 1: PowerShell Disable-NetAdapter
            try {
                Write-Log "Méthode PowerShell: Disable-NetAdapter" -Level "INFO"
                Disable-NetAdapter -Name $adapterToUseName -Confirm:$false -ErrorAction Stop
                Write-Log "Commande Disable-NetAdapter exécutée sans erreur" -Level "INFO"
            } catch {
                Write-Log "Erreur avec Disable-NetAdapter: $_" -Level "WARNING"
            }
            
            # Méthode 2: Netsh
            try {
                Write-Log "Méthode Netsh: interface set interface disabled" -Level "INFO"
                $netshDisableCmd = "netsh interface set interface name=`"$interfaceAlias`" admin=disabled"
                Write-Log "Exécution: $netshDisableCmd" -Level "DEBUG"
                Invoke-Expression $netshDisableCmd | Out-Null
                Write-Log "Commande netsh exécutée" -Level "INFO"
            } catch {
                Write-Log "Erreur avec netsh disable: $_" -Level "WARNING"
            }
            
            # Méthode 3: WMI
            try {
                Write-Log "Méthode WMI: Disable via Win32_NetworkAdapter" -Level "INFO"
                $wmiAdapter = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -eq $adapterToUseName }
                if ($wmiAdapter) {
                    $wmiResult = $wmiAdapter.Disable()
                    Write-Log "Résultat WMI Disable: $($wmiResult.ReturnValue)" -Level "DEBUG"
                }
            } catch {
                Write-Log "Erreur avec WMI disable: $_" -Level "WARNING"
            }
            
            # Attendre que l'adaptateur soit complètement désactivé
            Write-Log "Attente de la désactivation complète..." -Level "INFO"
            $waitTime = 5  # Augmentation significative du temps d'attente
            Start-Sleep -Seconds $waitTime
            
            # Vérifier si l'adaptateur est réellement désactivé
            try {
                $adapterStatus = (Get-NetAdapter -Name $adapterToUseName -ErrorAction SilentlyContinue).Status
                Write-Log "Statut actuel de l'adaptateur: $adapterStatus" -Level "INFO"
                
                if ($adapterStatus -eq 'Disabled') {
                    $disableSuccess = $true
                    Write-Log "Adaptateur correctement désactivé après $attempt tentative(s)" -Level "SUCCESS"
                    Write-ConsoleLog "✅ Adaptateur correctement désactivé" -Color Green
                    break
                } else {
                    Write-Log "L'adaptateur n'est toujours pas désactivé (statut: $adapterStatus)" -Level "WARNING"
                    Write-ConsoleLog "⚠️ L'adaptateur n'est pas encore désactivé, nouvelle tentative..." -Color Yellow
                }
            } catch {
                Write-Log "Erreur lors de la vérification du statut: $_" -Level "ERROR"
            }
            
            # Si nous n'avons pas réussi, attendre avant de réessayer
            if (-not $disableSuccess -and $attempt -lt $maxDisableAttempts) {
                Write-Log "Attente avant nouvelle tentative de désactivation..." -Level "INFO"
                Start-Sleep -Seconds 3
            }
        }
        
        if (-not $disableSuccess) {
            Write-Log "AVERTISSEMENT: Impossible de confirmer la désactivation complète de l'adaptateur après $maxDisableAttempts tentatives" -Level "WARNING"
            Write-ConsoleLog "⚠️ La désactivation complète de l'adaptateur n'a pas pu être confirmée, mais tentative de modification quand même..." -Color Yellow
        }
        
        # Méthode supplémentaire: Tuer tout processus qui pourrait interférer
        try {
            Write-Log "Arrêt des processus qui pourraient interférer avec la modification de l'adresse MAC" -Level "INFO"
            Stop-Process -Name "WmiPrvSE" -Force -ErrorAction SilentlyContinue
            # Attendre que les processus soient bien arrêtés
            Start-Sleep -Seconds 2
        } catch {
            Write-Log "Erreur lors de l'arrêt des processus: $_" -Level "WARNING"
        }
        
        # MÉTHODE 1 : Tentative de modification via les propriétés avancées de l'adaptateur
        Write-ConsoleLog "⏳ Recherche de propriétés avancées pour l'adresse MAC..." -Color Yellow
        Write-Log "Tentative de localisation de propriétés avancées pour l'adresse MAC" -Level "INFO"
        
        $macPropertyFound = $false
        $macPropertySuccess = $false
        
        try {
            # Obtenir toutes les propriétés avancées de l'adaptateur
            $advancedProperties = Get-NetAdapterAdvancedProperty -Name $adapterToUseName -ErrorAction SilentlyContinue
            
            # Noms courants de propriétés pour l'adresse MAC
            $possibleMacProperties = @(
                "NetworkAddress", 
                "MACAddress", 
                "PermanentAddress", 
                "LocallyAdministeredAddress", 
                "SpooferAddress",
                "MAC Address",
                "Current Address",
                "Locally Administered Address",
                "NetworkAddressSpoof"
            )
            
            # Chercher si une de ces propriétés existe
            foreach ($prop in $advancedProperties) {
                Write-Log "Propriété avancée trouvée: $($prop.RegistryKeyword)" -Level "DEBUG"
                
                if ($possibleMacProperties -contains $prop.RegistryKeyword) {
                    $macPropertyFound = $true
                    $macPropertyName = $prop.RegistryKeyword
                    Write-Log "Propriété d'adresse MAC trouvée: $macPropertyName" -Level "INFO"
                    
                    # Adaptateur déjà désactivé, on passe directement à la modification
                    
                    # Modifier la propriété
                    Write-Log "Tentative de modification de la propriété avancée: $macPropertyName = $macWithoutDashes" -Level "INFO"
                    Set-NetAdapterAdvancedProperty -Name $adapterToUseName -RegistryKeyword $macPropertyName -RegistryValue $macWithoutDashes -ErrorAction Stop
                    Write-Log "Propriété avancée modifiée avec succès" -Level "INFO"
                    
                    # Réactiver l'adaptateur plus tard
                    $macPropertySuccess = $true
                    break  # Sortir de la boucle si on a réussi
                }
            }
            
            if (-not $macPropertyFound) {
                Write-Log "Aucune propriété avancée pour l'adresse MAC trouvée" -Level "INFO"
            } elseif (-not $macPropertySuccess) {
                Write-Log "Toutes les tentatives via propriétés avancées ont échoué" -Level "WARNING"
            }
        } catch {
            Write-Log "Erreur lors de la tentative de modification via propriété avancée: $_" -Level "ERROR"
        }
        
        # MÉTHODE 2 : Si la propriété avancée a échoué, modification directe du registre
        if (-not $macPropertySuccess) {
            Write-ConsoleLog "⏳ Modification directe du registre..." -Color Yellow
            Write-Log "Tentative de modification directe du registre" -Level "INFO"
            
            try {
                # Chemins de registre possibles
                $registryPaths = @(
                    "HKLM:\SYSTEM\CurrentControlSet\Control\Class\{4D36E972-E325-11CE-BFC1-08002BE10318}\*",
                    "HKLM:\SYSTEM\CurrentControlSet\Control\Network\*\*"
                )
                
                $registrySuccess = $false
                
                foreach ($basePath in $registryPaths) {
                    Write-Log "Recherche dans le chemin de registre: $basePath" -Level "DEBUG"
                    
                    # Parcourir tous les sous-chemins
                    Get-ChildItem -Path $basePath -ErrorAction SilentlyContinue | ForEach-Object {
                        $path = $_.PSPath
                        
                        # Vérifier si ce chemin correspond à notre adaptateur
                        $driverDesc = (Get-ItemProperty -Path $path -Name "DriverDesc" -ErrorAction SilentlyContinue).DriverDesc
                        $netCfgInstanceId = (Get-ItemProperty -Path $path -Name "NetCfgInstanceId" -ErrorAction SilentlyContinue).NetCfgInstanceId
                        
                        if (($driverDesc -eq $interfaceDescription) -or ($netCfgInstanceId -eq $interfaceGuid)) {
                            Write-Log "Trouvé dans le registre: $path" -Level "INFO"
                            
                            # Définir la nouvelle adresse MAC
                            try {
                                Set-ItemProperty -Path $path -Name "NetworkAddress" -Value $macWithoutDashes -ErrorAction Stop
                                Write-Log "Adresse MAC définie dans le registre" -Level "INFO"
                                $registrySuccess = $true
                            } catch {
                                Write-Log "Erreur lors de la définition de l'adresse MAC dans le registre: $_" -Level "ERROR"
                            }
                        }
                    }
                    
                    if ($registrySuccess) {
                        break  # Sortir de la boucle si on a réussi
                    }
                }
                
                if (-not $registrySuccess) {
                    Write-Log "Aucune entrée de registre correspondante trouvée ou modification échouée" -Level "WARNING"
                }
            } catch {
                Write-Log "Erreur lors de la tentative de modification du registre: $_" -Level "ERROR"
            }
        }
        
        # MÉTHODE 3 : Modification via netsh (si les autres méthodes ont échoué)
        if (-not ($macPropertySuccess -or $registrySuccess)) {
            Write-ConsoleLog "⏳ Modification de l'adresse MAC via netsh..." -Color Yellow
            Write-Log "Tentative de modification de l'adresse MAC via netsh" -Level "INFO"
            
            # Créer la commande netsh
            $netshCommand = "netsh interface set interface name=`"$interfaceAlias`" newmac=$macWithoutDashes"
            Write-Log "Commande netsh pour MAC: $netshCommand" -Level "INFO"
            
            try {
                $netshOutput = Invoke-Expression $netshCommand 2>&1
                if ($netshOutput) {
                    $netshOutput | ForEach-Object { Write-Log "Netsh (MAC): $_" -Level "INFO" }
                } else {
                    Write-Log "Commande netsh exécutée sans sortie (généralement bon signe)" -Level "INFO"
                }
                
                # Attendre que les changements prennent effet
                Start-Sleep -Seconds 3
            }
            catch {
                $errorMessage = "Erreur lors de l'exécution de la commande netsh: $_"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                Write-Log $errorMessage -Level "ERROR"
            }
        }
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Réactivation de l'adaptateur..." -PercentComplete 80
        }
        
        # Réactiver l'adaptateur
        Write-ConsoleLog "⏳ Réactivation de l'adaptateur réseau..." -Color Yellow
        Write-Log "Réactivation de l'adaptateur réseau: $adapterToUseName" -Level "INFO"
        
        $enableSuccess = $false
        $maxEnableAttempts = 3
        
        for ($attempt = 1; $attempt -le $maxEnableAttempts; $attempt++) {
            Write-Log "Tentative $attempt/$maxEnableAttempts de réactivation de l'adaptateur" -Level "INFO"
            
            # Méthode 1: PowerShell Enable-NetAdapter
            try {
                Write-Log "Méthode PowerShell: Enable-NetAdapter" -Level "INFO"
                Enable-NetAdapter -Name $adapterToUseName -Confirm:$false -ErrorAction Stop
                Write-Log "Commande Enable-NetAdapter exécutée sans erreur" -Level "INFO"
            } catch {
                Write-Log "Erreur avec Enable-NetAdapter: $_" -Level "WARNING"
            }
            
            # Méthode 2: Netsh
            try {
                Write-Log "Méthode Netsh: interface set interface enabled" -Level "INFO"
                $netshEnableCmd = "netsh interface set interface name=`"$interfaceAlias`" admin=enabled"
                Write-Log "Exécution: $netshEnableCmd" -Level "DEBUG"
                Invoke-Expression $netshEnableCmd | Out-Null
                Write-Log "Commande netsh enable exécutée" -Level "INFO"
            } catch {
                Write-Log "Erreur avec netsh enable: $_" -Level "WARNING"
            }
            
            # Méthode 3: WMI
            try {
                Write-Log "Méthode WMI: Enable via Win32_NetworkAdapter" -Level "INFO"
                $wmiAdapter = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object { $_.NetConnectionID -eq $adapterToUseName }
                if ($wmiAdapter) {
                    $wmiResult = $wmiAdapter.Enable()
                    Write-Log "Résultat WMI Enable: $($wmiResult.ReturnValue)" -Level "DEBUG"
                }
            } catch {
                Write-Log "Erreur avec WMI enable: $_" -Level "WARNING"
            }
            
            # Attendre que l'adaptateur soit complètement activé
            Write-Log "Attente de l'activation complète..." -Level "INFO"
            $waitTime = 10  # Temps d'attente significatif
            Start-Sleep -Seconds $waitTime
            
            # Vérifier si l'adaptateur est réellement activé
            try {
                $adapterStatus = (Get-NetAdapter -Name $adapterToUseName -ErrorAction SilentlyContinue).Status
                Write-Log "Statut actuel de l'adaptateur après réactivation: $adapterStatus" -Level "INFO"
                
                if ($adapterStatus -eq 'Up') {
                    $enableSuccess = $true
                    Write-Log "Adaptateur correctement réactivé après $attempt tentative(s)" -Level "SUCCESS"
                    Write-ConsoleLog "✅ Adaptateur correctement réactivé" -Color Green
                    break
                } else {
                    Write-Log "L'adaptateur n'est toujours pas activé (statut: $adapterStatus)" -Level "WARNING"
                    Write-ConsoleLog "⚠️ L'adaptateur n'est pas encore activé, nouvelle tentative..." -Color Yellow
                }
            } catch {
                Write-Log "Erreur lors de la vérification du statut de réactivation: $_" -Level "ERROR"
            }
            
            # Si nous n'avons pas réussi, attendre avant de réessayer
            if (-not $enableSuccess -and $attempt -lt $maxEnableAttempts) {
                Write-Log "Attente avant nouvelle tentative de réactivation..." -Level "INFO"
                Start-Sleep -Seconds 3
            }
        }
        
        if (-not $enableSuccess) {
            Write-Log "AVERTISSEMENT: Impossible de confirmer la réactivation complète de l'adaptateur après $maxEnableAttempts tentatives" -Level "WARNING"
            Write-ConsoleLog "⚠️ La réactivation complète de l'adaptateur n'a pas pu être confirmée" -Color Yellow
        }
        
        # Mettre à jour la barre de progression
        if ($ProgressBar) {
            Update-ProgressBar -ProgressBar $ProgressBar -Status "Vérification du changement..." -PercentComplete 90
        }
        
        # Attendre plus longtemps pour que les changements prennent effet
        Write-Log "Attente supplémentaire pour la stabilisation de l'adaptateur..." -Level "INFO"
        Start-Sleep -Seconds 10
        
        # Vérifier si la modification a fonctionné
        Write-ConsoleLog "⏳ Vérification de la modification..." -Color Yellow
        Write-Log "Vérification de la modification de l'adresse MAC" -Level "INFO"
        
        try {
            # Tenter plusieurs fois de récupérer l'adaptateur mis à jour
            $updatedAdapter = $null
            $maxCheckAttempts = 3
            
            for ($attempt = 1; $attempt -le $maxCheckAttempts; $attempt++) {
                Write-Log "Tentative $attempt/$maxCheckAttempts de vérification de l'adresse MAC" -Level "INFO"
                
                try {
                    $updatedAdapter = Get-NetAdapter -Name $adapterToUseName -ErrorAction Stop
                    if ($updatedAdapter) { break }
                } catch {
                    Write-Log "Erreur lors de la récupération de l'adaptateur: $_" -Level "WARNING"
                    Start-Sleep -Seconds 2
                }
            }
            
            if ($updatedAdapter) {
                $newMac = $updatedAdapter.MacAddress
                
                Write-Log "Ancienne adresse MAC: $currentMac" -Level "INFO"
                Write-Log "Nouvelle adresse MAC: $newMac" -Level "INFO"
                
                # Normaliser les deux adresses pour comparaison
                $expectedClean = $MacAddress.Replace("-", "").Replace(":", "").ToUpper()
                $actualClean = $newMac.Replace("-", "").Replace(":", "").ToUpper()
                
                if ($actualClean -eq $expectedClean) {
                    Write-ConsoleLog "✅ Adresse MAC modifiée avec succès" -Color Green
                    Write-Log "Adresse MAC modifiée avec succès pour $adapterToUseName" -Level "SUCCESS"
                    
                    # Mettre à jour la barre de progression
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Modification réussie" -PercentComplete 100
                    }
                    
                    Write-Log "*********** FIN DE LA MODIFICATION D'ADRESSE MAC (SUCCÈS) ***********" -Level "INFO"
                    
                    return @{
                        Success = $true
                        Message = "Adresse MAC modifiée avec succès"
                        OldValue = $currentMac
                        NewValue = $newMac
                    }
                } else {
                    $errorMessage = "L'adresse MAC n'a pas été modifiée comme prévu"
                    Write-ConsoleLog "❌ $errorMessage" -Color Red
                    Write-Log "$errorMessage (attendu: $expectedClean, obtenu: $actualClean)" -Level "ERROR"
                    
                    # Méthode de dernier recours - informer sur les options manuelles
                    Write-Log "Toutes les méthodes automatiques de modification d'adresse MAC ont échoué" -Level "ERROR"
                    Write-Log "Suggestion pour l'utilisateur : Essayer de désactiver l'adaptateur manuellement" -Level "INFO"
                    
                    # Mettre à jour la barre de progression
                    if ($ProgressBar) {
                        Update-ProgressBar -ProgressBar $ProgressBar -Status "Échec de la modification" -PercentComplete 100
                    }
                    
                    Write-Log "*********** FIN DE LA MODIFICATION D'ADRESSE MAC (ÉCHEC) ***********" -Level "ERROR"
                    
                    $finalErrorMessage = "Impossible de modifier l'adresse MAC malgré plusieurs tentatives. Veuillez essayer de désactiver manuellement l'adaptateur via le Gestionnaire de périphériques avant de réessayer."
                    Write-ConsoleLog "❌ $finalErrorMessage" -Color Red
                    
                    return @{
                        Success = $false
                        Message = $finalErrorMessage
                    }
                }
            } else {
                $errorMessage = "Impossible de récupérer l'adaptateur après modification"
                Write-ConsoleLog "❌ $errorMessage" -Color Red
                Write-Log $errorMessage -Level "ERROR"
                
                return @{
                    Success = $false
                    Message = $errorMessage
                }
            }
        } catch {
            $errorMessage = "Erreur lors de la vérification de l'adresse MAC: $_"
            Write-ConsoleLog "❌ $errorMessage" -Color Red
            Write-Log $errorMessage -Level "ERROR"
            
            # Mettre à jour la barre de progression
            if ($ProgressBar) {
                Update-ProgressBar -ProgressBar $ProgressBar -Status "Erreur" -PercentComplete 100
            }
            
            Write-Log "*********** FIN DE LA MODIFICATION D'ADRESSE MAC (ERREUR) ***********" -Level "ERROR"
            
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
        
        Write-Log "*********** FIN DE LA MODIFICATION D'ADRESSE MAC (EXCEPTION) ***********" -Level "ERROR"
        
        return @{
            Success = $false
            Message = $errorMessage
        }
    }
}

#endregion

#region Fonctions d'attente et d'initialisation

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
        $adapters = Get-NetworkAdapters
        
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

# Initialiser le module de gestion des adaptateurs réseau et adresses MAC
function Initialize-NetworkAdapter {
    Write-ConsoleLog "🔍 Initialisation du module de gestion des adaptateurs réseau..." -Color Cyan
    
    try {
        $networkInfo = Get-NetworkInformation
        
        if ($networkInfo.Success) {
            Write-ConsoleLog "✅ Module de gestion des adaptateurs réseau initialisé avec succès" -Color Green
            Write-Log "Module de gestion des adaptateurs réseau initialisé avec succès" -Level "SUCCESS"
            
            # Vérifier si la génération d'adresse MAC fonctionne
            $testMac = New-MacAddress
            if ([string]::IsNullOrEmpty($testMac)) {
                Write-ConsoleLog "⚠️ La génération d'adresse MAC pourrait ne pas fonctionner correctement" -Color Yellow
                Write-Log "La génération d'adresse MAC pourrait ne pas fonctionner correctement" -Level "WARNING"
            } else {
                Write-Log "Test de génération d'adresse MAC réussi: $testMac" -Level "DEBUG"
            }
            
            return $true
        } 
        else {
            Write-ConsoleLog "⚠️ Module initialisé avec avertissement: $($networkInfo.Message)" -Color Yellow
            Write-Log "Module initialisé avec avertissement: $($networkInfo.Message)" -Level "WARNING"
            return $true # On retourne quand même true car l'absence de carte réseau n'est pas une erreur critique
        }
    }
    catch {
        Write-ConsoleLog "❌ Erreur lors de l'initialisation du module de gestion des adaptateurs réseau: $_" -Color Red
        Write-Log "Erreur lors de l'initialisation du module de gestion des adaptateurs réseau: $_" -Level "ERROR"
        return $false
    }
} 

#endregion 