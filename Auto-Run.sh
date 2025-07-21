#!/bin/bash

# =================================================================
# 🚀 TWITTER SCRAPER - UNIVERSAL AUTO INSTALLER & RUNNER 🚀
# Developer: ARMIN-SOFT
# Website: https://armin-soft.ir/
# Version: 1.3.0
# 
# ✨ FULLY AUTOMATED CROSS-PLATFORM INSTALLATION ✨
# This script automatically detects your OS and installs everything:
# - Python 3.11+ (if not available)
# - All required dependencies
# - Chrome/Chromium browser
# - Virtual environment setup
# - Directory structure
# - Runs the application
#
# Compatible: Linux, Ubuntu, Debian, RHEL, CentOS, macOS, Windows (WSL/Git Bash/MSYS2)
# =================================================================

set -e  # Exit immediately on error

# === CONFIGURATION ===
SCRIPT_VERSION="1.3.0"
REQUIRED_PYTHON="3.11"
AUTO_MODE=true
SKIP_CONFIRMATIONS=true

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

# === OS DETECTION ===
detect_os() {
    local os_type=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if command_exists apt-get; then
            os_type="debian"
        elif command_exists yum; then
            os_type="rhel"
        elif command_exists dnf; then
            os_type="fedora"
        elif command_exists pacman; then
            os_type="arch"
        else
            os_type="linux"
        fi
        
        # Check for WSL
        if grep -qi microsoft /proc/version 2>/dev/null || [[ -n "${WSL_DISTRO_NAME}" ]]; then
            os_type="wsl"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_type="macos"
    elif [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
        os_type="windows_bash"
    elif [[ -n "$WINDIR" || -n "$windir" || -n "$SYSTEMROOT" ]]; then
        os_type="windows_bash"
    else
        os_type="unknown"
    fi
    
    echo "$os_type"
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
    
    log_progress "Installing system dependencies..."
    
    case "$os_type" in
        "debian"|"wsl")
            sudo apt update -qq
            sudo apt install -y \
                curl wget unzip build-essential \
                python3-pip python3-venv python3-dev \
                software-properties-common apt-transport-https \
                ca-certificates gnupg lsb-release \
                libnss3-dev libgconf-2-4 libxss1 \
                libappindicator1 fonts-liberation \
                libappindicator3-1 libasound2 libdrm2 \
                libxcomposite1 libxdamage1 libxrandr2 \
                libgbm1 libxkbcommon0 libgtk-3-0
            ;;
        "rhel")
            sudo yum update -y
            sudo yum groupinstall -y "Development Tools"
            sudo yum install -y \
                curl wget unzip python3-pip python3-devel \
                epel-release
            ;;
        "fedora")
            sudo dnf update -y
            sudo dnf groupinstall -y "Development Tools"
            sudo dnf install -y \
                curl wget unzip python3-pip python3-devel \
                gtk3-devel libappindicator-gtk3
            ;;
        "arch")
            sudo pacman -Syu --noconfirm
            sudo pacman -S --noconfirm \
                curl wget unzip base-devel \
                python-pip gtk3 libappindicator-gtk3
            ;;
        "macos")
            if command_exists brew; then
                brew install curl wget
            fi
            ;;
        "windows_bash")
            log_info "System dependencies should be managed through Windows package managers"
            ;;
    esac
    
    log_success "System dependencies installed"
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
    
    log_progress "Setting up Python environment..."
    
    # Upgrade pip
    $python_cmd -m pip install --upgrade pip --quiet
    
    # Create virtual environment if it doesn't exist
    if [[ ! -d "venv" ]]; then
        log_progress "Creating virtual environment..."
        $python_cmd -m venv venv
        log_success "Virtual environment created"
    else
        log_info "Virtual environment already exists"
    fi
    
    # Activate virtual environment
    source venv/bin/activate 2>/dev/null || {
        log_warning "Failed to activate virtual environment, using system Python"
        return 0
    }
    
    log_success "Python environment ready"
}

# === DEPENDENCY INSTALLATION ===
install_python_dependencies() {
    log_progress "Installing Python dependencies..."
    
    # Critical packages list
    local packages=(
        "selenium>=4.34.2"
        "rich>=14.0.0"
        "pandas>=2.3.1"
        "cryptography>=45.0.5"
        "requests>=2.32.4"
        "beautifulsoup4>=4.13.4"
        "lxml>=5.4.0"
        "pyfiglet>=1.0.3"
        "trafilatura>=2.0.0"
    )
    
    # Try installing from requirements.txt first
    if [[ -f "requirements.txt" ]]; then
        log_progress "Installing from requirements.txt..."
        pip install -r requirements.txt --no-cache-dir --quiet || {
            log_warning "requirements.txt installation failed, installing packages individually..."
        }
    fi
    
    # Install packages individually
    local success_count=0
    for package in "${packages[@]}"; do
        if pip install "$package" --no-cache-dir --quiet; then
            ((success_count++))
        else
            log_warning "Failed to install: $package"
        fi
    done
    
    if [[ $success_count -ge 7 ]]; then
        log_success "Python dependencies installed ($success_count/${#packages[@]})"
    else
        log_error "Too many dependency failures ($success_count/${#packages[@]})"
        return 1
    fi
}

# === DIRECTORY SETUP ===
# Directories are created automatically by the application when needed

# === VERIFICATION ===
verify_installation() {
    log_progress "Verifying installation..."
    
    local python_cmd
    if [[ -f "venv/bin/python" ]]; then
        python_cmd="venv/bin/python"
    else
        python_cmd=$(get_python_command)
    fi
    
    if [[ -z "$python_cmd" ]]; then
        log_error "Python not found"
        return 1
    fi
    
    # Test imports
    local test_script='
try:
    import selenium, rich, pandas, cryptography, requests
    print("SUCCESS: All critical modules working")
except ImportError as e:
    print(f"ERROR: {e}")
    exit(1)
'
    
    if $python_cmd -c "$test_script" >/dev/null 2>&1; then
        log_success "All modules verified successfully"
        return 0
    else
        log_error "Module verification failed"
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

# === APPLICATION RUNNER ===
run_application() {
    log_progress "Starting Twitter Scraper..."
    echo ""
    
    # Determine Python command
    local python_cmd
    if [[ -f "venv/bin/python" ]]; then
        source venv/bin/activate 2>/dev/null
        python_cmd="python"
    else
        python_cmd=$(get_python_command)
    fi
    
    if [[ -z "$python_cmd" || ! -f "Run.py" ]]; then
        log_error "Cannot start application - missing Python or Run.py"
        return 1
    fi
    
    # Run the application
    exec $python_cmd Run.py
}

# === MAIN FUNCTION ===
main() {
    print_header
    
    log_info "Starting automatic installation process..."
    echo ""
    
    # Check if we're in the right directory
    if [[ ! -f "Run.py" ]]; then
        log_error "Run.py not found. Please run this script from the project root directory."
        exit 1
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
# Trap to handle interruption
trap 'echo -e "\n${YELLOW}${WARNING} Installation cancelled by user${NC}"; exit 1' INT TERM

# Run main function
main "$@"