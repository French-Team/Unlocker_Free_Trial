# Composition du Projet Unlocker Free Trial

Ce document décrit la structure détaillée du projet Unlocker Free Trial, en précisant le rôle de chaque fichier, les dépendances entre eux, et les tests unitaires associés à chaque fonction.

## Structure Générale

Le projet suit une architecture modulaire avec un fichier principal (`start.ps1`) qui orchestre le chargement et l'exécution des différents modules. Chaque module est responsable d'une fonctionnalité spécifique et expose clairement ses dépendances.

## Fichiers et Leurs Rôles

### 1. start.ps1

**Rôle** : Point d'entrée principal de l'application. Charge tous les modules, initialise l'environnement et lance l'interface utilisateur.

**Dépendances** :
- Charge tous les modules (Step1 à Step14)

**Fonctions principales** :
- `Load-StepModule` : Charge un module spécifique
- `Write-ConsoleLog` : Affiche des messages dans la console

**Tests unitaires** :
- Test de chargement des modules
- Test d'initialisation de l'environnement

### 2. Step1_AdminCheck.ps1

**Rôle** : Vérifier si l'application est exécutée avec des droits administrateur et relancer si nécessaire.

**Dépendances** :
- Aucune dépendance externe

**Fonctions principales** :
- `Check-AdminRights` : Vérifie les droits administrateur et relance le script si nécessaire

**Tests unitaires** :
- Test de détection des droits administrateur
- Test de relancement du script

### 3. Step2_Logging.ps1

**Rôle** : Fournir des fonctionnalités de journalisation pour l'application.

**Dépendances** :
- Utilise les fonctions globales définies dans start.ps1

**Fonctions principales** :
- `Initialize-LogFile` : Initialise le fichier de log
- `Write-Log` : Écrit un message dans le fichier de log
- `Initialize-Logging` : Initialise le système de journalisation

**Tests unitaires** :
- Test de création du fichier de log
- Test d'écriture dans le fichier de log

### 4. Step3_Configuration.ps1

**Rôle** : Gérer la configuration globale de l'application.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)

**Fonctions principales** :
- `Get-AppConfig` : Récupère la configuration
- `Update-AppConfig` : Met à jour la configuration
- `Initialize-Configuration` : Initialise la configuration

**Tests unitaires** :
- Test de récupération de la configuration
- Test de mise à jour de la configuration

### 5. Step4_Storage.ps1

**Rôle** : Gérer le stockage de données dans un fichier JSON.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)
- Step3_Configuration.ps1 (pour les chemins de fichier)

**Fonctions principales** :
- `Get-StoragePath` : Obtient le chemin du fichier de stockage
- `Test-StorageExists` : Vérifie si le fichier de stockage existe
- `New-Storage` : Crée un nouveau fichier de stockage
- `Get-StorageContent` : Lit le contenu du fichier de stockage
- `Update-Storage` : Met à jour le contenu du fichier de stockage
- `Remove-Storage` : Supprime le fichier de stockage

**Tests unitaires** :
- Test de création du fichier de stockage
- Test de lecture du fichier de stockage
- Test de mise à jour du fichier de stockage
- Test de suppression du fichier de stockage

### 6. Step5_NetworkInfo.ps1

**Rôle** : Collecter et fournir des informations sur les cartes réseau.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)

**Fonctions principales** :
- `Get-NetworkAdapters` : Récupère la liste des cartes réseau
- `Get-NetworkAdapterDetails` : Obtient les détails d'une carte réseau spécifique
- `Format-NetworkAdapterInfo` : Formate les informations d'une carte réseau pour l'affichage

**Tests unitaires** :
- Test de récupération des cartes réseau
- Test de récupération des détails d'une carte réseau

### 7. Step6_MacAddress.ps1

**Rôle** : Gérer les opérations liées aux adresses MAC.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)
- Step5_NetworkInfo.ps1 (pour les informations sur les cartes réseau)

**Fonctions principales** :
- `New-MacAddress` : Génère une nouvelle adresse MAC aléatoire
- `Test-MacAddress` : Valide une adresse MAC
- `Set-MacAddress` : Modifie l'adresse MAC d'une carte réseau

**Tests unitaires** :
- Test de génération d'adresse MAC
- Test de validation d'adresse MAC
- Test de modification d'adresse MAC

### 8. Step7_MachineGuid.ps1

**Rôle** : Gérer les opérations liées au GUID de la machine.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)

**Fonctions principales** :
- `New-MachineGuid` : Génère un nouveau GUID aléatoire
- `Get-CurrentMachineGuid` : Récupère le GUID actuel de la machine
- `Set-MachineGuid` : Modifie le GUID de la machine

**Tests unitaires** :
- Test de génération de GUID
- Test de récupération du GUID actuel
- Test de modification du GUID

### 9. Step8_FileManager.ps1

**Rôle** : Gérer les opérations sur les fichiers du système.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)
- Step4_Storage.ps1 (pour le stockage)

**Fonctions principales** :
- `Get-CursorStoragePath` : Obtient le chemin du fichier de stockage
- `Remove-CursorStorage` : Supprime le fichier de stockage

**Tests unitaires** :
- Test de récupération du chemin du fichier de stockage
- Test de suppression du fichier de stockage

### 10. Step9_Initialization.ps1

**Rôle** : Initialiser l'application et préparer l'environnement.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)
- Step3_Configuration.ps1 (pour la configuration)
- Step5_NetworkInfo.ps1 (pour les informations réseau)

**Fonctions principales** :
- `Initialize-Environment` : Initialise l'environnement d'exécution
- `Wait-ForNetworkCard` : Attend que la carte réseau soit disponible
- `Refresh-NetworkInfo` : Rafraîchit les informations réseau

**Tests unitaires** :
- Test d'initialisation de l'environnement
- Test d'attente de la carte réseau
- Test de rafraîchissement des informations réseau

### 11. Step10_ProgressBar.ps1

**Rôle** : Gérer la barre de progression dans l'interface utilisateur.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)

**Fonctions principales** :
- `Initialize-ProgressBar` : Initialise la barre de progression
- `Update-ProgressBar` : Met à jour la barre de progression
- `Update-StepProgress` : Met à jour la progression d'une étape
- `Reset-ProgressBar` : Réinitialise la barre de progression

**Tests unitaires** :
- Test d'initialisation de la barre de progression
- Test de mise à jour de la barre de progression
- Test de réinitialisation de la barre de progression

### 12. Step11_ExecuteAll.ps1

**Rôle** : Exécuter toutes les actions principales en séquence.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)
- Step4_Storage.ps1 (pour le stockage)
- Step6_MacAddress.ps1 (pour la modification de l'adresse MAC)
- Step7_MachineGuid.ps1 (pour la modification du GUID)
- Step8_FileManager.ps1 (pour la gestion des fichiers)
- Step10_ProgressBar.ps1 (pour la barre de progression)

**Fonctions principales** :
- `Invoke-ScriptWithProgress` : Exécute un script avec mise à jour de la progression
- `Execute-AllActions` : Exécute toutes les actions en séquence

**Tests unitaires** :
- Test d'exécution d'un script avec progression
- Test d'exécution de toutes les actions

### 13. Step12_Visuals.ps1

**Rôle** : Définir les éléments visuels de l'interface utilisateur.

**Dépendances** :
- Step3_Configuration.ps1 (pour la configuration)

**Fonctions principales** :
- `New-Button` : Crée un bouton
- `New-Label` : Crée une étiquette
- `New-ProgressBar` : Crée une barre de progression
- `New-Form` : Crée un formulaire

**Tests unitaires** :
- Test de création de bouton
- Test de création d'étiquette
- Test de création de barre de progression
- Test de création de formulaire

### 14. Step13_Interface.ps1

**Rôle** : Gérer l'interface utilisateur principale.

**Dépendances** :
- Tous les modules précédents

**Fonctions principales** :
- `Initialize-Interface` : Initialise l'interface utilisateur
- Gestionnaires d'événements pour les boutons
- `Show-Interface` : Affiche l'interface utilisateur

**Tests unitaires** :
- Test d'initialisation de l'interface
- Test des gestionnaires d'événements

### 15. Step14_FileTester.ps1

**Rôle** : Tester la présence des fichiers nécessaires à l'application.

**Dépendances** :
- Step2_Logging.ps1 (pour la journalisation)

**Fonctions principales** :
- `Test-RequiredFile` : Vérifie si un fichier requis existe
- `Test-AllRequiredFiles` : Vérifie tous les fichiers requis

**Tests unitaires** :
- Test de vérification d'un fichier
- Test de vérification de tous les fichiers

## Dépendances Globales

```
start.ps1
↓
Step1_AdminCheck.ps1
↓
Step2_Logging.ps1
↓
Step3_Configuration.ps1 ← Step4_Storage.ps1
                       ↓
Step5_NetworkInfo.ps1 → Step6_MacAddress.ps1
                       ↓
                       Step7_MachineGuid.ps1
                       ↓
Step8_FileManager.ps1 ← Step9_Initialization.ps1
                       ↓
Step10_ProgressBar.ps1 ← Step11_ExecuteAll.ps1
                       ↓
Step12_Visuals.ps1 ← Step13_Interface.ps1
                   ↓
                   Step14_FileTester.ps1
```

## Processus de Test

Conformément à l'approche TDD (Test-Driven Development), chaque fonctionnalité sera développée en suivant le cycle Red-Green-Refactor :

1. **Red** : Écrire des tests unitaires pour la fonctionnalité (qui échoueront initialement)
2. **Green** : Implémenter la fonctionnalité pour faire passer les tests
3. **Refactor** : Optimiser le code sans casser les tests existants

Les tests unitaires seront exécutés automatiquement après chaque modification significative du code pour garantir la stabilité de l'application. 