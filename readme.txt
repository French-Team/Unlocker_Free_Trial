=================================================================
Outil de modification du MachineGuid - Documentation
=================================================================

Description
-----------
Cet outil permet de modifier l'identifiant unique de la machine (MachineGuid)
dans le registre Windows. Cette modification est utile pour réinitialiser
l'identité de la machine auprès de certaines applications.

Fonctionnalités
--------------
1. Lecture du MachineGuid actuel
2. Génération d'un nouveau GUID aléatoire
3. Modification sécurisée du MachineGuid avec sauvegarde automatique
4. Restauration automatique en cas d'erreur
5. Tests automatisés des fonctionnalités
6. Interface graphique intégrée

Fichiers principaux
------------------
- Step7_RegistryManager.ps1 : Module principal de gestion du registre
- test_registry_guid.ps1    : Script de test autonome
- test_change_machine_guid.bat : Lanceur de test facile à utiliser

Utilisation
----------
1. Mode automatique (recommandé) :
   - Lancez l'application principale
   - Cliquez sur "Exécuter toutes les actions"
   - La modification du MachineGuid sera incluse dans le processus

2. Mode test :
   - Double-cliquez sur "test_change_machine_guid.bat"
   - Suivez les instructions à l'écran

3. Mode manuel :
   - Ouvrez PowerShell en tant qu'administrateur
   - Importez le module : . .\Step7_RegistryManager.ps1
   - Utilisez les commandes : Get-MachineGuid, New-MachineGuid, Set-MachineGuid

Sécurité
--------
- Une sauvegarde est créée avant chaque modification
- Les sauvegardes sont stockées dans %USERPROFILE%\MachineGuid_Backups
- Restauration automatique en cas d'erreur
- Validation du format GUID avant modification

Notes importantes
---------------
- Nécessite des droits administrateur
- Redémarrage recommandé après modification
- Conservez les fichiers de sauvegarde
- En cas de problème, utilisez les fichiers .reg de sauvegarde

Support
-------
En cas de problème :
1. Vérifiez les logs dans test_results.log
2. Consultez les sauvegardes dans le dossier MachineGuid_Backups
3. Utilisez le script de test pour valider l'installation

================================================================= 