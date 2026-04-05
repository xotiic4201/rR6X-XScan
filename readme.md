# 🎮 R6X CYBERSCAN - Anti-Cheat Scanner for Rainbow Six Siege

> **The only PC checker you'll ever need for R6 Siege**

---

## ❓ What the hell is R6X Scanner?

Look, we all know the problem. You're running a competitive server, hosting a tournament, or just trying to find decent teammates. And you have NO idea if their PC is clean or if they're running every cheat under the sun.

**R6X Scanner fixes that.**

It's a real, working PC checker that digs through someone's system and tells you exactly what's there. Not some fake "trust me bro" screenshot. Actual proof.

### What it actually does:

- **Scans registry** - finds execution traces of cheat software
- **Checks prefetch** - sees what programs have been run recently
- **Hunts for suspicious files** - loaders, injectors, cracks, you name it
- **Analyzes GHUB scripts** - catches those "totally legit" recoil macros
- **Finds R6 accounts** - sees what accounts are on the system
- **Checks Steam** - linked accounts and login history
- **Device fingerprinting** - detects hardware spoofing attempts

### Who actually uses this:

| Who | Why |
|-----|-----|
| **Server owners** | Verify members before giving roles |
| **Tournament hosts** | Quick pre-match checks |
| **Team captains** | Screen potential recruits |
| **Community mods** | Keep your server clean |
| **Players** | Prove you're legit |

---

## 💰 Pricing (real talk)

| What | Price |
|------|-------|
| **Using the scanner** | FREE (just need a key) |
| **Getting scan keys** | FREE (message xotiic) |
| **Your own branded version** | $5 |
| **Source code access** | $5 |

**Yeah you read that right.** For $5 you get:

- The complete source code
- Permission to modify it
- Your own branded version (put your name on it)
- Run it for your own server/community
- No recurring fees, no bullshit

**Why $5?** Because I spent time making this and $5 keeps out the broke kids who just wanna reverse engineer it. Pay once, own it forever.

**How to buy:** DM `xotiic` on Discord. CashApp, PayPal, or Crypto.

---

## 🖥️ System Requirements (it's not much)

- Windows 10 or 11 (64-bit)
- Administrator access (needed to actually scan stuff)
- Internet connection (for keys and Discord)
- Discord account (to get your key)

---

## 🚀 How to actually run this thing

### Step 1: Download the EXE

Grab it here: **[Download R6X_Scanner.exe](https://www.dropbox.com/scl/fi/lt8zoucbhq35lyqhumbub/R6X_Scanner.exe?rlkey=natflmd2f3viv7mi3dk6qikzc&st=h9nr1j9o&dl=0)**

### Step 2: Run it properly

**RIGHT CLICK** the file → **"Run as Administrator"**

Yes, you HAVE to do this. Otherwise it can't access half the stuff it needs to check. Click Yes on the popup.

### Step 3: Find your Discord ID (it's easy)

1. Open Discord
2. Settings (the gear icon bottom left)
3. Click **"Advanced"**
4. Turn ON **"Developer Mode"**
5. Right click your name anywhere → **"Copy ID"**
6. Paste that number somewhere. That's your user ID.

### Step 4: Get a scan key

Message **xotiic** on Discord (`xotiic` or `xotiic._.420`)

Tell him you need a key. He'll send you a 12-character code.

Keys last 30 days. One time use. Don't share it.

### Step 5: Run the scan

1. Open the app
2. Paste your Discord ID in the first box
3. Paste your scan key in the second box (optional if you already used one)
4. Hit **"AUTHENTICATE"**
5. Wait a few seconds
6. Scan starts automatically

### Step 6: Watch it do its thing

- Fans spin up when it's actively scanning (looks cool ngl)
- Progress bar shows how far along it is
- Log window shows everything it's finding in real time
- Takes about 1-3 minutes depending on your PC

### Step 7: Get your results

When it's done you get:

- **Risk level** - CLEAN, MEDIUM, or HIGH
- **Full stats** - registry traces, files found, accounts detected
- **Report copied to your clipboard** (instant, just paste it anywhere)
- **Text file saved** in `C:\Users\YOURNAME\R6X_Scans\`
- **Discord report** sent to the server channel

---

## 🔑 Getting a Scan Key (the right way)

No key? No scan. Simple as that.

1. DM **xotiic** on Discord
2. Tell him why you need access
3. Give him your Discord ID
4. He sends you a key
5. Keys are valid for 30 days
6. One key = one scan (keeps people from abusing it)

**Why the key system?** Keeps random people from spamming scans. Only legit users get access.

---

## 💻 Want your OWN version? (Source code)

Yeah I sell it. $5 gets you everything.

**What you get for $5:**

```
- Complete Python source code
- PyQt6 GUI (fully customizable)
- Discord bot integration
- Backend API code
- All scan modules
- Right to modify and rebrand
- Put your name on it
- Run it for your own community
```

**What you can do with it:**

- Change the colors, logos, branding
- Add your own Discord bot
- Modify what gets scanned
- Host your own backend
- Sell keys to your members
- Pretty much whatever you want

**What you CAN'T do:**

- Resell the source code itself (don't be that guy)
- Claim you made it from scratch

**How to buy:**

DM `xotiic` on Discord. Payment methods:

- CashApp
- PayPal
- Crypto (BTC, ETH, USDC)

Send $5, get the source code. Simple.

---

## 📊 Reading your results

### Risk levels explained

| Result | What it means |
|--------|---------------|
| 🟢 **CLEAN** | Nothing suspicious found. You're good. |
| 🟡 **MEDIUM** | 1-5 weird things found. Might be nothing, might be something. |
| 🔴 **HIGH** | 6+ suspicious findings. Definitely worth a closer look. |

### What the findings actually mean

- **Registry Execution Trace** - Some sketchy file was run recently. Windows keeps receipts.
- **Suspicious Name** - File name has cheat words (loader, inject, hack, aimbot, etc.)
- **Recently Modified** - File was changed in the last 2 days
- **GHUB Script** - Logitech macro file. If it has recoil/aim stuff... you know what that means.
- **GHUB Profile** - Macro profiles. Same deal.

### What files it looks for

- `.exe` - programs
- `.rar` - archives (where people hide stuff)
- `.tlscan` - custom format
- `.cfg` - config files
- `.lua` - scripts (GHUB macros especially)

---

## 🔧 Having problems? Try this.

### "Failed to authenticate"

- Double check your Discord ID (numbers ONLY, no spaces)
- Make sure your key isn't used already
- Check your internet
- Backend might be down (message xotiic)

### App won't open

- **Run as Administrator** (seriously, do this)
- Windows Defender might be scared of it (add exception)
- Redownload if corrupted

### Scan taking forever

- First scan is slowest (1-3 min)
- It stops at 10,000 files so it doesn't take all day
- Your PC might just be slow 🤷

### "Bot token not available"

- Report saves locally instead of Discord
- Check `C:\Users\YOURNAME\R6X_Scans\`
- Scan still works fine

### Report not in Discord

- Bot might be offline
- Check your local backup folder
- Send the text file manually

---

## 📁 Where reports go

Every scan saves a text file here:

```
C:\Users\YOUR_USERNAME\R6X_Scans\r6x_scan_20260104_143022.txt
```

The filename has the date and time so you don't lose track.

---

## 🔒 Privacy stuff (read this)

- Only the scan report leaves your PC (sent to Discord)
- Reports are encrypted when sent
- Local backups stay on YOUR computer
- No keylogging. No spying. No bullshit.
- No personal info collected

---

## 📞 Need help?

**Discord:** `https://discord.gg/SVvZFnct37` or `xotiic._.420`

**When you message me, include:**
- Screenshot of the error
- What Windows version you're on
- If you ran as Admin (you better have)

Response time is usually within a day.

---

## 💸 Want to buy source code?

**Price:** $5

**What you get:**
- Full source code
- Right to modify
- Right to rebrand
- No recurring fees

**How to pay:**
- CashApp
- PayPal

**DM `xotiic` on Discord.** Send $5, get the code. Easy.

---

## 📅 Version

**v2.1.0** - April 2026

---

## ⚠️ Disclaimer (lawyer stuff)

This tool is for checking your own system or systems you have permission to check. Don't be weird about it. If you're using cheats, this will probably find them. That's the point. Use at your own risk.

---

<div align="center">

**Made by xotiic**  
*Trusted R6 PC Checker*  
`xotiic` / `xotiic._.420`

**📥 [Download R6X_Scanner.exe](https://www.dropbox.com/scl/fi/lt8zoucbhq35lyqhumbub/R6X_Scanner.exe?rlkey=natflmd2f3viv7mi3dk6qikzc&st=h9nr1j9o&dl=0)**

**[⬆ Back to top](#-r6x-cyberscan---anti-cheat-scanner-for-rainbow-six-siege)**

</div>
