# 🔓 Unlocker Free Trial

<div align="center">

![Version](https://img.shields.io/badge/version-1.0.0-blue.svg?style=flat-square)
![PowerShell](https://img.shields.io/badge/PowerShell-7.0+-5391FE.svg?style=flat-square&logo=powershell&logoColor=white)
![Platform](https://img.shields.io/badge/platform-Windows%2010+-lightgrey.svg?style=flat-square&logo=windows&logoColor=white)
[![License](https://img.shields.io/badge/license-MIT-green.svg?style=flat-square)](LICENSE)

*Application PowerShell élégante pour gérer les essais gratuits de Cursor. Version bilingue Français/Anglais.*

[🇫🇷 Français](#) | [🇬🇧 English](#) | [📖 Documentation](#) | [🐛 Issues](#)

<img src="docs/images/unlocker.jpg" alt="Interface Unlocker Free Trial" width="600"/>
<img src="docs/images/interface.PNG" alt="Interface Unlocker Free Trial" width="600"/>

</div>

## ✨ Fonctionnalités

- 🎨 Interface graphique moderne et intuitive
- 🔄 Changement d'adresse MAC des adaptateurs réseau
- 🗑️ Suppression du fichier storage.json
- 🌍 Version bilingue (FR/EN) avec changement de langue à la volée
- 🛡️ Mode administrateur automatique
- 📝 Logs détaillés pour le débogage

## 📋 Prérequis

- Windows 10 ou supérieur
- PowerShell 7 ou supérieur
- Droits administrateur

## 🚀 Installation rapide

```powershell
# Cloner le dépôt
git clone https://github.com/French-Team/Unlocker_Free_Trial.git

# Accéder au dossier
cd Unlocker_Free_Trial

## Démarrage de l'application

### Méthode recommandée : Utiliser le launcher

Pour une expérience optimale, utilisez toujours le fichier `launcher.bat` fourni pour démarrer l'application. Ce fichier permet de lancer l'application sans afficher la fenêtre console PowerShell.

1. Double-cliquez simplement sur `launcher.bat`
2. L'interface graphique s'ouvrira directement, sans fenêtre console visible

### Autres méthodes de lancement

Si vous lancez directement le fichier `start.ps1`, une fenêtre PowerShell apparaîtra brièvement avant que l'interface ne s'ouvre. Cette fenêtre est nécessaire pour exécuter le script mais peut être gênante visuellement.

Pour créer un raccourci personnalisé :
1. Cliquez-droit sur votre bureau → Nouveau → Raccourci
2. Dans le champ "Emplacement de l'élément", entrez :
   ```
   powershell.exe -WindowStyle Hidden -ExecutionPolicy Bypass -File "C:\chemin\complet\vers\start.ps1"
   ```
   (remplacez par le chemin réel vers votre fichier start.ps1)
3. Donnez un nom à votre raccourci et validez

### Note pour les développeurs

En mode développement, vous pouvez définir la variable d'environnement `TEST_MODE` pour garder la console visible et voir les logs : 

```powershell
$env:TEST_MODE = "true"
.\start.ps1
```

## 📁 Structure du projet

```
Unlocker_Free_Trial/
├── start.ps1          # Point d'entrée principal
├── Step*.ps1          # Modules fonctionnels
├── EN/                # Version anglaise
│   ├── start.ps1
│   └── Step*.ps1
└── __tests__/         # Tests unitaires
```

## 🤝 Contribution

Les contributions sont les bienvenues ! Voici comment vous pouvez nous aider :

1. 🍴 Fork le projet
2. 🌿 Créez une branche (`git checkout -b feature/AmazingFeature`)
3. 🔧 Commit vos changements (`git commit -m 'Add: nouvelle fonctionnalité'`)
4. 📤 Push sur la branche (`git push origin feature/AmazingFeature`)
5. 🔍 Ouvrez une Pull Request

## 📜 Licence

Distribué sous la licence MIT. Voir `LICENSE` pour plus d'informations.

## 📞 Contact

French Team - french.team.ai@gmail.com

<div align="center">

[![GitHub stars](https://img.shields.io/github/stars/French-Team/Unlocker_Free_Trial?style=social)](https://github.com/French-Team/Unlocker_Free_Trial/stargazers)
[![Follow](https://img.shields.io/github/followers/French-Team?style=social)](https://github.com/French-Team)

*Made with ❤️ by French Team*

</div>



