#!/bin/bash

# ================================================================
# TWITTER SCRAPER - ARMIN-SOFT
# Licensed Auto Installation & Setup Script
# 
# Developer: ARMIN-SOFT
# Website: https://armin-soft.ir/
# Contact: @ARMIN_SOFT
# Version: 2.0.0 - Enhanced with License System & Smart Installation
# ================================================================

# Colors for enhanced terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Text symbols for terminal interface
SUCCESS="[✓]"
ERROR="[✗]"
WARNING="[!]"
INFO="[i]"
ROCKET="[🚀]"
GEAR="[⚙]"
DOWNLOAD="[⬇]"
INSTALL="[📦]"
PYTHON="[🐍]"
CHROME="[🌐]"
SETUP="[🔧]"
CHECK="[🔍]"

# Script configuration
SCRIPT_NAME="Twitter Scraper Auto-Run"
DEVELOPER="ARMIN-SOFT"
VERSION="2.0.0"
WEBSITE="https://armin-soft.ir/"

# License and installation status files
LICENSE_STATUS_FILE=".license_status"
INSTALLATION_STATUS_FILE=".installation_status"

# Project structure validation
PROJECT_ROOT="$(pwd)"
PYTHON_VERSION_MIN="3.11"

# Required project files validation
REQUIRED_FILES=(
    "Run.py"
    "Core/Twitter_Scraper.py"
    "Core/Data_Processor.py"
    "Core/Export_Manager.py"
    "Core/Rate_Limiter.py"
    "Models/Tweet_Data.py"
    "Utils/Auth_Manager.py"
    "Utils/Config.py"
    "Utils/Terminal_UI.py"
    "Utils/Logger.py"
    "Utils/Figlet_Banner.py"
    "pyproject.toml"
)

# Required directories
REQUIRED_DIRS=(
    "Core"
    "Models"
    "Utils"
    "exports"
    "logs"
    "sessions"
    "temp"
)

# Function to check license status
check_license_status() {
    echo -e "${CHECK} ${WHITE}Checking license status...${NC}"
    
    # Check if license validation is required
    python3 -c "
import sys
sys.path.append('.')
try:
    from Utils.License_Manager import SecureLicenseManager
    license_manager = SecureLicenseManager()
    is_valid = license_manager.is_license_valid()
    if is_valid:
        print('LICENSE_VALID')
    else:
        print('LICENSE_REQUIRED')
except Exception as e:
    print('LICENSE_ERROR')
    print(f'Error: {e}')
" 2>/dev/null
}

# Function to prompt for license key
prompt_license_key() {
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}License Activation Required${NC}"
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${YELLOW}This software requires a valid license to operate.${NC}"
    echo -e "${WHITE}Please enter your license key:${NC}"
    echo ""
    read -p "License Key: " license_key
    
    if [[ -z "$license_key" ]]; then
        echo -e "${ERROR} ${RED}No license key provided${NC}"
        return 1
    fi
    
    # Validate license
    echo -e "${CHECK} ${WHITE}Validating license...${NC}"
    
    validation_result=$(python3 -c "
import sys
sys.path.append('.')
try:
    from Utils.License_Manager import SecureLicenseManager
    license_manager = SecureLicenseManager()
    is_valid, message = license_manager.validate_license('$license_key')
    if is_valid:
        print('VALID')
    else:
        print('INVALID')
    print(message)
except Exception as e:
    print('ERROR')
    print(f'Validation error: {e}')
" 2>/dev/null)
    
    if echo "$validation_result" | grep -q "VALID"; then
        echo -e "${SUCCESS} ${GREEN}License activated successfully${NC}"
        return 0
    else
        echo -e "${ERROR} ${RED}License validation failed${NC}"
        echo -e "${WHITE}$(echo "$validation_result" | tail -n 1)${NC}"
        return 1
    fi
}

# Function to check installation status
check_installation_status() {
    echo -e "${CHECK} ${WHITE}Checking installation status...${NC}"
    
    installation_result=$(python3 -c "
import sys
sys.path.append('.')
try:
    from Utils.Installation_Status import InstallationStatusManager
    status_manager = InstallationStatusManager()
    needs_install, message = status_manager.needs_installation()
    if needs_install:
        print('INSTALL_REQUIRED')
    else:
        print('INSTALL_READY')
    print(message)
except Exception as e:
    print('INSTALL_REQUIRED')
    print('Status check failed - installation required')
" 2>/dev/null)
    
    if echo "$installation_result" | grep -q "INSTALL_READY"; then
        echo -e "${SUCCESS} ${GREEN}Installation up to date${NC}"
        return 0
    else
        echo -e "${WARNING} ${YELLOW}Installation required${NC}"
        return 1
    fi
}

# Function to display FIGlet banner
display_figlet_banner() {
    echo -e "${CYAN}================================================================${NC}"
    python3 -c "
import sys
from pathlib import Path
sys.path.append(str(Path('.').absolute()))
try:
    from Utils.Figlet_Banner import get_figlet_banner_text
    print(get_figlet_banner_text())
except Exception as e:
    print('Twitter SCRAPER')
    print('ARMIN-SOFT')
    print('Tweet Extraction System')
    print('High-Performance Data Extraction Tool')
" 2>/dev/null || echo -e "${BOLD}${BLUE}Twitter SCRAPER - ARMIN-SOFT${NC}\n${WHITE}High-Performance Data Extraction Tool${NC}"
    echo -e "${CYAN}================================================================${NC}"
}

# Function to print colored headers
print_header() {
    echo -e "${CYAN}================================================================${NC}"
    echo -e "${WHITE}$1${NC}"
    echo -e "${CYAN}================================================================${NC}"
}

# Function to print status messages
print_status() {
    local status=$1
    local message=$2
    echo -e "${status} ${WHITE}${message}${NC}"
}

# Function to print progress
print_progress() {
    echo -e "${BLUE}▶${NC} ${WHITE}$1${NC}"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to detect OS
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    elif [[ "$OSTYPE" == "msys" ]] || [[ "$OSTYPE" == "cygwin" ]]; then
        echo "windows"
    else
        echo "unknown"
    fi
}

# Function to check and install prerequisites automatically
install_prerequisites() {
    print_header "$SETUP SYSTEM PREPARATION"
    print_progress "Checking and installing system prerequisites..."
    
    OS=$(detect_os)
    
    case $OS in
        "linux")
            # Update package lists first
            if command_exists apt-get; then
                print_progress "Updating system package lists..."
                sudo apt-get update >/dev/null 2>&1
                
                # Install essential packages that might be missing
                ESSENTIAL_PACKAGES=(
                    "curl"
                    "wget" 
                    "unzip"
                    "software-properties-common"
                    "apt-transport-https"
                    "ca-certificates"
                    "gnupg"
                    "lsb-release"
                    "build-essential"
                )
                
                for package in "${ESSENTIAL_PACKAGES[@]}"; do
                    if ! dpkg -l | grep -q "^ii  $package "; then
                        print_progress "Installing $package..."
                        sudo apt-get install -y "$package" >/dev/null 2>&1
                    fi
                done
                
                print_status "$SUCCESS" "System prerequisites installed"
            fi
            ;;
        "macos")
            # Check for Xcode command line tools
            if ! xcode-select -p >/dev/null 2>&1; then
                print_progress "Installing Xcode command line tools..."
                xcode-select --install 2>/dev/null
                print_status "$INFO" "Please complete Xcode tools installation and re-run this script"
                exit 1
            fi
            
            # Check for Homebrew
            if ! command_exists brew; then
                print_progress "Installing Homebrew package manager..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            ;;
    esac
    
    print_status "$SUCCESS" "System preparation completed"
    echo ""
}

# Function to validate Python version
validate_python_version() {
    print_progress "Validating Python version..."
    
    PYTHON_CMD=""
    if command_exists python3; then
        PYTHON_CMD="python3"
    elif command_exists python; then
        PYTHON_CMD="python"
    else
        print_status "$ERROR" "Python not found. Please install Python $PYTHON_VERSION_MIN or higher."
        handle_error_with_guidance "python_missing" "Python interpreter not found in system PATH"
        return 1
    fi
    
    # Check Python version
    PYTHON_VERSION=$($PYTHON_CMD -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')" 2>/dev/null)
    
    if [ -z "$PYTHON_VERSION" ]; then
        print_status "$ERROR" "Could not determine Python version"
        handle_error_with_guidance "python_missing" "Python version detection failed"
        return 1
    fi
    
    if [ "$(printf '%s\n' "$PYTHON_VERSION_MIN" "$PYTHON_VERSION" | sort -V | head -n1)" = "$PYTHON_VERSION_MIN" ]; then
        print_status "$SUCCESS" "Python $PYTHON_VERSION is compatible (>= $PYTHON_VERSION_MIN required)"
        return 0
    else
        print_status "$ERROR" "Python $PYTHON_VERSION found, but $PYTHON_VERSION_MIN or higher is required"
        handle_error_with_guidance "python_missing" "Python version $PYTHON_VERSION is too old. Required: $PYTHON_VERSION_MIN+"
        return 1
    fi
}

# Function to install system dependencies
install_system_deps() {
    print_progress "Installing required system dependencies..."
    
    OS=$(detect_os)
    case $OS in
        "linux")
            if command_exists apt-get; then
                print_progress "Updating package lists..."
                sudo apt-get update >/dev/null 2>&1
                
                print_progress "Installing essential packages..."
                sudo apt-get install -y \
                    python3 \
                    python3-pip \
                    python3-dev \
                    python3-venv \
                    curl \
                    wget \
                    unzip \
                    build-essential \
                    software-properties-common \
                    apt-transport-https \
                    ca-certificates \
                    gnupg \
                    lsb-release >/dev/null 2>&1
                    
                print_status "$SUCCESS" "System dependencies installed"
            elif command_exists yum; then
                print_progress "Installing packages via yum..."
                sudo yum update -y >/dev/null 2>&1
                sudo yum install -y python3 python3-pip python3-devel curl wget unzip gcc >/dev/null 2>&1
            elif command_exists dnf; then
                print_progress "Installing packages via dnf..."
                sudo dnf update -y >/dev/null 2>&1
                sudo dnf install -y python3 python3-pip python3-devel curl wget unzip gcc >/dev/null 2>&1
            fi
            ;;
        "macos")
            if command_exists brew; then
                print_progress "Installing via Homebrew..."
                brew update >/dev/null 2>&1
                brew install python3 curl wget >/dev/null 2>&1
            else
                print_status "$WARNING" "Homebrew not found. Some packages might need manual installation."
            fi
            ;;
    esac
}

# Function to install Python dependencies from pyproject.toml
install_python_deps() {
    print_progress "Installing Python dependencies from pyproject.toml..."
    
    # Validate Python version first
    if ! validate_python_version; then
        print_status "$ERROR" "Python version validation failed"
        return 1
    fi
    
    # Install system dependencies first
    install_system_deps
    
    # Check if pip is available
    if ! command_exists pip3 && ! command_exists pip; then
        print_status "$ERROR" "pip not found. Installing pip..."
        
        # Try to install pip based on OS
        OS=$(detect_os)
        case $OS in
            "linux")
                if command_exists apt-get; then
                    sudo apt-get update >/dev/null 2>&1
                    sudo apt-get install -y python3-pip >/dev/null 2>&1
                elif command_exists yum; then
                    sudo yum install -y python3-pip >/dev/null 2>&1
                elif command_exists dnf; then
                    sudo dnf install -y python3-pip >/dev/null 2>&1
                fi
                ;;
            "macos")
                if command_exists brew; then
                    brew install python3 >/dev/null 2>&1
                else
                    print_status "$ERROR" "Homebrew not found. Please install it first."
                    return 1
                fi
                ;;
        esac
    fi
    
    # Use pip3 if available, otherwise pip
    PIP_CMD="pip3"
    if ! command_exists pip3; then
        PIP_CMD="pip"
    fi
    
    print_status "$PYTHON" "Using $PIP_CMD for package installation..."
    
    # Upgrade pip first for better compatibility
    print_progress "Upgrading pip to latest version..."
    $PIP_CMD install --upgrade pip --quiet --no-warn-script-location 2>/dev/null || true
    
    # Install wheel and setuptools for better package building
    print_progress "Installing build tools..."
    $PIP_CMD install --upgrade wheel setuptools --quiet --no-warn-script-location 2>/dev/null || true
    
    # Install exact dependencies from pyproject.toml
    PACKAGES=(
        "beautifulsoup4>=4.13.4"
        "cryptography>=45.0.5"
        "lxml>=5.4.0"
        "pandas>=2.3.1"
        "pyfiglet>=1.0.3"
        "requests>=2.32.4"
        "rich>=14.0.0"
        "selenium>=4.34.2"
        "sendgrid>=6.12.4"
        "trafilatura>=2.0.0"
    )
    
    # Try to install via pyproject.toml first (if uv is available)
    if command_exists uv; then
        print_status "$INSTALL" "Using UV package manager for faster installation..."
        uv pip install -e . --quiet >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            print_status "$SUCCESS" "Dependencies installed successfully via UV"
            return 0
        else
            print_status "$WARNING" "UV installation failed, falling back to pip"
        fi
    fi
    
    # Fallback to manual pip installation
    print_status "$INSTALL" "Installing packages individually with $PIP_CMD..."
    
    for package in "${PACKAGES[@]}"; do
        print_progress "Installing $package..."
        $PIP_CMD install "$package" --upgrade --quiet --no-warn-script-location
        if [ $? -eq 0 ]; then
            print_status "$SUCCESS" "$package installed successfully"
        else
            print_status "$ERROR" "Failed to install $package"
            return 1
        fi
    done
    
    print_status "$SUCCESS" "All Python dependencies installed successfully"
    return 0
}

# Function to validate project structure
validate_project_structure() {
    print_progress "Validating project structure..."
    
    local errors=0
    
    # Check required files
    print_progress "Checking required files..."
    for file in "${REQUIRED_FILES[@]}"; do
        if [ -f "$file" ]; then
            print_status "$SUCCESS" "Found: $file"
        else
            print_status "$ERROR" "Missing: $file"
            ((errors++))
        fi
    done
    
    # Check pyproject.toml specifically for dependencies
    if [ -f "pyproject.toml" ]; then
        print_progress "Validating pyproject.toml dependencies..."
        if grep -q "beautifulsoup4" pyproject.toml && grep -q "selenium" pyproject.toml && grep -q "rich" pyproject.toml; then
            print_status "$SUCCESS" "pyproject.toml contains required dependencies"
        else
            print_status "$WARNING" "pyproject.toml may be missing some dependencies"
        fi
    fi
    
    return $errors
}

# Function to install Chrome/Chromium and ChromeDriver
install_chrome_driver() {
    print_progress "Setting up Chrome/Chromium and ChromeDriver for Selenium..."
    
    OS=$(detect_os)
    case $OS in
        "linux")
            # Try to install Google Chrome first (more reliable than Chromium)
            if ! command_exists google-chrome && ! command_exists chromium-browser && ! command_exists chromium; then
                print_progress "Installing Google Chrome browser..."
                
                if command_exists apt-get; then
                    # Add Google Chrome repository
                    wget -q -O - https://dl.google.com/linux/linux_signing_key.pub | sudo apt-key add - 2>/dev/null
                    echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
                    sudo apt-get update >/dev/null 2>&1
                    
                    # Try Google Chrome first, fallback to Chromium
                    if sudo apt-get install -y google-chrome-stable >/dev/null 2>&1; then
                        print_status "$SUCCESS" "Google Chrome installed successfully"
                    else
                        print_progress "Google Chrome failed, trying Chromium..."
                        sudo apt-get install -y chromium-browser >/dev/null 2>&1
                    fi
                elif command_exists yum; then
                    sudo yum install -y chromium >/dev/null 2>&1
                elif command_exists dnf; then
                    sudo dnf install -y chromium >/dev/null 2>&1
                elif command_exists pacman; then
                    sudo pacman -S --noconfirm chromium >/dev/null 2>&1
                fi
                
                if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
                    print_status "$SUCCESS" "Browser installed successfully"
                else
                    print_status "$WARNING" "Could not install browser automatically. Installing headless dependencies..."
                    # Install xvfb for headless operation as fallback
                    if command_exists apt-get; then
                        sudo apt-get install -y xvfb >/dev/null 2>&1
                    fi
                fi
            else
                print_status "$SUCCESS" "Chrome/Chromium already available"
            fi
            
            # Install ChromeDriver via package manager or download
            if ! command_exists chromedriver; then
                print_progress "Installing ChromeDriver..."
                
                # Try package manager first
                if command_exists apt-get; then
                    sudo apt-get install -y chromium-chromedriver >/dev/null 2>&1
                fi
                
                # If still not available, download manually
                if ! command_exists chromedriver; then
                    print_progress "Downloading ChromeDriver manually..."
                    # Get latest stable Chrome version compatible driver
                    CHROME_VERSION=$(google-chrome --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)
                    
                    if [ -n "$CHROME_VERSION" ]; then
                        MAJOR_VERSION=$(echo $CHROME_VERSION | cut -d. -f1)
                        DRIVER_URL="https://chromedriver.storage.googleapis.com/LATEST_RELEASE_${MAJOR_VERSION}"
                        CHROME_DRIVER_VERSION=$(curl -sS "$DRIVER_URL" 2>/dev/null)
                    else
                        CHROME_DRIVER_VERSION=$(curl -sS chromedriver.storage.googleapis.com/LATEST_RELEASE 2>/dev/null)
                    fi
                    
                    if [ -n "$CHROME_DRIVER_VERSION" ]; then
                        wget -q -O /tmp/chromedriver.zip "https://chromedriver.storage.googleapis.com/${CHROME_DRIVER_VERSION}/chromedriver_linux64.zip"
                        sudo unzip -o /tmp/chromedriver.zip -d /usr/local/bin/ >/dev/null 2>&1
                        sudo chmod +x /usr/local/bin/chromedriver
                        rm -f /tmp/chromedriver.zip
                        print_status "$SUCCESS" "ChromeDriver $CHROME_DRIVER_VERSION installed"
                    else
                        print_status "$WARNING" "Could not determine ChromeDriver version"
                    fi
                fi
            else
                print_status "$SUCCESS" "ChromeDriver already available"
            fi
            ;;
        "macos")
            if command_exists brew; then
                print_progress "Installing Chrome and ChromeDriver via Homebrew..."
                if ! command_exists google-chrome; then
                    brew install --cask google-chrome >/dev/null 2>&1
                fi
                if ! command_exists chromedriver; then
                    brew install chromedriver >/dev/null 2>&1
                fi
                print_status "$SUCCESS" "Chrome/ChromeDriver setup completed via Homebrew"
            else
                print_status "$WARNING" "Homebrew not found. Please install Chrome and ChromeDriver manually."
            fi
            ;;
        *)
            print_status "$WARNING" "Unsupported OS. Please install Chrome/Chromium and ChromeDriver manually."
            ;;
    esac
    
    # Verify installation
    if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
        print_status "$SUCCESS" "Browser available for Selenium automation"
    else
        print_status "$WARNING" "No suitable browser found for Selenium"
    fi
    
    if command_exists chromedriver; then
        DRIVER_VERSION=$(chromedriver --version 2>/dev/null | head -1)
        print_status "$SUCCESS" "ChromeDriver available: $DRIVER_VERSION"
    else
        print_status "$WARNING" "ChromeDriver not found - Selenium may not work properly"
    fi
}

# Function to verify required directories (script will create them automatically)
check_directories() {
    print_progress "Checking directory structure..."
    
    local missing=0
    
    for dir in "${REQUIRED_DIRS[@]}"; do
        if [ ! -d "$dir" ]; then
            print_status "$INFO" "Directory will be created by script: $dir"
            ((missing++))
        else
            print_status "$SUCCESS" "Directory exists: $dir"
        fi
    done
    
    if [ $missing -gt 0 ]; then
        print_status "$INFO" "Script will automatically create $missing missing directories during runtime"
    else
        print_status "$SUCCESS" "All required directories are present"
    fi
}

# Function to set proper permissions
set_permissions() {
    print_progress "Setting proper file permissions..."
    
    # Make Python files executable
    find . -name "*.py" -exec chmod +x {} \;
    
    # Make this script executable
    chmod +x "$0"
    
    print_status "$SUCCESS" "Permissions set successfully"
}

# Function to test Python imports
test_python_imports() {
    print_progress "Testing Python package imports..."
    
    PYTHON_CMD="python3"
    if ! command_exists python3; then
        PYTHON_CMD="python"
    fi
    
    # Test critical imports
    IMPORT_TESTS=(
        "import selenium"
        "import rich"
        "import pandas"
        "import requests"
        "import bs4"
        "import lxml"
        "import pyfiglet"
        "import cryptography"
        "from selenium import webdriver"
        "from rich.console import Console"
    )
    
    local import_errors=0
    
    for test in "${IMPORT_TESTS[@]}"; do
        if $PYTHON_CMD -c "$test" 2>/dev/null; then
            print_status "$SUCCESS" "✓ $test"
        else
            print_status "$ERROR" "✗ $test"
            ((import_errors++))
        fi
    done
    
    return $import_errors
}

# Function to verify complete installation
verify_installation() {
    print_progress "Performing comprehensive installation verification..."
    
    local total_errors=0
    
    # 1. Validate Python environment
    print_progress "Checking Python environment..."
    if ! validate_python_version; then
        ((total_errors++))
    fi
    
    # 2. Check package manager
    if command_exists pip3 || command_exists pip; then
        print_status "$SUCCESS" "Package manager (pip) is available"
    else
        print_status "$ERROR" "pip not found"
        ((total_errors++))
    fi
    
    # 3. Test Python imports
    print_progress "Testing package imports..."
    test_python_imports
    import_errors=$?
    total_errors=$((total_errors + import_errors))
    
    # 4. Check browser and driver
    print_progress "Checking browser automation tools..."
    if command_exists google-chrome || command_exists chromium-browser || command_exists chromium; then
        print_status "$SUCCESS" "Browser available for automation"
    else
        print_status "$WARNING" "No browser found - Selenium may not work"
    fi
    
    if command_exists chromedriver; then
        DRIVER_VERSION=$(chromedriver --version 2>/dev/null | head -1 || echo "Unknown version")
        print_status "$SUCCESS" "ChromeDriver: $DRIVER_VERSION"
    else
        print_status "$WARNING" "ChromeDriver not found - Selenium may not work"
    fi
    
    # 5. Validate project structure
    print_progress "Validating project structure..."
    validate_project_structure
    structure_errors=$?
    total_errors=$((total_errors + structure_errors))
    
    # 6. Test core application files
    print_progress "Testing core application..."
    
    PYTHON_CMD="python3"
    if ! command_exists python3; then
        PYTHON_CMD="python"
    fi
    
    # Test Run.py syntax
    if [ -f "Run.py" ]; then
        if $PYTHON_CMD -m py_compile Run.py 2>/dev/null; then
            print_status "$SUCCESS" "Run.py syntax is valid"
        else
            print_status "$ERROR" "Run.py has syntax errors"
            ((total_errors++))
        fi
    fi
    
    # Test Utils/Figlet_Banner.py
    if [ -f "Utils/Figlet_Banner.py" ]; then
        if $PYTHON_CMD -c "from Utils.Figlet_Banner import display_figlet_banner" 2>/dev/null; then
            print_status "$SUCCESS" "Figlet banner module works"
        else
            print_status "$WARNING" "Figlet banner module has issues"
        fi
    fi
    
    # 7. Summary
    echo ""
    if [ $total_errors -eq 0 ]; then
        print_status "$SUCCESS" "✅ All verification checks passed! Installation is complete."
        print_status "$SUCCESS" "The Twitter Scraper is ready to use."
        return 0
    else
        print_status "$ERROR" "❌ Verification failed with $total_errors errors"
        print_status "$WARNING" "Some components may not work properly. Please review the errors above."
        return 1
    fi
}

# Function to display developer info
show_developer_info() {
    echo -e "${CYAN}Developer:${NC} ${WHITE}ARMIN-SOFT${NC}"
    echo -e "${CYAN}Website:${NC} ${WHITE}https://armin-soft.ir/${NC}"
    echo -e "${CYAN}Version:${NC} ${WHITE}$VERSION${NC}"
    echo ""
}

# Function to display system information
show_system_info() {
    print_progress "System Information:"
    
    echo -e "${CYAN}OS:${NC} $(detect_os)"
    
    if command_exists python3; then
        PYTHON_VERSION=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}.{sys.version_info.micro}')")
        echo -e "${CYAN}Python:${NC} $PYTHON_VERSION"
    fi
    
    if command_exists pip3; then
        PIP_VERSION=$(pip3 --version | cut -d' ' -f2)
        echo -e "${CYAN}Pip:${NC} $PIP_VERSION"
    fi
    
    if command_exists google-chrome; then
        CHROME_VERSION=$(google-chrome --version 2>/dev/null | cut -d' ' -f3)
        echo -e "${CYAN}Chrome:${NC} $CHROME_VERSION"
    elif command_exists chromium-browser; then
        CHROME_VERSION=$(chromium-browser --version 2>/dev/null | cut -d' ' -f2)
        echo -e "${CYAN}Chromium:${NC} $CHROME_VERSION"
    fi
    
    if command_exists chromedriver; then
        DRIVER_VERSION=$(chromedriver --version 2>/dev/null | cut -d' ' -f2)
        echo -e "${CYAN}ChromeDriver:${NC} $DRIVER_VERSION"
    fi
    
    echo ""
}

# Function to run the main application
run_application() {
    clear
    
    # Show FIGlet banner
    display_figlet_banner
    echo ""
    
    print_header "$ROCKET LAUNCHING TWITTER SCRAPER - ARMIN-SOFT $ROCKET"
    
    # Check if Run.py exists
    if [ ! -f "Run.py" ]; then
        print_status "$ERROR" "Run.py not found! Installation may be incomplete."
        echo ""
        print_status "$INFO" "Please run the setup first: $0"
        exit 1
    fi
    
    # Show system information
    show_system_info
    
    print_status "$ROCKET" "Starting Twitter Scraper..."
    print_status "$INFO" "Application will launch with modern UI interface"
    echo ""
    
    # Set up environment
    export PYTHONPATH="$PROJECT_ROOT:$PYTHONPATH"
    
    # Try python3 first, then python
    if command_exists python3; then
        print_status "$PYTHON" "Using Python 3..."
        python3 Run.py
    elif command_exists python; then
        print_status "$PYTHON" "Using Python..."
        python Run.py
    else
        print_status "$ERROR" "Python not found! Please install Python $PYTHON_VERSION_MIN or higher."
        exit 1
    fi
    
    # Handle exit status
    EXIT_CODE=$?
    echo ""
    
    if [ $EXIT_CODE -eq 0 ]; then
        print_status "$SUCCESS" "Application finished successfully"
    else
        print_status "$ERROR" "Application exited with code: $EXIT_CODE"
        print_status "$INFO" "Check logs directory for detailed error information"
    fi
}

# Function to handle errors and provide user guidance
handle_error_with_guidance() {
    local error_type="$1"
    local error_details="$2"
    
    echo ""
    print_status "$ERROR" "Error occurred: $error_type"
    echo ""
    
    case "$error_type" in
        "python_missing")
            echo -e "${YELLOW}Guidance:${NC}"
            echo -e "• Python is not installed. Please download it from python.org"
            echo -e "• Minimum Python 3.11 is required"
            echo -e "• After installing Python, you may need to restart your system"
            ;;
        "permission_denied")
            echo -e "${YELLOW}Guidance:${NC}"
            echo -e "• Insufficient system permissions"
            echo -e "• Run the script with sudo: sudo $0"
            echo -e "• Or enter admin password when prompted"
            ;;
        "network_error")
            echo -e "${YELLOW}Guidance:${NC}"
            echo -e "• Check your internet connection"
            echo -e "• Try disabling/enabling your VPN"
            echo -e "• Wait a few minutes and try again"
            ;;
        "dependency_error")
            echo -e "${YELLOW}Guidance:${NC}"
            echo -e "• Some libraries failed to install"
            echo -e "• Re-run the script: $0"
            echo -e "• Or use the update option: $0 --update"
            ;;
        *)
            echo -e "${YELLOW}General Guidance:${NC}"
            echo -e "• Re-run the script: $0"
            echo -e "• Check internet connection and system permissions"
            echo -e "• If problems persist, check log files"
            ;;
    esac
    
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}For additional help:${NC}"
    echo -e "• Run script with --help: $0 --help"
    echo -e "• Contact support for assistance"
    echo -e "${CYAN}═══════════════════════════════════════════════════════════════════${NC}"
}

# Function to show usage information
show_usage() {
    echo -e "${BOLD}${WHITE}Twitter Scraper Auto-Installation Script Usage:${NC}"
    echo -e "  $0 [OPTIONS]"
    echo ""
    echo -e "${BOLD}${WHITE}Available Options:${NC}"
    echo -e "  ${GREEN}--install${NC}     Complete installation and setup"
    echo -e "  ${GREEN}--run${NC}         Run the application directly"
    echo -e "  ${GREEN}--verify${NC}      Verify installation status"
    echo -e "  ${GREEN}--update${NC}      Update dependencies"
    echo -e "  ${GREEN}--clean${NC}       Clean temporary files"
    echo -e "  ${GREEN}--help${NC}        Show this help message"
    echo ""
    echo -e "${BOLD}${WHITE}Usage Examples:${NC}"
    echo -e "  $0                    # Complete automatic installation"
    echo -e "  $0 --run              # Run application directly"
    echo -e "  $0 --verify           # Check installation status"
    echo ""
    echo -e "${BOLD}${WHITE}Important Notes:${NC}"
    echo -e "• For first-time setup, run the script without parameters"
    echo -e "• Stable internet connection is required"
    echo -e "• Enter admin password when prompted if needed"
    echo ""
}

# Function to clean temporary files
clean_temp_files() {
    print_progress "Cleaning temporary files..."
    
    TEMP_PATTERNS=(
        "*.pyc"
        "__pycache__"
        ".twitter_session_cache"
        "temp/*"
        "logs/*.log"
        ".pytest_cache"
    )
    
    for pattern in "${TEMP_PATTERNS[@]}"; do
        if find . -name "$pattern" -type f 2>/dev/null | head -1 | grep -q .; then
            find . -name "$pattern" -type f -delete 2>/dev/null
            print_status "$SUCCESS" "Cleaned: $pattern"
        fi
        
        if find . -name "$pattern" -type d 2>/dev/null | head -1 | grep -q .; then
            find . -name "$pattern" -type d -exec rm -rf {} + 2>/dev/null
            print_status "$SUCCESS" "Cleaned directory: $pattern"
        fi
    done
    
    print_status "$SUCCESS" "Temporary files cleaned"
}

# Main execution function with license and smart installation
main() {
    # Parse command line arguments
    case "${1:-}" in
        --help|-h)
            clear
            display_figlet_banner
            echo ""
            show_usage
            exit 0
            ;;
        --run)
            smart_run_application
            exit $?
            ;;
        --verify)
            clear
            display_figlet_banner
            echo ""
            print_header "$CHECK VERIFICATION MODE"
            verify_installation
            exit $?
            ;;
        --clean)
            clear
            display_figlet_banner
            echo ""
            print_header "$SETUP CLEANUP MODE"
            clean_temp_files
            exit 0
            ;;
        --update)
            clear
            display_figlet_banner
            echo ""
            print_header "$INSTALL UPDATE MODE"
            install_python_deps
            exit $?
            ;;
        --install|"")
            # Continue with smart installation
            ;;
        *)
            echo -e "${RED}Error: Unknown option '$1'${NC}"
            echo ""
            show_usage
            exit 1
            ;;
    esac
    
    clear
    
    # Show FIGlet banner
    display_figlet_banner
    echo ""
    
    # Show header
    print_header "$GEAR TWITTER SCRAPER - ARMIN-SOFT LICENSED SETUP $GEAR"
    show_developer_info
    
    echo ""
    print_status "$INFO" "Starting smart installation with license validation..."
    echo ""
    
    # STEP 1: Check License Status
    print_header "$CHECK LICENSE VALIDATION"
    license_result=$(check_license_status)
    
    if echo "$license_result" | grep -q "LICENSE_VALID"; then
        print_status "$SUCCESS" "License validated - system authorized"
    elif echo "$license_result" | grep -q "LICENSE_REQUIRED"; then
        print_status "$WARNING" "License activation required"
        
        # Prompt for license key
        while true; do
            if prompt_license_key; then
                break
            else
                echo ""
                echo -e "${YELLOW}Would you like to try again? (y/n):${NC} "
                read -r retry
                case $retry in
                    [Nn]* )
                        print_status "$ERROR" "License required to continue. Exiting..."
                        exit 1
                        ;;
                esac
            fi
        done
    else
        print_status "$ERROR" "License system error. Please contact support."
        exit 1
    fi
    
    echo ""
    
    # STEP 2: Check Installation Status
    print_header "$CHECK INSTALLATION STATUS"
    
    if check_installation_status; then
        print_status "$SUCCESS" "All dependencies are up to date"
        echo ""
        print_status "$ROCKET" "Launching application directly..."
        run_application
        exit $?
    else
        print_status "$INFO" "Installation required - proceeding with setup..."
    fi
    
    echo ""
    
    # STEP 3: Complete System Preparation
    install_prerequisites
    
    # STEP 4: Perform Installation (only if needed)
    print_header "$DOWNLOAD SMART INSTALLATION PROCESS"
    print_status "$INFO" "Installing only missing dependencies..."
    echo ""
    
    # Project structure validation
    print_progress "Validating project structure..."
    if ! validate_project_structure; then
        print_status "$ERROR" "Project structure validation failed"
        exit 1
    fi
    
    # Install dependencies
    print_progress "Installing Python dependencies..."
    if ! install_python_deps; then
        print_status "$ERROR" "Python dependencies installation failed"
        exit 1
    fi
    
    # Setup browser automation
    print_progress "Setting up browser automation..."
    install_chrome_driver
    
    # Check directories
    print_progress "Checking directories..."
    check_directories
    
    # Set permissions
    print_progress "Setting permissions..."
    set_permissions
    
    echo ""
    
    # STEP 4: Final Verification and Save Status
    print_header "$CHECK COMPREHENSIVE VERIFICATION"
    if verify_installation; then
        # Save installation status
        python3 -c "
import sys
sys.path.append('.')
try:
    from Utils.Installation_Status import InstallationStatusManager
    status_manager = InstallationStatusManager()
    status_manager.save_installation_status()
    print('Installation status saved')
except Exception as e:
    print(f'Status save error: {e}')
" 2>/dev/null
        
        echo ""
        print_status "$SUCCESS" "🎉 Installation completed successfully!"
        print_status "$SUCCESS" "Twitter Scraper is ready with valid license"
        echo ""
        
        # Show final instructions
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "${BOLD}${WHITE}NEXT STEPS:${NC}"
        echo -e "  ${GREEN}1.${NC} Run the application: ${CYAN}./Auto-Run.sh --run${NC}"
        echo -e "  ${GREEN}2.${NC} Or start directly: ${CYAN}python3 Run.py${NC}"
        echo -e "  ${GREEN}Note:${NC} ${WHITE}Next time script will run directly without re-installation${NC}"
        echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo ""
        
        # Ask user if they want to run the application
        echo -e "${YELLOW}${BOLD}Do you want to run Twitter Scraper now? (y/n):${NC} "
        read -r choice
        
        case $choice in
            [Yy]* )
                echo ""
                print_status "$ROCKET" "Launching application..."
                run_application
                ;;
            [Nn]* )
                print_status "$INFO" "Setup complete. Use './Auto-Run.sh --run' to start the application."
                ;;
            * )
                echo ""
                print_status "$INFO" "Invalid choice. Use './Auto-Run.sh --run' to start the application."
                ;;
        esac
    else
        echo ""
        print_status "$ERROR" "❌ Installation verification failed. Please check the errors above."
        print_status "$INFO" "Try running './Auto-Run.sh --verify' to see detailed error information."
        exit 1
    fi
}

# Smart run application function
smart_run_application() {
    clear
    display_figlet_banner
    echo ""
    
    # Check license first
    license_result=$(check_license_status)
    
    if echo "$license_result" | grep -q "LICENSE_VALID"; then
        print_status "$SUCCESS" "License valid - proceeding..."
        echo ""
        run_application
    else
        print_status "$ERROR" "License validation failed"
        echo ""
        print_status "$INFO" "Please run './Auto-Run.sh' to activate your license"
        exit 1
    fi
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Ensure we're in the right directory
    if [ ! -f "pyproject.toml" ] || [ ! -f "Run.py" ]; then
        echo -e "${RED}Error: This script must be run from the Twitter Scraper project directory${NC}"
        echo -e "${RED}Make sure you have pyproject.toml and Run.py in the current directory${NC}"
        exit 1
    fi
    
    main "$@"
fi