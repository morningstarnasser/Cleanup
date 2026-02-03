# 🧹 Cleanup Scripts

Comprehensive system cleanup scripts for **Windows** and **macOS**. Remove temp files, caches, logs, and free up disk space in one command.

---

## 🪟 Windows

### What it cleans

| Category | Details |
|----------|---------|
| Temp Files | User temp, Windows temp, all users' temp |
| Windows Caches | Prefetch, Windows Update, Delivery Optimization |
| Browser Caches | Chrome, Edge, Firefox |
| App Caches | Teams, Discord, Spotify, npm, pip |
| System | Error reports, thumbnails, icon cache, memory dumps, font cache |
| Logs | CBS, DISM, old logs (30+ days) |
| Other | Recycle Bin, Windows component cleanup (DISM) |

### Usage

Open **PowerShell as Administrator** and run:

```powershell
cd ~\Downloads
Set-ExecutionPolicy Bypass -Scope Process -Force
.\windows-cleanup.ps1
```

> **Tip:** Close all browsers before running for best results.

---

## 🍏 macOS

### What it cleans

| Category | Details |
|----------|---------|
| System Caches | Library caches, DNS, CUPS printer cache |
| Temp Files | /tmp, /var/tmp, crash reports, diagnostics |
| Browser Caches | Safari, Chrome, Firefox, Edge |
| App Caches | Xcode, Spotify, Discord, Slack, Teams, Adobe |
| Dev Tools | Homebrew, npm, pip, yarn, CocoaPods |
| Logs | System logs, user logs, old logs (30+ days) |
| macOS Specific | QuickLook, font cache, Mail cache, iCloud cache |
| Docker | Images, containers, volumes |
| Other | Trash, inactive memory purge |

### Usage

Open **Terminal** and run:

```bash
cd ~/Downloads
sudo bash mac-cleanup.sh
```

> **Tip:** Close all browsers before running for best results.

---

## ⚠️ Notes

- Both scripts show how much disk space was freed after completion
- No personal files, documents, or application data are deleted
- Only caches, temp files, and logs are removed — these rebuild automatically
- Always close browsers and heavy applications before running

## 📋 Requirements

| OS | Requirement |
|----|-------------|
| Windows | PowerShell 5.1+, Administrator privileges |
| macOS | Bash, sudo/root access |

---

## 📜 License

MIT — free to use and modify.
