# R6X CYBERSCAN v4.0 - User Client Application with Supabase
# Save this as R6X-CyberScan.ps1

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
Add-Type -AssemblyName PresentationFramework
Add-Type -AssemblyName System.Web
Add-Type -AssemblyName System.Net.Http

# Global variables
$global:apiBaseUrl = "https://bot-hosting-b-ga04.onrender.com"  # Your Render API URL
$global:authToken = $null
$global:refreshToken = $null
$global:currentUser = $null
$global:botConnected = $false
$global:botChannelId = $null
$global:scanInProgress = $false
$global:httpClient = New-Object System.Net.Http.HttpClient

# Set default headers
$global:httpClient.DefaultRequestHeaders.Add("User-Agent", "R6X-CyberScan-Client/4.0")
$global:httpClient.DefaultRequestHeaders.Add("Accept", "application/json")
$global:httpClient.Timeout = [TimeSpan]::FromSeconds(30)

# API Function with better error handling
function Invoke-R6XApi {
    param(
        [string]$Endpoint,
        [string]$Method = "GET",
        [hashtable]$Body = $null,
        [bool]$UseAuth = $true
    )
    
    $url = "$global:apiBaseUrl$Endpoint"
    $request = New-Object System.Net.Http.HttpRequestMessage
    $request.Method = [System.Net.Http.HttpMethod]::$Method
    $request.RequestUri = [System.Uri]::new($url)
    
    if ($UseAuth -and $global:authToken) {
        $request.Headers.Add("Authorization", "Bearer $global:authToken")
    }
    
    if ($Body) {
        $jsonBody = $Body | ConvertTo-Json -Depth 10
        $content = New-Object System.Net.Http.StringContent($jsonBody, [System.Text.Encoding]::UTF8, "application/json")
        $request.Content = $content
    }
    
    try {
        $response = $global:httpClient.SendAsync($request).Result
        $responseContent = $response.Content.ReadAsStringAsync().Result
        
        if ($response.IsSuccessStatusCode) {
            return @{
                Success = $true
                Data = if ($responseContent) { $responseContent | ConvertFrom-Json } else $null
                StatusCode = $response.StatusCode
            }
        } else {
            # Try to refresh token if unauthorized
            if ($response.StatusCode -eq 401 -and $UseAuth) {
                $refreshResult = Update-AuthToken
                if ($refreshResult.Success) {
                    return Invoke-R6XApi -Endpoint $Endpoint -Method $Method -Body $Body -UseAuth $true
                }
            }
            
            $errorMsg = "API Error: $($response.StatusCode)"
            try {
                $errorData = $responseContent | ConvertFrom-Json
                if ($errorData.detail) {
                    $errorMsg = $errorData.detail
                }
            } catch {}
            
            return @{
                Success = $false
                Error = $errorMsg
                StatusCode = $response.StatusCode
            }
        }
    }
    catch {
        return @{
            Success = $false
            Error = "Connection Error: $_"
        }
    }
    finally {
        $request.Dispose()
    }
}

# Token refresh function
function Update-AuthToken {
    if (-not $global:refreshToken) {
        return @{ Success = $false }
    }
    
    $result = Invoke-R6XApi -Endpoint "/api/auth/refresh" -Method "POST" -Body @{
        refresh_token = $global:refreshToken
    } -UseAuth $false
    
    if ($result.Success) {
        $global:authToken = $result.Data.access_token
        $global:refreshToken = $result.Data.refresh_token
        return @{ Success = $true }
    }
    
    return @{ Success = $false }
}

# Save credentials securely
function Save-Credentials {
    param($username, $password)
    
    try {
        # Create directory if it doesn't exist
        $credPath = "$env:APPDATA\R6X_CyberScan"
        if (-not (Test-Path $credPath)) {
            New-Item -ItemType Directory -Path $credPath -Force | Out-Null
        }
        
        $credential = New-Object System.Management.Automation.PSCredential($username, (ConvertTo-SecureString $password -AsPlainText -Force))
        $credential | Export-Clixml -Path "$credPath\credentials_$username.xml" -ErrorAction SilentlyContinue
        return $true
    } catch {
        return $false
    }
}

# Load saved credentials
function Get-SavedCredentials {
    $credPath = "$env:APPDATA\R6X_CyberScan"
    $credFiles = Get-ChildItem "$credPath\credentials_*.xml" -ErrorAction SilentlyContinue
    if ($credFiles) {
        $latest = $credFiles | Sort-Object LastWriteTime -Descending | Select-Object -First 1
        try {
            $credential = Import-Clixml -Path $latest.FullName
            return @{
                Username = $credential.UserName
                Password = $credential.GetNetworkCredential().Password
            }
        } catch {
            return $null
        }
    }
    return $null
}

# Create app data directory
$appDataPath = "$env:APPDATA\R6X_CyberScan"
if (-not (Test-Path $appDataPath)) {
    New-Item -ItemType Directory -Path $appDataPath -Force | Out-Null
}

# Create main form
$form = New-Object System.Windows.Forms.Form
$form.Text = "R6X CYBERSCAN v4.0 - Security Scanner"
$form.Size = New-Object System.Drawing.Size(1300, 800)
$form.StartPosition = "CenterScreen"
$form.BackColor = "#0a0a0a"
$form.ForeColor = "White"
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false
$form.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)

# Create header
$headerPanel = New-Object System.Windows.Forms.Panel
$headerPanel.Size = New-Object System.Drawing.Size(1300, 80)
$headerPanel.Location = New-Object System.Drawing.Point(0, 0)
$headerPanel.BackColor = "#000000"

$logoLabel = New-Object System.Windows.Forms.Label
$logoLabel.Text = "🔍 R6X CYBERSCAN"
$logoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 24, [System.Drawing.FontStyle]::Bold)
$logoLabel.ForeColor = "#FF003C"
$logoLabel.Size = New-Object System.Drawing.Size(400, 50)
$logoLabel.Location = New-Object System.Drawing.Point(20, 15)
$headerPanel.Controls.Add($logoLabel)

$statusLabel = New-Object System.Windows.Forms.Label
$statusLabel.Text = "● DISCONNECTED"
$statusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$statusLabel.ForeColor = "#FF003C"
$statusLabel.Size = New-Object System.Drawing.Size(150, 30)
$statusLabel.Location = New-Object System.Drawing.Point(1100, 25)
$statusLabel.TextAlign = "MiddleRight"
$headerPanel.Controls.Add($statusLabel)

$userLabel = New-Object System.Windows.Forms.Label
$userLabel.Text = ""
$userLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$userLabel.ForeColor = "#00FF9D"
$userLabel.Size = New-Object System.Drawing.Size(200, 30)
$userLabel.Location = New-Object System.Drawing.Point(900, 25)
$userLabel.TextAlign = "MiddleRight"
$headerPanel.Controls.Add($userLabel)

$form.Controls.Add($headerPanel)

# Create tab control
$tabControl = New-Object System.Windows.Forms.TabControl
$tabControl.Size = New-Object System.Drawing.Size(1260, 640)
$tabControl.Location = New-Object System.Drawing.Point(20, 100)
$tabControl.BackColor = "#1a1a1a"
$tabControl.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# LOGIN TAB
$loginTab = New-Object System.Windows.Forms.TabPage
$loginTab.Text = "🔐 LOGIN"
$loginTab.BackColor = "#1a1a1a"

$loginPanel = New-Object System.Windows.Forms.Panel
$loginPanel.Size = New-Object System.Drawing.Size(500, 500)
$loginPanel.Location = New-Object System.Drawing.Point(380, 50)
$loginPanel.BackColor = "#252525"
$loginPanel.BorderStyle = "FixedSingle"

$loginTitle = New-Object System.Windows.Forms.Label
$loginTitle.Text = "WELCOME BACK"
$loginTitle.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
$loginTitle.ForeColor = "#FF003C"
$loginTitle.Size = New-Object System.Drawing.Size(450, 50)
$loginTitle.Location = New-Object System.Drawing.Point(25, 30)
$loginTitle.TextAlign = "MiddleCenter"
$loginPanel.Controls.Add($loginTitle)

$loginSubtitle = New-Object System.Windows.Forms.Label
$loginSubtitle.Text = "Sign in to access R6X CyberScan"
$loginSubtitle.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$loginSubtitle.ForeColor = "#888888"
$loginSubtitle.Size = New-Object System.Drawing.Size(450, 30)
$loginSubtitle.Location = New-Object System.Drawing.Point(25, 80)
$loginSubtitle.TextAlign = "MiddleCenter"
$loginPanel.Controls.Add($loginSubtitle)

# Username
$loginUserLabel = New-Object System.Windows.Forms.Label
$loginUserLabel.Text = "Username or Email"
$loginUserLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$loginUserLabel.ForeColor = "#CCCCCC"
$loginUserLabel.Size = New-Object System.Drawing.Size(400, 25)
$loginUserLabel.Location = New-Object System.Drawing.Point(50, 140)
$loginPanel.Controls.Add($loginUserLabel)

$loginUser = New-Object System.Windows.Forms.TextBox
$loginUser.Size = New-Object System.Drawing.Size(400, 35)
$loginUser.Location = New-Object System.Drawing.Point(50, 170)
$loginUser.BackColor = "#333333"
$loginUser.ForeColor = "White"
$loginUser.BorderStyle = "FixedSingle"
$loginUser.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$loginPanel.Controls.Add($loginUser)

# Password
$loginPassLabel = New-Object System.Windows.Forms.Label
$loginPassLabel.Text = "Password"
$loginPassLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$loginPassLabel.ForeColor = "#CCCCCC"
$loginPassLabel.Size = New-Object System.Drawing.Size(400, 25)
$loginPassLabel.Location = New-Object System.Drawing.Point(50, 220)
$loginPanel.Controls.Add($loginPassLabel)

$loginPass = New-Object System.Windows.Forms.TextBox
$loginPass.Size = New-Object System.Drawing.Size(400, 35)
$loginPass.Location = New-Object System.Drawing.Point(50, 250)
$loginPass.BackColor = "#333333"
$loginPass.ForeColor = "White"
$loginPass.BorderStyle = "FixedSingle"
$loginPass.PasswordChar = '•'
$loginPass.Font = New-Object System.Drawing.Font("Segoe UI", 11)
$loginPanel.Controls.Add($loginPass)

# Remember me checkbox
$rememberCheck = New-Object System.Windows.Forms.CheckBox
$rememberCheck.Text = "Remember me"
$rememberCheck.Location = New-Object System.Drawing.Point(50, 300)
$rememberCheck.Size = New-Object System.Drawing.Size(150, 25)
$rememberCheck.ForeColor = "#CCCCCC"
$rememberCheck.BackColor = "Transparent"
$rememberCheck.Checked = $true
$loginPanel.Controls.Add($rememberCheck)

# Login Button
$loginButton = New-Object System.Windows.Forms.Button
$loginButton.Text = "SIGN IN"
$loginButton.Size = New-Object System.Drawing.Size(400, 45)
$loginButton.Location = New-Object System.Drawing.Point(50, 340)
$loginButton.BackColor = "#FF003C"
$loginButton.ForeColor = "White"
$loginButton.FlatStyle = "Flat"
$loginButton.FlatAppearance.BorderSize = 0
$loginButton.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$loginButton.Cursor = "Hand"
$loginButton.Add_Click({
    $loginButton.Enabled = $false
    $loginButton.Text = "AUTHENTICATING..."
    
    $username = $loginUser.Text.Trim()
    $password = $loginPass.Text
    
    if ([string]::IsNullOrEmpty($username) -or [string]::IsNullOrEmpty($password)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter username and password", "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
        $loginButton.Enabled = $true
        $loginButton.Text = "SIGN IN"
        return
    }
    
    # Call login API - using form data format that FastAPI expects
    $formData = @{
        username = $username
        password = $password
        grant_type = "password"
    }
    
    $result = Invoke-R6XApi -Endpoint "/api/auth/login" -Method "POST" -Body $formData -UseAuth $false
    
    if ($result.Success) {
        $global:authToken = $result.Data.access_token
        $global:refreshToken = $result.Data.refresh_token
        
        # Get user info
        $userResult = Invoke-R6XApi -Endpoint "/api/auth/me"
        if ($userResult.Success) {
            $global:currentUser = $userResult.Data
            
            # Update UI
            $userLabel.Text = "👤 $($global:currentUser.username)"
            $statusLabel.Text = "● CONNECTED"
            $statusLabel.ForeColor = "#00FF9D"
            
            # Save credentials if remember me
            if ($rememberCheck.Checked) {
                Save-Credentials -username $username -password $password
            }
            
            # Load user data
            Get-UserData
            
            # Switch to scanner tab
            $tabControl.SelectedIndex = 1
            
            # Show welcome message
            Show-Notification -Title "Welcome Back!" -Message "Successfully logged in as $($global:currentUser.username)"
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Login failed: $($result.Error)", "Authentication Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
    
    $loginButton.Enabled = $true
    $loginButton.Text = "SIGN IN"
})
$loginPanel.Controls.Add($loginButton)

# Register link
$registerLink = New-Object System.Windows.Forms.LinkLabel
$registerLink.Text = "Don't have an account? Register here"
$registerLink.Location = New-Object System.Drawing.Point(50, 400)
$registerLink.Size = New-Object System.Drawing.Size(400, 30)
$registerLink.ForeColor = "#00FF9D"
$registerLink.LinkColor = "#00FF9D"
$registerLink.ActiveLinkColor = "#FF003C"
$registerLink.TextAlign = "MiddleCenter"
$registerLink.Add_Click({
    # Show registration form
    Show-RegistrationForm
})
$loginPanel.Controls.Add($registerLink)

$loginTab.Controls.Add($loginPanel)

# SCANNER TAB
$scannerTab = New-Object System.Windows.Forms.TabPage
$scannerTab.Text = "🔍 SCANNER"
$scannerTab.BackColor = "#1a1a1a"

# Control Panel
$controlPanel = New-Object System.Windows.Forms.Panel
$controlPanel.Size = New-Object System.Drawing.Size(1220, 120)
$controlPanel.Location = New-Object System.Drawing.Point(20, 20)
$controlPanel.BackColor = "#252525"

# Scan Name
$scanNameLabel = New-Object System.Windows.Forms.Label
$scanNameLabel.Text = "Scan Name:"
$scanNameLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$scanNameLabel.ForeColor = "#CCCCCC"
$scanNameLabel.Size = New-Object System.Drawing.Size(80, 25)
$scanNameLabel.Location = New-Object System.Drawing.Point(20, 20)
$controlPanel.Controls.Add($scanNameLabel)

$scanNameBox = New-Object System.Windows.Forms.TextBox
$scanNameBox.Size = New-Object System.Drawing.Size(200, 30)
$scanNameBox.Location = New-Object System.Drawing.Point(20, 50)
$scanNameBox.BackColor = "#333333"
$scanNameBox.ForeColor = "White"
$scanNameBox.BorderStyle = "FixedSingle"
$scanNameBox.Text = "System Scan $(Get-Date -Format 'yyyy-MM-dd HH:mm')"
$controlPanel.Controls.Add($scanNameBox)

# Discord Bot Token
$tokenLabel = New-Object System.Windows.Forms.Label
$tokenLabel.Text = "Discord Bot Token:"
$tokenLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$tokenLabel.ForeColor = "#CCCCCC"
$tokenLabel.Size = New-Object System.Drawing.Size(120, 25)
$tokenLabel.Location = New-Object System.Drawing.Point(250, 20)
$controlPanel.Controls.Add($tokenLabel)

$tokenBox = New-Object System.Windows.Forms.TextBox
$tokenBox.Size = New-Object System.Drawing.Size(300, 30)
$tokenBox.Location = New-Object System.Drawing.Point(250, 50)
$tokenBox.BackColor = "#333333"
$tokenBox.ForeColor = "White"
$tokenBox.BorderStyle = "FixedSingle"
$tokenBox.PasswordChar = '•'
$controlPanel.Controls.Add($tokenBox)

# Channel ID
$channelLabel = New-Object System.Windows.Forms.Label
$channelLabel.Text = "Channel ID:"
$channelLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
$channelLabel.ForeColor = "#CCCCCC"
$channelLabel.Size = New-Object System.Drawing.Size(80, 25)
$channelLabel.Location = New-Object System.Drawing.Point(570, 20)
$controlPanel.Controls.Add($channelLabel)

$channelBox = New-Object System.Windows.Forms.TextBox
$channelBox.Size = New-Object System.Drawing.Size(150, 30)
$channelBox.Location = New-Object System.Drawing.Point(570, 50)
$channelBox.BackColor = "#333333"
$channelBox.ForeColor = "White"
$channelBox.BorderStyle = "FixedSingle"
$controlPanel.Controls.Add($channelBox)

# Connect Bot Button
$connectBotBtn = New-Object System.Windows.Forms.Button
$connectBotBtn.Text = "🔌 CONNECT BOT"
$connectBotBtn.Size = New-Object System.Drawing.Size(140, 35)
$connectBotBtn.Location = New-Object System.Drawing.Point(740, 45)
$connectBotBtn.BackColor = "#FF003C"
$connectBotBtn.ForeColor = "White"
$connectBotBtn.FlatStyle = "Flat"
$connectBotBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
$connectBotBtn.Cursor = "Hand"
$connectBotBtn.Add_Click({
    if ([string]::IsNullOrEmpty($tokenBox.Text) -or [string]::IsNullOrEmpty($channelBox.Text)) {
        [System.Windows.Forms.MessageBox]::Show("Please enter bot token and channel ID", "Missing Information", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    $connectBotBtn.Enabled = $false
    $connectBotBtn.Text = "CONNECTING..."
    
    $result = Invoke-R6XApi -Endpoint "/api/discord/connect" -Method "POST" -Body @{
        token = $tokenBox.Text
        channel_id = $channelBox.Text
    }
    
    if ($result.Success) {
        $global:botConnected = $true
        $global:botChannelId = $channelBox.Text
        $connectBotBtn.BackColor = "#00FF9D"
        $connectBotBtn.Text = "✅ CONNECTED"
        $botStatusLabel.Text = "🟢 Bot Connected"
        $botStatusLabel.ForeColor = "#00FF9D"
        
        Show-Notification -Title "Bot Connected" -Message "Discord bot is now active"
    } else {
        $connectBotBtn.Enabled = $true
        $connectBotBtn.Text = "🔌 CONNECT BOT"
        $connectBotBtn.BackColor = "#FF003C"
        
        [System.Windows.Forms.MessageBox]::Show("Failed to connect bot: $($result.Error)", "Connection Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
})
$controlPanel.Controls.Add($connectBotBtn)

# Bot Status
$botStatusLabel = New-Object System.Windows.Forms.Label
$botStatusLabel.Text = "⚪ Bot Disconnected"
$botStatusLabel.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$botStatusLabel.ForeColor = "#888888"
$botStatusLabel.Size = New-Object System.Drawing.Size(150, 20)
$botStatusLabel.Location = New-Object System.Drawing.Point(740, 20)
$controlPanel.Controls.Add($botStatusLabel)

# Scan Options Group
$optionsGroup = New-Object System.Windows.Forms.GroupBox
$optionsGroup.Text = "Scan Options"
$optionsGroup.Size = New-Object System.Drawing.Size(300, 120)
$optionsGroup.Location = New-Object System.Drawing.Point(900, 20)
$optionsGroup.ForeColor = "White"
$optionsGroup.Font = New-Object System.Drawing.Font("Segoe UI", 9)

$rarCheck = New-Object System.Windows.Forms.CheckBox
$rarCheck.Text = "Scan RAR files"
$rarCheck.Location = New-Object System.Drawing.Point(20, 25)
$rarCheck.Size = New-Object System.Drawing.Size(120, 25)
$rarCheck.ForeColor = "#CCCCCC"
$rarCheck.Checked = $true
$optionsGroup.Controls.Add($rarCheck)

$exeCheck = New-Object System.Windows.Forms.CheckBox
$exeCheck.Text = "Scan EXE files"
$exeCheck.Location = New-Object System.Drawing.Point(150, 25)
$exeCheck.Size = New-Object System.Drawing.Size(120, 25)
$exeCheck.ForeColor = "#CCCCCC"
$exeCheck.Checked = $true
$optionsGroup.Controls.Add($exeCheck)

$susCheck = New-Object System.Windows.Forms.CheckBox
$susCheck.Text = "Suspicious files"
$susCheck.Location = New-Object System.Drawing.Point(20, 50)
$susCheck.Size = New-Object System.Drawing.Size(120, 25)
$susCheck.ForeColor = "#CCCCCC"
$susCheck.Checked = $true
$optionsGroup.Controls.Add($susCheck)

$registryCheck = New-Object System.Windows.Forms.CheckBox
$registryCheck.Text = "Registry scan"
$registryCheck.Location = New-Object System.Drawing.Point(150, 50)
$registryCheck.Size = New-Object System.Drawing.Size(120, 25)
$registryCheck.ForeColor = "#CCCCCC"
$registryCheck.Checked = $true
$optionsGroup.Controls.Add($registryCheck)

$prefetchCheck = New-Object System.Windows.Forms.CheckBox
$prefetchCheck.Text = "Prefetch analysis"
$prefetchCheck.Location = New-Object System.Drawing.Point(20, 75)
$prefetchCheck.Size = New-Object System.Drawing.Size(120, 25)
$prefetchCheck.ForeColor = "#CCCCCC"
$prefetchCheck.Checked = $true
$optionsGroup.Controls.Add($prefetchCheck)

$gameCheck = New-Object System.Windows.Forms.CheckBox
$gameCheck.Text = "Game accounts"
$gameCheck.Location = New-Object System.Drawing.Point(150, 75)
$gameCheck.Size = New-Object System.Drawing.Size(120, 25)
$gameCheck.ForeColor = "#CCCCCC"
$gameCheck.Checked = $true
$optionsGroup.Controls.Add($gameCheck)

$controlPanel.Controls.Add($optionsGroup)

$scannerTab.Controls.Add($controlPanel)

# Console Output
$consoleGroup = New-Object System.Windows.Forms.GroupBox
$consoleGroup.Text = "📋 SCAN OUTPUT"
$consoleGroup.Size = New-Object System.Drawing.Size(1220, 300)
$consoleGroup.Location = New-Object System.Drawing.Point(20, 150)
$consoleGroup.ForeColor = "White"
$consoleGroup.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)

$consoleBox = New-Object System.Windows.Forms.RichTextBox
$consoleBox.Size = New-Object System.Drawing.Size(1200, 250)
$consoleBox.Location = New-Object System.Drawing.Point(10, 25)
$consoleBox.BackColor = "#1a1a1a"
$consoleBox.ForeColor = "#00FF9D"
$consoleBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$consoleBox.ReadOnly = $true
$consoleBox.WordWrap = $false
$consoleBox.ScrollBars = "Both"

$consoleGroup.Controls.Add($consoleBox)
$scannerTab.Controls.Add($consoleGroup)

# Progress Bar
$progressBar = New-Object System.Windows.Forms.ProgressBar
$progressBar.Size = New-Object System.Drawing.Size(1100, 20)
$progressBar.Location = New-Object System.Drawing.Point(20, 460)
$progressBar.Style = "Continuous"
$progressBar.ForeColor = "#00FF9D"
$scannerTab.Controls.Add($progressBar)

# Start Scan Button
$startScanBtn = New-Object System.Windows.Forms.Button
$startScanBtn.Text = "▶ START SCAN"
$startScanBtn.Size = New-Object System.Drawing.Size(200, 50)
$startScanBtn.Location = New-Object System.Drawing.Point(1140, 450)
$startScanBtn.BackColor = "#00FF9D"
$startScanBtn.ForeColor = "#1a1a1a"
$startScanBtn.FlatStyle = "Flat"
$startScanBtn.Font = New-Object System.Drawing.Font("Segoe UI", 14, [System.Drawing.FontStyle]::Bold)
$startScanBtn.Cursor = "Hand"
$startScanBtn.Add_Click({
    if ($global:scanInProgress) {
        [System.Windows.Forms.MessageBox]::Show("A scan is already in progress", "Scan Active", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        return
    }
    
    if (-not $global:authToken) {
        [System.Windows.Forms.MessageBox]::Show("Please login first", "Authentication Required", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Warning)
        $tabControl.SelectedIndex = 0
        return
    }
    
    Start-Scan
})
$scannerTab.Controls.Add($startScanBtn)

# HISTORY TAB
$historyTab = New-Object System.Windows.Forms.TabPage
$historyTab.Text = "📊 HISTORY"
$historyTab.BackColor = "#1a1a1a"

# History ListView
$historyListView = New-Object System.Windows.Forms.ListView
$historyListView.Size = New-Object System.Drawing.Size(1220, 500)
$historyListView.Location = New-Object System.Drawing.Point(20, 20)
$historyListView.BackColor = "#252525"
$historyListView.ForeColor = "White"
$historyListView.View = "Details"
$historyListView.FullRowSelect = $true
$historyListView.GridLines = $true
$historyListView.Font = New-Object System.Drawing.Font("Segoe UI", 10)

# Add columns
$historyListView.Columns.Add("Scan Name", 250)
$historyListView.Columns.Add("Date", 180)
$historyListView.Columns.Add("Files", 100)
$historyListView.Columns.Add("Threats", 100)
$historyListView.Columns.Add("Duration", 100)
$historyListView.Columns.Add("Status", 150)

$historyTab.Controls.Add($historyListView)

# Refresh button
$refreshHistoryBtn = New-Object System.Windows.Forms.Button
$refreshHistoryBtn.Text = "⟳ Refresh History"
$refreshHistoryBtn.Size = New-Object System.Drawing.Size(150, 35)
$refreshHistoryBtn.Location = New-Object System.Drawing.Point(20, 530)
$refreshHistoryBtn.BackColor = "#333333"
$refreshHistoryBtn.ForeColor = "White"
$refreshHistoryBtn.FlatStyle = "Flat"
$refreshHistoryBtn.Add_Click({
    Get-ScanHistory
})
$historyTab.Controls.Add($refreshHistoryBtn)

# View Details button
$viewDetailsBtn = New-Object System.Windows.Forms.Button
$viewDetailsBtn.Text = "🔍 View Details"
$viewDetailsBtn.Size = New-Object System.Drawing.Size(150, 35)
$viewDetailsBtn.Location = New-Object System.Drawing.Point(180, 530)
$viewDetailsBtn.BackColor = "#FF003C"
$viewDetailsBtn.ForeColor = "White"
$viewDetailsBtn.FlatStyle = "Flat"
$viewDetailsBtn.Add_Click({
    if ($historyListView.SelectedItems.Count -gt 0) {
        $scanId = $historyListView.SelectedItems[0].Tag
        Show-ScanDetails -scanId $scanId
    }
})
$historyTab.Controls.Add($viewDetailsBtn)

# BOT TAB
$botTab = New-Object System.Windows.Forms.TabPage
$botTab.Text = "🤖 BOT CONTROL"
$botTab.BackColor = "#1a1a1a"

$botPanel = New-Object System.Windows.Forms.Panel
$botPanel.Size = New-Object System.Drawing.Size(600, 400)
$botPanel.Location = New-Object System.Drawing.Point(330, 100)
$botPanel.BackColor = "#252525"
$botPanel.BorderStyle = "FixedSingle"

$botTitle = New-Object System.Windows.Forms.Label
$botTitle.Text = "DISCORD BOT CONTROL"
$botTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$botTitle.ForeColor = "#FF003C"
$botTitle.Size = New-Object System.Drawing.Size(550, 40)
$botTitle.Location = New-Object System.Drawing.Point(25, 20)
$botTitle.TextAlign = "MiddleCenter"
$botPanel.Controls.Add($botTitle)

# Bot Status Display
$botStatusDisplay = New-Object System.Windows.Forms.Label
$botStatusDisplay.Text = "Current Status: ⚪ Not Connected"
$botStatusDisplay.Font = New-Object System.Drawing.Font("Segoe UI", 12)
$botStatusDisplay.ForeColor = "#888888"
$botStatusDisplay.Size = New-Object System.Drawing.Size(550, 30)
$botStatusDisplay.Location = New-Object System.Drawing.Point(25, 80)
$botStatusDisplay.TextAlign = "MiddleCenter"
$botPanel.Controls.Add($botStatusDisplay)

# Bot Commands List
$commandsBox = New-Object System.Windows.Forms.RichTextBox
$commandsBox.Size = New-Object System.Drawing.Size(550, 150)
$commandsBox.Location = New-Object System.Drawing.Point(25, 130)
$commandsBox.BackColor = "#333333"
$commandsBox.ForeColor = "#00FF9D"
$commandsBox.Font = New-Object System.Drawing.Font("Consolas", 10)
$commandsBox.ReadOnly = $true
$commandsBox.Text = @"
Available Bot Commands:
!scan - Get your latest scan results
!status - Check bot status
!help - Show available commands
"@
$botPanel.Controls.Add($commandsBox)

# Disconnect Bot Button
$disconnectBotBtn = New-Object System.Windows.Forms.Button
$disconnectBotBtn.Text = "🔌 DISCONNECT BOT"
$disconnectBotBtn.Size = New-Object System.Drawing.Size(250, 45)
$disconnectBotBtn.Location = New-Object System.Drawing.Point(175, 300)
$disconnectBotBtn.BackColor = "#FF003C"
$disconnectBotBtn.ForeColor = "White"
$disconnectBotBtn.FlatStyle = "Flat"
$disconnectBotBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$disconnectBotBtn.Add_Click({
    $result = Invoke-R6XApi -Endpoint "/api/discord/disconnect" -Method "POST"
    if ($result.Success) {
        $global:botConnected = $false
        $botStatusDisplay.Text = "Current Status: ⚪ Not Connected"
        $botStatusDisplay.ForeColor = "#888888"
        $botStatusLabel.Text = "⚪ Bot Disconnected"
        $botStatusLabel.ForeColor = "#888888"
        $connectBotBtn.BackColor = "#FF003C"
        $connectBotBtn.Text = "🔌 CONNECT BOT"
        
        Show-Notification -Title "Bot Disconnected" -Message "Discord bot has been disconnected"
    }
})
$botPanel.Controls.Add($disconnectBotBtn)

$botTab.Controls.Add($botPanel)

# SETTINGS TAB
$settingsTab = New-Object System.Windows.Forms.TabPage
$settingsTab.Text = "⚙ SETTINGS"
$settingsTab.BackColor = "#1a1a1a"

$settingsPanel = New-Object System.Windows.Forms.Panel
$settingsPanel.Size = New-Object System.Drawing.Size(600, 400)
$settingsPanel.Location = New-Object System.Drawing.Point(330, 100)
$settingsPanel.BackColor = "#252525"
$settingsPanel.BorderStyle = "FixedSingle"

$settingsTitle = New-Object System.Windows.Forms.Label
$settingsTitle.Text = "APPLICATION SETTINGS"
$settingsTitle.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
$settingsTitle.ForeColor = "#FF003C"
$settingsTitle.Size = New-Object System.Drawing.Size(550, 40)
$settingsTitle.Location = New-Object System.Drawing.Point(25, 20)
$settingsTitle.TextAlign = "MiddleCenter"
$settingsPanel.Controls.Add($settingsTitle)

# Auto-save scans
$autoSaveCheck = New-Object System.Windows.Forms.CheckBox
$autoSaveCheck.Text = "Auto-save scan results"
$autoSaveCheck.Location = New-Object System.Drawing.Point(50, 90)
$autoSaveCheck.Size = New-Object System.Drawing.Size(250, 30)
$autoSaveCheck.ForeColor = "White"
$autoSaveCheck.Checked = $true
$settingsPanel.Controls.Add($autoSaveCheck)

# Auto-connect bot
$autoBotCheck = New-Object System.Windows.Forms.CheckBox
$autoBotCheck.Text = "Auto-connect Discord bot on login"
$autoBotCheck.Location = New-Object System.Drawing.Point(50, 130)
$autoBotCheck.Size = New-Object System.Drawing.Size(300, 30)
$autoBotCheck.ForeColor = "White"
$autoBotCheck.Checked = $false
$settingsPanel.Controls.Add($autoBotCheck)

# Notifications
$notifyCheck = New-Object System.Windows.Forms.CheckBox
$notifyCheck.Text = "Show desktop notifications"
$notifyCheck.Location = New-Object System.Drawing.Point(50, 170)
$notifyCheck.Size = New-Object System.Drawing.Size(250, 30)
$notifyCheck.ForeColor = "White"
$notifyCheck.Checked = $true
$settingsPanel.Controls.Add($notifyCheck)

# Save Settings Button
$saveSettingsBtn = New-Object System.Windows.Forms.Button
$saveSettingsBtn.Text = "💾 SAVE SETTINGS"
$saveSettingsBtn.Size = New-Object System.Drawing.Size(250, 40)
$saveSettingsBtn.Location = New-Object System.Drawing.Point(175, 250)
$saveSettingsBtn.BackColor = "#00FF9D"
$saveSettingsBtn.ForeColor = "#1a1a1a"
$saveSettingsBtn.FlatStyle = "Flat"
$saveSettingsBtn.Font = New-Object System.Drawing.Font("Segoe UI", 12, [System.Drawing.FontStyle]::Bold)
$saveSettingsBtn.Add_Click({
    # Save settings to file
    $settings = @{
        AutoSave = $autoSaveCheck.Checked
        AutoBot = $autoBotCheck.Checked
        Notifications = $notifyCheck.Checked
    }
    $settings | ConvertTo-Json | Set-Content "$appDataPath\settings.json"
    
    Show-Notification -Title "Settings Saved" -Message "Your preferences have been saved"
})
$settingsPanel.Controls.Add($saveSettingsBtn)

$settingsTab.Controls.Add($settingsPanel)

# Add tabs to tab control
$tabControl.TabPages.Add($loginTab)
$tabControl.TabPages.Add($scannerTab)
$tabControl.TabPages.Add($historyTab)
$tabControl.TabPages.Add($botTab)
$tabControl.TabPages.Add($settingsTab)

$form.Controls.Add($tabControl)

# Logout button
$logoutBtn = New-Object System.Windows.Forms.Button
$logoutBtn.Text = "🚪 LOGOUT"
$logoutBtn.Size = New-Object System.Drawing.Size(100, 30)
$logoutBtn.Location = New-Object System.Drawing.Point(1150, 25)
$logoutBtn.BackColor = "#333333"
$logoutBtn.ForeColor = "White"
$logoutBtn.FlatStyle = "Flat"
$logoutBtn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$logoutBtn.Cursor = "Hand"
$logoutBtn.Add_Click({
    $result = Invoke-R6XApi -Endpoint "/api/auth/logout" -Method "POST"
    
    $global:authToken = $null
    $global:refreshToken = $null
    $global:currentUser = $null
    $global:botConnected = $false
    
    $userLabel.Text = ""
    $statusLabel.Text = "● DISCONNECTED"
    $statusLabel.ForeColor = "#FF003C"
    $botStatusLabel.Text = "⚪ Bot Disconnected"
    $botStatusLabel.ForeColor = "#888888"
    
    $tabControl.SelectedIndex = 0
    
    Show-Notification -Title "Logged Out" -Message "You have been successfully logged out"
})
$form.Controls.Add($logoutBtn)

# Functions

function Show-Notification {
    param($Title, $Message)
    
    $notify = New-Object System.Windows.Forms.NotifyIcon
    $notify.Icon = [System.Drawing.Icon]::ExtractAssociatedIcon((Get-Command powershell).Path)
    $notify.BalloonTipTitle = $Title
    $notify.BalloonTipText = $Message
    $notify.Visible = $true
    $notify.ShowBalloonTip(3000)
}

function Write-Console {
    param($Message, $Color = "#00FF9D")
    
    $consoleBox.AppendText("[$([DateTime]::Now.ToString('HH:mm:ss'))] $Message`r`n")
    $consoleBox.ScrollToCaret()
    
    # Also output to PowerShell console for debugging
    Write-Host "[$(Get-Date -Format 'HH:mm:ss')] $Message"
}

function Get-UserData {
    Write-Console "Loading user data..." -Color "#888888"
    Get-ScanHistory
    Get-BotStatus
    Get-Settings
}

function Get-ScanHistory {
    $historyListView.Items.Clear()
    
    $result = Invoke-R6XApi -Endpoint "/api/scans/history?limit=50"
    
    if ($result.Success -and $result.Data.scans) {
        foreach ($scan in $result.Data.scans) {
            $item = New-Object System.Windows.Forms.ListViewItem($scan.name)
            $item.SubItems.Add((Get-Date $scan.created_at).ToString("yyyy-MM-dd HH:mm"))
            $item.SubItems.Add($scan.files_scanned.ToString())
            $item.SubItems.Add($scan.threats_found.ToString())
            $item.SubItems.Add("{0:N2}s" -f $scan.scan_duration)
            
            $status = if ($scan.threats_found -gt 0) { "⚠️ Threats Found" } else { "✅ Clean" }
            $item.SubItems.Add($status)
            
            $item.Tag = $scan.scan_id
            $historyListView.Items.Add($item)
        }
        
        Write-Console "Loaded $($result.Data.scans.Count) scan records" -Color "#888888"
    }
}

function Get-BotStatus {
    $result = Invoke-R6XApi -Endpoint "/api/discord/status"
    
    if ($result.Success -and $result.Data.connected) {
        $global:botConnected = $true
        $global:botChannelId = $result.Data.channel_id
        $botStatusLabel.Text = "🟢 Bot Connected"
        $botStatusLabel.ForeColor = "#00FF9D"
        $connectBotBtn.BackColor = "#00FF9D"
        $connectBotBtn.Text = "✅ CONNECTED"
        $botStatusDisplay.Text = "Current Status: 🟢 Connected to channel $($result.Data.channel_id)"
        $botStatusDisplay.ForeColor = "#00FF9D"
    }
}

function Get-Settings {
    $settingsFile = "$appDataPath\settings.json"
    if (Test-Path $settingsFile) {
        $settings = Get-Content $settingsFile | ConvertFrom-Json
        # Apply settings to UI
        $autoSaveCheck.Checked = $settings.AutoSave
        $autoBotCheck.Checked = $settings.AutoBot
        $notifyCheck.Checked = $settings.Notifications
    }
}

function Show-RegistrationForm {
    $regForm = New-Object System.Windows.Forms.Form
    $regForm.Text = "Register New Account"
    $regForm.Size = New-Object System.Drawing.Size(400, 450)
    $regForm.StartPosition = "CenterParent"
    $regForm.BackColor = "#1a1a1a"
    $regForm.ForeColor = "White"
    $regForm.FormBorderStyle = "FixedDialog"
    $regForm.MaximizeBox = $false
    
    $panel = New-Object System.Windows.Forms.Panel
    $panel.Size = New-Object System.Drawing.Size(360, 400)
    $panel.Location = New-Object System.Drawing.Point(20, 20)
    $panel.BackColor = "#252525"
    
    $title = New-Object System.Windows.Forms.Label
    $title.Text = "CREATE ACCOUNT"
    $title.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $title.ForeColor = "#FF003C"
    $title.Size = New-Object System.Drawing.Size(320, 40)
    $title.Location = New-Object System.Drawing.Point(20, 20)
    $title.TextAlign = "MiddleCenter"
    $panel.Controls.Add($title)
    
    # Username
    $lblUser = New-Object System.Windows.Forms.Label
    $lblUser.Text = "Username:"
    $lblUser.Location = New-Object System.Drawing.Point(30, 80)
    $lblUser.Size = New-Object System.Drawing.Size(300, 25)
    $lblUser.ForeColor = "#CCCCCC"
    $panel.Controls.Add($lblUser)
    
    $txtUser = New-Object System.Windows.Forms.TextBox
    $txtUser.Location = New-Object System.Drawing.Point(30, 110)
    $txtUser.Size = New-Object System.Drawing.Size(300, 25)
    $txtUser.BackColor = "#333333"
    $txtUser.ForeColor = "White"
    $txtUser.BorderStyle = "FixedSingle"
    $panel.Controls.Add($txtUser)
    
    # Email
    $lblEmail = New-Object System.Windows.Forms.Label
    $lblEmail.Text = "Email:"
    $lblEmail.Location = New-Object System.Drawing.Point(30, 150)
    $lblEmail.Size = New-Object System.Drawing.Size(300, 25)
    $lblEmail.ForeColor = "#CCCCCC"
    $panel.Controls.Add($lblEmail)
    
    $txtEmail = New-Object System.Windows.Forms.TextBox
    $txtEmail.Location = New-Object System.Drawing.Point(30, 180)
    $txtEmail.Size = New-Object System.Drawing.Size(300, 25)
    $txtEmail.BackColor = "#333333"
    $txtEmail.ForeColor = "White"
    $txtEmail.BorderStyle = "FixedSingle"
    $panel.Controls.Add($txtEmail)
    
    # Password
    $lblPass = New-Object System.Windows.Forms.Label
    $lblPass.Text = "Password:"
    $lblPass.Location = New-Object System.Drawing.Point(30, 220)
    $lblPass.Size = New-Object System.Drawing.Size(300, 25)
    $lblPass.ForeColor = "#CCCCCC"
    $panel.Controls.Add($lblPass)
    
    $txtPass = New-Object System.Windows.Forms.TextBox
    $txtPass.Location = New-Object System.Drawing.Point(30, 250)
    $txtPass.Size = New-Object System.Drawing.Size(300, 25)
    $txtPass.BackColor = "#333333"
    $txtPass.ForeColor = "White"
    $txtPass.BorderStyle = "FixedSingle"
    $txtPass.PasswordChar = '•'
    $panel.Controls.Add($txtPass)
    
    # Confirm Password
    $lblConfirm = New-Object System.Windows.Forms.Label
    $lblConfirm.Text = "Confirm Password:"
    $lblConfirm.Location = New-Object System.Drawing.Point(30, 290)
    $lblConfirm.Size = New-Object System.Drawing.Size(300, 25)
    $lblConfirm.ForeColor = "#CCCCCC"
    $panel.Controls.Add($lblConfirm)
    
    $txtConfirm = New-Object System.Windows.Forms.TextBox
    $txtConfirm.Location = New-Object System.Drawing.Point(30, 320)
    $txtConfirm.Size = New-Object System.Drawing.Size(300, 25)
    $txtConfirm.BackColor = "#333333"
    $txtConfirm.ForeColor = "White"
    $txtConfirm.BorderStyle = "FixedSingle"
    $txtConfirm.PasswordChar = '•'
    $panel.Controls.Add($txtConfirm)
    
    # Register Button
    $btnRegister = New-Object System.Windows.Forms.Button
    $btnRegister.Text = "REGISTER"
    $btnRegister.Location = New-Object System.Drawing.Point(30, 360)
    $btnRegister.Size = New-Object System.Drawing.Size(300, 35)
    $btnRegister.BackColor = "#FF003C"
    $btnRegister.ForeColor = "White"
    $btnRegister.FlatStyle = "Flat"
    $btnRegister.Font = New-Object System.Drawing.Font("Segoe UI", 10, [System.Drawing.FontStyle]::Bold)
    $btnRegister.Add_Click({
        # Validation
        if ($txtPass.Text -ne $txtConfirm.Text) {
            [System.Windows.Forms.MessageBox]::Show("Passwords do not match!", "Error", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        if ($txtPass.Text.Length -lt 8) {
            [System.Windows.Forms.MessageBox]::Show("Password must be at least 8 characters!", "Error", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            return
        }
        
        $btnRegister.Enabled = $false
        $btnRegister.Text = "REGISTERING..."
        
        $result = Invoke-R6XApi -Endpoint "/api/auth/register" -Method "POST" -Body @{
            username = $txtUser.Text.Trim()
            email = $txtEmail.Text.Trim()
            password = $txtPass.Text
        } -UseAuth $false
        
        if ($result.Success) {
            [System.Windows.Forms.MessageBox]::Show("Registration successful! You can now login.", "Success", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
            $regForm.Close()
        } else {
            [System.Windows.Forms.MessageBox]::Show("Registration failed: $($result.Error)", "Error", 
                [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
            $btnRegister.Enabled = $true
            $btnRegister.Text = "REGISTER"
        }
    })
    $panel.Controls.Add($btnRegister)
    
    $regForm.Controls.Add($panel)
    $regForm.ShowDialog()
}

function Start-Scan {
    $global:scanInProgress = $true
    $startScanBtn.Enabled = $false
    $startScanBtn.Text = "SCANNING..."
    $consoleBox.Clear()
    $progressBar.Value = 0
    
    Write-Console "╔══════════════════════════════════════════════════════════╗" -Color "#FF003C"
    Write-Console "║           R6X CYBERSCAN - SECURITY ANALYSIS            ║" -Color "#FF003C"
    Write-Console "╚══════════════════════════════════════════════════════════╝" -Color "#FF003C"
    Write-Console ""
    Write-Console "Scan started at: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    Write-Console "Scan name: $($scanNameBox.Text)"
    Write-Console "User: $($global:currentUser.username)"
    Write-Console ""
    
    # Create a runspace for the scan
    $powershell = [PowerShell]::Create()
    $powershell.AddScript({
        param($scanName, $options, $userName)
        
        # Import functions
        function Write-ScanOutput {
            param($Message)
            $Message
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
            Write-ScanOutput "🔍 Searching for .rar and .exe files..."
            $files = @()
            
            $searchPaths = @("C:\Users", "C:\Program Files", "C:\Program Files (x86)")
            $oneDrivePath = Get-OneDrivePath
            if ($oneDrivePath) { $searchPaths += $oneDrivePath }
            
            foreach ($path in $searchPaths) {
                if (Test-Path $path) {
                    Get-ChildItem -Path $path -Recurse -Include "*.rar", "*.exe" -ErrorAction SilentlyContinue | ForEach-Object {
                        $files += $_.FullName
                    }
                }
            }
            
            Write-ScanOutput "  Found $($files.Count) files"
            return $files
        }
        
        function Find-SusFiles {
            Write-ScanOutput "🔍 Searching for suspicious files..."
            $susFiles = @()
            $pattern = '^[A-Za-z0-9]{10}\.exe$'
            $searchPaths = @("C:\Users", "C:\Program Files", "C:\Program Files (x86)", "C:\Windows\Temp")
            
            foreach ($path in $searchPaths) {
                if (Test-Path $path) {
                    Get-ChildItem -Path $path -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {
                        if ($_.Name -match $pattern -or $_.Name -ieq "Dapper.dll") {
                            $susFiles += @{
                                Name = $_.Name
                                Path = $_.FullName
                                Size = $_.Length
                                Modified = $_.LastWriteTime
                                Severity = if ($_.Name -match $pattern) { "HIGH" } else { "MEDIUM" }
                            }
                        }
                    }
                }
            }
            
            Write-ScanOutput "  Found $($susFiles.Count) suspicious files"
            return $susFiles
        }
        
        function Search-PrefetchFiles {
            Write-ScanOutput "🔍 Analyzing Prefetch files..."
            $prefetchPath = "$env:SystemRoot\Prefetch"
            $prefetchFiles = @()
            
            if (Test-Path $prefetchPath) {
                Get-ChildItem -Path $prefetchPath -Filter "*.pf" -ErrorAction SilentlyContinue | ForEach-Object {
                    $prefetchFiles += @{
                        Name = $_.Name
                        LastAccessed = $_.LastAccessTime
                        Size = $_.Length
                    }
                }
            }
            
            Write-ScanOutput "  Found $($prefetchFiles.Count) prefetch files"
            return $prefetchFiles
        }
        
        function Get-R6Accounts {
            Write-ScanOutput "🔍 Checking Rainbow Six Siege accounts..."
            $r6Accounts = @()
            $userName = $env:UserName
            
            $r6Paths = @(
                "C:\Users\$userName\Documents\My Games\Rainbow Six - Siege",
                "C:\Users\$userName\AppData\Local\Ubisoft Game Launcher"
            )
            
            foreach ($path in $r6Paths) {
                if (Test-Path $path) {
                    Get-ChildItem -Path $path -Directory -ErrorAction SilentlyContinue | ForEach-Object {
                        $r6Accounts += @{
                            Name = $_.Name
                            Path = $_.FullName
                            Status = "Active"
                            BanType = "None"
                        }
                    }
                }
            }
            
            Write-ScanOutput "  Found $($r6Accounts.Count) R6 account(s)"
            return $r6Accounts
        }
        
        function Get-SteamAccounts {
            Write-ScanOutput "🔍 Checking Steam accounts..."
            $steamAccounts = @()
            $steamPath = "C:\Program Files (x86)\Steam\config"
            
            if (Test-Path "$steamPath\loginusers.vdf") {
                $content = Get-Content "$steamPath\loginusers.vdf" -Raw
                $matches = [regex]::Matches($content, '"(\d+)"[\s\n]*{[\s\n]*"AccountName"\s*"([^"]*)"')
                
                foreach ($match in $matches) {
                    $steamAccounts += @{
                        Name = $match.Groups[2].Value
                        ID = $match.Groups[1].Value
                        Status = "Active"
                    }
                }
            }
            
            Write-ScanOutput "  Found $($steamAccounts.Count) Steam account(s)"
            return $steamAccounts
        }
        
        # Initialize results
        $scanStart = Get-Date
        $results = @{
            Name = $scanName
            FilesScanned = 0
            ThreatsFound = 0
            R6Accounts = @()
            SteamAccounts = @()
            SuspiciousFiles = @()
            ScanDuration = 0
            Status = "Completed"
        }
        
        # Run scans based on options
        Write-ScanOutput ""
        Write-ScanOutput "▶ EXECUTING SCANS..."
        Write-ScanOutput ""
        
        # RAR/EXE scan
        if ($options.RarScan) {
            $rarResults = Find-RarAndExeFiles
            $results.FilesScanned += $rarResults.Count
        }
        
        # Suspicious files scan
        if ($options.SusScan) {
            $susResults = Find-SusFiles
            $results.SuspiciousFiles = $susResults
            $results.ThreatsFound += ($susResults | Where-Object { $_.Severity -eq "HIGH" }).Count
        }
        
        # Prefetch scan
        if ($options.PrefetchScan) {
            $prefetchResults = Search-PrefetchFiles
        }
        
        # Game accounts
        if ($options.GameScan) {
            $results.R6Accounts = Get-R6Accounts
            $results.SteamAccounts = Get-SteamAccounts
        }
        
        # Calculate duration
        $results.ScanDuration = (Get-Date) - $scanStart | Select-Object -ExpandProperty TotalSeconds
        
        Write-ScanOutput ""
        Write-ScanOutput "╔══════════════════════════════════════════════════════════╗"
        Write-ScanOutput "║                    SCAN COMPLETE                       ║"
        Write-ScanOutput "╚══════════════════════════════════════════════════════════╝"
        Write-ScanOutput "  Files Scanned: $($results.FilesScanned)"
        Write-ScanOutput "  Threats Found: $($results.ThreatsFound)"
        Write-ScanOutput "  R6 Accounts: $($results.R6Accounts.Count)"
        Write-ScanOutput "  Steam Accounts: $($results.SteamAccounts.Count)"
        Write-ScanOutput "  Duration: $($results.ScanDuration.ToString('N2')) seconds"
        Write-ScanOutput ""
        
        return $results
        
    }).AddArgument($scanNameBox.Text).AddArgument(@{
        RarScan = $rarCheck.Checked
        ExeScan = $exeCheck.Checked
        SusScan = $susCheck.Checked
        RegistryScan = $registryCheck.Checked
        PrefetchScan = $prefetchCheck.Checked
        GameScan = $gameCheck.Checked
    }).AddArgument($global:currentUser.username)
    
    # Handle output in real-time
    $powershell.Streams.Information.DataAdding += {
        $consoleBox.AppendText("$($EventArgs.Item)$([Environment]::NewLine)")
        $consoleBox.ScrollToCaret()
    }
    
    # Start the scan
    $asyncResult = $powershell.BeginInvoke()
    
    # Monitor progress
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 500
    $timer.Add_Tick({
        if ($asyncResult.IsCompleted) {
            $timer.Stop()
            $results = $powershell.EndInvoke($asyncResult)
            $powershell.Dispose()
            
            # Save results
            if ($autoSaveCheck.Checked) {
                $saveResult = Invoke-R6XApi -Endpoint "/api/scans/save" -Method "POST" -Body @{
                    name = $results.Name
                    files_scanned = $results.FilesScanned
                    threats_found = $results.ThreatsFound
                    r6_accounts = $results.R6Accounts
                    steam_accounts = $results.SteamAccounts
                    suspicious_files = $results.SuspiciousFiles
                    scan_duration = $results.ScanDuration
                    status = $results.Status
                    system_info = @{
                        computer_name = $env:COMPUTERNAME
                        os_version = (Get-WmiObject Win32_OperatingSystem).Caption
                        user_name = $env:USERNAME
                    }
                }
                
                if ($saveResult.Success) {
                    Write-Console "✅ Scan results saved successfully" -Color "#00FF9D"
                } else {
                    Write-Console "❌ Failed to save scan results: $($saveResult.Error)" -Color "#FF003C"
                }
            }
            
            # Send to Discord if connected
            if ($global:botConnected) {
                Write-Console "📤 Sending results to Discord..." -Color "#888888"
                
                $discordResult = Invoke-R6XApi -Endpoint "/api/discord/send" -Method "POST" -Body @{
                    channel_id = $global:botChannelId
                    content = "✅ Scan completed: $($results.Name)"
                    results = @{
                        name = $results.Name
                        files_scanned = $results.FilesScanned
                        threats_found = $results.ThreatsFound
                        r6_accounts = $results.R6Accounts
                        steam_accounts = $results.SteamAccounts
                        suspicious_files = $results.SuspiciousFiles
                        scan_duration = $results.ScanDuration
                    }
                }
                
                if ($discordResult.Success) {
                    Write-Console "✅ Results sent to Discord" -Color "#00FF9D"
                } else {
                    Write-Console "❌ Failed to send to Discord: $($discordResult.Error)" -Color "#FF003C"
                }
            }
            
            # Show notification
            if ($results.ThreatsFound -gt 0) {
                Show-Notification -Title "⚠️ Threats Detected" -Message "Found $($results.ThreatsFound) potential threats during scan"
            } else {
                Show-Notification -Title "Scan Complete" -Message "No threats found. System is clean."
            }
            
            # Update history
            Get-ScanHistory
            
            # Reset UI
            $global:scanInProgress = $false
            $startScanBtn.Enabled = $true
            $startScanBtn.Text = "▶ START SCAN"
            $progressBar.Value = 100
        } else {
            # Update progress (simulate for now)
            if ($progressBar.Value -lt 90) {
                $progressBar.Value += 2
            }
        }
    })
    $timer.Start()
}

function Show-ScanDetails {
    param($scanId)
    
    $result = Invoke-R6XApi -Endpoint "/api/scans/$scanId"
    
    if ($result.Success) {
        $scan = $result.Data
        
        $detailsForm = New-Object System.Windows.Forms.Form
        $detailsForm.Text = "Scan Details - $($scan.name)"
        $detailsForm.Size = New-Object System.Drawing.Size(800, 600)
        $detailsForm.StartPosition = "CenterParent"
        $detailsForm.BackColor = "#1a1a1a"
        $detailsForm.ForeColor = "White"
        
        $detailsBox = New-Object System.Windows.Forms.RichTextBox
        $detailsBox.Size = New-Object System.Drawing.Size(760, 540)
        $detailsBox.Location = New-Object System.Drawing.Point(20, 20)
        $detailsBox.BackColor = "#252525"
        $detailsBox.ForeColor = "#00FF9D"
        $detailsBox.Font = New-Object System.Drawing.Font("Consolas", 10)
        $detailsBox.ReadOnly = $true
        
        # Build details text
        $text = @"
╔══════════════════════════════════════════════════════════╗
║                    SCAN DETAILS                          ║
╚══════════════════════════════════════════════════════════╝

Scan Name: $($scan.name)
Date: $(Get-Date $scan.created_at -Format 'yyyy-MM-dd HH:mm:ss')
User: $($scan.username)

📊 STATISTICS
────────────
Files Scanned: $($scan.files_scanned)
Threats Found: $($scan.threats_found)
Duration: $($scan.scan_duration.ToString('N2')) seconds
Status: $($scan.status)

🎮 R6 ACCOUNTS
─────────────
"@
        
        if ($scan.r6_accounts -and $scan.r6_accounts.Count -gt 0) {
            foreach ($acc in $scan.r6_accounts) {
                $text += "`n• $($acc.Name) - $($acc.Status)"
            }
        } else {
            $text += "`n• No R6 accounts found"
        }
        
        $text += "`n`n🔄 STEAM ACCOUNTS"
        $text += "`n──────────────"
        
        if ($scan.steam_accounts -and $scan.steam_accounts.Count -gt 0) {
            foreach ($acc in $scan.steam_accounts) {
                $text += "`n• $($acc.Name) - ID: $($acc.ID)"
            }
        } else {
            $text += "`n• No Steam accounts found"
        }
        
        if ($scan.suspicious_files -and $scan.suspicious_files.Count -gt 0) {
            $text += "`n`n⚠️ SUSPICIOUS FILES"
            $text += "`n─────────────────"
            
            foreach ($file in $scan.suspicious_files) {
                $text += "`n• $($file.Name)"
                $text += "`n  Path: $($file.Path)"
                $text += "`n  Severity: $($file.Severity)"
                $text += "`n  Modified: $(Get-Date $file.Modified -Format 'yyyy-MM-dd HH:mm')"
                $text += "`n"
            }
        }
        
        $detailsBox.Text = $text
        $detailsForm.Controls.Add($detailsBox)
        $detailsForm.ShowDialog()
    } else {
        [System.Windows.Forms.MessageBox]::Show("Failed to load scan details: $($result.Error)", "Error", 
            [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)
    }
}

# Check for saved credentials on startup
$savedCreds = Get-SavedCredentials
if ($savedCreds) {
    $loginUser.Text = $savedCreds.Username
    $loginPass.Text = $savedCreds.Password
    $rememberCheck.Checked = $true
}

# Load settings
Get-Settings

# Show the form
$form.Add_Shown({ $form.Activate() })
[System.Windows.Forms.Application]::Run($form)
