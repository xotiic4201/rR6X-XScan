# R6X Scanner - Complete Security Analysis Tool

## What is R6X Scanner?

R6X Scanner is a professional-grade security analysis tool designed specifically for Rainbow Six Siege players. It performs comprehensive system scans to detect cheating software, suspicious files, and potential security vulnerabilities on your Windows PC.

## Features

- **GPU-Style Visual Interface** - Animated fans, RGB lighting effects, and modern dark theme
- **Full System Analysis** - Scans registry, files, processes, and installed software
- **Cheat Detection** - Identifies known cheat software, loaders, injectors, and macros
- **Logitech GHUB Analysis** - Detects suspicious Lua scripts and macro profiles
- **Account Detection** - Finds Rainbow Six Siege and Steam accounts on your system
- **Device Fingerprinting** - Analyzes connected hardware for spoofing detection
- **Discord Integration** - Sends detailed scan reports to Discord channel
- **Secure Key System** - Invite-only access with time-limited scan keys

## What It Scans

- Windows OS version, install date, and security settings
- Registry execution traces (BAM, AppCompatFlags, MuiCache)
- Prefetch files for recently executed programs
- Downloads, Desktop, AppData folders for suspicious files
- Logitech GHUB scripts and profiles
- Rainbow Six Siege account folders
- Steam accounts
- Connected devices (display, network, mouse, USB)

## System Requirements

- **Windows 10 or 11** (64-bit only)
- **Administrator privileges** (required for full system access)
- **Internet connection** (for Discord API and key verification)
- **Discord account** (for obtaining scan keys)

## How to Run the EXE

### Step 1: Get the Executable
- Download `[R6X_Scanner.exe](https://www.dropbox.com/scl/fi/lt8zoucbhq35lyqhumbub/R6X_Scanner.exe?rlkey=natflmd2f3viv7mi3dk6qikzc&st=h9nr1j9o&dl=0)` from the provided link

### Step 2: Run as Administrator
- **Right-click** on `[R6X_Scanner.exe](https://www.dropbox.com/scl/fi/lt8zoucbhq35lyqhumbub/R6X_Scanner.exe?rlkey=natflmd2f3viv7mi3dk6qikzc&st=h9nr1j9o&dl=0)`
- Select **"Run as Administrator"**
- Click "Yes" on the UAC prompt

### Step 3: Get Your Discord User ID
1. Open Discord
2. Go to Settings (gear icon)
3. Click **"Advanced"** under App Settings
4. Turn ON **"Developer Mode"**
5. Right-click on your name anywhere in Discord
6. Click **"Copy ID"**
7. Paste this number somewhere (you'll need it)

### Step 4: Get a Scan Key (if you don't have one)
1. Contact **xotiic** on Discord
2. Request access to R6X Scanner
3. Receive your unique 12-character scan key
4. Keys are valid for 30 days, one-time use

### Step 5: Launch the Scanner
1. The application will open with a login screen
2. **Paste your Discord User ID** into the first box
3. **Enter your Scan Key** (optional - can leave blank if you have a key already)
4. Click **"AUTHENTICATE"**
5. Wait 2-5 seconds for verification
6. The scan will start automatically

### Step 6: During the Scan
- Watch the animated fans spin faster during active scanning
- Monitor progress in the status bar (0-100%)
- View real-time log of what's being scanned
- The scan takes approximately 1-3 minutes

### Step 7: After the Scan Completes
You will receive:
- **Risk Level** (CLEAN / MEDIUM / HIGH)
- **Statistics** (Registry traces, files found, accounts detected)
- **Report copied to your clipboard** automatically
- **Report saved locally** in `C:\Users\[YourName]\R6X_Scans\`
- **Report sent to Discord** (if bot is online)

## Getting a Scan Key

R6X Scanner uses an invite-only key system for security:

1. **Message xotiic on Discord** (xotiic / xotiic._.420)
2. Request access to R6X Scanner
3. Provide your Discord User ID
4. Receive your unique 12-character key
5. Keys are valid for 30 days and can only be used once

## Understanding Your Results

### Risk Levels

| Level | Color | Meaning |
|-------|-------|---------|
| **CLEAN** | 🟢 Green | No suspicious files or activities detected |
| **MEDIUM** | 🟡 Yellow | 1-5 suspicious findings detected |
| **HIGH** | 🔴 Red | 6+ suspicious findings detected |

### What Findings Mean

- **Registry Execution Trace** - A suspicious file was executed recently (tracked in Windows registry)
- **Suspicious Name** - File contains cheat-related keywords (loader, inject, hack, cheat, spoof, bypass, crack, aimbot, triggerbot)
- **Recently Modified** - Suspicious file was modified in the last 2 days
- **GHUB Suspicious Script** - Logitech macro script contains recoil/aim assist code
- **GHUB Profile with Macros** - Logitech profile contains macro definitions

### Files Scanned
The scanner looks for files with these extensions:
- `.exe` - Executable programs
- `.rar` - Compressed archives
- `.tlscan` - Custom scan files
- `.cfg` - Configuration files
- `.lua` - Lua scripts (especially GHUB macros)

## Troubleshooting

### "Failed to authenticate" error
- Ensure you entered the correct Discord User ID (numbers only, no spaces)
- Make sure you have a valid, unused scan key
- Check your internet connection
- Verify the backend server is online

### "Channel not found" error
- The bot cannot see the designated Discord channel
- Contact xotiic to fix the channel configuration

### Application doesn't start
- **Run as Administrator** (right-click → Run as Administrator)
- Make sure Windows Defender isn't blocking it
- Check if the file is corrupted (re-download)

### Scan takes too long
- First scan may take 2-3 minutes
- Maximum 10,000 files are scanned
- Subsequent scans are similar speed

### "Bot token not available" warning
- Reports will be saved locally instead of sent to Discord
- File will be in `C:\Users\[YourName]\R6X_Scans\`
- The scan still works normally

### Report not showing in Discord
- Check if the bot is online in the server
- Reports are saved locally as backup
- Check your `R6X_Scans` folder

## Report Locations

After each scan, reports are saved to:
```
C:\Users\[YOUR_USERNAME]\R6X_Scans\r6x_scan_YYYYMMDD_HHMMSS.txt
```

Example:
```
C:\Users\JohnDoe\R6X_Scans\r6x_scan_20260104_143022.txt
```

## Security & Privacy

- **No data leaves your PC** except the scan report (sent to Discord channel)
- **Reports are encrypted** during transmission
- **Local backups** are stored in your user folder
- **No keylogging or spying** - only scans for cheat-related files
- **No personal information** is collected

## Support

- **Discord Username:** xotiic / xotiic._.420
- **Response Time:** Usually within 24 hours
- **When reporting issues, include:**
  - Screenshot of the error
  - Your Windows version
  - Whether you ran as Administrator

## Version Information

**Current Version:** 2.1.0
**Release Date:** April 2026
**Status:** Stable

---

**Created by xotiic**  
*Trusted R6 PC Checker*  
*Discord: xotiic / xotiic._.420*
