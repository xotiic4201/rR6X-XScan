
# R6X CYBERSCAN - Anti-Cheat Scanner for Rainbow Six Siege

<div align="center">
  
![R6X CYBERSCAN](https://img.shields.io/badge/R6X-CYBERSCAN-FF003C?style=for-the-badge)
![Version](https://img.shields.io/badge/version-4.0.0-00FF9D?style=for-the-badge)
![Platform](https://img.shields.io/badge/platform-Windows-blue?style=for-the-badge)
![Discord](https://img.shields.io/badge/Discord-Bot-5865F2?style=for-the-badge)

**Professional security scanning with Discord key system - Keep your community cheat-free**

</div>

---

## 🎯 What is R6X CYBERSCAN?

R6X CYBERSCAN is a **professional security scanning tool** designed specifically for the **Rainbow Six Siege community**. It features a **Discord bot for key management** and a **Windows scanner** that checks systems for cheat-related files, suspicious executables, and gaming account information.

### 🆕 New Features in v4.0
- 🔑 **Key System** - Users need a valid key to scan
- 🤖 **Discord Slash Commands** - Generate and manage keys directly in Discord
- 🖱️ **Logitech Script Detection** - Flags ALL .lua scripts with feature analysis
- 🚀 **Instant Bot Startup** - Bot runs immediately, keys can be generated while scanner waits
- 📊 **Enhanced Logging** - More detailed scan results with feature detection

### Why Use It?

| For | Benefit |
|-----|---------|
| **Server Admins** | Verify members before granting access to competitive servers |
| **Tournament Organizers** | Quick pre-match checks with key-based access control |
| **Team Leaders** | Screen potential teammates with verified scans |
| **Community Managers** | Maintain clean, cheat-free environments with key system |
| **Players** | Prove your system is clean with timestamped, verified scans |

---

## 🔍 What It Detects

| Category | What We Scan For | Why It Matters |
|----------|------------------|----------------|
| 🎮 **R6 Accounts** | Local Rainbow Six Siege profiles | Multiple accounts might indicate account sharing/selling |
| 🔄 **Steam Accounts** | Steam login history from loginusers.vdf | Multiple Steam accounts on one PC |
| ⚠️ **Suspicious Files** | 10-character random .exe files, Dapper.dll | Common cheat file patterns |
| 📁 **Executables** | .rar and .exe files in user folders | Cheats often hide in user directories |
| 📋 **Prefetch Data** | Program execution history with timestamps | See what programs have been run recently |
| 🛡️ **Antivirus Status** | Third-party AV software and Defender status | Some cheats disable antivirus |
| 💻 **System Info** | Windows install date, Secure Boot, DMA protection | Track system changes and security features |
| 🖱️ **Logitech Scripts** | ALL .lua files with feature detection | Mouse macros with recoil, rapid fire, aim assist detection |
| 📝 **Registry Analysis** | BAM, AppCompat, AppSwitched entries | Find executed programs |
| 🖥️ **Hardware Info** | Monitor serials, PCIe devices | Hardware fingerprinting |

---

## ✨ Features

✅ **Key-Based Access** - Users need valid keys to scan  
✅ **Discord Slash Commands** - `/generate_key`, `/list_keys`, `/validate_key`, `/stats`  
✅ **Instant Bot Startup** - Bot starts immediately when scanner runs  
✅ **No Installation Required** - Single executable scanner  
✅ **Complete System Scan** - Scans all common cheat locations  
✅ **Logitech Script Analysis** - Detects recoil, rapid fire, aim assist features  
✅ **Account Detection** - Finds R6 and Steam accounts  
✅ **Professional UI** - Dark theme with real-time progress  
✅ **Clipboard Export** - Copy results instantly  
✅ **Render Backend** - 24/7 availability for key management  

---

## 🔑 Key System

Users must have a valid key to run a scan. Keys are generated in Discord:

### Discord Slash Commands

| Command | Description | Permission |
|---------|-------------|------------|
| `/generate_key @user [days]` | Generate a new key for a user | Admin Only |
| `/list_keys @user` | List all keys for a user | Anyone |
| `/validate_key @user` | Check if user has valid key | Anyone |
| `/stats` | Show bot statistics | Anyone |
| `/help` | Show available commands | Anyone |

### Key Format
```
R6X-ABCDE-FGHIJ-KLMNO
```

Keys are:
- Valid for 30 days by default
- Single-use (one scan per key)
- Tracked per user
- Stored securely on Render

---

## 🚀 Quick Start

### Step 1: Get Your Key
Join our Discord server and use `/generate_key YOUR_USER_ID` to get a key:
```
/generate_key 123456789012345678 30
```

### Step 2: Download the Scanner
[⬇️ Download R6XScan.exe](https://www.dropbox.com/scl/fi/monrwstbsvm5yt3f4cob0/R6XScan.exe?rlkey=33povief4dlpqvqcf7v85huzg&st=tjpfe2ef&dl=0)

### Step 3: Run and Login
```bash
# Just double-click R6XScan.exe
# The Discord bot starts immediately
# Enter your Discord ID when prompted
# Scan runs automatically
```

---

## 📥 Download

| Version | File | Size | Platform |
|---------|------|------|----------|
| **Windows Executable** | `R6XScan.exe` | ~10MB | Windows 10/11 |
| **Python Source** | `scanner.py` | ~150KB | Windows (with Python) |

### Direct Links
- [⬇️ Download R6XScan.exe](https://www.dropbox.com/scl/fi/monrwstbsvm5yt3f4cob0/R6XScan.exe?rlkey=33povief4dlpqvqcf7v85huzg&st=tjpfe2ef&dl=0)
- [⬇️ View Source Code]([https://github.com/xotiic4201/R6X-Scan](https://github.com/xotiic4201/rR6X-XScan/blob/main/r6x_cyberscan.py))

---

## 🖥️ Scanner Interface

```
╔══════════════════════════════════════════════════════════════╗
║                     R6X CYBERSCAN v4.0                       ║
║                Advanced Security Scanner                      ║
║              [ Discord Bot Already Running ]                  ║
╠══════════════════════════════════════════════════════════════╣
║  User ID: 123456789012345678                                  ║
║  Scan ID: R6X-20240315-143022-345678                         ║
╚══════════════════════════════════════════════════════════════╝

▶ Windows Installation Date
  ✓ Windows Install Date: 2023-08-15

▶ File Scan Results
  ✓ Found 1,234 files

▶ Suspicious Files
  ✓ No suspicious files found

▶ Logitech Script Detection
  ⚠ Found 2 .lua scripts (ALL flagged)
     1. recoil_script.lua [Rainbow Six Siege] (RECOIL, RAPID)
     2. aimbot.lua [Valorant] (AIM)

▶ Rainbow Six Siege Accounts
  ✓ Found 1 R6 accounts

▶ Steam Accounts
  ✓ Found 1 Steam accounts

════════════════════════════════════════════════════════════════
SCAN COMPLETE
════════════════════════════════════════════════════════════════
Duration: 45.23 seconds
Files Scanned: 1,234
Suspicious Files: 0
R6 Accounts: 1
Steam Accounts: 1
Logitech Scripts: 2
Log saved to: C:\Users\Player1\Desktop\R6X_Scan_20240315_143022.txt
```

---

## 🤖 Discord Integration

### Bot Status
When you run the scanner, the Discord bot automatically connects:
```
✅ Discord bot connected as R6XScanner#1234
✅ Bot ID: 123456789012345678
✅ Slash commands available: /generate_key, /list_keys, /validate_key, /stats, /help
```

### Scan Results
Results are automatically sent to your Discord channel:

```
📊 **R6X CyberScan Results**
Scan completed for <@123456789012345678>

📁 Files Scanned: 1,234
⚠️ Suspicious Files: 0
🎮 R6 Accounts: 1
🎮 Steam Accounts: 1
⏱️ Duration: 45.23s
🎮 Logitech: 🟢 Running | Scripts: 2

📜 Scripts Found:
recoil_script.lua [R6] (R,F)
aimbot.lua [VAL] (A)

Scan ID: R6X-20240315-143022-345678
```

---

## 📊 Sample Scan Results

### Clean System
```
✅ Files Scanned: 1,234
✅ Suspicious Files: 0
✅ R6 Accounts: 1
✅ Steam Accounts: 1
✅ Logitech Scripts: 0
✅ System appears clean!
```

### Suspicious System
```
⚠️ Files Scanned: 1,234
⚠️ Suspicious Files: 2
⚠️ R6 Accounts: 3
⚠️ Steam Accounts: 2
⚠️ Logitech Scripts: 3 (RECOIL, RAPID, AIM detected)

⚠️ WARNING: Found suspicious files!
• a1b2c3d4e5.exe (HIGH)
• dapper.dll (MEDIUM)

⚠️ WARNING: Logitech scripts with cheat features!
• recoil_script.lua - Recoil control for R6
• rapidfire.lua - Rapid fire macro
• aimbot.lua - Aim assistance
```

---

## 📋 Requirements

### For Running Scans
- Windows 10/11 (64-bit)
- Internet connection (for key validation)
- Discord account (for key generation)

### Optional (for better detection)
- Run as Administrator for full system access
- PowerShell 5.1 or higher

---

## 🚦 How to Use (Step by Step)

1. **Join our Discord server** and get your user ID
2. **Generate a key** using `/generate_key YOUR_USER_ID`
3. **Download** `R6XScan.exe`
4. **Run the scanner** (double-click)
5. **Watch the bot start** automatically
6. **Enter your Discord ID** when prompted
7. **Wait for scan** to complete (30-60 seconds)
8. **Results** appear in Discord and are saved locally

---

## 🔧 Troubleshooting

| Issue | Solution |
|-------|----------|
| "No valid key found" | Generate a key in Discord with `/generate_key YOUR_ID` |
| Bot won't start | Check internet connection and Render status |
| Scan takes too long | First scan is longest - subsequent scans are faster |
| "Access Denied" errors | Run as Administrator |
| Discord commands not working | Bot takes 5-10 seconds to initialize |
| Results not in Discord | Check channel ID in backend configuration |

---

## 🏗️ Architecture

```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│   Discord   │────▶│   Render     │────▶│   Scanner   │
│   /command  │     │   Backend    │     │  (Local)    │
└─────────────┘     └──────────────┘     └─────────────┘
       │                   │                    │
       │                   │                    │
       ▼                   ▼                    ▼
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│ Generate    │     │ Store Keys   │     │ Run Scan    │
│ Keys        │     │ Track Scans  │     │ Send Results│
└─────────────┘     └──────────────┘     └─────────────┘
```

1. **Discord Bot** (in scanner) - Handles key generation commands
2. **Render Backend** - Validates keys, tracks scans
3. **Scanner** - Runs locally, performs system analysis

---

## ⚠️ Important Notes

- **Keys are single-use** - one key = one scan
- **Bot runs locally** - starts immediately when scanner runs
- **No data uploaded** - only scan statistics, never file contents
- **Open source** - fully transparent about what it does
- **Run as Administrator** for complete system access

---

## 📞 Support

- **GitHub Issues**: [Report bugs](https://github.com/xotiic4201/R6X-Scan/issues)
- **Discord**: [Join our server](https://discord.gg/SVvZFnct37)

---

## ⚠️ Disclaimer

R6X CYBERSCAN is a security auditing tool. It should be used responsibly and in accordance with all applicable laws and terms of service. The developers are not responsible for misuse of this software. Always obtain consent before scanning someone else's system.

---

<div align="center">
  
**Made with ❤️ for the Rainbow Six Siege Community**

[⬆ Back to Top](#r6x-cyberscan---anti-cheat-scanner-for-rainbow-six-siege)

</div>
