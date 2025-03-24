# Brief du Projet - Unlocker Free Trial

## Contexte

L'application "Unlocker Free Trial" est un outil de gestion permettant de modifier l'adresse MAC des cartes réseau et de réinitialiser l'identifiant unique de la machine (GUID). Ces modifications permettent de réinitialiser les périodes d'essai de certains logiciels qui utilisent ces identifiants pour limiter la durée d'utilisation.

Le code actuel fonctionne mais présente plusieurs problèmes :
- Une structure monolithique difficile à maintenir
- Des fonctions aux responsabilités mal définies
- Des erreurs de gestion d'interface utilisateur
- Des messages d'information incohérents ou trompeurs

## Objectif du Projet

Restructurer complètement l'application en suivant une architecture modulaire afin de :
1. **Améliorer la maintenabilité** : Séparer clairement les responsabilités
2. **Faciliter les évolutions futures** : Permettre l'ajout de nouvelles fonctionnalités sans modifier le code existant
3. **Renforcer la fiabilité** : Garantir un comportement cohérent et prévisible
4. **Améliorer l'expérience utilisateur** : Fournir des informations claires et précises

## Principales Fonctionnalités

- Vérification des droits administrateur
- Journalisation des actions et des erreurs
- Modification de l'adresse MAC des cartes réseau
- Réinitialisation du GUID de la machine
- Gestion d'un fichier de stockage pour les données persistantes
- Interface utilisateur claire avec barre de progression
- Exécution de toutes les actions en une seule opération

## Public Cible

L'application est destinée aux utilisateurs techniques qui comprennent les implications de la modification de ces paramètres système.

## Contraintes Techniques

- Langage : PowerShell
- Interface : Windows Forms
- Compatibilité : Windows 10 et versions ultérieures
- Exécution avec des droits administrateur
- Maintien des fonctionnalités existantes

## Délais

Le projet est à réaliser selon un calendrier à définir, avec une phase initiale de restructuration suivie de tests approfondis avant mise en production. 