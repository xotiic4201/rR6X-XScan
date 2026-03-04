

import os
import sys
import json
import time
import platform
import subprocess
import re
from datetime import datetime
import argparse
from typing import Dict, List, Any, Optional

# Try to import Windows-specific modules
try:
    import winreg
    import ctypes
    WINDOWS_AVAILABLE = True
except ImportError:
    WINDOWS_AVAILABLE = False

# Try to import requests
try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

# ==================== CONFIGURATION ====================
# These will be replaced by the bot when serving
API_URL = "https://bot-hosting-b-ga04.onrender.com/api/scan"
API_KEY = "rnd_o2SUQpg4Ln3EsJSJsOYOeCHnLnId"

# Color codes for terminal (Windows compatible)
class Colors:
    HEADER = '\033[95m'
    BLUE = '\033[94m'
    CYAN = '\033[96m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    MAGENTA = '\033[95m'
    GRAY = '\033[90m'
    WHITE = '\033[97m'
    END = '\033[0m'
    BOLD = '\033[1m'

# Disable colors if not supported
if platform.system() == 'Windows':
    try:
        import ctypes
        kernel32 = ctypes.windll.kernel32
        kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
    except:
        # Colors not supported
        for attr in dir(Colors):
            if not attr.startswith('__'):
                setattr(Colors, attr, '')

def print_color(text, color=Colors.WHITE, end='\n'):
    """Print colored text"""
    print(f"{color}{text}{Colors.END}", end=end)

def clear_screen():
    """Clear terminal screen"""
    os.system('cls' if os.name == 'nt' else 'clear')

def resource_path(relative_path):
    """Get absolute path to resource, works for dev and for PyInstaller"""
    try:
        # PyInstaller creates a temp folder and stores path in _MEIPASS
        base_path = sys._MEIPASS
    except Exception:
        base_path = os.path.abspath(".")
    return os.path.join(base_path, relative_path)

# ==================== MAIN SCANNER CLASS ====================
class R6XScanner:
    def __init__(self, user_id: str):
        self.user_id = user_id
        self.scan_id = None
        self.start_time = None
        self.end_time = None
        
        # Check requirements
        if not WINDOWS_AVAILABLE:
            print_color("❌ This scanner requires Windows!", Colors.RED)
            sys.exit(1)
        
        if not REQUESTS_AVAILABLE:
            print_color("❌ Requests library not found. Please install: pip install requests", Colors.RED)
            sys.exit(1)
        
        # Initialize scan data
        self.scan_data = {
            "scan_id": "",
            "user_id": user_id,
            "timestamp": datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
            "system_info": {},
            "security": {},
            "threats": [],
            "files": {
                "exe_files": [],
                "rar_files": [],
                "suspicious": [],
                "exe_count": 0,
                "rar_count": 0,
                "sus_count": 0
            },
            "executed_programs": [],
            "game_bans": {
                "rainbow_six": [],
                "steam": []
            },
            "prefetch": [],
            "logitech_scripts": [],
            "hardware": {
                "monitors": [],
                "pcie_devices": []
            }
        }

    def print_banner(self):
        """Print the R6X banner"""
        banner = """
╔══════════════════════════════════════════════════════════════╗
║                     R6X XScan v1.0                           ║
║                Advanced System Security Scanner               ║
║                      [ Discord Integrated ]                   ║
╚══════════════════════════════════════════════════════════════╝
"""
        print_color(banner, Colors.CYAN)
        print_color("", Colors.END)
        print_color(f"User ID: {self.user_id}", Colors.YELLOW)
        print_color("", Colors.END)

    def get_scan_id_from_bot(self):
        """Get a scan ID from the bot by starting a scan"""
        try:
            print_color("🔄 Requesting scan ID from Discord bot...", Colors.CYAN)
            
            # Make API call to get a new scan ID
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': API_KEY
            }
            
            payload = {
                'user_id': self.user_id
            }
            
            response = requests.post(
                f"{API_URL}/start-scan",
                headers=headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                self.scan_id = data.get('scan_id')
                self.scan_data['scan_id'] = self.scan_id
                print_color(f"✅ Got scan ID: {self.scan_id}", Colors.GREEN)
                return True
            else:
                print_color(f"❌ Failed to get scan ID: {response.status_code}", Colors.RED)
                return False
                
        except Exception as e:
            print_color(f"❌ Error getting scan ID: {e}", Colors.RED)
            return False

    # ==================== SYSTEM INFO FUNCTIONS ====================
    def get_system_info(self):
        """Collect system information"""
        print_color("📊 Collecting System Information...", Colors.CYAN)
        
        # Windows Install Date
        try:
            result = subprocess.run(
                ['wmic', 'os', 'get', 'installdate'],
                capture_output=True, text=True, check=True
            )
            lines = result.stdout.strip().split('\n')
            if len(lines) >= 2:
                install_date_str = lines[1].strip()
                if install_date_str and len(install_date_str) >= 8:
                    year = install_date_str[:4]
                    month = install_date_str[4:6]
                    day = install_date_str[6:8]
                    self.scan_data["system_info"]["install_date"] = f"{year}-{month}-{day}"
                else:
                    self.scan_data["system_info"]["install_date"] = "Unknown"
            else:
                self.scan_data["system_info"]["install_date"] = "Unknown"
            print_color(f"  ✅ Windows Install Date: {self.scan_data['system_info']['install_date']}", Colors.GRAY)
        except Exception as e:
            self.scan_data["system_info"]["install_date"] = "Unknown"
            print_color(f"  ⚠️ Could not get install date: {e}", Colors.YELLOW)
        
        # Secure Boot Status
        try:
            if os.path.exists("/sys/firmware/efi") or os.path.exists("C:\\Windows\\Panther\\setupact.log"):
                result = subprocess.run(
                    ['powershell', '-Command', 'Confirm-SecureBootUEFI'],
                    capture_output=True, text=True, check=False
                )
                if "True" in result.stdout:
                    self.scan_data["system_info"]["secure_boot"] = "Enabled"
                elif "False" in result.stdout:
                    self.scan_data["system_info"]["secure_boot"] = "Disabled"
                else:
                    self.scan_data["system_info"]["secure_boot"] = "Not Available"
            else:
                self.scan_data["system_info"]["secure_boot"] = "Not Available (Legacy BIOS)"
            print_color(f"  ✅ Secure Boot: {self.scan_data['system_info']['secure_boot']}", Colors.GRAY)
        except Exception as e:
            self.scan_data["system_info"]["secure_boot"] = "Unknown"
            print_color(f"  ⚠️ Could not get Secure Boot status: {e}", Colors.YELLOW)
        
        # DMA Protection
        try:
            key_path = r"SYSTEM\CurrentControlSet\Control\DeviceGuard"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path) as key:
                try:
                    value, _ = winreg.QueryValueEx(key, "EnableDmaProtection")
                    self.scan_data["system_info"]["dma_protection"] = "Enabled" if value == 1 else "Disabled"
                except FileNotFoundError:
                    self.scan_data["system_info"]["dma_protection"] = "Disabled"
            print_color(f"  ✅ DMA Protection: {self.scan_data['system_info']['dma_protection']}", Colors.GRAY)
        except Exception as e:
            self.scan_data["system_info"]["dma_protection"] = "Unknown"
            print_color(f"  ⚠️ Could not get DMA Protection status: {e}", Colors.YELLOW)
        
        print_color("  ✅ System info collected", Colors.GREEN)

    # ==================== SECURITY STATUS FUNCTIONS ====================
    def get_security_status(self):
        """Check security status"""
        print_color("🛡️ Checking Security Status...", Colors.CYAN)
        
        # Check Windows Defender status
        try:
            result = subprocess.run(
                ['powershell', '-Command', 'Get-MpComputerStatus | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip():
                defender_data = json.loads(result.stdout)
                self.scan_data["security"]["defender_enabled"] = defender_data.get("AntivirusEnabled", False)
                self.scan_data["security"]["realtime"] = defender_data.get("RealTimeProtectionEnabled", False)
                self.scan_data["security"]["firewall"] = defender_data.get("FirewallEnabled", False)
                print_color(f"  ✅ Defender Enabled: {self.scan_data['security']['defender_enabled']}", Colors.GRAY)
                print_color(f"  ✅ Real-time: {self.scan_data['security']['realtime']}", Colors.GRAY)
            else:
                self.scan_data["security"]["defender_enabled"] = False
                self.scan_data["security"]["realtime"] = False
                print_color("  ⚠️ Could not get Defender status via PowerShell", Colors.YELLOW)
        except Exception as e:
            self.scan_data["security"]["defender_enabled"] = False
            self.scan_data["security"]["realtime"] = False
            print_color(f"  ⚠️ Error checking Defender: {e}", Colors.YELLOW)
        
        # Check for third-party AV via WMI
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-WmiObject -Namespace "root\\SecurityCenter2" -Class AntiVirusProduct | Where-Object { $_.displayName -ne "Windows Defender" } | Select-Object displayName | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    av_data = json.loads(result.stdout)
                    if isinstance(av_data, list):
                        av_list = [av.get("displayName") for av in av_data if av.get("displayName")]
                    else:
                        av_list = [av_data.get("displayName")] if av_data.get("displayName") else []
                    
                    self.scan_data["security"]["antivirus_enabled"] = len(av_list) > 0
                    self.scan_data["security"]["antivirus_list"] = av_list
                    
                    if av_list:
                        print_color(f"  ⚠️ Third-party AV detected: {', '.join(av_list)}", Colors.YELLOW)
                    else:
                        print_color("  ✅ No third-party AV detected", Colors.GRAY)
                except:
                    self.scan_data["security"]["antivirus_enabled"] = False
                    print_color("  ✅ No third-party AV detected", Colors.GRAY)
            else:
                self.scan_data["security"]["antivirus_enabled"] = False
                print_color("  ✅ No third-party AV detected", Colors.GRAY)
        except Exception as e:
            self.scan_data["security"]["antivirus_enabled"] = False
            print_color(f"  ⚠️ Could not check third-party AV: {e}", Colors.YELLOW)
        
        print_color("  ✅ Security status collected", Colors.GREEN)

    # ==================== THREAT HISTORY FUNCTIONS ====================
    def get_threat_history(self):
        """Check threat history"""
        print_color("🦠 Checking Threat History...", Colors.CYAN)
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 'Get-MpThreat | ConvertTo-Json -Depth 3'],
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    threat_data = json.loads(result.stdout)
                    if isinstance(threat_data, list):
                        threats = threat_data
                    else:
                        threats = [threat_data] if threat_data else []
                    
                    for threat in threats:
                        self.scan_data["threats"].append({
                            "name": threat.get("ThreatName", "Unknown"),
                            "severity": threat.get("SeverityID", 0),
                            "path": threat.get("ExecutionPath", "Unknown"),
                            "time": threat.get("InitialDetectionTime", "Unknown")
                        })
                    
                    if self.scan_data["threats"]:
                        print_color(f"  ⚠️ Found {len(self.scan_data['threats'])} threats in history", Colors.YELLOW)
                    else:
                        print_color("  ✅ No threats found in history", Colors.GREEN)
                except json.JSONDecodeError:
                    print_color("  ✅ No threats found in history", Colors.GREEN)
            else:
                print_color("  ✅ No threats found in history", Colors.GREEN)
        except Exception as e:
            print_color(f"  ⚠️ Could not access threat history: {e}", Colors.YELLOW)

    # ==================== FILE SCANNING FUNCTIONS ====================
    def scan_files(self):
        """Scan for executable and suspicious files"""
        print_color("📁 Scanning for files...", Colors.CYAN)
        
        # Define search paths
        user_profile = os.environ.get('USERPROFILE', 'C:\\Users\\Default')
        search_paths = [
            "C:\\Users",
            "C:\\Program Files",
            "C:\\Program Files (x86)",
            "C:\\Windows\\Temp",
            os.path.join(user_profile, "Downloads"),
            os.path.join(user_profile, "Desktop"),
            os.path.join(user_profile, "Documents")
        ]
        
        # EXE Files
        print_color("  🔍 Searching for EXE files...", Colors.GRAY)
        exe_files = []
        for path in search_paths:
            if os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        if len(exe_files) >= 1000:
                            break
                        for file in files:
                            if file.lower().endswith('.exe'):
                                full_path = os.path.join(root, file)
                                exe_files.append(full_path)
                                if len(exe_files) >= 1000:
                                    break
                except (PermissionError, OSError):
                    continue
        
        self.scan_data["files"]["exe_files"] = list(set(exe_files))[:1000]
        self.scan_data["files"]["exe_count"] = len(self.scan_data["files"]["exe_files"])
        print_color(f"    ✅ Found {self.scan_data['files']['exe_count']} EXE files", Colors.GREEN)
        
        # RAR Files
        print_color("  🔍 Searching for RAR files...", Colors.GRAY)
        rar_files = []
        for path in search_paths:
            if os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        if len(rar_files) >= 500:
                            break
                        for file in files:
                            if file.lower().endswith('.rar'):
                                full_path = os.path.join(root, file)
                                rar_files.append(full_path)
                                if len(rar_files) >= 500:
                                    break
                except (PermissionError, OSError):
                    continue
        
        self.scan_data["files"]["rar_files"] = list(set(rar_files))[:500]
        self.scan_data["files"]["rar_count"] = len(self.scan_data["files"]["rar_files"])
        print_color(f"    ✅ Found {self.scan_data['files']['rar_count']} RAR files", Colors.GREEN)
        
        # Suspicious files (10-char exe and Dapper.dll)
        print_color("  🔍 Searching for suspicious files...", Colors.GRAY)
        suspicious_files = []
        pattern = re.compile(r'^[A-Za-z0-9]{10}\.exe$')
        
        for path in search_paths:
            if os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        for file in files:
                            if pattern.match(file) or file.lower() == "dapper.dll":
                                full_path = os.path.join(root, file)
                                suspicious_files.append(full_path)
                except (PermissionError, OSError):
                    continue
        
        self.scan_data["files"]["suspicious"] = list(set(suspicious_files))
        self.scan_data["files"]["sus_count"] = len(self.scan_data["files"]["suspicious"])
        
        if self.scan_data["files"]["sus_count"] > 0:
            print_color(f"    ⚠️ Found {self.scan_data['files']['sus_count']} suspicious files", Colors.YELLOW)
        else:
            print_color("    ✅ No suspicious files found", Colors.GREEN)

    # ==================== REGISTRY EXECUTED PROGRAMS ====================
    def get_executed_programs(self):
        """Get recently executed programs from registry"""
        print_color("📋 Checking recently executed programs...", Colors.CYAN)
        
        executed_programs = set()
        
        # BAM entries
        print_color("  🔍 Checking BAM registry...", Colors.GRAY)
        try:
            key_path = r"SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path) as key:
                i = 0
                while True:
                    try:
                        subkey_name = winreg.EnumKey(key, i)
                        with winreg.OpenKey(key, subkey_name) as subkey:
                            j = 0
                            while True:
                                try:
                                    value_name, value_data, _ = winreg.EnumValue(subkey, j)
                                    if re.search(r'\.exe|\.rar', value_name, re.I):
                                        executed_programs.add(value_name)
                                    j += 1
                                except WindowsError:
                                    break
                        i += 1
                    except WindowsError:
                        break
        except Exception as e:
            print_color(f"    ⚠️ Could not access BAM registry: {e}", Colors.YELLOW)
        
        # AppCompat
        print_color("  🔍 Checking AppCompat registry...", Colors.GRAY)
        try:
            key_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store"
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path) as key:
                i = 0
                while True:
                    try:
                        value_name, value_data, _ = winreg.EnumValue(key, i)
                        if re.search(r'\.exe|\.rar', value_name, re.I):
                            executed_programs.add(value_name)
                        i += 1
                    except WindowsError:
                        break
        except Exception as e:
            print_color(f"    ⚠️ Could not access AppCompat registry: {e}", Colors.YELLOW)
        
        # AppSwitched
        print_color("  🔍 Checking AppSwitched registry...", Colors.GRAY)
        try:
            key_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched"
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, key_path) as key:
                i = 0
                while True:
                    try:
                        value_name, value_data, _ = winreg.EnumValue(key, i)
                        if re.search(r'\.exe|\.rar', value_name, re.I):
                            executed_programs.add(value_name)
                        i += 1
                    except WindowsError:
                        break
        except Exception as e:
            print_color(f"    ⚠️ Could not access AppSwitched registry: {e}", Colors.YELLOW)
        
        self.scan_data["executed_programs"] = list(executed_programs)[:500]
        print_color(f"  ✅ Found {len(self.scan_data['executed_programs'])} executed programs", Colors.GREEN)

    # ==================== GAME BAN FUNCTIONS ====================
    def check_r6_ban_status(self):
        """Check Rainbow Six Siege ban status via stats.cc"""
        print_color("  🎯 Checking Rainbow Six Siege accounts...", Colors.GRAY)
        
        r6_accounts = []
        username = os.environ.get('USERNAME', '')
        
        # Paths to check for R6 accounts
        r6_paths = [
            f"C:\\Users\\{username}\\Documents\\My Games\\Rainbow Six - Siege",
            f"C:\\Users\\{username}\\AppData\\Local\\Ubisoft Game Launcher\\spool",
            "C:\\Program Files (x86)\\Ubisoft\\Ubisoft Game Launcher\\savegames",
            "C:\\Program Files (x86)\\Ubisoft\\Ubisoft Game Launcher\\cache\\ownership",
            "C:\\Program Files (x86)\\Ubisoft\\Ubisoft Game Launcher\\cache\\club"
        ]
        
        account_names = set()
        
        for path in r6_paths:
            if os.path.exists(path):
                try:
                    for item in os.listdir(path):
                        item_path = os.path.join(path, item)
                        if os.path.isdir(item_path):
                            if re.match(r'^[a-f0-9]{32}$', item) or re.match(r'^[A-Za-z0-9]{3,20}$', item):
                                account_names.add(item)
                        elif os.path.isfile(item_path):
                            if re.match(r'^[a-f0-9]{32}\.json$', item) or 'profile' in item.lower():
                                account_names.add(os.path.splitext(item)[0])
                except (PermissionError, OSError):
                    continue
        
        if not account_names:
            print_color("    ℹ️ No Rainbow Six Siege accounts found", Colors.GRAY)
            return
        
        print_color(f"    🔍 Found {len(account_names)} potential R6 accounts, checking ban status...", Colors.GRAY)
        
        for account in account_names:
            try:
                time.sleep(0.5)  # Rate limiting
                
                url = f"https://stats.cc/siege/{account}"
                print_color(f"      Checking: {account}", Colors.GRAY)
                
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                }
                response = requests.get(url, headers=headers, timeout=10)
                
                if response.status_code == 200:
                    content = response.text
                    
                    # Extract account name
                    match = re.search(r'<title>Siege Stats - Stats\.CC (.*?) - Rainbow Six Siege Player Stats</title>', content)
                    if match:
                        account_name = match.group(1)
                        
                        # Check for bans
                        ban_type = "None"
                        status = "Active"
                        
                        if re.search(r'<div id="Ubisoft Bans".*?<div>Cheating</div>', content, re.DOTALL):
                            ban_type = "Cheating"
                            status = "BANNED"
                        elif re.search(r'<div id="Ubisoft Bans".*?<div>Toxic Behavior</div>', content, re.DOTALL):
                            ban_type = "Toxic Behavior"
                            status = "BANNED"
                        elif re.search(r'<div id="Ubisoft Bans".*?<div>Botting</div>', content, re.DOTALL):
                            ban_type = "Botting"
                            status = "BANNED"
                        elif re.search(r'<div id="Reputation Bans".*?Reputation Bans', content, re.DOTALL):
                            ban_type = "Reputation"
                            status = "BANNED"
                        
                        # Check for match count
                        match_count_match = re.search(r'<div class="text-2xl font-bold">([0-9,]+)</div>\s*<div class="text-xs opacity-60">Matches</div>', content)
                        if match_count_match:
                            match_count = match_count_match.group(1).replace(',', '')
                            if status == "BANNED":
                                result = f"{account_name} - {status} ({ban_type}) - Matches: {match_count}"
                            else:
                                result = f"{account_name} - Active - Matches: {match_count}"
                        else:
                            result = f"{account_name} - {status} {ban_type}"
                        
                        r6_accounts.append(result)
                        
                        if status == "BANNED":
                            print_color(f"      ⚠️ {result}", Colors.RED)
                        else:
                            print_color(f"      ✅ {result}", Colors.GREEN)
                elif response.status_code == 404:
                    print_color(f"      ❌ Account not found on stats.cc: {account}", Colors.GRAY)
                else:
                    print_color(f"      ⚠️ Error checking {account}: HTTP {response.status_code}", Colors.YELLOW)
            except requests.exceptions.Timeout:
                print_color(f"      ⚠️ Timeout checking {account}", Colors.YELLOW)
            except Exception as e:
                print_color(f"      ⚠️ Error checking {account}: {e}", Colors.YELLOW)
        
        self.scan_data["game_bans"]["rainbow_six"] = r6_accounts

    def check_steam_ban_status(self):
        """Check Steam ban status via web scraping"""
        print_color("  🎯 Checking Steam accounts via web scraping...", Colors.GRAY)
        
        steam_accounts = []
        steam_ids = set()
        steam_names = {}
        
        # Check avatar cache
        avatar_cache = "C:\\Program Files (x86)\\Steam\\config\\avatarcache"
        if os.path.exists(avatar_cache):
            try:
                for file in os.listdir(avatar_cache):
                    if file.lower().endswith('.png'):
                        steam_id = os.path.splitext(file)[0]
                        if re.match(r'^7656[0-9]{13}$', steam_id):
                            steam_ids.add(steam_id)
                print_color(f"    🔍 Found {len(steam_ids)} Steam IDs from avatar cache", Colors.GRAY)
            except Exception as e:
                print_color(f"    ⚠️ Error reading avatar cache: {e}", Colors.YELLOW)
        
        # Check loginusers.vdf
        login_users = "C:\\Program Files (x86)\\Steam\\config\\loginusers.vdf"
        if os.path.exists(login_users):
            try:
                with open(login_users, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Extract Steam IDs and account names
                pattern = r'"([0-9]{17})"\s*{\s*"AccountName"\s*"([^"]+)"'
                for match in re.finditer(pattern, content):
                    steam_id = match.group(1)
                    account_name = match.group(2)
                    steam_ids.add(steam_id)
                    steam_names[steam_id] = account_name
                
                print_color(f"    🔍 Found {len(steam_names)} Steam accounts from loginusers.vdf", Colors.GRAY)
            except Exception as e:
                print_color(f"    ⚠️ Error reading loginusers.vdf: {e}", Colors.YELLOW)
        
        if not steam_ids:
            print_color("    ℹ️ No Steam accounts found", Colors.GRAY)
            return
        
        print_color(f"    🔍 Checking ban status for {len(steam_ids)} Steam accounts via web scraping...", Colors.GRAY)
        
        for steam_id in steam_ids:
            try:
                time.sleep(2)  # Rate limiting
                
                account_name = steam_names.get(steam_id, "Unknown")
                url = f"https://steamcommunity.com/profiles/{steam_id}"
                print_color(f"      Checking: {account_name} ({steam_id})", Colors.GRAY)
                
                headers = {
                    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
                }
                response = requests.get(url, headers=headers, timeout=10)
                
                if response.status_code == 200:
                    content = response.text
                    
                    # Check for bans
                    ban_type = "None"
                    status = "Clean"
                    
                    if re.search(r'VAC ban\(s\) on record|VAC Banned', content, re.I):
                        status = "BANNED"
                        ban_type = "VAC"
                    
                    if re.search(r'Game ban\(s\) on record|Game Banned', content, re.I):
                        if status == "BANNED":
                            ban_type += ", Game"
                        else:
                            status = "BANNED"
                            ban_type = "Game"
                    
                    if re.search(r'community banned|Community Ban', content, re.I):
                        if status == "BANNED":
                            ban_type += ", Community"
                        else:
                            status = "BANNED"
                            ban_type = "Community"
                    
                    # Extract profile name
                    profile_match = re.search(r'<title>(.*?) :: Steam Community</title>', content)
                    if profile_match:
                        profile_name = profile_match.group(1).replace('Steam Community :: ', '')
                        account_name = profile_name
                    
                    if status == "BANNED":
                        result = f"{account_name} - {status} ({ban_type})"
                        print_color(f"      ⚠️ {result}", Colors.RED)
                    else:
                        result = f"{account_name} - Clean (No bans detected)"
                        print_color(f"      ✅ {result}", Colors.GREEN)
                    
                    steam_accounts.append(result)
                    
                elif response.status_code == 404:
                    print_color(f"      ❌ Profile not found: {steam_id}", Colors.GRAY)
                else:
                    print_color(f"      ⚠️ Error checking {steam_id}: HTTP {response.status_code}", Colors.YELLOW)
            except requests.exceptions.Timeout:
                print_color(f"      ⚠️ Timeout checking {steam_id}", Colors.YELLOW)
            except Exception as e:
                print_color(f"      ⚠️ Error checking {steam_id}: {e}", Colors.YELLOW)
        
        self.scan_data["game_bans"]["steam"] = steam_accounts

    def get_game_ban_status(self):
        """Main game ban check function"""
        print_color("🎮 Checking game ban status...", Colors.CYAN)
        
        self.check_r6_ban_status()
        self.check_steam_ban_status()
        
        print_color("  ✅ Game ban checks completed", Colors.GREEN)

    # ==================== HARDWARE INFO FUNCTIONS ====================
    def get_hardware_info(self):
        """Collect hardware information"""
        print_color("💻 Collecting hardware information...", Colors.CYAN)
        
        # Monitor info via PowerShell
        print_color("  🔍 Checking monitors...", Colors.GRAY)
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-CimInstance -Namespace root\\wmi -ClassName WmiMonitorID | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    monitor_data = json.loads(result.stdout)
                    if isinstance(monitor_data, list):
                        monitors = monitor_data
                    else:
                        monitors = [monitor_data] if monitor_data else []
                    
                    for monitor in monitors:
                        name_bytes = monitor.get("UserFriendlyName", [])
                        serial_bytes = monitor.get("SerialNumberID", [])
                        
                        name = ''.join([chr(b) for b in name_bytes if b != 0]) if name_bytes else "Unknown"
                        serial = ''.join([chr(b) for b in serial_bytes if b != 0]) if serial_bytes else "Unknown"
                        
                        self.scan_data["hardware"]["monitors"].append({
                            "name": name,
                            "serial": serial
                        })
                    
                    print_color(f"    ✅ Found {len(self.scan_data['hardware']['monitors'])} monitors", Colors.GREEN)
                except:
                    print_color("    ⚠️ Could not parse monitor info", Colors.YELLOW)
            else:
                print_color("    ⚠️ No monitor info found", Colors.YELLOW)
        except Exception as e:
            print_color(f"    ⚠️ Could not get monitor info: {e}", Colors.YELLOW)
        
        # PCIe devices
        print_color("  🔍 Checking PCIe devices...", Colors.GRAY)
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-PnpDevice | Where-Object { $_.InstanceId -like "PCI*" -and $_.Status -eq "OK" } | Select-Object FriendlyName, Status -First 50 | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    pcie_data = json.loads(result.stdout)
                    if isinstance(pcie_data, list):
                        devices = pcie_data
                    else:
                        devices = [pcie_data] if pcie_data else []
                    
                    for device in devices:
                        self.scan_data["hardware"]["pcie_devices"].append({
                            "name": device.get("FriendlyName", "Unknown"),
                            "status": device.get("Status", "Unknown")
                        })
                    
                    print_color(f"    ✅ Found {len(self.scan_data['hardware']['pcie_devices'])} PCIe devices", Colors.GREEN)
                except:
                    print_color("    ⚠️ Could not parse PCIe info", Colors.YELLOW)
            else:
                print_color("    ⚠️ No PCIe devices found", Colors.YELLOW)
        except Exception as e:
            print_color(f"    ⚠️ Could not get PCIe info: {e}", Colors.YELLOW)

    # ==================== LOGITECH SCRIPTS ====================
    def get_logitech_scripts(self):
        """Check Logitech scripts"""
        print_color("🎮 Checking Logitech scripts...", Colors.CYAN)
        
        scripts_path = os.path.join(os.environ.get('LOCALAPPDATA', ''), "LGHUB", "scripts")
        
        if os.path.exists(scripts_path):
            try:
                scripts = []
                for root, dirs, files in os.walk(scripts_path):
                    for file in files:
                        full_path = os.path.join(root, file)
                        mtime = os.path.getmtime(full_path)
                        scripts.append({
                            "path": full_path,
                            "modified": datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
                        })
                        if len(scripts) >= 100:
                            break
                
                self.scan_data["logitech_scripts"] = scripts
                print_color(f"  ✅ Found {len(scripts)} Logitech scripts", Colors.GREEN)
            except Exception as e:
                print_color(f"  ⚠️ Could not read Logitech scripts: {e}", Colors.YELLOW)
        else:
            print_color("  ℹ️ No Logitech scripts found", Colors.GRAY)

    # ==================== PREFETCH FILES ====================
    def get_prefetch_files(self):
        """Check prefetch files"""
        print_color("📂 Checking Prefetch files...", Colors.CYAN)
        
        prefetch_path = os.path.join(os.environ.get('SYSTEMROOT', 'C:\\Windows'), "Prefetch")
        
        if os.path.exists(prefetch_path):
            try:
                prefetch_files = []
                for file in os.listdir(prefetch_path):
                    if file.lower().endswith('.pf'):
                        full_path = os.path.join(prefetch_path, file)
                        mtime = os.path.getmtime(full_path)
                        prefetch_files.append({
                            "name": file,
                            "last_accessed": datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
                        })
                
                # Sort by last accessed (newest first)
                prefetch_files.sort(key=lambda x: x['last_accessed'], reverse=True)
                self.scan_data["prefetch"] = prefetch_files[:200]
                
                print_color(f"  ✅ Found {len(self.scan_data['prefetch'])} prefetch files", Colors.GREEN)
            except Exception as e:
                print_color(f"  ⚠️ Could not read prefetch files: {e}", Colors.YELLOW)
        else:
            print_color("  ℹ️ Prefetch folder not found", Colors.GRAY)

    # ==================== SEND DATA TO DISCORD ====================
    def send_to_discord(self):
        """Send scan data to Discord bot"""
        print_color("", Colors.END)
        print_color("📤 Sending data to Discord bot...", Colors.CYAN)
        
        headers = {
            'Content-Type': 'application/json',
            'X-API-Key': API_KEY
        }
        
        try:
            print_color(f"  📡 Connecting to {API_URL}...", Colors.GRAY)
            response = requests.post(
                API_URL,
                headers=headers,
                json=self.scan_data,
                timeout=30
            )
            
            if response.status_code == 200:
                result = response.json()
                if result.get('status') == 'success':
                    print_color("  ✅ Data sent successfully!", Colors.GREEN)
                    print_color(f"  📊 Response: {result.get('message', '')}", Colors.CYAN)
                    return True
                else:
                    print_color(f"  ❌ Server returned error: {result.get('message', 'Unknown')}", Colors.RED)
                    return False
            else:
                print_color(f"  ❌ HTTP Error: {response.status_code}", Colors.RED)
                try:
                    error_data = response.json()
                    print_color(f"  📝 Server error: {error_data.get('detail', 'Unknown')}", Colors.RED)
                except:
                    pass
                return False
                
        except requests.exceptions.Timeout:
            print_color("  ❌ Request timed out", Colors.RED)
            return False
        except requests.exceptions.ConnectionError:
            print_color("  ❌ Connection error - check your internet", Colors.RED)
            return False
        except Exception as e:
            print_color(f"  ❌ Failed to send data: {e}", Colors.RED)
            return False

    # ==================== MAIN SCAN FUNCTION ====================
    def run_scan(self):
        """Run all scan functions"""
        # First get a scan ID from the bot
        if not self.get_scan_id_from_bot():
            print_color("❌ Cannot proceed without scan ID. Make sure you're authorized and the bot is online.", Colors.RED)
            input("Press Enter to exit...")
            return
        
        self.start_time = time.time()
        
        print_color("", Colors.END)
        print_color("="*50, Colors.GRAY)
        print_color("STARTING SCAN...", Colors.MAGENTA)
        print_color("="*50, Colors.GRAY)
        print_color("", Colors.END)
        
        # Run all scan functions
        self.get_system_info()
        self.get_security_status()
        self.get_threat_history()
        self.scan_files()
        self.get_executed_programs()
        self.get_hardware_info()
        self.get_logitech_scripts()
        self.get_prefetch_files()
        self.get_game_ban_status()
        
        self.end_time = time.time()
        scan_duration = self.end_time - self.start_time
        
        # Print summary
        print_color("", Colors.END)
        print_color("="*50, Colors.GRAY)
        print_color("SCAN COMPLETE", Colors.GREEN)
        print_color("="*50, Colors.GRAY)
        print_color("", Colors.END)
        print_color("📊 Scan Summary:", Colors.CYAN)
        print_color(f"  ⏱️ Duration: {scan_duration:.2f} seconds", Colors.WHITE)
        print_color(f"  💻 System: Windows Install: {self.scan_data['system_info'].get('install_date', 'Unknown')}", Colors.WHITE)
        print_color(f"  🛡️ Security: Defender: {self.scan_data['security'].get('defender_enabled', False)}, Real-time: {self.scan_data['security'].get('realtime', False)}", Colors.WHITE)
        print_color(f"  🦠 Threats: {len(self.scan_data['threats'])}", Colors.WHITE)
        print_color(f"  📁 Files: {self.scan_data['files']['exe_count']} EXE, {self.scan_data['files']['rar_count']} RAR, {self.scan_data['files']['sus_count']} Suspicious", Colors.WHITE)
        print_color(f"  📋 Executed Programs: {len(self.scan_data['executed_programs'])}", Colors.WHITE)
        print_color(f"  🎮 R6 Accounts: {len(self.scan_data['game_bans']['rainbow_six'])}", Colors.WHITE)
        print_color(f"  🎮 Steam Accounts: {len(self.scan_data['game_bans']['steam'])}", Colors.WHITE)
        print_color("", Colors.END)
        
        # Send to Discord
        success = self.send_to_discord()
        
        if success:
            print_color("", Colors.END)
            print_color("✅ Scan completed successfully! Check Discord for results.", Colors.GREEN)
            print_color("You will be pinged when the results are posted.", Colors.CYAN)
        else:
            print_color("", Colors.END)
            print_color("❌ Scan completed but failed to send to Discord.", Colors.RED)
            print_color("Please check your internet connection and try again.", Colors.YELLOW)
        
        print_color("", Colors.END)
        print_color("Thank you for using R6X XScan!", Colors.MAGENTA)
        print_color("", Colors.END)
        
        input("Press Enter to exit...")

# ==================== MAIN ENTRY POINT ====================
def main():
    clear_screen()
    
    print_color("="*50, Colors.CYAN)
    print_color("R6X XScan - Advanced System Security Scanner", Colors.CYAN)
    print_color("="*50, Colors.CYAN)
    print_color("", Colors.END)
    
    # Check if running on Windows
    if platform.system() != 'Windows':
        print_color("❌ This scanner is designed for Windows only!", Colors.RED)
        input("Press Enter to exit...")
        sys.exit(1)
    
    # Check for admin rights (optional but recommended)
    try:
        is_admin = ctypes.windll.shell32.IsUserAnAdmin()
        if not is_admin:
            print_color("⚠️ Warning: Not running as Administrator. Some features may be limited.", Colors.YELLOW)
            print_color("   For full scan capabilities, run as Administrator.\n", Colors.YELLOW)
    except:
        pass
    
    # Get Discord User ID from user
    print_color("Please enter your Discord User ID:", Colors.YELLOW)
    print_color("(You can find this in Discord by enabling Developer Mode and right-clicking your profile)", Colors.GRAY)
    user_id = input("> ").strip()
    
    if not user_id or not user_id.isdigit():
        print_color("❌ Invalid Discord User ID. Please enter a numeric ID.", Colors.RED)
        input("Press Enter to exit...")
        sys.exit(1)
    
    scanner = R6XScanner(user_id)
    scanner.print_banner()
    
    try:
        scanner.run_scan()
    except KeyboardInterrupt:
        print_color("\n\n⚠️ Scan cancelled by user.", Colors.YELLOW)
        input("Press Enter to exit...")
    except Exception as e:
        print_color(f"\n❌ Unexpected error: {e}", Colors.RED)
        input("Press Enter to exit...")

if __name__ == "__main__":
    main()
