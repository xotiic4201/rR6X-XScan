# R6X CYBERSCAN - Anti-Cheat Scanner for Rainbow Six Siege

<div align="center">
  
![R6X CYBERSCAN](https://img.shields.io/badge/R6X-CYBERSCAN-FF003C?style=for-the-badge)
![Version](https://img.shields.io/badge/version-4.0.0-00FF9D?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20Linux%20%7C%20macOS-blue?style=for-the-badge)

**Check if someone is cheating or keep your system clean for competitive play**

[Features](#features) • [Quick Start](#quick-start) • [Download](#download) • [Documentation](#documentation) • [Discord](#discord-bot)

</div>

---

## 🎯 What is R6X CYBERSCAN?

R6X CYBERSCAN is a **professional security scanning tool** designed specifically for the **Rainbow Six Siege community**. It scans a user's system for cheat-related files, suspicious executables, and gaming account information to help determine if someone might be using unauthorized software.

### Why Use It?

| For | Benefit |
|-----|---------|
| **Server Admins** | Verify members before granting access to competitive servers |
| **Tournament Organizers** | Quick pre-match checks for all participants |
| **Team Leaders** | Screen potential teammates before roster additions |
| **Community Managers** | Maintain clean, cheat-free environments |
| **Players** | Prove your system is clean to join trusted communities |

---

## 🔍 What It Detects

| Category | What We Scan For | Why It Matters |
|----------|------------------|----------------|
| 🎮 **R6 Accounts** | Local Rainbow Six Siege profiles | Multiple accounts might indicate account sharing/selling |
| 🔄 **Steam Accounts** | Steam login history | Multiple Steam accounts on one PC |
| ⚠️ **Suspicious Files** | 10-character random .exe files, Dapper.dll | Common cheat file patterns |
| 📁 **Executables** | .exe and .rar files in user folders | Cheats often hide in user directories |
| 📋 **Prefetch Data** | Program execution history | See what programs have been run recently |
| 🛡️ **Antivirus Status** | Third-party AV software | Some cheats disable antivirus |
| 💻 **System Info** | Windows install date, computer name | Track system changes |
| 🖱️ **Logitech Scripts** | LGHUB script files | Mouse macros that can be used for cheating |

---

## ✨ Features

✅ **No Installation Required** - PowerShell version runs instantly  
✅ **Cross-Platform** - Python version works on Windows, Mac, Linux  
✅ **Discord Integration** - Results auto-send to your Discord channel  
✅ **No Login Required** - Just enter a name and scan  
✅ **Complete System Scan** - Scans all common cheat locations  
✅ **Account Detection** - Finds R6 and Steam accounts  
✅ **Clean UI** - Professional dark theme with R6X branding  
✅ **Real-Time Progress** - Watch the scan as it happens  
✅ **Free & Open Source** - MIT License  

---

## 🚀 Quick Start

### Option 1: PowerShell (Windows - No Install)

```powershell
# 1. Open PowerShell as Administrator
# 2. Run this one-liner:

Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser -Force; 
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/xotiic4201/R6X-CYBERSCAN/main/clients/powershell/R6X-Scanner.ps1" -OutFile "$env:USERPROFILE\Desktop\R6X-Scanner.ps1"; 
PowerShell -File "$env:USERPROFILE\Desktop\R6X-Scanner.ps1"
```

### Option 2: Python (Cross-Platform)

```bash
# 1. Install Python 3.11 or higher
# 2. Install the only dependency:
pip install requests

# 3. Download and run:
python r6x_scanner.py
```

---

## 📥 Download

| Version | File | Size | Platform |
|---------|------|------|----------|
| **PowerShell** | `R6X-Scanner.ps1` | ~50KB | Windows 7/8/10/11 |
| **Python GUI** | `r6x_scanner.py` | ~25KB | Windows/Linux/macOS |

### Direct Links
- [⬇️ Download PowerShell Version](https://raw.githubusercontent.com/xotiic4201/R6X-CYBERSCAN/main/clients/powershell/R6X-Scanner.ps1)
- [⬇️ Download Python Version](https://raw.githubusercontent.com/xotiic4201/R6X-CYBERSCAN/main/clients/python/r6x_scanner.py)

---

## 🖥️ Screenshots

### PowerShell Client
```
┌─────────────────────────────────────┐
│  🔍 R6X CYBERSCAN v4.0              │
├─────────────────────────────────────┤
│ Your Name: [Player1    ]             │
│                                      │
│ [▶ START COMPLETE SCAN]              │
│                                      │
│ 🤖 Discord Bot: Active               │
│                                      │
│ [14:23:45] ╔════════════════════╗    │
│ [14:23:45] ║ SCAN COMPLETE      ║    │
│ [14:23:45] ╚════════════════════╝    │
│ [14:23:45] Files Scanned: 1,234      │
│ [14:23:45] Threats Found: 2 ⚠️       │
│ [14:23:45] R6 Accounts: 1            │
│ [14:23:45] Steam Accounts: 1         │
│                                      │
│ [===============] 100%               │
└─────────────────────────────────────┘
```

### Python Client
```
╔═════════════════════════════════════╗
║     🔍 R6X CYBERSCAN v4.0           ║
╠═════════════════════════════════════╣
║  Your Name: ┌────────────────────┐  ║
║             │ Player1            │  ║
║             └────────────────────┘  ║
║  [▶ START COMPLETE SCAN]            ║
║                                      ║
║  🤖 Discord Bot: ● Active            ║
║                                      ║
║  [14:23:45] Scanning files...        ║
║  [14:23:52] Found 1,234 files        ║
║  [14:23:58] Found 2 suspicious       ║
║  [14:24:00] Scan complete!           ║
║                                      ║
║  [██████████████████████████] 100%   ║
╚═════════════════════════════════════╝
```

---

## 🤖 Discord Bot Integration

When you run a scan, results are automatically sent to your Discord channel:

```
📊 **New Scan: Player1**
Computer: DESKTOP-ABC123

📁 Files Scanned: 1,234
🚨 Threats Found: 2 ⚠️
🎮 R6 Accounts: 1
🔄 Steam Accounts: 1
💻 Windows Install: 2023-08-15
🛡️ Antivirus: Windows Defender Only

⚠️ **Suspicious Files Found**
• a1b2c3d4e5.exe (HIGH)
• dapper.dll (MEDIUM)

🎮 **Gaming Accounts Found**
• R6: Player1
• Steam: Player1
```

### Discord Commands
| Command | Description |
|---------|-------------|
| `!scan username` | Get the latest scan results for a user |
| `!stats` | Show bot statistics (total scans, users) |
| `!help` | Show available commands |

---

## 📊 Sample Scan Results

### Clean System
```
✅ Files Scanned: 1,234
✅ Threats Found: 0
✅ R6 Accounts: 1
✅ Steam Accounts: 1
✅ System appears clean!
```

### Suspicious System
```
⚠️ Files Scanned: 1,234
⚠️ Threats Found: 2
⚠️ R6 Accounts: 3
⚠️ Steam Accounts: 2

⚠️ WARNING: Found 2 suspicious files!
• a1b2c3d4e5.exe (HIGH)
• dapper.dll (MEDIUM)
```

---

## 🛠️ Configuration

### For Server Owners (Discord Setup)

1. **Create a Discord Bot** at https://discord.com/developers/applications
2. **Get your Bot Token** and add to Render environment variables
3. **Get your Channel ID** (right-click channel → Copy ID)
4. **Add to Render**:
   ```
   DISCORD_BOT_TOKEN=your_bot_token_here
   DISCORD_CHANNEL_ID=your_channel_id_here
   ```

### For Users
Just run the script and enter your name - no configuration needed!

---

## 📋 Requirements

### PowerShell Version
- Windows 7/8/10/11
- PowerShell 5.0 or higher
- No additional software needed

### Python Version
- Python 3.8 or higher
- `requests` library (`pip install requests`)

---

## 🚦 How to Use

1. **Download** your preferred version
2. **Run** the application (PowerShell as Administrator for best results)
3. **Enter** your name or username
4. **Click** "START COMPLETE SCAN"
5. **Wait** for the scan to complete (30-60 seconds)
6. **Share** results with your community via Discord

---

## ⚠️ Important Notes

- **Run PowerShell version as Administrator** for full system access
- **Scans only file names and metadata** - never uploads file contents
- **Results are anonymous** - only the username you provide is stored
- **Open source** - fully transparent about what it does

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| PowerShell won't run | Run as Administrator, then: `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Python not found | Install Python 3.8+ from python.org |
| Discord bot not responding | Check bot token in Render environment variables |
| Scan takes too long | First scan is always longest - subsequent scans are faster |
| "Access Denied" errors | Run PowerShell as Administrator |

---

## ⚠️ Disclaimer

R6X CYBERSCAN is a security auditing tool. It should be used responsibly and in accordance with all applicable laws and terms of service. The developers are not responsible for misuse of this software. Always obtain consent before scanning someone else's system.

---

## 📞 Support

- **GitHub Issues**: [Report bugs](https://github.com/xotiic4201/rR6X-XScan/issues))
- **Discord**: [Join our server](https://discord.gg/SVvZFnct37)


---

<div align="center">
  
**Made with ❤️ for the Rainbow Six Siege Community**

[⬆ Back to Top](#r6x-cyberscan---anti-cheat-scanner-for-rainbow-six-siege)

</div>
