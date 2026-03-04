# R6X-Scanner-Terminal.ps1 - R6 Cheat Scanner (Terminal Version)
# Save this file and run in PowerShell as Administrator
# Usage: .\R6X-Scanner-Terminal.ps1 [-ApiUrl "https://your-url.com"] [-Name "Username"]

param(
    [string]$ApiUrl = "https://bot-hosting-b-ga04.onrender.com",  # Change this to your Render URL
    [string]$Name = ""
)

# ========== CONFIGURATION ==========
$host.UI.RawUI.BackgroundColor = "Black"
$host.UI.RawUI.ForegroundColor = "White"
Clear-Host

# Colors
$RED = "Red"
$GREEN = "Green"
$YELLOW = "Yellow"
$CYAN = "Cyan"
$MAGENTA = "Magenta"
$GRAY = "Gray"
$DARKGRAY = "DarkGray"

# ========== FUNCTIONS ==========

function Write-Color {
    param(
        [string]$Text,
        [string]$Color = "White",
        [switch]$NoNewLine
    )
    
    if ($NoNewLine) {
        Write-Host $Text -ForegroundColor $Color -NoNewline
    } else {
        Write-Host $Text -ForegroundColor $Color
    }
}

function Write-Banner {
    Clear-Host
    Write-Color "╔══════════════════════════════════════════════════════════╗" $RED
    Write-Color "║                     R6X CYBERSCAN v4.2                  ║" $RED
    Write-Color "║              Rainbow Six Siege Security Scanner         ║" $RED
    Write-Color "╚══════════════════════════════════════════════════════════╝" $RED
    Write-Host ""
}

function Write-Section {
    param([string]$Title)
    Write-Host ""
    Write-Color "┌────────── $Title ──────────┐" $CYAN
}

function Write-ProgressBar {
    param(
        [int]$Percent,
        [string]$Status = ""
    )
    
    $barSize = 40
    $filled = [math]::Floor($barSize * $Percent / 100)
    $empty = $barSize - $filled
    
    $bar = "[" + ("█" * $filled) + ("░" * $empty) + "]"
    
    Write-Host -NoNewline "`r$bar $Percent% " -ForegroundColor $GREEN
    if ($Status) {
        Write-Host -NoNewline "- $Status" -ForegroundColor $GRAY
    }
}

function Test-BackendConnection {
    param([int]$TimeoutSeconds = 5)
    try {
        $response = Invoke-WebRequest -Uri "$ApiUrl/api/health" -Method Get -TimeoutSec $TimeoutSeconds -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            return $true
        }
    } catch {
        if ($_.Exception.Response -and $_.Exception.Response.StatusCode.value__ -eq 405) {
            return $true
        }
    }
    return $false
}

function Show-LoadingAnimation {
    param(
        [string]$Text,
        [int]$Duration = 2
    )
    
    $frames = @("⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏")
    $endTime = (Get-Date).AddSeconds($Duration)
    
    while ((Get-Date) -lt $endTime) {
        foreach ($frame in $frames) {
            Write-Host -NoNewline "`r$frame $Text" -ForegroundColor $CYAN
            Start-Sleep -Milliseconds 100
            if ((Get-Date) -ge $endTime) { break }
        }
    }
    Write-Host "`r✓ $Text" -ForegroundColor $GREEN
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
    Write-Color "🔍 Scanning for executables..." $CYAN
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
    
    $totalFiles = 0
    foreach ($path in $searchPaths) {
        if (Test-Path $path) {
            try {
                $pathFiles = Get-ChildItem -Path $path -Recurse -Include "*.rar", "*.exe" -ErrorAction SilentlyContinue
                $files += $pathFiles.FullName
                $totalFiles += $pathFiles.Count
                Write-Color "  → $path : $($pathFiles.Count) files" $GRAY
            } catch {}
        }
    }
    
    Write-Color "  ✓ Found $totalFiles total files" $GREEN
    return $files
}

function Find-SusFiles {
    Write-Color "🔍 Analyzing suspicious patterns..." $CYAN
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
                        $severity = if ($_.Name -match $pattern) { "CRITICAL" } else { "SUSPICIOUS" }
                        $susFiles += @{
                            name = $_.Name
                            path = $_.FullName
                            severity = $severity
                        }
                        
                        $color = if ($severity -eq "CRITICAL") { $RED } else { $YELLOW }
                        Write-Color "    ⚠ Found: $($_.Name) [$severity]" $color
                    }
                }
            } catch {}
        }
    }
    
    Write-Color "  → Found $($susFiles.Count) suspicious items" $($susFiles.Count -gt 0 ? $RED : $GREEN)
    return $susFiles
}

function Get-R6Accounts {
    Write-Color "🔍 Extracting Rainbow Six accounts..." $CYAN
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
                    Write-Color "    → Found: $($_.Name)" $GRAY
                }
            } catch {}
        }
    }
    
    Write-Color "  → Found $($accounts.Count) R6 profile(s)" $GREEN
    return $accounts
}

function Get-SteamAccounts {
    Write-Color "🔍 Extracting Steam accounts..." $CYAN
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
                    Write-Color "    → Found: $($match.Groups[1].Value)" $GRAY
                }
            }
        } catch {}
    }
    
    Write-Color "  → Found $($accounts.Count) Steam profile(s)" $GREEN
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
            $avList = ($antivirus | Where-Object { $_.displayName -ne "Windows Defender" }).displayName -join ", "
            if ($avList) { return $avList }
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

function Show-Results {
    param($Results)
    
    Write-Host ""
    Write-Color "╔══════════════════════════════════════════════════════════╗" $MAGENTA
    Write-Color "║                    SCAN RESULTS                         ║" $MAGENTA
    Write-Color "╚══════════════════════════════════════════════════════════╝" $MAGENTA
    Write-Host ""
    
    Write-Color "  📁 Files Scanned     : " -NoNewLine
    Write-Color "$($Results.files_scanned)" $($Results.files_scanned -gt 1000 ? $YELLOW : $GREEN)
    
    Write-Color "  ⚠ Threats Found      : " -NoNewLine
    Write-Color "$($Results.threats_found)" $($Results.threats_found -gt 0 ? $RED : $GREEN)
    
    Write-Color "  🎮 R6 Accounts        : " -NoNewLine
    Write-Color "$($Results.r6_accounts.Count)" $($Results.r6_accounts.Count -gt 0 ? $YELLOW : $GRAY)
    
    Write-Color "  🔄 Steam Accounts     : " -NoNewLine
    Write-Color "$($Results.steam_accounts.Count)" $($Results.steam_accounts.Count -gt 0 ? $YELLOW : $GRAY)
    
    Write-Color "  💻 Windows Install    : " -NoNewLine
    Write-Color "$($Results.windows_install_date)" $GRAY
    
    Write-Color "  🛡 Antivirus Status    : " -NoNewLine
    Write-Color "$($Results.antivirus_status)" $GRAY
    
    Write-Color "  📊 Prefetch Files     : " -NoNewLine
    Write-Color "$($Results.prefetch_files.Count)" $GRAY
    
    Write-Color "  ⌨ Logitech Scripts    : " -NoNewLine
    Write-Color "$($Results.logitech_scripts.Count)" $GRAY
    
    # Show suspicious files if any
    if ($Results.suspicious_files.Count -gt 0) {
        Write-Host ""
        Write-Color "  ⚠ SUSPICIOUS FILES DETECTED:" $RED
        $Results.suspicious_files | ForEach-Object {
            Write-Color "    • $($_.name) [$($_.severity)]" $($_.severity -eq "CRITICAL" ? $RED : $YELLOW)
        }
    }
    
    # Calculate clean score
    $cleanScore = 100 - ($Results.threats_found * 10)
    if ($cleanScore -lt 0) { $cleanScore = 0 }
    
    Write-Host ""
    Write-Color "  System Clean Score: " -NoNewLine
    if ($cleanScore -ge 80) {
        Write-Color "$cleanScore% (GOOD)" $GREEN
    } elseif ($cleanScore -ge 50) {
        Write-Color "$cleanScore% (WARNING)" $YELLOW
    } else {
        Write-Color "$cleanScore% (CRITICAL)" $RED
    }
}

# ========== MAIN SCRIPT ==========

Write-Banner

# Check if running as admin
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Color "⚠ Warning: Not running as Administrator" $YELLOW
    Write-Color "  Some scans may be limited. Run PowerShell as Admin for full access." $GRAY
    Write-Host ""
}

# Get username if not provided
if (-not $Name) {
    $Name = Read-Host "Enter your username (or press Enter for $env:USERNAME)"
    if (-not $Name) { $Name = $env:USERNAME }
}

Write-Section "CONNECTION CHECK"
Write-Host ""

# Test backend connection
Write-Color "Testing connection to backend..." $GRAY
$connected = Test-BackendConnection

if ($connected) {
    Write-Color "✓ Backend connected successfully" $GREEN
    Write-Color "  Discord bot: Active" $GREEN
} else {
    Write-Color "⚠ Backend offline - continuing in offline mode" $YELLOW
    Write-Color "  Discord bot: Inactive" $RED
    Write-Color "  Results will be saved locally only" $GRAY
}

Write-Section "STARTING SCAN"
Write-Host ""
Write-Color "Operator: $Name" $CYAN
Write-Color "System: $env:COMPUTERNAME" $CYAN
Write-Color "Time: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" $CYAN
Write-Host ""

# Initialize results
$results = @{
    username = $Name
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

# Phase 1: File scanning
Write-Section "PHASE 1: FILE ANALYSIS"
Write-Host ""
$rarExeFiles = Find-RarAndExeFiles
$results.files_scanned = $rarExeFiles.Count
Write-Host ""

# Phase 2: Suspicious patterns
Write-Section "PHASE 2: THREAT DETECTION"
Write-Host ""
$results.suspicious_files = Find-SusFiles
$results.threats_found = $results.suspicious_files.Count
Write-Host ""

# Phase 3: Account extraction
Write-Section "PHASE 3: ACCOUNT EXTRACTION"
Write-Host ""
$results.r6_accounts = Get-R6Accounts
Write-Host ""
$results.steam_accounts = Get-SteamAccounts
Write-Host ""

# Phase 4: System information
Write-Section "PHASE 4: SYSTEM ANALYSIS"
Write-Host ""
Write-Color "🔍 Gathering system information..." $CYAN
$results.windows_install_date = Get-WindowsInstallDate
$results.antivirus_status = Get-AntivirusStatus
$results.prefetch_files = Get-PrefetchFiles
$results.logitech_scripts = Get-LogitechScripts
Write-Color "  ✓ System information collected" $GREEN
Write-Host ""

# Show results
Show-Results $results

# Save to backend if connected
if ($connected) {
    Write-Section "UPLOADING RESULTS"
    Write-Host ""
    Write-Color "Transmitting to Discord..." $GRAY
    
    try {
        $body = $results | ConvertTo-Json -Depth 10
        $response = Invoke-RestMethod -Uri "$ApiUrl/api/scan/save" -Method Post -Body $body -ContentType "application/json" -ErrorAction Stop
        Write-Color "✓ Results successfully sent to Discord" $GREEN
    } catch {
        Write-Color "✗ Failed to send results: $_" $RED
    }
}

# Save local copy
$localPath = "$env:USERPROFILE\Desktop\R6X_Scan_$(Get-Date -Format 'yyyyMMdd_HHmmss').json"
$results | ConvertTo-Json -Depth 10 | Out-File $localPath
Write-Color "✓ Local copy saved to: $localPath" $GRAY

Write-Host ""
Write-Color "╔══════════════════════════════════════════════════════════╗" $GREEN
Write-Color "║                    SCAN COMPLETE                        ║" $GREEN
Write-Color "╚══════════════════════════════════════════════════════════╝" $GREEN
Write-Host ""

# Final message based on threats
if ($results.threats_found -gt 0) {
    Write-Color "⚠ CRITICAL: $($results.threats_found) suspicious files detected!" $RED
    Write-Color "  Review the suspicious files listed above and take action." $YELLOW
} else {
    Write-Color "✓ SYSTEM CLEAN: No threats detected" $GREEN
}

Write-Host ""
Write-Host "Press any key to exit..." -ForegroundColor $GRAY
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
