import os
import sys
import time
import json
import platform
import subprocess
import re
import winreg
import ctypes
import threading
import asyncio
from datetime import datetime
from pathlib import Path
from typing import Dict, List, Any, Optional
import requests
import pyperclip

# Try to import psutil for process detection
try:
    import psutil
    PSUTIL_AVAILABLE = True
except ImportError:
    PSUTIL_AVAILABLE = False
    print("⚠️ psutil not installed. Install with: pip install psutil")

# Try to import discord
try:
    import discord
    from discord.ext import commands
    from discord import Embed, Color, File, app_commands
    DISCORD_AVAILABLE = True
except ImportError:
    DISCORD_AVAILABLE = False
    print("⚠️ Discord.py not installed. Install with: pip install discord.py")

# ==================== CONFIGURATION ====================
RENDER_API_URL = "Your Render API URL"  
API_KEY = "Your Render API key"  

# ANSI colors for terminal output
class Colors:
    HEADER = '\033[95m'
    DARK_RED = '\033[31m'
    RED = '\033[91m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    BLUE = '\033[94m'
    MAGENTA = '\033[95m'
    CYAN = '\033[96m'
    WHITE = '\033[97m'
    GRAY = '\033[90m'
    END = '\033[0m'
    BOLD = '\033[1m'

# ==================== LOGITECH SCRIPT DETECTION ====================
class LogitechScriptDetector:
    """Detect ALL Logitech scripts (flags every .lua file)"""
    
    @staticmethod
    def find_scripts():
        """Find all Logitech scripts on the system (flags ALL .lua files)"""
        results = {
            'total_scripts': 0,
            'all_scripts': [],  # Contains ALL scripts found
            'script_locations': [],
            'logitech_running': False
        }
        
        if platform.system() != 'Windows':
            return results
        
        # Common Logitech script locations
        logitech_paths = [
            os.path.join(os.environ.get('LOCALAPPDATA', ''), "LGHUB", "scripts"),
            os.path.join(os.environ.get('LOCALAPPDATA', ''), "Logitech", "LGHUB", "scripts"),
            os.path.join(os.environ.get('PROGRAMDATA', ''), "Logitech", "LGHUB", "scripts"),
            os.path.join(os.path.expanduser('~'), "Documents", "Logitech", "LGHUB", "scripts"),
            os.path.join(os.path.expanduser('~'), "AppData", "Roaming", "Logitech", "LGHUB", "scripts"),
            "C:\\Program Files\\Logitech Gaming Software\\Scripts",
            "C:\\Program Files (x86)\\Logitech Gaming Software\\Scripts",
            os.path.join(os.path.expanduser('~'), "Documents", "Logitech", "G-series Scripts"),
            os.path.join(os.environ.get('PROGRAMDATA', ''), "Logitech", "G-series Software", "Scripts"),
            "C:\\Program Files\\Logitech Gaming Software\\Resources\\Scripts",
            "C:\\Program Files (x86)\\Logitech Gaming Software\\Resources\\Scripts",
            os.path.join(os.environ.get('APPDATA', ''), "Logitech", "LGHUB", "scripts"),
            os.path.join(os.environ.get('LOCALAPPDATA', ''), "Logitech", "Logitech Gaming Software", "Scripts"),
            "C:\\Users\\Public\\Documents\\Logitech\\Scripts",
            os.path.join(os.path.expanduser('~'), "Downloads", "Logitech Scripts"),
            os.path.join(os.path.expanduser('~'), "Desktop", "Logitech Scripts"),
        ]
        
        # Check if Logitech software is running
        results['logitech_running'] = LogitechScriptDetector.get_logitech_status().get('running', False)
        
        # Scan each path - FLAG ALL .lua FILES
        for path in logitech_paths:
            if path and os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        for file in files:
                            if file.lower().endswith('.lua'):
                                file_path = os.path.join(root, file)
                                results['total_scripts'] += 1
                                results['script_locations'].append(file_path)
                                
                                # Get file info
                                script_info = {
                                    'name': file,
                                    'path': file_path,
                                    'size': os.path.getsize(file_path) if os.path.exists(file_path) else 0,
                                    'modified': datetime.fromtimestamp(os.path.getmtime(file_path)).isoformat() if os.path.exists(file_path) else None
                                }
                                
                                # Try to read script content
                                try:
                                    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
                                        content = f.read(2000)  # Read first 2000 chars
                                        script_info['preview'] = content[:200] + "..." if len(content) > 200 else content
                                        
                                        # Check for game references
                                        if re.search(r'rainbow|six|siege|r6|tomclancy', content, re.IGNORECASE):
                                            script_info['game'] = 'Rainbow Six Siege'
                                        elif re.search(r'valorant|valo', content, re.IGNORECASE):
                                            script_info['game'] = 'Valorant'
                                        elif re.search(r'csgo|counter|strike|cs2', content, re.IGNORECASE):
                                            script_info['game'] = 'CS:GO/CS2'
                                        elif re.search(r'fortnite|fn', content, re.IGNORECASE):
                                            script_info['game'] = 'Fortnite'
                                        elif re.search(r'apex|legends', content, re.IGNORECASE):
                                            script_info['game'] = 'Apex Legends'
                                        elif re.search(r'cod|callofduty|warzone|mw2|mw3', content, re.IGNORECASE):
                                            script_info['game'] = 'Call of Duty'
                                        elif re.search(r'pubg|playerunknown', content, re.IGNORECASE):
                                            script_info['game'] = 'PUBG'
                                        elif re.search(r'overwatch|ow2', content, re.IGNORECASE):
                                            script_info['game'] = 'Overwatch'
                                        
                                        # Check for recoil patterns
                                        if re.search(r'recoil|antirecoil|no recoil|compensat', content, re.IGNORECASE):
                                            script_info['has_recoil'] = True
                                        
                                        # Check for mouse movement
                                        if re.search(r'move|movement|mousemove|moverelative', content, re.IGNORECASE):
                                            script_info['has_mouse_movement'] = True
                                        
                                        # Check for rapid fire
                                        if re.search(r'rapid|fastfire|autofire|spam', content, re.IGNORECASE):
                                            script_info['has_rapid_fire'] = True
                                        
                                        # Check for aim assistance
                                        if re.search(r'aim|target|lockon|snap|tracking', content, re.IGNORECASE):
                                            script_info['has_aim_assist'] = True
                                        
                                        # Check for timing controls
                                        if re.search(r'sleep|wait|delay|timer', content, re.IGNORECASE):
                                            script_info['has_timing'] = True
                                        
                                except Exception as e:
                                    script_info['read_error'] = str(e)
                                
                                results['all_scripts'].append(script_info)
                                
                except Exception as e:
                    print(f"{Colors.YELLOW}⚠ Error scanning {path}: {e}{Colors.END}")
        
        return results
    
    @staticmethod
    def get_logitech_status():
        """Check if Logitech software is running"""
        if platform.system() != 'Windows':
            return {'running': False}
        
        if not PSUTIL_AVAILABLE:
            return {'running': False, 'error': 'psutil not installed'}
        
        try:
            logitech_processes = []
            for proc in psutil.process_iter(['name', 'pid', 'exe']):
                try:
                    name = proc.info['name'].lower() if proc.info['name'] else ''
                    if any(x in name for x in ['logitech', 'lghub', 'lgs', 'logi', 'ghub']):
                        logitech_processes.append({
                            'name': proc.info['name'],
                            'pid': proc.info['pid'],
                            'exe': proc.info['exe']
                        })
                except:
                    continue
            
            return {
                'running': len(logitech_processes) > 0,
                'processes': logitech_processes
            }
        except Exception as e:
            return {'running': False, 'error': str(e)}

# ==================== DISCORD BOT WITH SLASH COMMANDS ====================
class R6XBot(commands.Bot):
    """Discord bot with slash commands for key management"""
    
    def __init__(self, render_api_url: str, api_key: str):
        intents = discord.Intents.default()
        intents.message_content = True
        super().__init__(command_prefix='!', intents=intents)
        self.render_api_url = render_api_url
        self.api_key = api_key
        self.scanner = None
        self.ready = False
        
    async def setup_hook(self):
        """Setup slash commands"""
        await self.add_cog(KeyManagement(self))
        await self.tree.sync()  # Sync slash commands with Discord
        print(f"{Colors.GREEN}✅ Slash commands synced{Colors.END}")
    
    async def on_ready(self):
        """Called when bot is ready"""
        self.ready = True
        print(f"{Colors.GREEN}✅ Discord bot connected as {self.user.name}{Colors.END}")
        print(f"{Colors.GREEN}✅ Bot ID: {self.user.id}{Colors.END}")
        print(f"{Colors.GREEN}✅ Slash commands available: /generate_key, /list_keys, /validate_key, /stats, /help{Colors.END}")
        
        # Set bot status
        await self.change_presence(
            activity=discord.Activity(
                type=discord.ActivityType.watching,
                name="for /commands"
            )
        )

class KeyManagement(commands.Cog):
    """Key management commands"""
    
    def __init__(self, bot: R6XBot):
        self.bot = bot
    
    @app_commands.command(name="generate_key", description="Generate a new license key for a user")
    @app_commands.describe(
        user_id="Discord User ID to generate key for",
        duration_days="Number of days the key is valid for (default: 30)"
    )
    async def generate_key(
        self, 
        interaction: discord.Interaction, 
        user_id: str,
        duration_days: int = 30
    ):
        """Generate a new key for a user"""
        await interaction.response.defer()
        
        try:
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': self.bot.api_key
            }
            
            payload = {
                'user_id': user_id,
                'duration_days': duration_days
            }
            
            response = requests.post(
                f"{self.bot.render_api_url}/api/generate-key",
                headers=headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                embed = Embed(
                    title="✅ Key Generated Successfully",
                    description=f"Key for user {user_id}",
                    color=Color.green(),
                    timestamp=datetime.now()
                )
                
                embed.add_field(
                    name="🔑 Key",
                    value=f"```\n{data['key']}\n```",
                    inline=False
                )
                
                embed.add_field(
                    name="⏰ Expires",
                    value=f"```\n{data['expires_at']}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="📅 Duration",
                    value=f"```\n{duration_days} days\n```",
                    inline=True
                )
                
                embed.set_footer(text=f"Generated by {interaction.user.name}")
                
                await interaction.followup.send(embed=embed)
            else:
                await interaction.followup.send(
                    f"❌ Failed to generate key: {response.status_code}",
                    ephemeral=True
                )
                
        except Exception as e:
            await interaction.followup.send(
                f"❌ Error: {str(e)}",
                ephemeral=True
            )
    
    @app_commands.command(name="list_keys", description="List all keys for a user")
    @app_commands.describe(user_id="Discord User ID to list keys for")
    async def list_keys(self, interaction: discord.Interaction, user_id: str):
        """List all keys for a user"""
        await interaction.response.defer()
        
        try:
            headers = {'X-API-Key': self.bot.api_key}
            
            response = requests.get(
                f"{self.bot.render_api_url}/api/user/keys/{user_id}",
                headers=headers,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if not data['keys']:
                    await interaction.followup.send(
                        f"ℹ️ No keys found for user {user_id}",
                        ephemeral=True
                    )
                    return
                
                embed = Embed(
                    title=f"🔑 Keys for User {user_id}",
                    description=f"Total Keys: {data['total_keys']}",
                    color=Color.blue(),
                    timestamp=datetime.now()
                )
                
                # Count valid keys
                valid_count = sum(1 for k in data['keys'] if k.get('valid', False))
                embed.add_field(name="✅ Valid Keys", value=str(valid_count), inline=True)
                embed.add_field(name="❌ Used/Expired", value=str(len(data['keys']) - valid_count), inline=True)
                
                # Show first 5 keys
                for i, key_info in enumerate(data['keys'][:5], 1):
                    status = "✅ VALID" if key_info.get('valid') else "❌ USED/EXPIRED"
                    expires = key_info.get('expires_at', 'Unknown')[:10]  # Just show date
                    
                    embed.add_field(
                        name=f"Key {i}: {key_info['key'][:15]}...",
                        value=f"Status: {status}\nExpires: {expires}",
                        inline=False
                    )
                
                if len(data['keys']) > 5:
                    embed.set_footer(text=f"Showing 5 of {len(data['keys'])} keys")
                
                await interaction.followup.send(embed=embed)
            else:
                await interaction.followup.send(
                    f"❌ Failed to list keys: {response.status_code}",
                    ephemeral=True
                )
                
        except Exception as e:
            await interaction.followup.send(
                f"❌ Error: {str(e)}",
                ephemeral=True
            )
    
    @app_commands.command(name="validate_key", description="Check if a user has a valid key")
    @app_commands.describe(user_id="Discord User ID to validate")
    async def validate_key(self, interaction: discord.Interaction, user_id: str):
        """Check if a user has a valid key"""
        await interaction.response.defer()
        
        try:
            headers = {
                'Content-Type': 'application/json',
                'X-API-Key': self.bot.api_key
            }
            
            payload = {'user_id': user_id}
            
            response = requests.post(
                f"{self.bot.render_api_url}/api/validate-key",
                headers=headers,
                json=payload,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                if data['valid']:
                    embed = Embed(
                        title="✅ Valid Key Found",
                        description=f"User {user_id} has {data['available_keys']} valid key(s)",
                        color=Color.green()
                    )
                else:
                    embed = Embed(
                        title="❌ No Valid Key",
                        description=data['message'],
                        color=Color.red()
                    )
                
                await interaction.followup.send(embed=embed)
            else:
                await interaction.followup.send(
                    f"❌ Failed to validate: {response.status_code}",
                    ephemeral=True
                )
                
        except Exception as e:
            await interaction.followup.send(
                f"❌ Error: {str(e)}",
                ephemeral=True
            )
    
    @app_commands.command(name="stats", description="Get bot statistics")
    async def stats(self, interaction: discord.Interaction):
        """Get bot statistics"""
        await interaction.response.defer()
        
        try:
            headers = {'X-API-Key': self.bot.api_key}
            
            response = requests.get(
                f"{self.bot.render_api_url}/api/stats",
                headers=headers,
                timeout=30
            )
            
            if response.status_code == 200:
                data = response.json()
                
                embed = Embed(
                    title="📊 Bot Statistics",
                    color=Color.gold(),
                    timestamp=datetime.now()
                )
                
                # Scan stats
                embed.add_field(
                    name="📁 Total Scans",
                    value=f"```\n{data['total_scans']}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="📊 Files Scanned",
                    value=f"```\n{data['total_files_scanned']}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="⚠️ Suspicious",
                    value=f"```\n{data['total_suspicious_files']}\n```",
                    inline=True
                )
                
                # Key stats
                key_stats = data.get('key_stats', {})
                embed.add_field(
                    name="🔑 Total Keys",
                    value=f"```\n{key_stats.get('total_keys', 0)}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="✅ Valid Keys",
                    value=f"```\n{key_stats.get('valid_keys', 0)}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="👥 Users",
                    value=f"```\n{key_stats.get('unique_users', 0)}\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="⏱️ Avg Duration",
                    value=f"```\n{data['average_duration']:.2f}s\n```",
                    inline=True
                )
                
                embed.add_field(
                    name="🟢 Active Scans",
                    value=f"```\n{data['active_scans']}\n```",
                    inline=True
                )
                
                await interaction.followup.send(embed=embed)
            else:
                await interaction.followup.send(
                    f"❌ Failed to get stats: {response.status_code}",
                    ephemeral=True
                )
                
        except Exception as e:
            await interaction.followup.send(
                f"❌ Error: {str(e)}",
                ephemeral=True
            )
    
    @app_commands.command(name="help", description="Show available commands")
    async def help_command(self, interaction: discord.Interaction):
        """Show help"""
        embed = Embed(
            title="🤖 R6X CyberScan Bot Commands",
            description="Available slash commands:",
            color=Color.blue()
        )
        
        commands = [
            ("/generate_key [user_id] [days]", "Generate a new license key"),
            ("/list_keys [user_id]", "List all keys for a user"),
            ("/validate_key [user_id]", "Check if user has valid key"),
            ("/stats", "Show bot statistics"),
            ("/help", "Show this help message")
        ]
        
        for cmd, desc in commands:
            embed.add_field(name=cmd, value=desc, inline=False)
        
        await interaction.response.send_message(embed=embed)

# ==================== RENDER API FUNCTIONS ====================
def get_bot_token() -> dict:
    """Get bot token from Render (no user ID needed)"""
    try:
        print(f"{Colors.YELLOW}🔄 Getting bot token from Render...{Colors.END}")
        
        headers = {
            'Content-Type': 'application/json',
            'X-API-Key': API_KEY
        }
        
        response = requests.get(
            f"{RENDER_API_URL}/api/bot-token",
            headers=headers,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"{Colors.GREEN}✅ Got bot token from Render{Colors.END}")
            return {
                'success': True,
                'bot_token': data['bot_token'],
                'channel_id': data['channel_id']
            }
        else:
            return {
                'success': False,
                'error': f"Failed: {response.status_code}"
            }
            
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

def login_user(user_id: str) -> dict:
    """Login user with their Discord ID"""
    try:
        print(f"{Colors.YELLOW}🔄 Logging in user {user_id}...{Colors.END}")
        
        headers = {
            'Content-Type': 'application/json',
            'X-API-Key': API_KEY
        }
        
        payload = {'user_id': user_id}
        
        response = requests.post(
            f"{RENDER_API_URL}/api/login",
            headers=headers,
            json=payload,
            timeout=30
        )
        
        if response.status_code == 200:
            data = response.json()
            print(f"{Colors.GREEN}✅ Login successful!{Colors.END}")
            return {
                'success': True,
                'scan_id': data['scan_id'],
                'message': data['message']
            }
        else:
            error_msg = f"Failed: {response.status_code}"
            if response.status_code == 403:
                error_msg = "Invalid or no valid key"
            elif response.status_code == 401:
                error_msg = "Invalid API key"
            
            return {
                'success': False,
                'error': error_msg
            }
            
    except Exception as e:
        return {
            'success': False,
            'error': str(e)
        }

def notify_scan_complete(scan_id: str, user_id: str, scan_data: dict, logitech_data: dict = None) -> bool:
    """Notify Render that scan is complete"""
    try:
        headers = {
            'Content-Type': 'application/json',
            'X-API-Key': API_KEY
        }
        
        payload = {
            'scan_id': scan_id,
            'user_id': user_id,
            'files_scanned': scan_data.get('files_scanned', 0),
            'suspicious_count': scan_data.get('suspicious_count', 0),
            'duration': scan_data.get('duration', 0)
        }
        
        if logitech_data:
            payload['logitech'] = {
                'total_scripts': logitech_data.get('total_scripts', 0),
                'logitech_running': logitech_data.get('logitech_running', False),
                'scripts': logitech_data.get('all_scripts', [])[:10]
            }
        
        response = requests.post(
            f"{RENDER_API_URL}/api/scan/complete",
            headers=headers,
            json=payload,
            timeout=10
        )
        
        return response.status_code == 200
    except Exception as e:
        print(f"{Colors.YELLOW}⚠ Could not notify Render: {e}{Colors.END}")
        return False

# ==================== SCANNER CLASS ====================
class R6XCyberScan:
    def __init__(self, user_id: str, scan_id: str, channel_id: int, bot: R6XBot = None):
        self.user_id = user_id
        self.scan_id = scan_id
        self.channel_id = channel_id
        self.bot = bot
        self.name = f"User_{user_id[-4:]}"
        self.log_file = f"R6X_Scan_{datetime.now().strftime('%Y%m%d_%H%M%S')}.txt"
        self.log_path = os.path.join(os.path.expanduser('~'), 'Desktop', self.log_file)
        self.desktop_path = os.path.join(os.path.expanduser('~'), 'Desktop')
        self.user_profile = os.path.expanduser('~')
        self.downloads_path = os.path.join(self.user_profile, 'Downloads')
        self.logged_paths = set()
        self.start_time = time.time()
        self.scan_data = {
            'files_scanned': 0,
            'suspicious_count': 0,
            'r6_count': 0,
            'steam_count': 0,
            'duration': 0
        }
        self.logitech_results = None
        self._discord_task = None  # Store the discord task
        
    def print_banner(self):
        """Print the R6X banner"""
        banner = f"""
╔══════════════════════════════════════════════════════════════╗
║                     R6X CYBERSCAN v4.0                       ║
║                Advanced Security Scanner                      ║
║              [ Discord Bot Already Running ]                  ║
╠══════════════════════════════════════════════════════════════╣
║  User ID: {self.user_id}                                        ║
║  Scan ID: {self.scan_id}                                      ║
╚══════════════════════════════════════════════════════════════╝
"""
        print(f"{Colors.CYAN}{banner}{Colors.END}")
    
    def write_log(self, content: str):
        """Write to log file"""
        with open(self.log_path, 'a', encoding='utf-8') as f:
            f.write(content + '\n')
    
    def write_section(self, title: str):
        """Write a section header"""
        self.write_log(f"\n{'-'*50}")
        self.write_log(f"{title}")
        self.write_log(f"{'-'*50}")
        print(f"{Colors.BLUE}▶ {title}{Colors.END}")
    
    def get_onedrive_path(self) -> str:
        """Get OneDrive path from registry"""
        try:
            key = winreg.OpenKey(winreg.HKEY_CURRENT_USER, r"Software\Microsoft\OneDrive")
            one_drive = winreg.QueryValueEx(key, "UserFolder")[0]
            winreg.CloseKey(key)
            if os.path.exists(one_drive):
                return one_drive
        except:
            pass
        
        env_one_drive = os.path.join(self.user_profile, "OneDrive")
        if os.path.exists(env_one_drive):
            return env_one_drive
        
        return None
    
    def log_windows_install_date(self):
        """Log Windows installation date"""
        self.write_section("Windows Installation Date")
        
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
                    install_date = f"{year}-{month}-{day}"
                    self.write_log(f"Windows Installation Date: {install_date}")
                    print(f"{Colors.GREEN}  ✓ Windows Install Date: {install_date}{Colors.END}")
                else:
                    self.write_log("Windows Installation Date: Unknown")
            else:
                self.write_log("Windows Installation Date: Unknown")
        except Exception as e:
            self.write_log(f"Windows Installation Date: Error - {e}")
            print(f"{Colors.RED}  ✗ Could not get install date{Colors.END}")
    
    def find_rar_exe_files(self):
        """Find .rar and .exe files"""
        self.write_section("File Scan Results")
        print(f"{Colors.YELLOW}  Scanning for .rar and .exe files...{Colors.END}")
        
        one_drive_path = self.get_onedrive_path()
        
        search_paths = [
            "C:\\Users",
            "C:\\Program Files",
            "C:\\Program Files (x86)",
            "C:\\Windows\\Temp",
            "C:\\Temp"
        ]
        
        if one_drive_path:
            search_paths.append(one_drive_path)
        
        one_drive_files = []
        all_files = []
        
        for path in search_paths:
            if os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        dirs[:] = [d for d in dirs if d.lower() not in ['windows', 'system32']]
                        
                        for file in files:
                            if file.lower().endswith(('.rar', '.exe')):
                                full_path = os.path.join(root, file)
                                all_files.append(full_path)
                                
                                if one_drive_path and one_drive_path in full_path:
                                    one_drive_files.append(full_path)
                                
                                if len(all_files) > 1000:
                                    break
                except (PermissionError, OSError):
                    continue
        
        if one_drive_files:
            self.write_log("\nOneDrive Files:")
            for f in sorted(set(one_drive_files))[:100]:
                self.write_log(f)
        
        self.write_log("\nAll Files Found:")
        for f in sorted(set(all_files))[:500]:
            self.write_log(f)
        
        self.scan_data['files_scanned'] = len(all_files)
        print(f"{Colors.GREEN}  ✓ Found {len(all_files)} files{Colors.END}")
    
    def find_sus_files(self):
        """Find suspicious files (10-char exe and Dapper.dll)"""
        self.write_section("Suspicious Files")
        print(f"{Colors.YELLOW}  Searching for suspicious files...{Colors.END}")
        
        pattern = re.compile(r'^[A-Za-z0-9]{10}\.exe$')
        search_paths = [
            "C:\\Users",
            "C:\\Program Files",
            "C:\\Program Files (x86)",
            "C:\\Windows\\Temp",
            "C:\\Temp"
        ]
        
        sus_files = []
        
        for path in search_paths:
            if os.path.exists(path):
                try:
                    for root, dirs, files in os.walk(path):
                        for file in files:
                            if pattern.match(file) or file.lower() == "dapper.dll":
                                full_path = os.path.join(root, file)
                                sus_files.append(full_path)
                                self.write_log(full_path)
                except (PermissionError, OSError):
                    continue
        
        self.scan_data['suspicious_count'] = len(sus_files)
        
        if sus_files:
            print(f"{Colors.YELLOW}  ⚠ Found {len(sus_files)} suspicious files{Colors.END}")
        else:
            print(f"{Colors.GREEN}  ✓ No suspicious files found{Colors.END}")
    
    def list_bam_state(self):
        """Log registry entries from BAM and related keys"""
        self.write_section("Registry - Executed Programs")
        print(f"{Colors.YELLOW}  Checking registry for executed programs...{Colors.END}")
        
        # BAM entries
        try:
            bam_path = r"SYSTEM\CurrentControlSet\Services\bam\State\UserSettings"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, bam_path) as key:
                i = 0
                while True:
                    try:
                        subkey_name = winreg.EnumKey(key, i)
                        with winreg.OpenKey(key, subkey_name) as subkey:
                            self.write_log(f"\n{subkey_name}:")
                            j = 0
                            while True:
                                try:
                                    name, value, _ = winreg.EnumValue(subkey, j)
                                    if re.search(r'\.exe|\.rar', name, re.I):
                                        if name not in self.logged_paths:
                                            self.write_log(f"  {name}")
                                            self.logged_paths.add(name)
                                    j += 1
                                except WindowsError:
                                    break
                        i += 1
                    except WindowsError:
                        break
        except Exception as e:
            self.write_log(f"BAM registry error: {e}")
        
        # AppCompat
        try:
            compat_path = r"SOFTWARE\Microsoft\Windows NT\CurrentVersion\AppCompatFlags\Compatibility Assistant\Store"
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, compat_path) as key:
                self.write_log("\nAppCompat Store:")
                i = 0
                while True:
                    try:
                        name, value, _ = winreg.EnumValue(key, i)
                        if re.search(r'\.exe|\.rar', name, re.I) and name not in self.logged_paths:
                            self.write_log(f"  {name}")
                            self.logged_paths.add(name)
                        i += 1
                    except WindowsError:
                        break
        except:
            pass
        
        # AppSwitched
        try:
            switched_path = r"SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\FeatureUsage\AppSwitched"
            with winreg.OpenKey(winreg.HKEY_CURRENT_USER, switched_path) as key:
                self.write_log("\nAppSwitched:")
                i = 0
                while True:
                    try:
                        name, value, _ = winreg.EnumValue(key, i)
                        if re.search(r'\.exe|\.rar', name, re.I) and name not in self.logged_paths:
                            self.write_log(f"  {name}")
                            self.logged_paths.add(name)
                        i += 1
                    except WindowsError:
                        break
        except:
            pass
        
        print(f"{Colors.GREEN}  ✓ Registry scan complete{Colors.END}")
    
    def log_browser_folders(self):
        """Log installed browsers"""
        self.write_section("Installed Browsers")
        
        try:
            browsers_path = r"SOFTWARE\Clients\StartMenuInternet"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, browsers_path) as key:
                i = 0
                while True:
                    try:
                        browser = winreg.EnumKey(key, i)
                        self.write_log(browser)
                        i += 1
                    except WindowsError:
                        break
        except Exception as e:
            self.write_log(f"Browser detection error: {e}")
    
    def search_prefetch(self):
        """Search prefetch files"""
        self.write_section("Prefetch Files")
        print(f"{Colors.YELLOW}  Checking Prefetch files...{Colors.END}")
        
        prefetch_path = os.path.join(os.environ.get('SYSTEMROOT', 'C:\\Windows'), 'Prefetch')
        
        if os.path.exists(prefetch_path):
            try:
                prefetch_files = []
                for file in os.listdir(prefetch_path):
                    if file.lower().endswith('.pf'):
                        file_path = os.path.join(prefetch_path, file)
                        try:
                            mtime = os.path.getmtime(file_path)
                            last_accessed = datetime.fromtimestamp(mtime).strftime('%Y-%m-%d %H:%M:%S')
                            prefetch_files.append(f"{file} - Last Accessed: {last_accessed}")
                        except:
                            prefetch_files.append(file)
                
                if prefetch_files:
                    for pf in sorted(prefetch_files)[:200]:
                        self.write_log(pf)
                    print(f"{Colors.GREEN}  ✓ Found {len(prefetch_files)} prefetch files{Colors.END}")
                else:
                    self.write_log("No prefetch files found")
            except Exception as e:
                self.write_log(f"Error accessing prefetch: {e}")
        else:
            self.write_log("Prefetch folder not found")
    
    def log_windows_security(self):
        """Log Windows Security status"""
        self.write_section("Windows Security Status")
        print(f"{Colors.YELLOW}  Checking Windows Security...{Colors.END}")
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-WmiObject -Namespace "root\\SecurityCenter2" -Class AntiVirusProduct | Select-Object displayName, productState | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    av_data = json.loads(result.stdout)
                    if isinstance(av_data, list):
                        av_products = av_data
                    else:
                        av_products = [av_data] if av_data else []
                    
                    third_party = [av for av in av_products if av.get('displayName') != 'Windows Defender']
                    
                    if third_party:
                        self.write_log("Third-Party Antivirus Detected:")
                        for av in third_party:
                            state = av.get('productState', 'Unknown')
                            self.write_log(f"  Name: {av.get('displayName', 'Unknown')}, State: {state}")
                    else:
                        self.write_log("No third-party antivirus found")
                        
                        defender_result = subprocess.run(
                            ['powershell', '-Command', 'Get-MpComputerStatus | ConvertTo-Json'],
                            capture_output=True, text=True, check=False
                        )
                        if defender_result.returncode == 0 and defender_result.stdout.strip():
                            defender = json.loads(defender_result.stdout)
                            self.write_log(f"Defender Enabled: {defender.get('AntivirusEnabled', False)}")
                            self.write_log(f"Real-Time Protection: {defender.get('RealTimeProtectionEnabled', False)}")
                except:
                    pass
        except Exception as e:
            self.write_log(f"Security check error: {e}")
        
        print(f"{Colors.GREEN}  ✓ Security check complete{Colors.END}")
    
    def log_protection_history(self):
        """Log protection history threats"""
        self.write_section("Protection History")
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 'Get-MpThreat | ConvertTo-Json -Depth 3'],
                capture_output=True, text=True, check=False
            )
            
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    threats = json.loads(result.stdout)
                    if isinstance(threats, list):
                        threat_list = threats
                    else:
                        threat_list = [threats] if threats else []
                    
                    if threat_list:
                        for threat in threat_list:
                            self.write_log(f"Threat: {threat.get('ThreatName', 'Unknown')}")
                            self.write_log(f"  Severity: {threat.get('SeverityID', 'Unknown')}")
                            self.write_log(f"  Path: {threat.get('ExecutionPath', 'Unknown')}")
                            self.write_log(f"  Time: {threat.get('InitialDetectionTime', 'Unknown')}")
                            self.write_log("")
                    else:
                        self.write_log("No threats found in protection history")
                except:
                    self.write_log("No threats found in protection history")
            else:
                self.write_log("No threats found in protection history")
        except Exception as e:
            self.write_log(f"Protection history error: {e}")
    
    def log_system_info(self):
        """Log Secure Boot and DMA protection info"""
        self.write_section("System Information")
        print(f"{Colors.YELLOW}  Checking system information...{Colors.END}")
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 'Confirm-SecureBootUEFI'],
                capture_output=True, text=True, check=False
            )
            if "True" in result.stdout:
                secure_boot = "Enabled"
            elif "False" in result.stdout:
                secure_boot = "Disabled"
            else:
                secure_boot = "Not Available"
            self.write_log(f"Secure Boot: {secure_boot}")
        except:
            self.write_log("Secure Boot: Unknown")
        
        try:
            key_path = r"SYSTEM\CurrentControlSet\Control\DeviceGuard"
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, key_path) as key:
                try:
                    value, _ = winreg.QueryValueEx(key, "EnableDmaProtection")
                    dma = "Enabled" if value == 1 else "Disabled"
                except:
                    dma = "Disabled"
                self.write_log(f"Kernel DMA Protection: {dma}")
        except:
            self.write_log("Kernel DMA Protection: Unknown")
        
        print(f"{Colors.GREEN}  ✓ System info collected{Colors.END}")
    
    def log_monitors(self):
        """Log monitor information"""
        self.write_section("Monitor Information")
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-CimInstance -Namespace root\\wmi -ClassName WmiMonitorID | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    monitors = json.loads(result.stdout)
                    if isinstance(monitors, list):
                        monitor_list = monitors
                    else:
                        monitor_list = [monitors] if monitors else []
                    
                    for monitor in monitor_list:
                        name_bytes = monitor.get("UserFriendlyName", [])
                        serial_bytes = monitor.get("SerialNumberID", [])
                        
                        name = ''.join([chr(b) for b in name_bytes if b != 0]) if name_bytes else "Unknown"
                        serial = ''.join([chr(b) for b in serial_bytes if b != 0]) if serial_bytes else "Unknown"
                        
                        self.write_log(f"Monitor: {name}, Serial: {serial}")
                except:
                    self.write_log("Could not parse monitor information")
            else:
                self.write_log("No monitor information found")
        except Exception as e:
            self.write_log(f"Monitor detection error: {e}")
    
    def log_pcie_devices(self):
        """Log PCIe devices"""
        self.write_section("PCIe Devices")
        
        try:
            result = subprocess.run(
                ['powershell', '-Command', 
                 'Get-PnpDevice | Where-Object { $_.InstanceId -like "PCI*" } | Select-Object FriendlyName, Status -First 50 | ConvertTo-Json'],
                capture_output=True, text=True, check=False
            )
            
            if result.returncode == 0 and result.stdout.strip() and result.stdout.strip() != "null":
                try:
                    devices = json.loads(result.stdout)
                    if isinstance(devices, list):
                        device_list = devices
                    else:
                        device_list = [devices] if devices else []
                    
                    for device in device_list:
                        self.write_log(f"Name: {device.get('FriendlyName', 'Unknown')}, Status: {device.get('Status', 'Unknown')}")
                except:
                    self.write_log("Could not parse PCIe device information")
            else:
                self.write_log("No PCIe devices found")
        except Exception as e:
            self.write_log(f"PCIe detection error: {e}")
    
    def log_r6_accounts(self):
        """Log Rainbow Six Siege accounts"""
        self.write_section("Rainbow Six Siege Accounts")
        print(f"{Colors.YELLOW}  Checking R6 accounts...{Colors.END}")
        
        username = os.environ.get('USERNAME', '')
        r6_paths = [
            f"C:\\Users\\{username}\\Documents\\My Games\\Rainbow Six - Siege",
            f"C:\\Users\\{username}\\AppData\\Local\\Ubisoft Game Launcher"
        ]
        
        accounts = []
        
        for path in r6_paths:
            if os.path.exists(path):
                try:
                    for item in os.listdir(path):
                        item_path = os.path.join(path, item)
                        if os.path.isdir(item_path):
                            accounts.append(item)
                            self.write_log(f"Account: {item}")
                except:
                    pass
        
        if not accounts:
            self.write_log("No R6 accounts found")
        
        self.scan_data['r6_count'] = len(accounts)
        print(f"{Colors.GREEN}  ✓ Found {len(accounts)} R6 accounts{Colors.END}")
    
    def log_steam_accounts(self):
        """Log Steam accounts"""
        self.write_section("Steam Accounts")
        print(f"{Colors.YELLOW}  Checking Steam accounts...{Colors.END}")
        
        steam_config = "C:\\Program Files (x86)\\Steam\\config\\loginusers.vdf"
        accounts = []
        
        if os.path.exists(steam_config):
            try:
                with open(steam_config, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                pattern = r'"(\d+)"\s*{\s*"AccountName"\s*"([^"]*)"'
                matches = re.finditer(pattern, content)
                
                for match in matches:
                    account_id = match.group(1)
                    account_name = match.group(2)
                    self.write_log(f"Account: {account_name} (ID: {account_id})")
                    accounts.append(account_name)
            except Exception as e:
                self.write_log(f"Error reading Steam config: {e}")
        else:
            self.write_log("Steam not found or no accounts configured")
        
        self.scan_data['steam_count'] = len(accounts)
        print(f"{Colors.GREEN}  ✓ Found {len(accounts)} Steam accounts{Colors.END}")
    
    def find_registry_subkeys(self):
        """Find registry subkeys under AllowedBuses"""
        self.write_section("Registry - AllowedBuses")
        
        reg_path = r"SYSTEM\CurrentControlSet\Control\DmaSecurity\AllowedBuses"
        
        try:
            with winreg.OpenKey(winreg.HKEY_LOCAL_MACHINE, reg_path) as key:
                i = 0
                subkeys = []
                while True:
                    try:
                        subkey = winreg.EnumKey(key, i)
                        subkeys.append(subkey)
                        i += 1
                    except WindowsError:
                        break
                
                if subkeys:
                    for sk in subkeys:
                        self.write_log(sk)
                else:
                    self.write_log("No subkeys found (only default key exists)")
        except:
            self.write_log("Registry path not found")
    
    def scan_logitech_scripts(self):
        """Scan for Logitech scripts (flags ALL .lua files)"""
        self.write_section("Logitech Script Detection")
        print(f"{Colors.YELLOW}  Scanning for ALL Logitech scripts (.lua files)...{Colors.END}")
        
        # Find all scripts
        self.logitech_results = LogitechScriptDetector.find_scripts()
        
        # Write results to log
        self.write_log(f"\nTotal Logitech Scripts Found: {self.logitech_results['total_scripts']}")
        self.write_log(f"Logitech Software Running: {self.logitech_results['logitech_running']}")
        
        if self.logitech_results['total_scripts'] > 0:
            self.write_log("\nAll Scripts Found (ALL .lua files are flagged):")
            for script in self.logitech_results['all_scripts']:
                self.write_log(f"\n  📄 Name: {script['name']}")
                self.write_log(f"     Path: {script['path']}")
                self.write_log(f"     Size: {script['size']} bytes")
                self.write_log(f"     Modified: {script['modified']}")
                
                if script.get('game'):
                    self.write_log(f"     Game: {script['game']}")
                if script.get('has_recoil'):
                    self.write_log(f"     ⚠ Has Recoil Control")
                if script.get('has_rapid_fire'):
                    self.write_log(f"     ⚠ Has Rapid Fire")
                if script.get('has_aim_assist'):
                    self.write_log(f"     ⚠ Has Aim Assist")
                if script.get('has_mouse_movement'):
                    self.write_log(f"     Has Mouse Movement")
                if script.get('has_timing'):
                    self.write_log(f"     Has Timing Controls")
            
            print(f"{Colors.YELLOW}  ⚠ Found {self.logitech_results['total_scripts']} .lua scripts (ALL flagged){Colors.END}")
            
            # Show first few scripts in console
            for i, script in enumerate(self.logitech_results['all_scripts'][:5]):
                game_info = f" [{script.get('game', 'Unknown')}]" if script.get('game') else ""
                features = []
                if script.get('has_recoil'):
                    features.append("RECOIL")
                if script.get('has_rapid_fire'):
                    features.append("RAPID")
                if script.get('has_aim_assist'):
                    features.append("AIM")
                
                feature_str = f" ({', '.join(features)})" if features else ""
                print(f"{Colors.WHITE}     {i+1}. {script['name']}{game_info}{feature_str}{Colors.END}")
            
            if len(self.logitech_results['all_scripts']) > 5:
                print(f"{Colors.WHITE}     ... and {len(self.logitech_results['all_scripts']) - 5} more{Colors.END}")
        else:
            print(f"{Colors.GREEN}  ✓ No Logitech scripts found{Colors.END}")
        
        # Add to scan data
        self.scan_data['logitech_scripts'] = self.logitech_results['total_scripts']
        self.scan_data['logitech_running'] = self.logitech_results['logitech_running']
        
        print(f"{Colors.GREEN}  ✓ Logitech script scan complete{Colors.END}")
    
    def copy_to_clipboard(self):
        """Copy log content to clipboard"""
        try:
            with open(self.log_path, 'r', encoding='utf-8') as f:
                content = f.read()
            
            pyperclip.copy(content)
            print(f"{Colors.GREEN}✓ Log file copied to clipboard{Colors.END}")
        except Exception as e:
            print(f"{Colors.YELLOW}⚠ Could not copy to clipboard: {e}{Colors.END}")
    
    def cleanup_files(self):
        """Clean up temporary files"""
        pc_check_desktop = os.path.join(self.desktop_path, "PcCheck.txt")
        pc_check_downloads = os.path.join(self.downloads_path, "PcCheck.txt")
        
        for file_path in [pc_check_desktop, pc_check_downloads]:
            if os.path.exists(file_path):
                try:
                    os.remove(file_path)
                except:
                    pass
    
    async def send_results_to_discord(self):
        """Send scan results to Discord"""
        if not DISCORD_AVAILABLE or not self.bot or not self.bot.ready:
            print(f"{Colors.YELLOW}⚠ Cannot send results to Discord (bot not ready){Colors.END}")
            return False
        
        try:
            channel = self.bot.get_channel(self.channel_id)
            if not channel:
                print(f"{Colors.RED}❌ Could not find channel {self.channel_id}{Colors.END}")
                return False
            
            # Create main embed
            embed = Embed(
                title="📊 R6X CyberScan Results",
                description=f"Scan completed for <@{self.user_id}>",
                color=Color.gold(),
                timestamp=datetime.now()
            )
            
            # Add scan stats
            embed.add_field(
                name="📁 Files Scanned",
                value=f"```\n{self.scan_data.get('files_scanned', 0)} files\n```",
                inline=True
            )
            
            embed.add_field(
                name="⚠️ Suspicious Files",
                value=f"```\n{self.scan_data.get('suspicious_count', 0)} files\n```",
                inline=True
            )
            
            embed.add_field(
                name="🎮 R6 Accounts",
                value=f"```\n{self.scan_data.get('r6_count', 0)} accounts\n```",
                inline=True
            )
            
            embed.add_field(
                name="🎮 Steam Accounts",
                value=f"```\n{self.scan_data.get('steam_count', 0)} accounts\n```",
                inline=True
            )
            
            embed.add_field(
                name="⏱️ Duration",
                value=f"```\n{self.scan_data.get('duration', 0):.2f}s\n```",
                inline=True
            )
            
            # Add Logitech info
            if self.logitech_results:
                logitech_status = "🟢 Running" if self.logitech_results.get('logitech_running') else "🔴 Not Running"
                embed.add_field(
                    name="🎮 Logitech",
                    value=f"```\n{logitech_status}\nScripts: {self.logitech_results.get('total_scripts', 0)}\n```",
                    inline=True
                )
                
                if self.logitech_results.get('total_scripts', 0) > 0:
                    # List first few scripts with features
                    script_lines = []
                    for script in self.logitech_results['all_scripts'][:3]:
                        features = []
                        if script.get('has_recoil'):
                            features.append("R")
                        if script.get('has_rapid_fire'):
                            features.append("F")
                        if script.get('has_aim_assist'):
                            features.append("A")
                        
                        feature_str = f" [{','.join(features)}]" if features else ""
                        script_lines.append(f"{script['name']}{feature_str}")
                    
                    if len(self.logitech_results['all_scripts']) > 3:
                        script_lines.append(f"... and {len(self.logitech_results['all_scripts']) - 3} more")
                    
                    embed.add_field(
                        name="📜 Scripts Found",
                        value=f"```\n" + "\n".join(script_lines) + "\n```",
                        inline=False
                    )
            
            embed.set_footer(text=f"Scan ID: {self.scan_id}")
            
            # Send embed with file
            await channel.send(
                content=f"<@{self.user_id}> - Your scan results are ready!",
                embed=embed,
                file=File(self.log_path)
            )
            
            print(f"{Colors.GREEN}✅ Results sent to Discord!{Colors.END}")
            return True
            
        except Exception as e:
            print(f"{Colors.RED}❌ Failed to send to Discord: {e}{Colors.END}")
            return False
    
    def send_to_discord_sync(self):
        """Synchronous wrapper for sending to Discord"""
        if not self.bot or not self.bot.ready:
            print(f"{Colors.YELLOW}⚠ Bot not ready, cannot send to Discord{Colors.END}")
            return False
        
        try:
            # Get the bot's loop
            loop = self.bot.loop
            
            # Check if we're in the bot's thread
            if loop.is_running():
                # Loop is already running, use run_coroutine_threadsafe
                future = asyncio.run_coroutine_threadsafe(
                    self.send_results_to_discord(), 
                    loop
                )
                # Wait for the result with a timeout
                return future.result(timeout=30)
            else:
                # Loop is not running, we can run it directly
                loop.run_until_complete(self.send_results_to_discord())
                return True
                
        except Exception as e:
            print(f"{Colors.RED}❌ Failed to send to Discord: {e}{Colors.END}")
            return False
    
    def run_scan(self):
        """Run all scan functions"""
        self.print_banner()
        print()
        
        # Initialize log file
        with open(self.log_path, 'w', encoding='utf-8') as f:
            f.write(f"R6X CyberScan Log\n")
            f.write(f"User ID: {self.user_id}\n")
            f.write(f"Scan ID: {self.scan_id}\n")
            f.write(f"Scan Date: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}\n")
            f.write("="*60 + "\n")
        
        print(f"{Colors.CYAN}{'='*60}{Colors.END}")
        print(f"{Colors.MAGENTA}Starting system scan...{Colors.END}")
        print(f"{Colors.CYAN}{'='*60}{Colors.END}")
        print()
        
        # Run all scans
        self.log_windows_install_date()
        print()
        
        self.find_rar_exe_files()
        print()
        
        self.find_sus_files()
        print()
        
        self.list_bam_state()
        print()
        
        self.log_browser_folders()
        print()
        
        self.search_prefetch()
        print()
        
        self.log_windows_security()
        print()
        
        self.log_protection_history()
        print()
        
        self.log_system_info()
        print()
        
        self.find_registry_subkeys()
        print()
        
        self.log_monitors()
        print()
        
        self.log_pcie_devices()
        print()
        
        self.scan_logitech_scripts()  # Flags ALL .lua files
        print()
        
        self.log_r6_accounts()
        print()
        
        self.log_steam_accounts()
        print()
        
        # Calculate scan duration
        self.scan_data['duration'] = time.time() - self.start_time
        
        # Add summary to log
        self.write_section("Scan Summary")
        self.write_log(f"Scan Duration: {self.scan_data['duration']:.2f} seconds")
        self.write_log(f"Files Scanned: {self.scan_data['files_scanned']}")
        self.write_log(f"Suspicious Files: {self.scan_data['suspicious_count']}")
        self.write_log(f"R6 Accounts: {self.scan_data['r6_count']}")
        self.write_log(f"Steam Accounts: {self.scan_data['steam_count']}")
        
        if self.logitech_results:
            self.write_log(f"\nLogitech Scripts Found: {self.logitech_results.get('total_scripts', 0)}")
            self.write_log(f"Logitech Running: {self.logitech_results.get('logitech_running', False)}")
        
        # Print summary
        print(f"{Colors.CYAN}{'='*60}{Colors.END}")
        print(f"{Colors.GREEN}SCAN COMPLETE{Colors.END}")
        print(f"{Colors.CYAN}{'='*60}{Colors.END}")
        print(f"{Colors.WHITE}Duration: {self.scan_data['duration']:.2f} seconds{Colors.END}")
        print(f"{Colors.WHITE}Files Scanned: {self.scan_data['files_scanned']}{Colors.END}")
        print(f"{Colors.WHITE}Suspicious Files: {self.scan_data['suspicious_count']}{Colors.END}")
        print(f"{Colors.WHITE}R6 Accounts: {self.scan_data['r6_count']}{Colors.END}")
        print(f"{Colors.WHITE}Steam Accounts: {self.scan_data['steam_count']}{Colors.END}")
        
        if self.logitech_results:
            print(f"{Colors.WHITE}Logitech Scripts: {self.logitech_results.get('total_scripts', 0)}{Colors.END}")
            if self.logitech_results.get('logitech_running'):
                print(f"{Colors.GREEN}  ✓ Logitech software is running{Colors.END}")
        
        print(f"{Colors.WHITE}Log saved to: {self.log_path}{Colors.END}")
        print()
        
        # Copy to clipboard
        self.copy_to_clipboard()
        print()
        
        # Send results to Discord - ULTIMATE FIX
        if self.bot and self.bot.ready:
            try:
                # Check if we're in a thread with a running event loop
                try:
                    # Try to get the current event loop
                    loop = asyncio.get_running_loop()
                    
                    # If we get here, there's already a running loop
                    # We need to create a task in that loop
                    print(f"{Colors.YELLOW}⏳ Creating Discord task in existing loop...{Colors.END}")
                    
                    # Create a task in the existing loop
                    loop.create_task(self.send_results_to_discord())
                    
                    print(f"{Colors.GREEN}✅ Discord task created successfully{Colors.END}")
                    
                except RuntimeError:
                    # No running loop, we need to run it synchronously
                    print(f"{Colors.YELLOW}⏳ No running loop, sending synchronously...{Colors.END}")
                    self.send_to_discord_sync()
                    
            except Exception as e:
                print(f"{Colors.RED}❌ Failed to send to Discord: {e}{Colors.END}")
        else:
            print(f"{Colors.YELLOW}⚠ Bot not ready, results saved locally{Colors.END}")
        
        # Notify Render that scan is complete
        notify_scan_complete(self.scan_id, self.user_id, self.scan_data, self.logitech_results)
        
        # Cleanup
        self.cleanup_files()
        
        print(f"{Colors.GREEN}✓ Script execution completed{Colors.END}")
        print()

# ==================== BOT THREAD ====================
def run_bot_in_thread(token: str, render_api_url: str, api_key: str) -> R6XBot:
    """Run the Discord bot in a separate thread and return the bot instance"""
    bot = R6XBot(render_api_url, api_key)
    
    async def start_bot():
        try:
            await bot.start(token)
        except Exception as e:
            print(f"{Colors.RED}❌ Bot error: {e}{Colors.END}")
    
    def run_bot():
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        loop.run_until_complete(start_bot())
    
    thread = threading.Thread(target=run_bot, daemon=True)
    thread.start()
    return bot

# ==================== MAIN ====================
def main():
    """Main entry point"""
    # Check if running on Windows
    if platform.system() != 'Windows':
        print(f"{Colors.RED}This scanner is designed for Windows only!{Colors.END}")
        input("Press Enter to exit...")
        sys.exit(1)
    
    # Check for admin rights
    try:
        is_admin = ctypes.windll.shell32.IsUserAnAdmin()
        if not is_admin:
            print(f"{Colors.YELLOW}⚠ Warning: Not running as Administrator. Some features may be limited.{Colors.END}")
            print()
    except:
        pass
    
    # Clear screen
    os.system('cls' if os.name == 'nt' else 'clear')
    
    # Print header
    print(f"{Colors.CYAN}{'='*60}{Colors.END}")
    print(f"{Colors.CYAN}            R6X CYBERSCAN v4.0{Colors.END}")
    print(f"{Colors.CYAN}{'='*60}{Colors.END}")
    print()
    
    # STEP 1: Start Discord bot immediately (no user ID needed)
    bot = None
    channel_id = 0
    
    if DISCORD_AVAILABLE:
        print(f"{Colors.YELLOW}🤖 Starting Discord bot...{Colors.END}")
        
        # Get bot token from Render (no user ID needed)
        token_result = get_bot_token()
        
        if not token_result['success']:
            print(f"{Colors.RED}❌ Failed to get bot token: {token_result.get('error', 'Unknown error')}{Colors.END}")
            print(f"{Colors.YELLOW}Continuing without Discord bot...{Colors.END}")
        else:
            bot_token = token_result['bot_token']
            channel_id = int(token_result['channel_id'])
            
            # Start bot in background
            bot = run_bot_in_thread(bot_token, RENDER_API_URL, API_KEY)
            print(f"{Colors.GREEN}✅ Discord bot started in background{Colors.END}")
            print()
            
            # Give bot a moment to initialize
            print(f"{Colors.YELLOW}⏳ Waiting for bot to initialize...{Colors.END}")
            time.sleep(5)
            print(f"{Colors.GREEN}✅ Bot is ready! You can now use Discord commands while using the scanner.{Colors.END}")
            print()
    else:
        print(f"{Colors.RED}❌ Discord.py not installed. Bot cannot start.{Colors.END}")
        print()
    
    # STEP 2: User login with Discord ID
    print(f"{Colors.YELLOW}🔐 Please enter your Discord User ID to login:{Colors.END}")
    user_id = input(f"{Colors.GREEN}> {Colors.END}").strip()
    
    if not user_id or not user_id.isdigit():
        print(f"{Colors.RED}❌ Invalid Discord User ID. Please enter a numeric ID.{Colors.END}")
        input("Press Enter to exit...")
        sys.exit(1)
    
    print()
    
    # STEP 3: Login user with their ID
    print(f"{Colors.YELLOW}🔄 Logging in...{Colors.END}")
    login_result = login_user(user_id)
    
    if not login_result['success']:
        print(f"{Colors.RED}❌ Login failed: {login_result.get('error', 'Unknown error')}{Colors.END}")
        print(f"{Colors.YELLOW}Make sure you have a valid key. Generate one in Discord with /generate_key{Colors.END}")
        input("Press Enter to exit...")
        sys.exit(1)
    
    scan_id = login_result['scan_id']
    print(f"{Colors.GREEN}✅ Login successful!{Colors.END}")
    print(f"{Colors.GREEN}✅ Scan ID: {scan_id}{Colors.END}")
    print()
    
    # STEP 4: Create scanner and run the scan
    scanner = R6XCyberScan(
        user_id=user_id,
        scan_id=scan_id,
        channel_id=channel_id,
        bot=bot
    )
    
    try:
        scanner.run_scan()
    except KeyboardInterrupt:
        print(f"\n{Colors.YELLOW}⚠ Scan cancelled by user{Colors.END}")
    except Exception as e:
        print(f"{Colors.RED}❌ Error: {e}{Colors.END}")
        import traceback
        traceback.print_exc()
    
    input(f"{Colors.GRAY}Press Enter to exit...{Colors.END}")

if __name__ == "__main__":
    main()
