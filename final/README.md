# Unlocker Free Trial

## Description
Unlocker Free Trial est un utilitaire qui vous permet de réinitialiser différents identifiants système pour recommencer des périodes d'essai de logiciels. Il effectue trois opérations principales :

1. **Suppression du fichier de stockage** : Supprime le fichier `storage.json` qui stocke les informations d'identification de certains logiciels.
2. **Réinitialisation de l'adresse MAC** : Modifie l'adresse MAC (Media Access Control) de votre carte réseau principale.
3. **Réinitialisation du GUID machine** : Change l'identifiant unique global (GUID) de votre machine dans le registre Windows.

## Architecture
Cette application a été développée suivant les principes de modularité et de séparation des responsabilités (TDD). Chaque module a une fonction spécifique :

- **Step1_AdminCheck** : Vérifie et gère les privilèges administrateur
- **Step2_Logging** : Système de journalisation
- **Step3_Configuration** : Gestion de la configuration
- **Step4_Storage** : Gestion du stockage d'application
- **Step5_NetworkInfo** : Informations sur le réseau
- **Step6_MacAddress** : Gestion des adresses MAC
- **Step7_MachineGuid** : Gestion du GUID machine
- **Step8_FileManager** : Opérations sur les fichiers
- **Step9_Initialization** : Initialisation coordonnée
- **Step10_ProgressBar** : Barres de progression
- **Step11_ExecuteAll** : Exécution des actions
- **Step12_Visuals** : Éléments visuels
- **Step13_Interface** : Interface utilisateur principale
- **Step14_FinalTester** : Tests de fonctionnement du demarrage de la fenetre de l'interface

## Prérequis
- Windows 10 ou supérieur
- PowerShell 5.1 ou supérieur
- Droits d'administrateur pour certaines fonctionnalités

## Installation
1. Téléchargez l'archive de l'application
2. Extrayez tous les fichiers dans un dossier de votre choix
3. Assurez-vous que tous les fichiers .ps1 sont présents dans le dossier

## Utilisation
### Méthode 1 : Lancement avec launcher.bat
1. Double-cliquez sur `launcher.bat`
2. Si demandé, acceptez l'élévation des privilèges administrateur

### Méthode 2 : Lancement via PowerShell
1. Ouvrez PowerShell en tant qu'administrateur
2. Naviguez jusqu'au dossier de l'application : `cd chemin\vers\dossier`
3. Exécutez la commande : `.\start.ps1`

## Interface utilisateur
L'application présente une interface graphique intuitive avec quatre sections principales :

1. **Suppression du fichier de stockage** : Bouton pour supprimer uniquement le fichier storage.json
2. **Réinitialisation de l'adresse MAC** : Bouton pour modifier uniquement l'adresse MAC
3. **Réinitialisation du GUID machine** : Bouton pour modifier uniquement le GUID machine
4. **Exécuter toutes les actions** : Bouton pour exécuter les trois actions ensemble

Chaque action affiche sa progression et un compte-rendu détaillé du résultat.

## Résolution des problèmes courants
- **Erreur "Fichiers requis manquants"** : Vérifiez que tous les fichiers .ps1 sont présents dans le dossier.
- **Erreur "Impossible de modifier le registre"** : Assurez-vous de lancer l'application avec des droits administrateur.
- **Erreur "Aucun adaptateur réseau disponible"** : Vérifiez que vous disposez d'une carte réseau active.

## Remarques importantes
- L'application crée des sauvegardes du registre avant toute modification
- Les fichiers de journalisation sont créés dans un sous-dossier "logs"
- Certaines opérations peuvent nécessiter un redémarrage pour prendre effet

## Sécurité
Cette application modifie des éléments importants de votre système. Utilisez-la à vos propres risques.
- Les modifications du registre sont sauvegardées avant application
- L'application ne collecte ni ne transmet aucune donnée personnelle

## Développement
Cette application a été développée avec PowerShell et suit les principes de modularité et de séparation des responsabilités.
- **Architecture modulaire** : Chaque module a une responsabilité unique
- **Gestion d'erreurs robuste** : Tous les cas d'erreur sont traités
- **Interface utilisateur claire** : Feedback visuel pour toutes les opérations 