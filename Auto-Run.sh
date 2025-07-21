#!/bin/bash

# =================================================================
# 🚀 TWITTER SCRAPER - ENHANCED UNIVERSAL AUTO INSTALLER 🚀
# Developer: ARMIN-SOFT
# Website: https://armin-soft.ir/
# Version: 1.3.0
# 
# ✨ FULLY AUTOMATED CROSS-PLATFORM INSTALLATION ✨
# This script automatically detects your OS and installs everything:
# - Python 3.11+ (if not available)
# - All required system dependencies
# - Chrome/Chromium browser with proper drivers
# - Virtual environment setup with error handling
# - Complete dependency installation with fallbacks
# - Advanced error recovery mechanisms
# - Runs the application with proper configuration
#
# Compatible: Linux, Ubuntu, Debian, RHEL, CentOS, Fedora, Arch, macOS, Windows (WSL/Git Bash/MSYS2)
# Enhanced for: Ubuntu 20.04+, Debian 11+, CentOS 8+, all modern Linux distributions
# =================================================================

set -e  # Exit immediately on error

# === CONFIGURATION ===
SCRIPT_VERSION="1.3.0"
REQUIRED_PYTHON="3.11"
AUTO_MODE=true
SKIP_CONFIRMATIONS=true
GITHUB_REPO="armin-soft/Twitter-Scraper"
GITHUB_API="https://api.github.com/repos/$GITHUB_REPO/releases/latest"
BACKUP_DIR=".backup_$(date +%Y%m%d_%H%M%S)"

# === COLORS AND SYMBOLS ===
if [[ -t 1 ]]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    BOLD='\033[1m'
    NC='\033[0m'
else
    RED='' GREEN='' YELLOW='' BLUE='' PURPLE='' CYAN='' WHITE='' BOLD='' NC=''
fi

# Symbols
SUCCESS="✓"
ERROR="✗"
WARNING="⚠"
INFO="ℹ"
ROCKET="🚀"
PYTHON="🐍"
CHROME="🌐"
GEAR="⚙"

# === UTILITY FUNCTIONS ===

print_header() {
    clear
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}${WHITE}                🚀 TWITTER SCRAPER v${SCRIPT_VERSION}                     ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                    UNIVERSAL AUTO INSTALLER                       ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                        Developer: ARMIN-SOFT                      ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}║${WHITE}                      Website: https://armin-soft.ir/              ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

log_info() {
    echo -e "${BLUE}${INFO}${NC} ${WHITE}$1${NC}"
}

log_success() {
    echo -e "${GREEN}${SUCCESS}${NC} ${WHITE}$1${NC}"
}

log_warning() {
    echo -e "${YELLOW}${WARNING}${NC} ${WHITE}$1${NC}"
}

log_error() {
    echo -e "${RED}${ERROR}${NC} ${WHITE}$1${NC}"
}

log_progress() {
    echo -e "${CYAN}${GEAR}${NC} ${WHITE}$1${NC}"
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# === ENHANCED OS DETECTION ===
detect_os() {
    local os_type=""
    local os_details=""
    
    log_progress "Detecting operating system..."
    
    # Primary OS detection
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux distribution detection with fallbacks
        if [[ -f "/etc/os-release" ]]; then
            local distro_id=$(grep '^ID=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
            local distro_name=$(grep '^NAME=' /etc/os-release | cut -d'=' -f2 | tr -d '"')
            os_details="$distro_name ($distro_id)"
            
            case "$distro_id" in
                ubuntu|debian|linuxmint|pop|elementary)
                    os_type="debian"
                    ;;
                rhel|centos|rocky|alma|oracle)
                    os_type="rhel"
                    ;;
                fedora)
                    os_type="fedora"
                    ;;
                arch|manjaro|endeavour)
                    os_type="arch"
                    ;;
                opensuse|sles)
                    os_type="opensuse"
                    ;;
                *)
                    # Fallback to package manager detection
                    if command_exists apt-get; then
                        os_type="debian"
                    elif command_exists yum; then
                        os_type="rhel"
                    elif command_exists dnf; then
                        os_type="fedora"
                    elif command_exists pacman; then
                        os_type="arch"
                    elif command_exists zypper; then
                        os_type="opensuse"
                    else
                        os_type="linux_generic"
                    fi
                    ;;
            esac
        else
            # Legacy detection method
            if command_exists apt-get; then
                os_type="debian"
                os_details="Debian-based (legacy detection)"
            elif command_exists yum; then
                os_type="rhel"
                os_details="RHEL-based (legacy detection)"
            elif command_exists dnf; then
                os_type="fedora"
                os_details="Fedora-based (legacy detection)"
            elif command_exists pacman; then
                os_type="arch"
                os_details="Arch-based (legacy detection)"
            else
                os_type="linux_generic"
                os_details="Generic Linux"
            fi
        fi
        
        # Check for WSL (Windows Subsystem for Linux)
        if grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME}" ]]; then
            os_type="wsl"
            os_details="$os_details (WSL)"
        fi
        
        # Check for Docker/Container environment
        if [[ -f "/.dockerenv" ]] || grep -qi docker /proc/1/cgroup 2>/dev/null; then
            os_details="$os_details (Container)"
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
        local macos_version=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        os_details="macOS $macos_version"
        
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        os_type="windows_bash"
        os_details="Windows ($OSTYPE)"
        
    elif [[ -n "$WINDIR" || -n "$windir" || -n "$SYSTEMROOT" ]]; then
        os_type="windows_bash"
        os_details="Windows (detected via environment)"
        
    elif [[ "$OSTYPE" == "freebsd"* ]]; then
        os_type="freebsd"
        os_details="FreeBSD"
        
    elif [[ "$OSTYPE" == "openbsd"* ]]; then
        os_type="openbsd"
        os_details="OpenBSD"
        
    else
        os_type="unknown"
        os_details="Unknown OS ($OSTYPE)"
    fi
    
    # Log detection results
    log_success "OS detected: $os_type"
    if [[ -n "$os_details" ]]; then
        log_info "Details: $os_details"
    fi
    
    # Store details for later use
    export DETECTED_OS_DETAILS="$os_details"
    
    echo "$os_type"
}

# === UPDATE SYSTEM ===
check_for_updates() {
    log_progress "Checking for updates from GitHub..."
    
    # Get current version
    local current_version="$SCRIPT_VERSION"
    if [[ -f "Update.json" ]]; then
        current_version=$(grep '"current_version"' Update.json | cut -d'"' -f4 2>/dev/null || echo "$SCRIPT_VERSION")
    fi
    
    log_info "Current version: $current_version"
    
    # Check internet connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log_warning "No internet connection - skipping update check"
        return 1
    fi
    
    # Get latest release info from GitHub API
    local latest_info
    if command_exists curl; then
        latest_info=$(curl -s "$GITHUB_API" 2>/dev/null)
    elif command_exists wget; then
        latest_info=$(wget -qO- "$GITHUB_API" 2>/dev/null)
    else
        log_warning "No curl or wget available - skipping update check"
        return 1
    fi
    
    if [[ -z "$latest_info" ]]; then
        log_warning "Failed to fetch latest release information"
        return 1
    fi
    
    # Parse latest version
    local latest_version=$(echo "$latest_info" | grep '"tag_name"' | cut -d'"' -f4 | sed 's/^v//' 2>/dev/null)
    local download_url=$(echo "$latest_info" | grep '"zipball_url"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ -z "$latest_version" ]]; then
        log_warning "Could not parse latest version information"
        return 1
    fi
    
    log_info "Latest version: $latest_version"
    
    # Compare versions
    if version_compare "$current_version" "$latest_version"; then
        log_info "You already have the latest version"
        return 0
    else
        log_success "New version available: $latest_version"
        return 2
    fi
}

version_compare() {
    local current="$1"
    local latest="$2"
    
    # Simple version comparison (works for most semantic versions)
    local current_num=$(echo "$current" | sed 's/[^0-9.]//g' | tr '.' ' ' | awk '{print $1*10000 + $2*100 + $3}')
    local latest_num=$(echo "$latest" | sed 's/[^0-9.]//g' | tr '.' ' ' | awk '{print $1*10000 + $2*100 + $3}')
    
    [[ $current_num -ge $latest_num ]]
}

download_and_extract_update() {
    local download_url="$1"
    local temp_dir="/tmp/twitter_scraper_update_$$"
    
    log_progress "Downloading latest version..."
    
    # Create temporary directory
    mkdir -p "$temp_dir"
    
    # Download the latest release
    local download_success=false
    if command_exists curl; then
        if curl -L -o "$temp_dir/update.zip" "$download_url" 2>/dev/null; then
            download_success=true
        fi
    elif command_exists wget; then
        if wget -O "$temp_dir/update.zip" "$download_url" 2>/dev/null; then
            download_success=true
        fi
    fi
    
    if [[ "$download_success" == false ]]; then
        log_error "Failed to download update"
        rm -rf "$temp_dir"
        return 1
    fi
    
    log_success "Download completed"
    
    # Extract the zip file
    log_progress "Extracting update..."
    
    if command_exists unzip; then
        cd "$temp_dir"
        if unzip -q update.zip; then
            log_success "Extraction completed"
        else
            log_error "Failed to extract update"
            rm -rf "$temp_dir"
            return 1
        fi
    else
        log_error "unzip command not found - cannot extract update"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Find extracted folder
    local extracted_folder=$(find "$temp_dir" -maxdepth 1 -type d -name "*Twitter*" | head -1)
    if [[ -z "$extracted_folder" ]]; then
        extracted_folder=$(find "$temp_dir" -maxdepth 1 -type d ! -name "." | head -1)
    fi
    
    if [[ -z "$extracted_folder" ]]; then
        log_error "Could not find extracted folder"
        rm -rf "$temp_dir"
        return 1
    fi
    
    echo "$extracted_folder"
    return 0
}

backup_current_version() {
    log_progress "Creating backup of current version..."
    
    # Create backup directory
    if mkdir -p "../$BACKUP_DIR"; then
        # Copy current project to backup
        if cp -r . "../$BACKUP_DIR/" 2>/dev/null; then
            log_success "Backup created: ../$BACKUP_DIR"
            return 0
        else
            log_warning "Failed to create backup"
            return 1
        fi
    else
        log_warning "Failed to create backup directory"
        return 1
    fi
}

apply_update() {
    local extracted_folder="$1"
    local temp_dir=$(dirname "$extracted_folder")
    
    log_progress "Applying update..."
    
    # Find the Original_Source folder in extracted content
    local source_folder="$extracted_folder/Original_Source"
    if [[ ! -d "$source_folder" ]]; then
        source_folder="$extracted_folder"
    fi
    
    if [[ ! -d "$source_folder" ]]; then
        log_error "Could not find source folder in update"
        rm -rf "$temp_dir"
        return 1
    fi
    
    # Preserve user data and configurations
    local preserve_files=(
        "Config.json"
        "venv/"
        "Exports/"
        "Logs/"
        "Sessions/"
        ".session_auth"
        ".env"
    )
    
    local temp_preserve="/tmp/preserve_$$"
    mkdir -p "$temp_preserve"
    
    # Backup user files
    for file in "${preserve_files[@]}"; do
        if [[ -e "$file" ]]; then
            cp -r "$file" "$temp_preserve/" 2>/dev/null || true
        fi
    done
    
    # Remove old files (except preserved ones)
    log_progress "Removing old files..."
    find . -maxdepth 1 -not -name "." -not -name ".." \
        -not -name "venv" -not -name "Exports" -not -name "Logs" \
        -not -name "Sessions" -not -name ".session_auth" -not -name ".env" \
        -not -name "Config.json" -exec rm -rf {} + 2>/dev/null || true
    
    # Copy new files
    log_progress "Installing new files..."
    if cp -r "$source_folder"/* . 2>/dev/null; then
        log_success "New files installed"
    else
        log_error "Failed to install new files"
        rm -rf "$temp_dir" "$temp_preserve"
        return 1
    fi
    
    # Restore preserved files
    log_progress "Restoring user data..."
    for file in "${preserve_files[@]}"; do
        if [[ -e "$temp_preserve/$file" ]]; then
            cp -r "$temp_preserve/$file" . 2>/dev/null || true
        fi
    done
    
    # Make scripts executable
    chmod +x Auto-Run.sh 2>/dev/null || true
    chmod +x Auto-Run-Replit.sh 2>/dev/null || true
    
    # Cleanup
    rm -rf "$temp_dir" "$temp_preserve"
    
    log_success "Update applied successfully!"
    return 0
}

perform_update() {
    log_progress "Starting automatic update process..."
    
    # Check for updates
    check_for_updates
    local update_status=$?
    
    case $update_status in
        0)
            log_info "No update needed"
            return 0
            ;;
        1)
            log_warning "Update check failed"
            return 1
            ;;
        2)
            log_success "Update available - proceeding with update"
            ;;
        *)
            log_error "Unknown update status"
            return 1
            ;;
    esac
    
    # Get download URL
    local latest_info
    if command_exists curl; then
        latest_info=$(curl -s "$GITHUB_API" 2>/dev/null)
    elif command_exists wget; then
        latest_info=$(wget -qO- "$GITHUB_API" 2>/dev/null)
    fi
    
    local download_url=$(echo "$latest_info" | grep '"zipball_url"' | cut -d'"' -f4 2>/dev/null)
    
    if [[ -z "$download_url" ]]; then
        log_error "Could not get download URL"
        return 1
    fi
    
    # Create backup
    backup_current_version || log_warning "Backup failed - continuing anyway"
    
    # Download and extract
    local extracted_folder
    extracted_folder=$(download_and_extract_update "$download_url")
    
    if [[ $? -ne 0 ]]; then
        log_error "Download/extraction failed"
        return 1
    fi
    
    # Apply update
    if apply_update "$extracted_folder"; then
        echo ""
        log_success "🎉 UPDATE COMPLETED SUCCESSFULLY! 🎉"
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${BOLD}${WHITE}                    ✨ UPDATE SUCCESSFUL! ✨                        ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}                                                                    ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  Your Twitter Scraper has been updated to the latest version!     ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  Backup saved in: ../$BACKUP_DIR${NC} ${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}                                                                    ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  🚀 Restarting with new version...                                ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        # Restart script with new version
        sleep 2
        exec bash Auto-Run.sh
    else
        log_error "Update failed - your original files should still be intact"
        return 1
    fi
}

# === PYTHON MANAGEMENT ===
get_python_command() {
    local python_cmd=""
    
    # Try different Python commands
    for cmd in python3.12 python3.11 python3 python; do
        if command_exists "$cmd"; then
            local version=$($cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
            local major=$(echo $version | cut -d. -f1)
            local minor=$(echo $version | cut -d. -f2)
            
            if [[ "$major" == "3" && "$minor" -ge "11" ]]; then
                python_cmd="$cmd"
                break
            fi
        fi
    done
    
    echo "$python_cmd"
}

install_python() {
    local os_type="$1"
    
    log_progress "Installing Python 3.11+..."
    
    case "$os_type" in
        "debian"|"wsl")
            sudo apt update -qq
            sudo apt install -y software-properties-common
            sudo add-apt-repository -y ppa:deadsnakes/ppa 2>/dev/null || true
            sudo apt update -qq
            sudo apt install -y python3.11 python3.11-venv python3.11-pip python3.11-dev
            ;;
        "rhel")
            sudo yum install -y python3.11 python3.11-pip python3.11-devel
            ;;
        "fedora")
            sudo dnf install -y python3.11 python3.11-pip python3.11-devel
            ;;
        "arch")
            sudo pacman -S --noconfirm python python-pip
            ;;
        "macos")
            if command_exists brew; then
                brew install python@3.11
            else
                log_error "Please install Homebrew first: /bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
                return 1
            fi
            ;;
        "windows_bash")
            log_error "Please install Python 3.11+ from https://python.org manually"
            return 1
            ;;
        *)
            log_error "Unsupported OS for automatic Python installation"
            return 1
            ;;
    esac
    
    log_success "Python installation completed"
}

# === DEPENDENCY MANAGEMENT ===
install_system_dependencies() {
    local os_type="$1"
    
    log_progress "Installing enhanced system dependencies..."
    
    case "$os_type" in
        "debian"|"wsl")
            # Update package index with retries
            for i in {1..3}; do
                sudo apt update -qq && break || {
                    log_warning "Package update failed, retrying... ($i/3)"
                    sleep 2
                }
            done
            
            # Install essential build tools and libraries
            sudo apt install -y \
                curl wget unzip build-essential \
                python3-pip python3-venv python3-dev python3-setuptools \
                software-properties-common apt-transport-https \
                ca-certificates gnupg lsb-release git \
                libnss3-dev libgconf-2-4 libxss1 \
                libappindicator1 fonts-liberation \
                libappindicator3-1 libasound2 libdrm2 \
                libxcomposite1 libxdamage1 libxrandr2 \
                libgbm1 libxkbcommon0 libgtk-3-0 \
                libxtst6 libxrandr2 libasound2 libpangocairo-1.0-0 \
                libatk1.0-0 libcairo-gobject2 libgtk-3-0 libgdk-pixbuf2.0-0 \
                xvfb x11-utils xfonts-100dpi xfonts-75dpi xfonts-scalable xfonts-cyrillic \
                libssl-dev libffi-dev libbz2-dev libreadline-dev libsqlite3-dev \
                pkg-config libxml2-dev libxmlsec1-dev libxmlsec1-openssl
            
            # Install additional Ubuntu/Debian specific packages
            sudo apt install -y \
                python3-distutils python3-tk \
                libjpeg-dev libpng-dev libtiff-dev \
                zlib1g-dev libfreetype6-dev liblcms2-dev \
                libwebp-dev tcl8.6-dev tk8.6-dev python3-tk \
                || log_warning "Some optional packages failed to install"
            ;;
        "rhel")
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools" "X Window System"
            sudo yum install -y \
                curl wget unzip python3-pip python3-devel python3-setuptools \
                epel-release git \
                nss libXScrnSaver gtk3 libappindicator-gtk3 \
                mesa-libgbm alsa-lib \
                openssl-devel libffi-devel bzip2-devel readline-devel \
                sqlite-devel xz-devel
            ;;
        "fedora")
            sudo dnf update -y
            sudo dnf groupinstall -y "Development Tools" "X Window System"
            sudo dnf install -y \
                curl wget unzip python3-pip python3-devel python3-setuptools \
                gtk3-devel libappindicator-gtk3 git \
                nss libXScrnSaver alsa-lib mesa-libgbm \
                openssl-devel libffi-devel bzip2-devel readline-devel \
                sqlite-devel xz-devel
            ;;
        "arch")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                curl wget unzip base-devel \
                python-pip gtk3 libappindicator-gtk3 git \
                nss libxss alsa-lib mesa \
                openssl libffi bzip2 readline sqlite xz
            ;;
        "macos")
            if command_exists brew; then
                brew install curl wget git pkg-config
                # Install Python build dependencies
                brew install openssl readline sqlite3 xz zlib
            else
                log_warning "Homebrew not found, some dependencies may be missing"
            fi
            ;;
        "windows_bash")
            log_info "Windows detected - checking for required tools..."
            # Check for Windows Subsystem for Linux
            if grep -qi microsoft /proc/version 2>/dev/null; then
                log_info "WSL detected - installing Linux dependencies"
                install_system_dependencies "debian"
                return $?
            else
                log_warning "Native Windows bash - please ensure Python and Git are installed manually"
            fi
            ;;
        *)
            log_warning "Unknown OS type: $os_type - attempting generic installation"
            # Try generic package managers
            if command_exists apt-get; then
                install_system_dependencies "debian"
            elif command_exists yum; then
                install_system_dependencies "rhel"
            elif command_exists dnf; then
                install_system_dependencies "fedora"
            elif command_exists pacman; then
                install_system_dependencies "arch"
            else
                log_error "No supported package manager found"
                return 1
            fi
            ;;
    esac
    
    log_success "Enhanced system dependencies installed"
}

# === BROWSER INSTALLATION ===
install_browser() {
    local os_type="$1"
    
    log_progress "Installing/checking web browser..."
    
    # Check if browser already exists
    local browser_found=false
    local browser_paths=()
    
    case "$os_type" in
        "debian"|"wsl")
            browser_paths=(
                "/usr/bin/google-chrome"
                "/usr/bin/google-chrome-stable"
                "/usr/bin/chromium-browser"
                "/usr/bin/chromium"
                "/snap/bin/chromium"
            )
            ;;
        "macos")
            browser_paths=(
                "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
                "/Applications/Chromium.app/Contents/MacOS/Chromium"
            )
            ;;
        "windows_bash")
            browser_paths=(
                "/c/Program Files/Google/Chrome/Application/chrome.exe"
                "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
                "/c/Program Files/Microsoft/Edge/Application/msedge.exe"
            )
            ;;
    esac
    
    # Check existing browsers
    for path in "${browser_paths[@]}"; do
        if [[ -f "$path" ]]; then
            browser_found=true
            log_success "Browser found: $path"
            break
        fi
    done
    
    # Install browser if not found
    if [[ "$browser_found" == false ]]; then
        case "$os_type" in
            "debian"|"wsl")
                log_progress "Installing Google Chrome..."
                wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 2>/dev/null || true
                echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
                sudo apt update -qq
                sudo apt install -y google-chrome-stable || {
                    log_warning "Chrome installation failed, trying Chromium..."
                    sudo apt install -y chromium-browser
                }
                ;;
            "rhel"|"fedora")
                log_progress "Installing Chromium..."
                if [[ "$os_type" == "fedora" ]]; then
                    sudo dnf install -y chromium
                else
                    sudo yum install -y chromium
                fi
                ;;
            "arch")
                sudo pacman -S --noconfirm chromium
                ;;
            "macos")
                if command_exists brew; then
                    brew install --cask google-chrome
                else
                    log_warning "Please install Chrome manually from https://www.google.com/chrome/"
                fi
                ;;
            "windows_bash")
                log_warning "Please install Chrome or Edge manually from their official websites"
                ;;
        esac
        log_success "Browser installation completed"
    fi
}

# === PYTHON ENVIRONMENT SETUP ===
setup_python_environment() {
    local python_cmd="$1"
    
    log_progress "Setting up enhanced Python environment..."
    
    # Upgrade pip with retries
    local pip_upgrade_success=false
    for i in {1..3}; do
        if $python_cmd -m pip install --upgrade pip --quiet --no-warn-script-location; then
            pip_upgrade_success=true
            break
        else
            log_warning "Pip upgrade failed, retrying... ($i/3)"
            sleep 2
        fi
    done
    
    if [[ "$pip_upgrade_success" == false ]]; then
        log_warning "Pip upgrade failed, continuing with existing version"
    fi
    
    # Install essential Python tools
    $python_cmd -m pip install --quiet --no-warn-script-location setuptools wheel virtualenv || {
        log_warning "Failed to install essential Python tools, continuing..."
    }
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        log_progress "Creating virtual environment..."
        
        # Try different methods to create virtual environment
        if $python_cmd -m venv venv; then
            log_success "Virtual environment created with venv"
        elif $python_cmd -m virtualenv venv; then
            log_success "Virtual environment created with virtualenv"
        elif python3 -m venv venv; then
            log_success "Virtual environment created with python3 venv"
        else
            log_warning "Failed to create virtual environment, using system Python"
            return 0
        fi
    else
        log_info "Virtual environment already exists"
    fi
    
    # Activate virtual environment with multiple attempts
    local venv_activated=false
    
    # Try different activation scripts
    for activate_script in "venv/bin/activate" "venv/Scripts/activate"; do
        if [[ -f "$activate_script" ]]; then
            if source "$activate_script" 2>/dev/null; then
                venv_activated=true
                log_success "Virtual environment activated: $activate_script"
                break
            fi
        fi
    done
    
    if [[ "$venv_activated" == false ]]; then
        log_warning "Failed to activate virtual environment, using system Python"
        # Set PATH to use venv python directly if available
        if [[ -f "venv/bin/python" ]]; then
            export PATH="$(pwd)/venv/bin:$PATH"
            log_info "Using venv Python directly"
        elif [[ -f "venv/Scripts/python.exe" ]]; then
            export PATH="$(pwd)/venv/Scripts:$PATH"
            log_info "Using Windows venv Python directly"
        fi
    fi
    
    # Verify Python environment
    local current_python
    if [[ "$venv_activated" == true ]]; then
        current_python="python"
    elif [[ -f "venv/bin/python" ]]; then
        current_python="venv/bin/python"
    elif [[ -f "venv/Scripts/python.exe" ]]; then
        current_python="venv/Scripts/python.exe"
    else
        current_python="$python_cmd"
    fi
    
    log_info "Python environment ready: $($current_python --version 2>&1)"
    log_success "Enhanced Python environment setup completed"
}

# === ENHANCED DEPENDENCY INSTALLATION ===
install_python_dependencies() {
    log_progress "Installing enhanced Python dependencies..."
    
    # Determine the correct pip command
    local pip_cmd="pip"
    if command_exists pip3; then
        pip_cmd="pip3"
    fi
    
    # If we're in a virtual environment, use the venv pip
    if [[ -f "venv/bin/pip" ]]; then
        pip_cmd="venv/bin/pip"
    elif [[ -f "venv/Scripts/pip.exe" ]]; then
        pip_cmd="venv/Scripts/pip.exe"
    fi
    
    log_info "Using pip command: $pip_cmd"
    
    # Ensure pip is up to date
    $pip_cmd install --upgrade pip setuptools wheel --quiet || {
        log_warning "Failed to upgrade pip/setuptools, continuing..."
    }
    
    # Critical packages with specific versions and fallbacks
    local core_packages=(
        "selenium>=4.20.0"
        "rich>=13.0.0"
        "pandas>=2.0.0"
        "cryptography>=41.0.0"
        "requests>=2.31.0"
        "beautifulsoup4>=4.12.0"
        "lxml>=4.9.0"
        "pyfiglet>=0.8.0"
        "trafilatura>=1.6.0"
        "sendgrid>=6.9.0"
    )
    
    # Additional helpful packages
    local optional_packages=(
        "urllib3>=1.26.0"
        "certifi>=2023.5.7"
        "charset-normalizer>=3.1.0"
        "idna>=3.4"
        "webdriver-manager>=3.8.0"
        "fake-useragent>=1.2.0"
    )
    
    # Method 1: Try installing from requirements.txt with multiple strategies
    if [[ -f "requirements.txt" ]]; then
        log_progress "Method 1: Installing from requirements.txt..."
        
        # Strategy 1: Direct installation
        if $pip_cmd install -r requirements.txt --no-cache-dir --quiet --timeout 300; then
            log_success "Successfully installed from requirements.txt"
        else
            log_warning "requirements.txt installation failed, trying alternative methods..."
            
            # Strategy 2: Install with --force-reinstall
            if $pip_cmd install -r requirements.txt --force-reinstall --no-cache-dir --quiet --timeout 300; then
                log_success "Successfully installed from requirements.txt with --force-reinstall"
            else
                log_warning "requirements.txt installation failed completely, falling back to individual packages"
            fi
        fi
    fi
    
    # Method 2: Install core packages individually with fallbacks
    log_progress "Method 2: Installing core packages individually..."
    
    local core_success=0
    local total_core=${#core_packages[@]}
    
    for package in "${core_packages[@]}"; do
        local package_name=$(echo "$package" | cut -d'>' -f1 | cut -d'=' -f1 | cut -d'[' -f1)
        local install_success=false
        
        log_progress "Installing $package_name..."
        
        # Strategy 1: Install with version constraint
        if $pip_cmd install "$package" --no-cache-dir --quiet --timeout 180; then
            install_success=true
            log_success "✓ $package_name installed with constraints"
        else
            # Strategy 2: Install latest version without constraints
            if $pip_cmd install "$package_name" --no-cache-dir --quiet --timeout 180; then
                install_success=true
                log_success "✓ $package_name installed (latest version)"
            else
                # Strategy 3: Install with --user flag (fallback)
                if $pip_cmd install "$package_name" --user --no-cache-dir --quiet --timeout 180; then
                    install_success=true
                    log_warning "✓ $package_name installed with --user flag"
                else
                    log_error "✗ Failed to install $package_name"
                fi
            fi
        fi
        
        if [[ "$install_success" == true ]]; then
            ((core_success++))
        fi
        
        # Small delay to prevent overwhelming the system
        sleep 0.5
    done
    
    # Method 3: Install optional packages (best effort)
    log_progress "Method 3: Installing optional packages..."
    
    local optional_success=0
    for package in "${optional_packages[@]}"; do
        local package_name=$(echo "$package" | cut -d'>' -f1 | cut -d'=' -f1 | cut -d'[' -f1)
        
        if $pip_cmd install "$package" --no-cache-dir --quiet --timeout 120 2>/dev/null; then
            ((optional_success++))
            log_info "✓ Optional: $package_name"
        fi
    done
    
    # Method 4: Verify critical imports
    log_progress "Method 4: Verifying critical imports..."
    
    local critical_imports=("selenium" "rich" "pandas" "cryptography" "requests" "bs4")
    local import_success=0
    
    for module in "${critical_imports[@]}"; do
        if $pip_cmd show "${module/bs4/beautifulsoup4}" >/dev/null 2>&1; then
            ((import_success++))
            log_success "✓ $module verified"
        else
            log_warning "✗ $module not found"
        fi
    done
    
    # Results summary
    log_info "Installation Summary:"
    log_info "  Core packages: $core_success/$total_core installed"
    log_info "  Optional packages: $optional_success/${#optional_packages[@]} installed"
    log_info "  Critical imports: $import_success/${#critical_imports[@]} verified"
    
    # Success criteria: At least 80% of core packages and 50% of critical imports
    if [[ $core_success -ge $((total_core * 80 / 100)) && $import_success -ge $((${#critical_imports[@]} * 50 / 100)) ]]; then
        log_success "Enhanced Python dependencies installation completed successfully!"
        return 0
    else
        log_error "Dependency installation failed - insufficient critical packages installed"
        log_error "Core packages required: $((total_core * 80 / 100)), got: $core_success"
        log_error "Critical imports required: $((${#critical_imports[@]} * 50 / 100)), got: $import_success"
        return 1
    fi
}

# === DIRECTORY SETUP ===
# Directories are created automatically by the application when needed

# === COMPREHENSIVE SYSTEM VERIFICATION ===
verify_installation() {
    log_progress "Performing comprehensive system verification..."
    
    local verification_errors=0
    local python_cmd=""
    
    # Step 1: Find the correct Python command
    if [[ -f "venv/bin/python" ]]; then
        python_cmd="venv/bin/python"
        log_success "✓ Virtual environment Python found"
    elif [[ -f "venv/Scripts/python.exe" ]]; then
        python_cmd="venv/Scripts/python.exe"
        log_success "✓ Windows virtual environment Python found"
    else
        python_cmd=$(get_python_command)
        if [[ -n "$python_cmd" ]]; then
            log_warning "⚠ Using system Python: $python_cmd"
        else
            log_error "✗ No suitable Python found"
            ((verification_errors++))
        fi
    fi
    
    # Step 2: Verify Python version
    if [[ -n "$python_cmd" ]]; then
        local py_version=$($python_cmd -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null || echo "0.0")
        local major=$(echo $py_version | cut -d. -f1)
        local minor=$(echo $py_version | cut -d. -f2)
        
        if [[ "$major" == "3" && "$minor" -ge "8" ]]; then
            log_success "✓ Python version: $py_version (compatible)"
        else
            log_error "✗ Python version: $py_version (requires 3.8+)"
            ((verification_errors++))
        fi
    fi
    
    # Step 3: Test critical module imports with detailed feedback
    log_progress "Testing critical module imports..."
    
    local critical_modules=(
        "selenium:Selenium WebDriver"
        "rich:Rich console library"
        "pandas:Pandas data analysis"
        "cryptography:Cryptography library"
        "requests:HTTP requests library"
        "bs4:BeautifulSoup HTML parsing"
        "lxml:LXML XML/HTML parser"
        "pyfiglet:PyFiglet ASCII art"
    )
    
    local module_success=0
    local total_modules=${#critical_modules[@]}
    
    for module_info in "${critical_modules[@]}"; do
        local module_name=$(echo "$module_info" | cut -d':' -f1)
        local module_desc=$(echo "$module_info" | cut -d':' -f2)
        
        local test_script="
import sys
try:
    import $module_name
    print('SUCCESS')
    sys.exit(0)
except ImportError as e:
    print(f'ERROR: {e}')
    sys.exit(1)
except Exception as e:
    print(f'UNEXPECTED_ERROR: {e}')
    sys.exit(2)
"
        
        local result=$($python_cmd -c "$test_script" 2>&1)
        if [[ $? -eq 0 && "$result" == "SUCCESS" ]]; then
            log_success "✓ $module_desc"
            ((module_success++))
        else
            log_error "✗ $module_desc - $result"
            ((verification_errors++))
        fi
    done
    
    # Step 4: Test Selenium WebDriver functionality
    log_progress "Testing Selenium WebDriver functionality..."
    
    local selenium_test='
import sys
try:
    from selenium import webdriver
    from selenium.webdriver.chrome.options import Options
    from selenium.webdriver.chrome.service import Service
    from selenium.webdriver.common.by import By
    
    # Test Chrome options creation
    options = Options()
    options.add_argument("--headless")
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    
    print("SUCCESS: Selenium WebDriver configuration verified")
    sys.exit(0)
except ImportError as e:
    print(f"IMPORT_ERROR: {e}")
    sys.exit(1)
except Exception as e:
    print(f"CONFIG_ERROR: {e}")
    sys.exit(2)
'
    
    local selenium_result=$($python_cmd -c "$selenium_test" 2>&1)
    if [[ $? -eq 0 ]]; then
        log_success "✓ Selenium WebDriver configuration verified"
    else
        log_warning "⚠ Selenium WebDriver test failed: $selenium_result"
        # This is a warning, not a critical error for basic functionality
    fi
    
    # Step 5: Check for browser availability
    log_progress "Checking browser availability..."
    
    local browser_paths=(
        "/usr/bin/google-chrome"
        "/usr/bin/google-chrome-stable" 
        "/usr/bin/chromium-browser"
        "/usr/bin/chromium"
        "/snap/bin/chromium"
        "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
        "/Applications/Chromium.app/Contents/MacOS/Chromium"
        "/c/Program Files/Google/Chrome/Application/chrome.exe"
        "/c/Program Files (x86)/Google/Chrome/Application/chrome.exe"
    )
    
    local browser_found=false
    for browser_path in "${browser_paths[@]}"; do
        if [[ -f "$browser_path" || -x "$browser_path" ]]; then
            browser_found=true
            log_success "✓ Browser found: $browser_path"
            break
        fi
    done
    
    if [[ "$browser_found" == false ]]; then
        # Check if browser is in PATH
        for browser_cmd in google-chrome google-chrome-stable chromium-browser chromium chrome; do
            if command_exists "$browser_cmd"; then
                browser_found=true
                log_success "✓ Browser found in PATH: $browser_cmd"
                break
            fi
        done
    fi
    
    if [[ "$browser_found" == false ]]; then
        log_warning "⚠ No browser found - web scraping may not work properly"
        # This is a warning for functionality, not a critical installation error
    fi
    
    # Step 6: Check project files
    log_progress "Checking project files..."
    
    local required_files=(
        "Run.py:Main application script"
        "Config.json:Configuration file"
        "Update.json:Version information"
        "requirements.txt:Python dependencies"
        "pyproject.toml:Project metadata"
    )
    
    local file_success=0
    for file_info in "${required_files[@]}"; do
        local file_name=$(echo "$file_info" | cut -d':' -f1)
        local file_desc=$(echo "$file_info" | cut -d':' -f2)
        
        if [[ -f "$file_name" ]]; then
            log_success "✓ $file_desc: $file_name"
            ((file_success++))
        else
            log_warning "⚠ Missing $file_desc: $file_name"
        fi
    done
    
    # Step 7: Test basic application startup
    log_progress "Testing basic application startup..."
    
    local startup_test='
import sys
import os
sys.path.insert(0, os.getcwd())

try:
    # Test basic imports from our application
    from Utils.Config import Config
    from Utils.Version_Manager import get_current_version
    
    # Test configuration loading
    config = Config()
    version = get_current_version()
    
    print(f"SUCCESS: Application startup test passed - Version: {version}")
    sys.exit(0)
except ImportError as e:
    print(f"IMPORT_ERROR: {e}")
    sys.exit(1)
except Exception as e:
    print(f"STARTUP_ERROR: {e}")
    sys.exit(2)
'
    
    local startup_result=$($python_cmd -c "$startup_test" 2>&1)
    if [[ $? -eq 0 ]]; then
        log_success "✓ Application startup test passed"
        log_info "  $(echo "$startup_result" | grep "SUCCESS")"
    else
        log_error "✗ Application startup test failed: $startup_result"
        ((verification_errors++))
    fi
    
    # Final verification summary
    log_progress "Verification Summary:"
    log_info "  Python modules: $module_success/$total_modules verified"
    log_info "  Project files: $file_success/${#required_files[@]} found"
    log_info "  Total verification errors: $verification_errors"
    
    # Success criteria: No critical verification errors
    if [[ $verification_errors -eq 0 ]]; then
        log_success "🎉 Comprehensive system verification PASSED!"
        log_success "All critical components verified and ready to use"
        return 0
    else
        log_error "❌ System verification FAILED with $verification_errors critical errors"
        log_error "Please review the errors above and run the installer again"
        return 1
    fi
}

# === STATUS DISPLAY ===
display_system_status() {
    local os_type="$1"
    local python_cmd="$2"
    
    echo ""
    echo -e "${BLUE}╔════════════════ SYSTEM STATUS ════════════════╗${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Operating System: ${GREEN}$os_type${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Python Command:   ${GREEN}$python_cmd${NC} ${BLUE}║${NC}"
    
    if [[ -n "$python_cmd" ]]; then
        local py_version=$($python_cmd --version 2>/dev/null | cut -d' ' -f2)
        echo -e "${BLUE}║${NC} ${WHITE}Python Version:   ${GREEN}$py_version${NC} ${BLUE}║${NC}"
    fi
    
    local browser_status="Not Found"
    for path in "/usr/bin/google-chrome" "/usr/bin/chromium-browser" "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"; do
        if [[ -f "$path" ]]; then
            browser_status="Available"
            break
        fi
    done
    echo -e "${BLUE}║${NC} ${WHITE}Browser:          ${GREEN}$browser_status${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Virtual Env:      ${GREEN}$([ -d venv ] && echo 'Created' || echo 'System')${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${NC} ${WHITE}Directories:      ${GREEN}Auto-created by app${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════╝${NC}"
    echo ""
}

# === MAIN INSTALLATION FUNCTION ===
run_installation() {
    local os_type=$(detect_os)
    local python_cmd=$(get_python_command)
    
    log_info "Detected OS: $os_type"
    
    # Step 1: Install Python if needed
    if [[ -z "$python_cmd" ]]; then
        log_warning "Python 3.11+ not found, installing..."
        install_python "$os_type" || return 1
        python_cmd=$(get_python_command)
        
        if [[ -z "$python_cmd" ]]; then
            log_error "Python installation failed"
            return 1
        fi
    fi
    
    log_success "Python available: $python_cmd"
    
    # Step 2: Install system dependencies
    install_system_dependencies "$os_type" || log_warning "Some system dependencies may have failed"
    
    # Step 3: Install browser
    install_browser "$os_type" || log_warning "Browser installation may have failed"
    
    # Step 4: Setup Python environment
    setup_python_environment "$python_cmd" || return 1
    
    # Step 5: Install Python dependencies
    install_python_dependencies || return 1
    
    # Step 6: Directories will be created automatically by the application
    
    # Step 7: Verify installation
    verify_installation || return 1
    
    # Display status
    display_system_status "$os_type" "$python_cmd"
    
    return 0
}

# === COMPREHENSIVE ERROR RECOVERY ===
perform_error_recovery() {
    local error_type="$1"
    
    log_warning "Performing error recovery for: $error_type"
    
    case "$error_type" in
        "python_missing")
            log_progress "Attempting Python installation recovery..."
            local os_type=$(detect_os)
            install_python "$os_type"
            ;;
        "dependencies_failed")
            log_progress "Attempting dependency installation recovery..."
            # Clear pip cache
            pip cache purge 2>/dev/null || true
            # Try alternative installation methods
            install_python_dependencies
            ;;
        "browser_missing")
            log_progress "Attempting browser installation recovery..."
            local os_type=$(detect_os)
            install_browser "$os_type"
            ;;
        "venv_corrupted")
            log_progress "Recreating virtual environment..."
            rm -rf venv 2>/dev/null || true
            local python_cmd=$(get_python_command)
            setup_python_environment "$python_cmd"
            ;;
        *)
            log_warning "Unknown error type, attempting generic recovery..."
            ;;
    esac
}

# === SYSTEM HEALTH CHECK ===
system_health_check() {
    log_progress "Performing system health check..."
    
    local health_issues=()
    
    # Check disk space
    local available_space=$(df . | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then # Less than 1GB
        health_issues+=("LOW_DISK_SPACE:Available space: ${available_space}KB")
    fi
    
    # Check memory
    if command_exists free; then
        local available_memory=$(free -m | awk 'NR==2{print $7}')
        if [[ $available_memory -lt 512 ]]; then # Less than 512MB
            health_issues+=("LOW_MEMORY:Available memory: ${available_memory}MB")
        fi
    fi
    
    # Check network connectivity
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        health_issues+=("NETWORK_ISSUE:Cannot reach internet")
    fi
    
    # Check write permissions
    if ! touch .permission_test 2>/dev/null; then
        health_issues+=("PERMISSION_ISSUE:Cannot write to current directory")
    else
        rm -f .permission_test 2>/dev/null
    fi
    
    # Report health issues
    if [[ ${#health_issues[@]} -gt 0 ]]; then
        log_warning "System health issues detected:"
        for issue in "${health_issues[@]}"; do
            local issue_type=$(echo "$issue" | cut -d':' -f1)
            local issue_desc=$(echo "$issue" | cut -d':' -f2)
            log_warning "  $issue_type: $issue_desc"
        done
        return 1
    else
        log_success "System health check passed"
        return 0
    fi
}

# === ENHANCED APPLICATION RUNNER ===
run_application() {
    log_progress "Preparing to start Twitter Scraper..."
    
    # Pre-flight system check
    system_health_check || log_warning "System health issues detected, continuing anyway..."
    
    # Determine the best Python command to use
    local python_cmd=""
    local python_source=""
    
    # Priority 1: Virtual environment Python
    if [[ -f "venv/bin/python" ]]; then
        # Try to activate virtual environment
        if source venv/bin/activate 2>/dev/null; then
            python_cmd="python"
            python_source="Virtual environment (activated)"
            log_success "✓ Using virtual environment Python"
        else
            python_cmd="venv/bin/python"
            python_source="Virtual environment (direct)"
            log_info "Using virtual environment Python directly"
        fi
    elif [[ -f "venv/Scripts/python.exe" ]]; then
        python_cmd="venv/Scripts/python.exe"
        python_source="Windows virtual environment"
        log_info "Using Windows virtual environment Python"
    else
        # Priority 2: System Python
        python_cmd=$(get_python_command)
        python_source="System Python"
        log_warning "Using system Python (virtual environment not available)"
    fi
    
    # Validate Python command
    if [[ -z "$python_cmd" ]]; then
        log_error "❌ No suitable Python interpreter found"
        perform_error_recovery "python_missing"
        return 1
    fi
    
    # Validate Run.py existence
    if [[ ! -f "Run.py" ]]; then
        log_error "❌ Run.py not found in current directory"
        log_error "Please ensure you're running this script from the project root directory"
        return 1
    fi
    
    # Quick dependency check
    local dependency_check=$($python_cmd -c "
try:
    import selenium, rich, requests, pandas, cryptography
    print('DEPENDENCIES_OK')
except ImportError as e:
    print(f'MISSING_DEPENDENCY:{e}')
except Exception as e:
    print(f'DEPENDENCY_ERROR:{e}')
" 2>&1)
    
    if [[ "$dependency_check" != "DEPENDENCIES_OK" ]]; then
        log_warning "⚠ Dependency issue detected: $dependency_check"
        log_progress "Attempting to fix dependencies..."
        perform_error_recovery "dependencies_failed"
        
        # Retry dependency check
        dependency_check=$($python_cmd -c "
try:
    import selenium, rich, requests, pandas, cryptography
    print('DEPENDENCIES_OK')
except ImportError as e:
    print(f'MISSING_DEPENDENCY:{e}')
" 2>&1)
        
        if [[ "$dependency_check" != "DEPENDENCIES_OK" ]]; then
            log_error "❌ Critical dependencies still missing after recovery attempt"
            log_error "Please run the installer again or install dependencies manually"
            return 1
        fi
    fi
    
    # Display startup information
    echo ""
    log_success "🚀 Starting Twitter Scraper Application"
    echo ""
    echo -e "${BLUE}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${BLUE}║${BOLD}${WHITE}                   🎯 APPLICATION STARTUP                           ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                                                                    ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}  Python Source: ${GREEN}$python_source${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}  Python Version: ${GREEN}$($python_cmd --version 2>&1)${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}  Working Directory: ${GREEN}$(pwd)${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}  OS Details: ${GREEN}${DETECTED_OS_DETAILS:-"Unknown"}${NC} ${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}                                                                    ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}║${WHITE}  🌟 All systems ready - launching application...                  ${NC}${BLUE}║${NC}"
    echo -e "${BLUE}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # Set up environment variables for the application
    export PYTHON_CMD="$python_cmd"
    export INSTALLATION_METHOD="Auto-Run.sh Enhanced"
    export INSTALLATION_DATE=$(date -u +"%Y-%m-%dT%H:%M:%S.%6NZ")
    
    # Launch the application with error handling
    log_info "Executing: $python_cmd Run.py"
    echo ""
    
    # Trap signals for graceful shutdown
    trap 'echo -e "\n${YELLOW}${WARNING} Application interrupted by user${NC}"; exit 130' INT TERM
    
    # Execute the application
    if $python_cmd Run.py; then
        log_success "✅ Application completed successfully"
        return 0
    else
        local exit_code=$?
        log_error "❌ Application exited with code: $exit_code"
        
        # Provide helpful error messages based on exit code
        case $exit_code in
            1)
                log_error "General error - check application logs for details"
                ;;
            2)
                log_error "Misuse of shell command or invalid argument"
                ;;
            126)
                log_error "Command invoked cannot execute (permission problem)"
                ;;
            127)
                log_error "Command not found or PATH issue"
                ;;
            130)
                log_warning "Application interrupted by user (Ctrl+C)"
                ;;
            *)
                log_error "Application error - exit code $exit_code"
                ;;
        esac
        
        return $exit_code
    fi
}

# === ARGUMENT PARSING ===
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            --update|-u)
                UPDATE_MODE=true
                shift
                ;;
            --help|-h)
                show_help
                exit 0
                ;;
            *)
                log_warning "Unknown argument: $1"
                shift
                ;;
        esac
    done
}

show_help() {
    echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║${BOLD}${WHITE}                🚀 TWITTER SCRAPER HELP                             ${NC}${CYAN}║${NC}"
    echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "${WHITE}Usage: ${CYAN}bash Auto-Run.sh [OPTIONS]${NC}"
    echo ""
    echo -e "${WHITE}Options:${NC}"
    echo -e "  ${CYAN}--update, -u${NC}     Update to latest version from GitHub"
    echo -e "  ${CYAN}--help, -h${NC}       Show this help message"
    echo ""
    echo -e "${WHITE}Examples:${NC}"
    echo -e "  ${CYAN}bash Auto-Run.sh${NC}          # Normal installation and run"
    echo -e "  ${CYAN}bash Auto-Run.sh --update${NC} # Update to latest version"
    echo ""
    echo -e "${WHITE}Developer: ARMIN-SOFT${NC}"
    echo -e "${WHITE}Website: https://armin-soft.ir/${NC}"
}

# === MAIN FUNCTION ===
main() {
    # Parse command line arguments
    parse_arguments "$@"
    
    # Handle update mode
    if [[ "$UPDATE_MODE" == true ]]; then
        print_header
        log_info "Starting update process..."
        echo ""
        
        if perform_update; then
            exit 0
        else
            log_error "Update failed"
            exit 1
        fi
    fi
    
    print_header
    
    log_info "Starting automatic installation process..."
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "Run.py" ]]; then
        log_error "Run.py not found. Please run this script from the project root directory."
        exit 1
    fi
    
    # Check for updates (non-blocking)
    log_progress "Quick update check..."
    check_for_updates
    local update_status=$?
    if [[ $update_status -eq 2 ]]; then
        echo ""
        log_warning "🆕 A new version is available!"
        log_info "Run 'bash Auto-Run.sh --update' to update automatically"
        echo ""
        sleep 3
    fi
    
    # Run installation
    if run_installation; then
        echo ""
        log_success "✨ INSTALLATION COMPLETED SUCCESSFULLY! ✨"
        echo ""
        echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${GREEN}║${BOLD}${WHITE}                    🎉 READY TO RUN! 🎉                            ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}                                                                    ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  Your Twitter Scraper is fully installed and ready to use!       ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  Starting the application automatically...                        ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}                                                                    ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}║${WHITE}  Support: https://armin-soft.ir/                                  ${NC}${GREEN}║${NC}"
        echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
        echo ""
        
        sleep 2
        run_application
    else
        echo ""
        log_error "❌ INSTALLATION FAILED"
        echo ""
        echo -e "${RED}╔════════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${RED}║${BOLD}${WHITE}                    ⚠ INSTALLATION ISSUES ⚠                       ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}                                                                    ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  Please check the error messages above and try again.            ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  For support, visit: https://armin-soft.ir/                      ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}                                                                    ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  You can try running individual components manually:             ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  1. Install Python 3.11+ manually                               ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  2. Install Chrome/Chromium browser                              ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  3. Run: pip install -r requirements.txt                        ${NC}${RED}║${NC}"
        echo -e "${RED}║${WHITE}  4. Run: python Run.py                                           ${NC}${RED}║${NC}"
        echo -e "${RED}╚════════════════════════════════════════════════════════════════════╝${NC}"
        exit 1
    fi
}

# === SCRIPT EXECUTION ===
# Initialize variables
UPDATE_MODE=false

# Trap to handle interruption
trap 'echo -e "\n${YELLOW}${WARNING} Process cancelled by user${NC}"; exit 1' INT TERM

# Run main function with all arguments
main "$@"