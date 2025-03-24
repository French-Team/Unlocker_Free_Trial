# Cahier des Charges - Unlocker Free Trial

## 1. Introduction

### 1.1 Présentation du Projet
Le projet "Unlocker Free Trial" consiste en la restructuration complète d'une application PowerShell existante qui permet de modifier l'adresse MAC des cartes réseau et de réinitialiser l'identifiant unique de la machine (GUID). L'objectif principal est de transformer une architecture monolithique en une architecture modulaire suivant les principes de modularité, de TDD (Test-Driven Development) et du principe "Open/Closed".

### 1.2 Portée du Document
Ce cahier des charges définit les exigences fonctionnelles et techniques pour la restructuration de l'application. Il servira de référence pour les développeurs et les testeurs tout au long du projet.

## 2. Architecture Globale

### 2.1 Principes Architecturaux
L'architecture du projet suivra les principes suivants :
- **Modularité** : Séparation claire des responsabilités
- **Test-Driven Development (TDD)** : Développement guidé par les tests
- **Principe Open/Closed** : Les modules sont ouverts à l'extension mais fermés à la modification
- **Injection de dépendances** : Les dépendances sont injectées plutôt que créées à l'intérieur des modules

### 2.2 Structure des Fichiers
La structure du projet suivra une approche modulaire avec un fichier central `start.ps1` qui orchestre l'exécution des différents modules. Chaque module sera défini dans un fichier distinct avec des responsabilités clairement définies.

```
final/
│
├── start.ps1                  # Point d'entrée principal
├── Step1_AdminCheck.ps1       # Vérification des droits administrateur
├── Step2_Logging.ps1          # Système de journalisation
├── Step3_Configuration.ps1    # Configuration de l'application
├── Step4_Storage.ps1          # Gestion du stockage
├── Step5_NetworkInfo.ps1      # Informations sur le réseau
├── Step6_MacAddress.ps1       # Gestion des adresses MAC
├── Step7_MachineGuid.ps1      # Gestion du GUID machine
├── Step8_Delete_storage.json.ps1      # Gestion de storage.json dans cursor/
├── Step9_Initialization.ps1   # Initialisation de l'application
├── Step10_ProgressBar.ps1     # Gestion de la barre de progression
├── Step11_ExecuteAll.ps1      # Exécution de toutes les actions
├── Step12_Visuals.ps1         # Éléments visuels de l'interface
├── Step13_Interface.ps1       # Interface principale
├── Step14_FileTester.ps1      # Tests de présence des fichiers
│
└── docs/                      # Documentation
    ├── brief.md               # Brief du projet
    ├── CDC.md                 # Cahier des charges
    └── composition.md         # Description de la structure
```

## 3. Spécifications Fonctionnelles

### 3.1 Vérification des Droits Administrateur
- L'application doit vérifier si elle est exécutée avec des droits administrateur
- Si les droits ne sont pas suffisants, l'application doit se relancer avec des droits élevés

### 3.2 Journalisation
- Toutes les actions et erreurs doivent être journalisées dans un fichier de log
- Le système de log doit inclure horodatage, niveau de sévérité et message

### 3.3 Gestion du Stockage
- L'application doit gérer un fichier de stockage JSON pour les données persistantes
- Fonctions pour créer, lire, mettre à jour et supprimer le fichier de stockage
- Messages clairs concernant le statut du fichier (existant, créé, supprimé, etc.)

### 3.4 Modification d'Adresse MAC
- L'application doit lister toutes les cartes réseau disponibles
- Permettre la génération d'une nouvelle adresse MAC aléatoire
- Modifier l'adresse MAC dans le registre Windows
- Vérifier que la modification a été appliquée

### 3.5 Réinitialisation du GUID Machine
- Générer un nouveau GUID aléatoire
- Modifier le GUID dans le registre Windows
- Vérifier que la modification a été appliquée

### 3.6 Interface Utilisateur
- Interface Windows Forms simple et intuitive
- Boutons pour chaque action principale
- Barre de progression positionnée sous le bouton "ExecuteAll"
- Affichage des messages de statut clairs et précis

### 3.7 Exécution de Toutes les Actions
- Un bouton pour exécuter toutes les actions en séquence
- Affichage de la progression pour chaque étape
- Rapport de synthèse des actions effectuées

## 4. Spécifications Techniques

### 4.1 Langage et Framework
- PowerShell 5.1 ou supérieur
- Windows Forms pour l'interface graphique

### 4.2 Compatibilité
- Windows 10 et versions ultérieures
- PowerShell 5.1 ou supérieur

### 4.3 Sécurité
- Exécution uniquement avec des droits administrateur
- Vérification des permissions avant toute modification du registre

### 4.4 Performance
- L'application doit démarrer en moins de 5 secondes
- Chaque opération individuelle ne doit pas dépasser 10 secondes d'exécution

### 4.5 Tests
- Tests unitaires pour chaque fonction
- Tests d'intégration pour les interactions entre modules
- Tests fonctionnels pour valider le comportement global

## 5. Livrables

### 5.1 Code Source
- Ensemble des fichiers PowerShell structurés selon l'architecture définie
- Documentation du code intégrée (commentaires)

### 5.2 Documentation
- Brief du projet (brief.md)
- Cahier des charges (CDC.md)
- Description de la structure (composition.md)
- Guide d'utilisation pour les utilisateurs finaux

### 5.3 Tests
- Suite de tests unitaires
- Rapport de tests

## 6. Critères d'Acceptation

### 6.1 Fonctionnels
- Toutes les fonctionnalités de l'application originale sont préservées
- L'interface utilisateur est intuitive et informative
- Les messages d'erreur sont clairs et actionnables

### 6.2 Techniques
- Le code suit les principes de modularité et du principe Open/Closed
- Tous les tests unitaires passent avec succès
- L'application fonctionne sur les systèmes Windows cibles

### 6.3 Documentation
- La documentation est complète et à jour
- Le code est bien commenté et suit les conventions de nommage

## 7. Planning et Phases

### 7.1 Phase 1 : Analyse et Conception
- Analyse du code existant
- Conception de la nouvelle architecture
- Validation du cahier des charges

### 7.2 Phase 2 : Développement
- Implémentation des modules de base
- Développement des fonctionnalités principales
- Intégration des modules

### 7.3 Phase 3 : Tests et Validation
- Exécution des tests unitaires et fonctionnels
- Correction des bugs identifiés
- Validation finale

### 7.4 Phase 4 : Déploiement
- Préparation de la version finale
- Documentation utilisateur
- Formation des utilisateurs 