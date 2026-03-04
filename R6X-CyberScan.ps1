# R6X-Scanner.ps1 - Complete R6 Cheat Scanner with Discord Integration
# Save this file and run in PowerShell as Administrator

param(
    [string]$ApiUrl = "https://your-render-app.onrender.com"  # Change this to your Render URL
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "R6X CYBERSCAN v4.0 - Complete Scanner"
$form.Size = New-Object System.Drawing.Size(800, 600)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0a0a0a"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

# Header
$header = New-Object System.Windows.Forms.Label
$header.Text = "🔍 R6X CYBERSCAN"
$header.Font = New-Object System.Drawing.Font("Segoe UI", 28, [System.Drawing.FontStyle]::Bold)
$header.ForeColor = "#FF003C"
$header.Size = New-Object System.Drawing.Size(400, 50)
$header.Location = New-Object System.Drawing.Point(20, 20)
$form.Controls.Add($header)

# ASCII Art Header (decoded from base64)
$headerBase64 = "77u/ICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAg4paI4paI4paI4paEIOKWhOKWiOKWiOKWiOKWk+KWk+KWiOKWiOKWiOKWiOKWiCAg4paI4paI4paTICAgICDilojilojilpMgICAg4paE4paI4paI4paI4paI4paEICAg4paI4paI4paRIOKWiOKWiCDilpPilojilojilojilojiloggIOKWhOKWiOKWiOKWiOKWiOKWhCAgIOKWiOKWiCDiloTilojiloAKICAgICAgICAgICAgICAgICAgICDilpPilojilojilpLiloDilojiloAg4paI4paI4paS4paT4paIICAg4paAIOKWk+KWiOKWiOKWkiAgICDilpPilojilojilpIgICDilpLilojilojiloAg4paA4paIICDilpPilojilojilpEg4paI4paI4paS4paT4paIICAg4paAIOKWkuKWiOKWiOKWgCDiloDiloggICDilojilojiloTilojilpIKICAgICAgICAgICAgICAgICAgICDilpPilojiloggICAg4paT4paI4paI4paR4paS4paI4paI4paIICAg4paS4paI4paI4paRICAgIOKWkuKWiOKWiOKWkiAgIOKWkuKWk+KWiCAgICDiloQg4paS4paI4paI4paA4paA4paI4paI4paR4paS4paI4paI4paIICAg4paS4paT4paIICAgIOKWhCDilpPilojilojilojiloTilpEKICAgICAgICAgICAgICAgICAgICDilpLilojiloggICAg4paS4paI4paIIOKWkuKWk+KWiCAg4paEIOKWkuKWiOKWiOKWkSAgICDilpHilojilojilpEgICDilpLilpPilpPiloQg4paE4paI4paI4paS4paR4paT4paIIOKWkeKWiOKWiCDilpLilpPiloggIOKWhCDilpLilpPilpPiloQg4paE4paI4paI4paS4paT4paI4paIIOKWiOKWhAogICAgICAgICAgICAgICAgICAgIOKWkuKWiOKWiOKWkiAgIOKWkeKWiOKWiOKWkuKWkeKWkuKWiOKWiOKWiOKWiOKWkuKWkeKWiOKWiOKWiOKWiOKWiOKWiOKWkuKWkeKWiOKWiOKWkSAgIOKWkiDilpPilojilojilojiloAg4paR4paR4paT4paI4paS4paR4paI4paI4paT4paR4paS4paI4paI4paI4paI4paS4paSIOKWk+KWiOKWiOKWiOKWgCDilpHilpLilojilojilpIg4paI4paECiAgICAgICAgICAgICAgICAgICAg4paRIOKWkuKWkSAgIOKWkSAg4paR4paR4paRIOKWkuKWkSDilpHilpEg4paS4paR4paTICDilpHilpHilpMgICAgIOKWkSDilpHilpIg4paSICDilpEg4paSIOKWkeKWkeKWkuKWkeKWkuKWkeKWkSDilpLilpEg4paR4paRIOKWkeKWkiDilpIgIOKWkeKWkiDilpLilpIg4paT4paSCiAgICAgICAgICAgICAgICAgICAg4paRICDilpEgICAgICDilpEg4paRIOKWkSAg4paR4paRIOKWkSDilpIgIOKWkSDilpIg4paRICAgICDilpEgIOKWkiAgICDilpIg4paR4paS4paRIOKWkSDilpEg4paRICDilpEgIOKWkSAg4paSICAg4paRIOKWkeKWkiDilpLilpEKICAgICAgICAgICAgICAgICAgICDilpEgICAgICDilpEgICAgICDilpEgICAgIOKWkSDilpEgICAg4paSIOKWkSAgIOKWkSAgICAgICAgIOKWkSAg4paR4paRIOKWkSAgIOKWkSAgIOKWkSAgICAgICAg4paRIOKWkeKWkSDilpEgCiAgICAgICAgICAgICAgICAgICAgICAgICAg4paRICAgICAg4paRICDilpEgICAg4paRICDilpEg4paRICAgICDilpEg4paRICAgICAgIOKWkSAg4paRICDilpEgICDilpEgIOKWkeKWkSDilpEgICAgICDilpEgIOKWkSAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAg4paRICAgICAgICAgICAgICAgICAgICAgICDilpEgICAgICAgICAgICAg"
$headerString = [System.Text.Encoding]::UTF8.GetString([Convert]::FromBase64String($headerBase64))
$headerLines = $headerString -split "`n"

# Show animated header
$headerLabel = New-Object System.Windows.Forms.Label
$headerLabel.Text = ""
$headerLabel.Font = New-Object System.Drawing.Font("Consolas", 8)
$headerLabel.ForeColor = "#FF003C"
$headerLabel.Size = New-Object System.Drawing.Size(760, 100)
$headerLabel.Location = New-Object System.Drawing.Point(20, 70)
$form.Controls.Add($headerLabel)

# Timer for animation
$animTimer = New-Object System.Windows.Forms.Timer
$animTimer.Interval = 200
$animLine = 0
$animTimer.Add_Tick({
    if ($animLine -lt $headerLines.Count) {
        $headerLabel.Text += $headerLines[$animLine] + "`n"
        $animLine++
    } else {
        $animTimer.Stop()
    }
})
$animTimer.Start()

# Name input
$nameLabel = New-Object System.Windows.Forms.Label
$nameLabel.Text = "Your Name:"
$nameLabel.ForeColor = "#CCCCCC"
$nameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$nameLabel.Size = New-Object System.Drawing.Size(100, 25)
$nameLabel.Location = New-Object System.Drawing.Point(30, 180)
$form.Controls.Add($nameLabel)

$nameBox = New-Object System.Windows.Forms.TextBox
$nameBox.Size = New-Object System.Drawing.Size(300, 30)
$nameBox.Location = New-Object System.Drawing.Point(30, 210)
$nameBox.BackColor = "#333333"
$nameBox.ForeColor = "White"
$nameBox.BorderStyle = "FixedSingle"
$nameBox.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$nameBox.Text = $env:USERNAME
$form.Controls.Add($nameBox)

# Login/Register buttons
$loginBtn = New-Object System.Windows.Forms.Button
$loginBtn.Text = "🔐 Login"
$loginBtn.Size = New-Object System.Drawing.Size(100, 30)
$loginBtn.Location = New-Object System.Drawing.Point(350, 210)
$loginBtn.BackColor = "#333333"
$loginBtn.ForeColor = "White"
$loginBtn.FlatStyle = "Flat"
$loginBtn.Add_Click({ Show-Login })
$form.Controls.Add($loginBtn)

$registerBtn = New-Object System.Windows.Forms.Button
$registerBtn.Text = "📝 Register"
$registerBtn.Size = New-Object System.Drawing.Size(100, 30)
$registerBtn.Location = New-Object System.Drawing.Point(460, 210)
$registerBtn.BackColor = "#333333"
$registerBtn.ForeColor = "White"
$registerBtn.FlatStyle = "Flat"
$registerBtn.Add_Click({ Show-Register })
$form.Controls.Add($registerBtn)

# Status label
$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "● Not logged in"
$statusLabel.ForeColor = "#FF003C"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$statusLabel.Size = New-Object System.Drawing.Size(300, 20)
$statusLabel.Location = New-Object System.Drawing.Point(30, 250)
$form.Controls.Add($statusLabel)

# Scan button
$scanBtn = New-Object System.Windows.Forms.Button
$scanBtn.Text = "▶ START COMPLETE SCAN"
$scanBtn.Size = New-Object System.Drawing.Size(250, 45)
$scanBtn.Location = New-Object System.Drawing.Point(30, 280)
$scanBtn.BackColor = "#00FF9D"
$scanBtn.ForeColor = "#000000"
$scanBtn.FlatStyle = "Flat"
$scanBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$scanBtn.Enabled = $false
$scanBtn.Add_Click({ Start-Scan })
$form.Controls.Add($scanBtn)

# Bot control panel
$botGroup = New-Object System.Windows.Forms.GroupBox
$botGroup.Text = "🤖 Discord Bot Control"
$botGroup.ForeColor = "White"
$botGroup.Size = New-Object System.Drawing.Size(400, 150)
$botGroup.Location = New-Object System.Drawing.Point(350, 250)
$form.Controls.Add($botGroup)

$botTokenLabel = New-Object System.Windows.Forms.Label
$botTokenLabel.Text = "Bot Token:"
$botTokenLabel.ForeColor = "#CCCCCC"
$botTokenLabel.Size = New-Object System.Drawing.Size(80, 20)
$botTokenLabel.Location = New-Object System.Drawing.Point(10, 30)
$botGroup.Controls.Add($botTokenLabel)

$botTokenBox = New-Object System.Windows.Forms.TextBox
$botTokenBox.Size = New-Object System.Drawing.Size(250, 25)
$botTokenBox.Location = New-Object System.Drawing.Point(10, 55)
$botTokenBox.BackColor = "#333333"
$botTokenBox.ForeColor = "White"
$botTokenBox.PasswordChar = '*'
$botGroup.Controls.Add($botTokenBox)

$channelLabel = New-Object System.Windows.Forms.Label
$channelLabel.Text = "Channel ID:"
$channelLabel.ForeColor = "#CCCCCC"
$channelLabel.Size = New-Object System.Drawing.Size(80, 20)
$channelLabel.Location = New-Object System.Drawing.Point(10, 85)
$botGroup.Controls.Add($channelLabel)

$channelBox = New-Object System.Windows.Forms.TextBox
$channelBox.Size = New-Object System.Drawing.Size(150, 25)
$channelBox.Location = New-Object System.Drawing.Point(10, 110)
$channelBox.BackColor = "#333333"
$channelBox.ForeColor = "White"
$botGroup.Controls.Add($channelBox)

$connectBotBtn = New-Object System.Windows.Forms.Button
$connectBotBtn.Text = "🔌 Connect Bot"
$connectBotBtn.Size = New-Object System.Drawing.Size(100, 30)
$connectBotBtn.Location = New-Object System.Drawing.Point(180, 105)
$connectBotBtn.BackColor = "#FF003C"
$connectBotBtn.ForeColor = "White"
$connectBotBtn.FlatStyle = "Flat"
$connectBotBtn.Enabled = $false
$connectBotBtn.Add_Click({ Connect-Bot })
$botGroup.Controls.Add($connectBotBtn)

$botStatusLabel = New-Object System.Windows.Forms.Label
$botStatusLabel.Text = "⚪ Disconnected"
$botStatusLabel.ForeColor = "#888888"
$botStatusLabel.Size = New-Object System.Drawing.Size(150, 20)
$botStatusLabel.Location = New-Object System.Drawing.Point(180, 60)
$botGroup.Controls.Add($botStatusLabel)

# Console output
$console = New-Object System.Windows.Forms.RichTextBox
$console.Size = New-Object System.Drawing.Size(740, 200)
$console.Location = New-Object System.Drawing.Point(30, 410)
$console.BackColor = "#000000"
$console.ForeColor = "#00FF9D"
$console.Font = New-Object System.Drawing.Font("Consolas", 9)
$console.ReadOnly = $true
$form.Controls.Add($console)

# Progress bar
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(740, 20)
$progress.Location = New-Object System.Drawing.Point(30, 380)
$progress.Style = "Continuous"
$form.Controls.Add($progress)

# Global variables
$script:authToken = $null
$script:userId = $null
$script:username = $null
$script:botConnected = $false
$script:channelId = $null

# ========== FUNCTIONS ==========

function Write-Log {
    param($Message, $Color)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $console.AppendText("[$timestamp] $Message`r`n")
    $console.ScrollToCaret()
}

function Update-Progress {
    param($Value)
    $progress.Value = $Value
    $progress.Refresh()
}

function Show-Login {
    $loginForm = New-Object System.Windows.Forms.Form
    $loginForm.Text = "Login"
    $loginForm.Size = New-Object System.Drawing.Size(300, 250)
    $loginForm.StartPosition = "CenterParent"
    $loginForm.BackColor = "#1a1a1a"
    $loginForm.FormBorderStyle = "FixedDialog"
    
    $userLabel = New-Object System.Windows.Forms.Label
    $userLabel.Text = "Username:"
    $userLabel.ForeColor = "White"
    $userLabel.Location = New-Object System.Drawing.Point(20, 30)
    $userLabel.Size = New-Object System.Drawing.Size(100, 20)
    $loginForm.Controls.Add($userLabel)
    
    $userBox = New-Object System.Windows.Forms.TextBox
    $userBox.Location = New-Object System.Drawing.Point(20, 55)
    $userBox.Size = New-Object System.Drawing.Size(240, 20)
    $userBox.BackColor = "#333333"
    $userBox.ForeColor = "White"
    $loginForm.Controls.Add($userBox)
    
    $passLabel = New-Object System.Windows.Forms.Label
    $passLabel.Text = "Password:"
    $passLabel.ForeColor = "White"
    $passLabel.Location = New-Object System.Drawing.Point(20, 85)
    $passLabel.Size = New-Object System.Drawing.Size(100, 20)
    $loginForm.Controls.Add($passLabel)
    
    $passBox = New-Object System.Windows.Forms.TextBox
    $passBox.Location = New-Object System.Drawing.Point(20, 110)
    $passBox.Size = New-Object System.Drawing.Size(240, 20)
    $passBox.BackColor = "#333333"
    $passBox.ForeColor = "White"
    $passBox.PasswordChar = '*'
    $loginForm.Controls.Add($passBox)
    
    $loginBtn = New-Object System.Windows.Forms.Button
    $loginBtn.Text = "Login"
    $loginBtn.Location = New-Object System.Drawing.Point(20, 150)
    $loginBtn.Size = New-Object System.Drawing.Size(100, 30)
    $loginBtn.BackColor = "#00FF9D"
    $loginBtn.FlatStyle = "Flat"
    $loginBtn.Add_Click({
        $user = $userBox.Text
        $pass = $passBox.Text
        
        try {
            $body = @{
                username = $user
                password = $pass
                grant_type = "password"
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri "$ApiUrl/api/auth/login" -Method Post -Body $body -ContentType "application/json"
            
            $script:authToken = $response.access_token
            $script:userId = $response.user_id
            $script:username = $response.username
            
            $statusLabel.Text = "● Logged in as $script:username"
            $statusLabel.ForeColor = "#00FF9D"
            $scanBtn.Enabled = $true
            $connectBotBtn.Enabled = $true
            
            Write-Log "✅ Logged in successfully" "#00FF9D"
            $loginForm.Close()
        } catch {
            Write-Log "❌ Login failed: $_" "#FF003C"
        }
    })
    $loginForm.Controls.Add($loginBtn)
    
    $loginForm.ShowDialog()
}

function Show-Register {
    $regForm = New-Object System.Windows.Forms.Form
    $regForm.Text = "Register"
    $regForm.Size = New-Object System.Drawing.Size(300, 300)
    $regForm.StartPosition = "CenterParent"
    $regForm.BackColor = "#1a1a1a"
    $regForm.FormBorderStyle = "FixedDialog"
    
    $userLabel = New-Object System.Windows.Forms.Label
    $userLabel.Text = "Username:"
    $userLabel.ForeColor = "White"
    $userLabel.Location = New-Object System.Drawing.Point(20, 30)
    $userLabel.Size = New-Object System.Drawing.Size(100, 20)
    $regForm.Controls.Add($userLabel)
    
    $userBox = New-Object System.Windows.Forms.TextBox
    $userBox.Location = New-Object System.Drawing.Point(20, 55)
    $userBox.Size = New-Object System.Drawing.Size(240, 20)
    $userBox.BackColor = "#333333"
    $userBox.ForeColor = "White"
    $regForm.Controls.Add($userBox)
    
    $emailLabel = New-Object System.Windows.Forms.Label
    $emailLabel.Text = "Email:"
    $emailLabel.ForeColor = "White"
    $emailLabel.Location = New-Object System.Drawing.Point(20, 85)
    $emailLabel.Size = New-Object System.Drawing.Size(100, 20)
    $regForm.Controls.Add($emailLabel)
    
    $emailBox = New-Object System.Windows.Forms.TextBox
    $emailBox.Location = New-Object System.Drawing.Point(20, 110)
    $emailBox.Size = New-Object System.Drawing.Size(240, 20)
    $emailBox.BackColor = "#333333"
    $emailBox.ForeColor = "White"
    $regForm.Controls.Add($emailBox)
    
    $passLabel = New-Object System.Windows.Forms.Label
    $passLabel.Text = "Password:"
    $passLabel.ForeColor = "White"
    $passLabel.Location = New-Object System.Drawing.Point(20, 140)
    $passLabel.Size = New-Object System.Drawing.Size(100, 20)
    $regForm.Controls.Add($passLabel)
    
    $passBox = New-Object System.Windows.Forms.TextBox
    $passBox.Location = New-Object System.Drawing.Point(20, 165)
    $passBox.Size = New-Object System.Drawing.Size(240, 20)
    $passBox.BackColor = "#333333"
    $passBox.ForeColor = "White"
    $passBox.PasswordChar = '*'
    $regForm.Controls.Add($passBox)
    
    $regBtn = New-Object System.Windows.Forms.Button
    $regBtn.Text = "Register"
    $regBtn.Location = New-Object System.Drawing.Point(20, 200)
    $regBtn.Size = New-Object System.Drawing.Size(100, 30)
    $regBtn.BackColor = "#00FF9D"
    $regBtn.FlatStyle = "Flat"
    $regBtn.Add_Click({
        try {
            $body = @{
                username = $userBox.Text
                email = $emailBox.Text
                password = $passBox.Text
            } | ConvertTo-Json
            
            $response = Invoke-RestMethod -Uri "$ApiUrl/api/auth/register" -Method Post -Body $body -ContentType "application/json"
            
            Write-Log "✅ Registration successful! You can now login." "#00FF9D"
            $regForm.Close()
        } catch {
            Write-Log "❌ Registration failed: $_" "#FF003C"
        }
    })
    $regForm.Controls.Add($regBtn)
    
    $regForm.ShowDialog()
}

function Connect-Bot {
    $token = $botTokenBox.Text
    $channel = $channelBox.Text
    
    if (-not $token -or -not $channel) {
        Write-Log "❌ Please enter bot token and channel ID" "#FF003C"
        return
    }
    
    $connectBotBtn.Enabled = $false
    $connectBotBtn.Text = "Connecting..."
    
    try {
        $body = @{
            user_id = $script:userId
            bot_token = $token
            channel_id = $channel
        } | ConvertTo-Json
        
        $headers = @{
            "Authorization" = "Bearer $script:authToken"
        }
        
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/bot/start" -Method Post -Body $body -ContentType "application/json" -Headers $headers
        
        $script:botConnected = $true
        $script:channelId = $channel
        $botStatusLabel.Text = "🟢 Connected"
        $botStatusLabel.ForeColor = "#00FF9D"
        $connectBotBtn.Text = "🔌 Connected"
        $connectBotBtn.BackColor = "#00FF9D"
        
        Write-Log "✅ Bot connected successfully" "#00FF9D"
    } catch {
        Write-Log "❌ Failed to connect bot: $_" "#FF003C"
        $connectBotBtn.Enabled = $true
        $connectBotBtn.Text = "🔌 Connect Bot"
    }
}

function Get-OneDrivePath {
    $oneDrivePath = (Get-ItemProperty "HKCU:\Software\Microsoft\OneDrive" -Name "UserFolder" -ErrorAction SilentlyContinue).UserFolder
    if (-not $oneDrivePath) {
        $envOneDrive = [System.IO.Path]::Combine($env:UserProfile, "OneDrive")
        if (Test-Path $envOneDrive) {
            $oneDrivePath = $envOneDrive
        }
    }
    return $oneDrivePath
}

function Find-RarAndExeFiles {
    Write-Log "🔍 Finding .rar and .exe files..."
    $files = @()
    $searchPaths = @(
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "C:\Program Files",
        "C:\Program Files (x86)"
    )
    
    $oneDrivePath = Get-OneDrivePath
    if ($oneDrivePath) { $searchPaths += $oneDrivePath }
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -Include "*.rar", "*.exe" -ErrorAction SilentlyContinue | ForEach-Object {
                    $files += $_.FullName
                }
            } catch {}
        }
    }
    
    Write-Log "  Found $($files.Count) files"
    return $files
}

function Find-SusFiles {
    Write-Log "🔍 Searching for suspicious files..."
    $susFiles = @()
    $pattern = '^[A-Za-z0-9]{10}\.exe$'
    $searchPaths = @(
        "$env:USERPROFILE\Desktop",
        "$env:USERPROFILE\Downloads",
        "$env:USERPROFILE\Documents",
        "$env:USERPROFILE\AppData\Local\Temp",
        "C:\Windows\Temp",
        "C:\Program Files",
        "C:\Program Files (x86)"
    )
    
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                    if ($_.Name -match $pattern -or $_.Name -ieq "Dapper.dll") {
                        $susFiles += @{
                            name = $_.Name
                            path = $_.FullName
                            severity = if ($_.Name -match $pattern) { "HIGH" } else { "MEDIUM" }
                        }
                        Write-Log "    Found: $($_.Name) ($($_.FullName))" "#FFFF00"
                    }
                }
            } catch {}
        }
    }
    
    Write-Log "  Found $($susFiles.Count) suspicious files"
    return $susFiles
}

function Get-R6Accounts {
    Write-Log "🔍 Checking Rainbow Six Siege accounts..."
    $accounts = @()
    $userName = $env:USERNAME
    
    $r6Paths = @(
        "C:\Users\$userName\Documents\My Games\Rainbow Six - Siege",
        "C:\Users\$userName\AppData\Local\Ubisoft Game Launcher"
    )
    
    foreach ($path in $r6Paths) {
        if (Test-Path $path) {
            try {
                Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                    $accounts += @{
                        name = $_.Name
                        path = $_.FullName
                    }
                    Write-Log "    Found R6 account: $($_.Name)" "#00FF9D"
                }
            } catch {}
        }
    }
    
    Write-Log "  Found $($accounts.Count) R6 account(s)"
    return $accounts
}

function Get-SteamAccounts {
    Write-Log "🔍 Checking Steam accounts..."
    $accounts = @()
    $steamConfig = "C:\Program Files (x86)\Steam\config\loginusers.vdf"
    
    if (Test-Path $steamConfig) {
        try {
            $content = Get-Content $steamConfig -Raw -ErrorAction SilentlyContinue
            if ($content) {
                $matches = [regex]::Matches($content, '"AccountName"\s*"([^"]*)"')
                foreach ($match in $matches) {
                    $accounts += @{
                        name = $match.Groups[1].Value
                    }
                    Write-Log "    Found Steam account: $($match.Groups[1].Value)" "#00FF9D"
                }
            }
        } catch {}
    }
    
    Write-Log "  Found $($accounts.Count) Steam account(s)"
    return $accounts
}

function Get-WindowsInstallDate {
    try {
        $os = Get-WmiObject -Class Win32_OperatingSystem -ErrorAction Stop
        $installDate = $os.ConvertToDateTime($os.InstallDate)
        return $installDate.ToString("yyyy-MM-dd")
    } catch {
        return $null
    }
}

function Get-AntivirusStatus {
    try {
        $antivirus = Get-WmiObject -Namespace "root\SecurityCenter2" -Class AntiVirusProduct -ErrorAction SilentlyContinue
        if ($antivirus) {
            return ($antivirus | Where-Object { $_.displayName -ne "Windows Defender" }).displayName -join ", "
        }
        return "Windows Defender Only"
    } catch {
        return "Unknown"
    }
}

function Get-PrefetchFiles {
    $prefetchPath = "$env:SystemRoot\Prefetch"
    $files = @()
    
    if (Test-Path $prefetchPath) {
        try {
            Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue | ForEach-Object {
                $files += @{
                    name = $_.Name
                    last_accessed = $_.LastAccessTime.ToString("yyyy-MM-dd HH:mm")
                }
            }
        } catch {}
    }
    
    return $files
}

function Get-LogitechScripts {
    $scriptsPath = Join-Path -Path $env:LocalAppData -ChildPath "LGHUB\scripts"
    $scripts = @()
    
    if (Test-Path $scriptsPath) {
        try {
            Get-ChildItem -Path $scriptsPath -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                $scripts += @{
                    name = $_.Name
                    path = $_.FullName
                    modified = $_.LastWriteTime.ToString("yyyy-MM-dd HH:mm")
                }
            }
        } catch {}
    }
    
    return $scripts
}

function Start-Scan {
    $scanBtn.Enabled = $false
    $scanBtn.Text = "SCANNING..."
    $console.Clear()
    Update-Progress 0
    
    $name = $nameBox.Text
    $startTime = Get-Date
    
    Write-Log "╔══════════════════════════════════════════════════════════╗" "#FF003C"
    Write-Log "║           R6X CYBERSCAN - COMPLETE ANALYSIS            ║" "#FF003C"
    Write-Log "╚══════════════════════════════════════════════════════════╝" "#FF003C"
    Write-Log ""
    Write-Log "Scan started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Log "User: $name"
    Write-Log "Computer: $env:COMPUTERNAME"
    Write-Log ""
    
    # Initialize results
    $results = @{
        username = $name
        computer = $env:COMPUTERNAME
        files_scanned = 0
        threats_found = 0
        suspicious_files = @()
        r6_accounts = @()
        steam_accounts = @()
        windows_install_date = $null
        antivirus_status = $null
        prefetch_files = @()
        logitech_scripts = @()
        scan_time = (Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
    }
    
    # Run all scans
    Update-Progress 10
    $rarExeFiles = Find-RarAndExeFiles
    $results.files_scanned = $rarExeFiles.Count
    
    Update-Progress 30
    $results.suspicious_files = Find-SusFiles
    $results.threats_found = $results.suspicious_files.Count
    
    Update-Progress 50
    $results.r6_accounts = Get-R6Accounts
    
    Update-Progress 60
    $results.steam_accounts = Get-SteamAccounts
    
    Update-Progress 70
    $results.windows_install_date = Get-WindowsInstallDate
    
    Update-Progress 80
    $results.antivirus_status = Get-AntivirusStatus
    
    Update-Progress 90
    $results.prefetch_files = Get-PrefetchFiles
    $results.logitech_scripts = Get-LogitechScripts
    
    # Display summary
    Write-Log ""
    Write-Log "╔══════════════════════════════════════════════════════════╗" "#FF003C"
    Write-Log "║                    SCAN COMPLETE                       ║" "#FF003C"
    Write-Log "╚══════════════════════════════════════════════════════════╝" "#FF003C"
    Write-Log "  Files Scanned: $($results.files_scanned)"
    Write-Log "  Threats Found: $($results.threats_found)"
    Write-Log "  R6 Accounts: $($results.r6_accounts.Count)"
    Write-Log "  Steam Accounts: $($results.steam_accounts.Count)"
    Write-Log "  Windows Install: $($results.windows_install_date)"
    Write-Log "  Antivirus: $($results.antivirus_status)"
    Write-Log "  Prefetch Files: $($results.prefetch_files.Count)"
    Write-Log "  Logitech Scripts: $($results.logitech_scripts.Count)"
    Write-Log ""
    
    # Save to backend
    if ($script:authToken) {
        try {
            $headers = @{
                "Authorization" = "Bearer $script:authToken"
            }
            
            $body = $results | ConvertTo-Json -Depth 10
            $response = Invoke-RestMethod -Uri "$ApiUrl/api/scan/save" -Method Post -Body $body -ContentType "application/json" -Headers $headers
            
            Write-Log "✅ Results saved to database" "#00FF9D"
        } catch {
            Write-Log "❌ Failed to save results: $_" "#FF003C"
        }
    }
    
    Update-Progress 100
    
    # Show completion message
    if ($results.threats_found -gt 0) {
        Write-Log "⚠️ WARNING: Found $($results.threats_found) suspicious files!" "#FF003C"
        $resultColor = "#FF003C"
    } else {
        Write-Log "✅ System appears clean!" "#00FF9D"
        $resultColor = "#00FF9D"
    }
    
    $scanBtn.Enabled = $true
    $scanBtn.Text = "▶ START COMPLETE SCAN"
}

# Show form
$form.Add_Shown({ $form.Activate() })
[System.Windows.Forms.Application]::Run($form)
