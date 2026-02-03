#Requires -RunAsAdministrator
<#
.SYNOPSIS
    Comprehensive Windows Disk Cleanup Script
.DESCRIPTION
    Cleans temporary files, caches, logs, and other unnecessary data from Windows
.NOTES
    Run as Administrator for full functionality
    Author: Claude AI
    Date: 2025-01-19
#>

# Set error handling
$ErrorActionPreference = "SilentlyContinue"

# Colors for output
function Write-Header($text) { Write-Host "`n=== $text ===" -ForegroundColor Cyan }
function Write-Status($text) { Write-Host "  [+] $text" -ForegroundColor Green }
function Write-Info($text) { Write-Host "  [i] $text" -ForegroundColor Yellow }

# Get initial disk space
$initialFree = (Get-PSDrive C).Free

Write-Host @"

 __        ___           _                    ____ _                  
 \ \      / (_)_ __   __| | _____      _____ / ___| | ___  __ _ _ __  
  \ \ /\ / /| | '_ \ / _` / _ \ \ /\ / / __| |   | |/ _ \/ _` | '_ \ 
   \ V  V / | | | | | (_| | (_) \ V  V /\__ \ |___| |  __/ (_| | | | |
    \_/\_/  |_|_| |_|\__,_|\___/ \_/\_/ |___/\____|_|\___|\__,_|_| |_|

"@ -ForegroundColor Magenta

Write-Host "Starting comprehensive disk cleanup..." -ForegroundColor White
Write-Host "Initial free space: $([math]::Round($initialFree / 1GB, 2)) GB" -ForegroundColor White

# ============================================
Write-Header "TEMPORARY FILES"
# ============================================

Write-Status "Cleaning User Temp folder..."
Remove-Item -Path "$env:TEMP\*" -Recurse -Force

Write-Status "Cleaning Windows Temp folder..."
Remove-Item -Path "C:\Windows\Temp\*" -Recurse -Force

Write-Status "Cleaning all users' temp folders..."
Get-ChildItem "C:\Users\*\AppData\Local\Temp\*" -Force | Remove-Item -Recurse -Force

# ============================================
Write-Header "WINDOWS CACHES"
# ============================================

Write-Status "Cleaning Prefetch..."
Remove-Item -Path "C:\Windows\Prefetch\*" -Force

Write-Status "Cleaning Windows Update cache..."
Stop-Service wuauserv -Force
Stop-Service bits -Force
Remove-Item -Path "C:\Windows\SoftwareDistribution\Download\*" -Recurse -Force
Start-Service bits
Start-Service wuauserv

Write-Status "Cleaning Delivery Optimization cache..."
Delete-DeliveryOptimizationCache -Force

Write-Status "Cleaning Windows Installer cache (orphaned)..."
# Only removes orphaned patches, safe operation
$installerFolder = "C:\Windows\Installer\`$PatchCache`$"
if (Test-Path $installerFolder) {
    Remove-Item -Path "$installerFolder\*" -Recurse -Force
}

# ============================================
Write-Header "BROWSER CACHES"
# ============================================

Write-Status "Cleaning Chrome cache..."
$chromePaths = @(
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Google\Chrome\User Data\Default\GPUCache"
)
foreach ($path in $chromePaths) {
    if (Test-Path $path) { Remove-Item -Path "$path\*" -Recurse -Force }
}

Write-Status "Cleaning Edge cache..."
$edgePaths = @(
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\Code Cache",
    "$env:LOCALAPPDATA\Microsoft\Edge\User Data\Default\GPUCache"
)
foreach ($path in $edgePaths) {
    if (Test-Path $path) { Remove-Item -Path "$path\*" -Recurse -Force }
}

Write-Status "Cleaning Firefox cache..."
$firefoxCache = "$env:LOCALAPPDATA\Mozilla\Firefox\Profiles\*\cache2"
if (Test-Path $firefoxCache) {
    Get-ChildItem $firefoxCache | ForEach-Object { Remove-Item -Path "$($_.FullName)\*" -Recurse -Force }
}

# ============================================
Write-Header "APPLICATION CACHES"
# ============================================

Write-Status "Cleaning Microsoft Teams cache..."
$teamsPaths = @(
    "$env:APPDATA\Microsoft\Teams\Cache",
    "$env:APPDATA\Microsoft\Teams\blob_storage",
    "$env:APPDATA\Microsoft\Teams\databases",
    "$env:APPDATA\Microsoft\Teams\GPUCache",
    "$env:APPDATA\Microsoft\Teams\IndexedDB",
    "$env:APPDATA\Microsoft\Teams\Local Storage",
    "$env:APPDATA\Microsoft\Teams\tmp"
)
foreach ($path in $teamsPaths) {
    if (Test-Path $path) { Remove-Item -Path "$path\*" -Recurse -Force }
}

Write-Status "Cleaning Discord cache..."
$discordCache = "$env:APPDATA\discord\Cache"
if (Test-Path $discordCache) { Remove-Item -Path "$discordCache\*" -Recurse -Force }

Write-Status "Cleaning Spotify cache..."
$spotifyCache = "$env:LOCALAPPDATA\Spotify\Data"
if (Test-Path $spotifyCache) { Remove-Item -Path "$spotifyCache\*" -Recurse -Force }

Write-Status "Cleaning npm cache..."
if (Get-Command npm -ErrorAction SilentlyContinue) {
    npm cache clean --force 2>$null
}

Write-Status "Cleaning pip cache..."
$pipCache = "$env:LOCALAPPDATA\pip\Cache"
if (Test-Path $pipCache) { Remove-Item -Path "$pipCache\*" -Recurse -Force }

# ============================================
Write-Header "SYSTEM CLEANUP"
# ============================================

Write-Status "Cleaning Windows Error Reports..."
Remove-Item -Path "C:\ProgramData\Microsoft\Windows\WER\*" -Recurse -Force
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\WER\*" -Recurse -Force

Write-Status "Cleaning Thumbnail cache..."
Remove-Item -Path "$env:LOCALAPPDATA\Microsoft\Windows\Explorer\thumbcache_*.db" -Force

Write-Status "Cleaning Icon cache..."
$iconCache = "$env:LOCALAPPDATA\IconCache.db"
if (Test-Path $iconCache) { Remove-Item -Path $iconCache -Force }

Write-Status "Cleaning Font cache..."
Stop-Service FontCache -Force
Remove-Item -Path "C:\Windows\ServiceProfiles\LocalService\AppData\Local\FontCache\*" -Recurse -Force
Start-Service FontCache

Write-Status "Cleaning Memory dumps..."
Remove-Item -Path "C:\Windows\MEMORY.DMP" -Force
Remove-Item -Path "C:\Windows\Minidump\*" -Force

Write-Status "Cleaning old Windows installations..."
# This uses DISM to clean up component store
Dism.exe /Online /Cleanup-Image /StartComponentCleanup /ResetBase 2>$null

# ============================================
Write-Header "RECYCLE BIN"
# ============================================

Write-Status "Emptying Recycle Bin..."
Clear-RecycleBin -Force -ErrorAction SilentlyContinue

# ============================================
Write-Header "LOG FILES"
# ============================================

Write-Status "Cleaning old log files..."
$logPaths = @(
    "C:\Windows\Logs\CBS\*.log",
    "C:\Windows\Logs\DISM\*.log",
    "C:\Windows\Panther\*.log",
    "C:\Windows\inf\*.log",
    "C:\Windows\debug\*.log"
)
foreach ($path in $logPaths) {
    Remove-Item -Path $path -Force
}

# Clean logs older than 30 days
Get-ChildItem "C:\Windows\Logs" -Recurse -File | Where-Object { $_.LastWriteTime -lt (Get-Date).AddDays(-30) } | Remove-Item -Force

# ============================================
Write-Header "OPTIONAL: ADDITIONAL CLEANUP"
# ============================================

Write-Status "Running Windows Disk Cleanup utility..."
# Configure cleanmgr to clean all categories
$volumeCaches = Get-ChildItem "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\VolumeCaches"
foreach ($cache in $volumeCaches) {
    Set-ItemProperty -Path $cache.PSPath -Name "StateFlags0100" -Value 2 -Type DWord -ErrorAction SilentlyContinue
}
# Run cleanmgr silently
Start-Process cleanmgr -ArgumentList "/sagerun:100" -Wait -NoNewWindow

# ============================================
Write-Header "CLEANUP COMPLETE"
# ============================================

# Calculate space freed
$finalFree = (Get-PSDrive C).Free
$freedSpace = $finalFree - $initialFree

Write-Host ""
Write-Host "============================================" -ForegroundColor Cyan
Write-Host "  Final free space: $([math]::Round($finalFree / 1GB, 2)) GB" -ForegroundColor White
Write-Host "  Space freed: $([math]::Round($freedSpace / 1MB, 2)) MB" -ForegroundColor Green
Write-Host "============================================" -ForegroundColor Cyan
Write-Host ""

# Recommendations
Write-Host "Additional recommendations:" -ForegroundColor Yellow
Write-Host "  - Run 'winget upgrade --all' to update apps" -ForegroundColor Gray
Write-Host "  - Check large files: WinDirStat or TreeSize Free" -ForegroundColor Gray
Write-Host "  - Uninstall unused programs via Settings > Apps" -ForegroundColor Gray
Write-Host "  - Enable Storage Sense: Settings > System > Storage" -ForegroundColor Gray
Write-Host ""

Write-Host "Press any key to exit..." -ForegroundColor Cyan
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
