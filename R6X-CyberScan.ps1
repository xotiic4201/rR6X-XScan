# R6X-Scanner.ps1 - Complete R6 Cheat Scanner (No Login Required)
# Save this file and run in PowerShell as Administrator

param(
    [string]$ApiUrl = "https://bot-hosting-b-ga04.onrender.com"  # Change this to your Render URL
)

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# Create form
$form = New-Object System.Windows.Forms.Form
$form.Text = "R6X CYBERSCAN v4.0"
$form.Size = New-Object System.Drawing.Size(700, 500)
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

# Subtitle
$subtitle = New-Object System.Windows.Forms.Label
$subtitle.Text = "Anti-Cheat Scanner for Rainbow Six Siege"
$subtitle.ForeColor = "#888888"
$subtitle.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$subtitle.Size = New-Object System.Drawing.Size(400, 20)
$subtitle.Location = New-Object System.Drawing.Point(30, 70)
$form.Controls.Add($subtitle)

# Name input
$nameLabel = New-Object System.Windows.Forms.Label
$nameLabel.Text = "Your Name:"
$nameLabel.ForeColor = "#CCCCCC"
$nameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$nameLabel.Size = New-Object System.Drawing.Size(100, 25)
$nameLabel.Location = New-Object System.Drawing.Point(30, 120)
$form.Controls.Add($nameLabel)

$nameBox = New-Object System.Windows.Forms.TextBox
$nameBox.Size = New-Object System.Drawing.Size(350, 35)
$nameBox.Location = New-Object System.Drawing.Point(30, 150)
$nameBox.BackColor = "#333333"
$nameBox.ForeColor = "White"
$nameBox.BorderStyle = "FixedSingle"
$nameBox.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$nameBox.Text = $env:USERNAME
$form.Controls.Add($nameBox)

# Scan button
$scanBtn = New-Object System.Windows.Forms.Button
$scanBtn.Text = "▶ START COMPLETE SCAN"
$scanBtn.Size = New-Object System.Drawing.Size(250, 50)
$scanBtn.Location = New-Object System.Drawing.Point(30, 210)
$scanBtn.BackColor = "#00FF9D"
$scanBtn.ForeColor = "#000000"
$scanBtn.FlatStyle = "Flat"
$scanBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$scanBtn.Add_Click({ Start-Scan })
$form.Controls.Add($scanBtn)

# Discord Status
$discordStatus = New-Object System.Windows.Forms.Label
$discordStatus.Text = "🤖 Discord Bot: Active"
$discordStatus.ForeColor = "#00FF9D"
$discordStatus.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$discordStatus.Size = New-Object System.Drawing.Size(200, 25)
$discordStatus.Location = New-Object System.Drawing.Point(320, 225)
$form.Controls.Add($discordStatus)

# Console output
$console = New-Object System.Windows.Forms.RichTextBox
$console.Size = New-Object System.Drawing.Size(640, 150)
$console.Location = New-Object System.Drawing.Point(30, 280)
$console.BackColor = "#000000"
$console.ForeColor = "#00FF9D"
$console.Font = New-Object System.Drawing.Font("Consolas", 10)
$console.ReadOnly = $true
$form.Controls.Add($console)

# Progress bar
$progress = New-Object System.Windows.Forms.ProgressBar
$progress.Size = New-Object System.Drawing.Size(640, 20)
$progress.Location = New-Object System.Drawing.Point(30, 440)
$progress.Style = "Continuous"
$form.Controls.Add($progress)

# ========== FUNCTIONS ==========

function Write-Log {
    param($Message)
    $timestamp = Get-Date -Format "HH:mm:ss"
    $console.AppendText("[$timestamp] $Message`r`n")
    $console.ScrollToCaret()
}

function Update-Progress {
    param($Value)
    $progress.Value = $Value
    $progress.Refresh()
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
                        Write-Log "    Found: $($_.Name)" 
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
                    Write-Log "    Found R6 account: $($_.Name)"
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
                    Write-Log "    Found Steam account: $($match.Groups[1].Value)"
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
    
    $name = $nameBox.Text.Trim()
    if (-not $name) {
        [System.Windows.Forms.MessageBox]::Show("Please enter your name", "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $scanBtn.Enabled = $true
        $scanBtn.Text = "▶ START COMPLETE SCAN"
        return
    }
    
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║           R6X CYBERSCAN - COMPLETE ANALYSIS            ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
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
    Write-Log "╔══════════════════════════════════════════════════════════╗"
    Write-Log "║                    SCAN COMPLETE                       ║"
    Write-Log "╚══════════════════════════════════════════════════════════╝"
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
    try {
        $body = $results | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/scan/save" -Method Post -Body $body -ContentType "application/json" -ErrorAction SilentlyContinue
        
        Write-Log "✅ Results saved and sent to Discord"
    } catch {
        Write-Log "❌ Failed to send results: $_"
    }
    
    Update-Progress 100
    
    # Show completion message
    if ($results.threats_found -gt 0) {
        Write-Log "⚠️ WARNING: Found $($results.threats_found) suspicious files!"
        [System.Windows.Forms.MessageBox]::Show("Found $($results.threats_found) suspicious files!", "Threats Detected", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
    } else {
        Write-Log "✅ System appears clean!"
        [System.Windows.Forms.MessageBox]::Show("Scan complete - No threats found!", "Clean System", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    }
    
    $scanBtn.Enabled = $true
    $scanBtn.Text = "▶ START COMPLETE SCAN"
}

# Show form
$form.Add_Shown({ $form.Activate() })
[System.Windows.Forms.Application]::Run($form)
