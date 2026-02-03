#!/bin/bash
#
# macOS Disk Cleanup Script
# Run with: sudo bash mac-cleanup.sh
# Author: Claude AI
#

# Colors
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m'

header() { echo -e "\n${CYAN}=== $1 ===${NC}"; }
status() { echo -e "  ${GREEN}[+]${NC} $1"; }
info() { echo -e "  ${YELLOW}[i]${NC} $1"; }

# Check for root
if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}Please run as root: sudo bash mac-cleanup.sh${NC}"
    exit 1
fi

# Get current user (not root)
CURRENT_USER=$(stat -f "%Su" /dev/console)
USER_HOME="/Users/$CURRENT_USER"

# Get initial disk space
INITIAL_FREE=$(df -g / | tail -1 | awk '{print $4}')

echo -e "${MAGENTA}"
echo '  __  __            _____ _                  '
echo ' |  \/  | __ _  ___|  ___| | ___  __ _ _ __  '
echo ' | |\/| |/ _` |/ __| |   | |/ _ \/ _` | `_ \ '
echo ' | |  | | (_| | (__| |___| |  __/ (_| | | | |'
echo ' |_|  |_|\__,_|\___|_____|_|\___|\__,_|_| |_|'
echo -e "${NC}"

echo -e "${WHITE}Starting comprehensive macOS cleanup...${NC}"
echo -e "${WHITE}Initial free space: ${INITIAL_FREE} GB${NC}"
echo -e "${WHITE}User: ${CURRENT_USER}${NC}"

# ============================================
header "SYSTEM CACHES"
# ============================================

status "Cleaning system cache..."
rm -rf /Library/Caches/* 2>/dev/null

status "Cleaning user cache..."
rm -rf "$USER_HOME/Library/Caches/"* 2>/dev/null

status "Cleaning DNS cache..."
dscacheutil -flushcache 2>/dev/null
killall -HUP mDNSResponder 2>/dev/null

status "Cleaning CUPS printer cache..."
rm -rf /var/spool/cups/cache/* 2>/dev/null

# ============================================
header "TEMPORARY FILES"
# ============================================

status "Cleaning system temp files..."
rm -rf /private/tmp/* 2>/dev/null
rm -rf /private/var/tmp/* 2>/dev/null

status "Cleaning temporary items..."
rm -rf "$USER_HOME/Library/Application Support/CrashReporter/"* 2>/dev/null
rm -rf /Library/Logs/DiagnosticReports/* 2>/dev/null
rm -rf "$USER_HOME/Library/Logs/DiagnosticReports/"* 2>/dev/null

# ============================================
header "BROWSER CACHES"
# ============================================

status "Cleaning Safari cache..."
rm -rf "$USER_HOME/Library/Caches/com.apple.Safari/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Caches/com.apple.Safari.SearchHelper/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Safari/LocalStorage/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Safari/Databases/"* 2>/dev/null

status "Cleaning Chrome cache..."
rm -rf "$USER_HOME/Library/Caches/Google/Chrome/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Google/Chrome/Default/Cache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Google/Chrome/Default/Code Cache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Google/Chrome/Default/GPUCache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Google/Chrome/Default/Service Worker/CacheStorage/"* 2>/dev/null

status "Cleaning Firefox cache..."
rm -rf "$USER_HOME/Library/Caches/Firefox/"* 2>/dev/null

status "Cleaning Edge cache..."
rm -rf "$USER_HOME/Library/Caches/Microsoft Edge/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Microsoft Edge/Default/Cache/"* 2>/dev/null

# ============================================
header "APPLICATION CACHES"
# ============================================

status "Cleaning Xcode derived data..."
rm -rf "$USER_HOME/Library/Developer/Xcode/DerivedData/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Developer/Xcode/Archives/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Developer/CoreSimulator/Caches/"* 2>/dev/null

status "Cleaning Homebrew cache..."
if command -v brew &>/dev/null; then
    su "$CURRENT_USER" -c "brew cleanup -s 2>/dev/null"
    rm -rf "$(su "$CURRENT_USER" -c "brew --cache" 2>/dev/null)"/* 2>/dev/null
fi

status "Cleaning npm cache..."
if command -v npm &>/dev/null; then
    su "$CURRENT_USER" -c "npm cache clean --force 2>/dev/null"
fi

status "Cleaning pip cache..."
rm -rf "$USER_HOME/Library/Caches/pip/"* 2>/dev/null

status "Cleaning yarn cache..."
if command -v yarn &>/dev/null; then
    su "$CURRENT_USER" -c "yarn cache clean 2>/dev/null"
fi

status "Cleaning Composer cache..."
rm -rf "$USER_HOME/.composer/cache/"* 2>/dev/null

status "Cleaning CocoaPods cache..."
rm -rf "$USER_HOME/Library/Caches/CocoaPods/"* 2>/dev/null

status "Cleaning Spotify cache..."
rm -rf "$USER_HOME/Library/Application Support/Spotify/PersistentCache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Caches/com.spotify.client/"* 2>/dev/null

status "Cleaning Discord cache..."
rm -rf "$USER_HOME/Library/Application Support/discord/Cache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/discord/Code Cache/"* 2>/dev/null

status "Cleaning Slack cache..."
rm -rf "$USER_HOME/Library/Application Support/Slack/Cache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Slack/Service Worker/CacheStorage/"* 2>/dev/null

status "Cleaning Teams cache..."
rm -rf "$USER_HOME/Library/Application Support/Microsoft/Teams/Cache/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Microsoft/Teams/blob_storage/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Microsoft/Teams/GPUCache/"* 2>/dev/null

status "Cleaning Adobe cache..."
rm -rf "$USER_HOME/Library/Caches/Adobe/"* 2>/dev/null
rm -rf "$USER_HOME/Library/Application Support/Adobe/Common/Media Cache Files/"* 2>/dev/null

# ============================================
header "LOG FILES"
# ============================================

status "Cleaning system logs..."
rm -rf /private/var/log/asl/*.asl 2>/dev/null
rm -rf /Library/Logs/*.log 2>/dev/null

status "Cleaning user logs..."
rm -rf "$USER_HOME/Library/Logs/"* 2>/dev/null

status "Cleaning old system logs (30+ days)..."
find /private/var/log -type f -name "*.log" -mtime +30 -delete 2>/dev/null
find /private/var/log -type f -name "*.gz" -delete 2>/dev/null

# ============================================
header "macOS SPECIFIC"
# ============================================

status "Cleaning QuickLook cache..."
qlmanage -r cache 2>/dev/null

status "Cleaning shared cache..."
update_dyld_shared_cache -force 2>/dev/null

status "Cleaning font cache..."
atsutil databases -remove 2>/dev/null

status "Cleaning iCloud cache..."
rm -rf "$USER_HOME/Library/Caches/CloudKit/"* 2>/dev/null

status "Cleaning Mail cache..."
rm -rf "$USER_HOME/Library/Containers/com.apple.mail/Data/Library/Caches/"* 2>/dev/null

status "Cleaning Downloads metadata..."
rm -rf "$USER_HOME/Library/Caches/com.apple.previewapps/"* 2>/dev/null

status "Purging inactive memory..."
purge 2>/dev/null

# ============================================
header "TRASH"
# ============================================

status "Emptying Trash..."
rm -rf "$USER_HOME/.Trash/"* 2>/dev/null
rm -rf /Volumes/*/.Trashes/* 2>/dev/null

# ============================================
header "DOCKER (if installed)"
# ============================================

if command -v docker &>/dev/null; then
    status "Cleaning Docker..."
    docker system prune -af 2>/dev/null
    docker volume prune -f 2>/dev/null
else
    info "Docker not installed, skipping..."
fi

# ============================================
header "CLEANUP COMPLETE"
# ============================================

# Calculate space freed
sleep 1
FINAL_FREE=$(df -g / | tail -1 | awk '{print $4}')
FREED=$((FINAL_FREE - INITIAL_FREE))

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "  ${WHITE}Final free space: ${FINAL_FREE} GB${NC}"
echo -e "  ${GREEN}Space freed: ~${FREED} GB${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

echo -e "${YELLOW}Additional recommendations:${NC}"
echo -e "${GRAY}  - Review large files: du -sh ~/* | sort -rh | head -20${NC}"
echo -e "${GRAY}  - Check storage: Apple Menu > About This Mac > Storage${NC}"
echo -e "${GRAY}  - Uninstall unused apps from /Applications${NC}"
echo -e "${GRAY}  - Review mail attachments & old downloads${NC}"
echo -e "${GRAY}  - Consider CleanMyMac or GrandPerspective for visual analysis${NC}"
echo ""
echo -e "${CYAN}Done! Your Mac is clean. 🍏${NC}"
