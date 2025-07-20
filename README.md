# 🐦 Twitter Scraper

A professional X/Twitter data extraction tool built with Python, featuring advanced scraping capabilities and comprehensive security measures.

**🐍 Python 3.11+ | 📄 MIT License | 🔢 Version 1.0.0**

---

## ✨ Features

🔹 **🐦 X/Twitter Data Extraction** - Scrape tweets from usernames, hashtags, and search terms  
🔹 **🛡️ Anti-Detection Technology** - Stealth browsing techniques to avoid detection  
🔹 **📊 Multiple Export Formats** - CSV and JSON support for data export  
🔹 **💻 Rich Terminal Interface** - Modern CLI with progress tracking and interactive menus  
🔹 **⏱️ Smart Rate Limiting** - Intelligent delays to prevent account restrictions  
🔹 **🔐 License Management** - Secure license validation system  
🔹 **🔄 Auto-Update System** - Check and install updates automatically  
🔹 **⚙️ Advanced Configuration** - Customizable settings via JSON configuration file  
🔹 **🎛️ Timing Control** - Full control over all delays and timing settings  

---

## 📋 System Requirements

🔸 **🐍 Python** - Version 3.11 or higher  
🔸 **🌐 Browser** - Chrome/Chromium browser  
🔸 **🚗 ChromeDriver** - Automatically handled by Selenium  
🔸 **🌍 Internet** - Stable internet connection  
🔸 **🔑 License** - Valid license key from ARMIN-SOFT  

---

## 📦 Dependencies

The application uses these essential Python libraries:

🔸 **🤖 selenium** - Web browser automation framework  
🔸 **💎 rich** - Enhanced terminal interface and styling  
🔸 **🐼 pandas** - Data manipulation and analysis  
🔸 **🔒 cryptography** - Security and encryption services  
🔸 **📡 requests** - HTTP requests handling  
🔸 **🎨 pyfiglet** - ASCII art generation  
🔸 **🍲 beautifulsoup4** - HTML parsing and extraction  
🔸 **📄 lxml** - High-performance XML processing  

---

## 🔧 Development Environment

**💡 Developer Note**: When running in development environments, the license validation is automatically bypassed for testing purposes. The system intelligently detects development environments and allows unrestricted access.

---

## 📄 License Requirements

⚠️ **Important**: This software requires a valid license key for production usage. Without a proper license, the application will not function in production environments.

### 🔑 How to Activate License

1. **▶️ Run the Application**
2. **🔑 Enter License Key** - Input your valid license key when prompted
3. **💾 Automatic Binding** - License will be permanently saved and bound to your system
4. **🚀 Ready to Use** - No restart required after license activation

### 🛡️ License Features

✅ **🔗 Hardware Binding** - License is securely bound to your specific system  
✅ **💾 Persistent Storage** - Once activated, license persists across all restarts  
✅ **🔧 Development Bypass** - Automatic bypass in development environments  
✅ **🔐 Encrypted Security** - Secure encrypted storage of license data  

### 🛠️ Troubleshooting License Issues

🔸 **Validation Fails** - Ensure you're using the exact license key provided  
🔸 **Development Mode** - Development environments automatically bypass license checks  
🔸 **Production Issues** - Contact support if license issues persist in production  

---

## 🛠️ Installation Guide

### 🚀 Method 1: Automatic Installation (Recommended)

**Step 1: Clone Repository**
```bash
git clone https://github.com/armin-soft/Twitter-Scraper.git
cd Twitter-Scraper
```

**Step 2: Run Auto-Installation**
```bash
# On Linux/Mac
chmod +x Auto-Run.sh
./Auto-Run.sh

# On Windows
Auto-Run.sh
```

**🎯 What the script does automatically:**
🔸 📦 Installs all Python dependencies  
🔸 🚗 Downloads and configures ChromeDriver  
🔸 ⚙️ Sets up the complete environment  
🔸 🚀 Launches the application immediately  

### 🔧 Method 2: Manual Installation

**Step 1: Clone Repository**
```bash
git clone https://github.com/armin-soft/Twitter-Scraper.git
cd Twitter-Scraper
```

**Step 2: Install Dependencies**
```bash
pip install -r requirements.txt
```

**Step 3: Launch Application**
```bash
python Run.py
```

---

## 📖 Usage Guide

### 🚀 Getting Started

**1. 🎯 Launch Application**
```bash
python Run.py
```

**2. 🔐 License Activation**
🔸 🔑 Enter your license key when prompted  
🔸 📞 Contact ARMIN-SOFT for license purchase  

**3. 🎮 Main Menu Navigation**

🔸 **👤 Username Scraper** - Extract tweets from specific X/Twitter profiles  
🔸 **🏷️ Hashtag Scraper** - Collect tweets containing specific hashtags  
🔸 **🔍 Search Engine** - Scrape tweets based on custom search queries  
🔸 **⚙️ Advanced Options** - Configure settings and check for updates  

**4. ⚙️ Configuration Management**
🔸 📁 All settings stored in `Config.json`  
🔸 🛠️ Customize scraping parameters and export formats  
🔸 ⏱️ Configure timing through built-in Timing Configuration menu  

**5. 📊 Data Export Options**
🔸 📄 Choose between CSV or JSON formats  
🔸 💾 Files automatically saved to configured export directory  

---

## ⚙️ Configuration Settings

The application uses a `Config.json` file for all settings:

```json
{
  "scraping": {
    "rate_limit_delay": 2,
    "max_tweets": 1000,
    "headless_mode": true,
    "initial_load_delay": [2, 4],
    "hashtag_load_delay": [2, 4],
    "search_load_delay": [2, 4],
    "scroll_delay": [0.5, 1.5],
    "human_thinking_delay": [0.5, 1.5],
    "human_thinking_chance": 0.2,
    "extra_delay_chance": 0.3,
    "rate_limit_wait_time": 30
  },
  "export": {
    "format": "csv",
    "output_directory": "./exports"
  },
  "proxy": {
    "enabled": false,
    "host": "",
    "port": "",
    "username": "",
    "password": ""
  }
}
```

---

## ⏱️ Advanced Timing Configuration

The application offers **complete control over all timing and delay settings** through an interactive menu system:

### 🎛️ Available Timing Controls

🔸 **📄 Page Loading Delays** - Control initial page load waiting times  
🔸 **🏷️ Hashtag Search Delays** - Set delays for hashtag searches  
🔸 **🔍 Search Term Delays** - Configure search query delays  
🔸 **📜 Scrolling Delays** - Adjust page scrolling speeds  
🔸 **🤔 Human Thinking Delays** - Simulate realistic human-like pauses  
🔸 **🎲 Probability Settings** - Control randomness of extra delays  
🔸 **⏳ Rate Limit Wait Time** - Set wait time when rate limited  

### 🛠️ Access Configuration Menu

**Navigate to**: Advanced Options → Timing Configuration

**🎯 Preset Configurations Available:**
🔸 **⚡ Fast Settings** - Optimized for speed (may increase detection risk)  
🔸 **🛡️ Safe Settings** - Conservative delays for maximum stealth  

### 📝 Manual Configuration

All timing settings can be edited directly in `Config.json`:

```json
{
  "scraping": {
    "initial_load_delay": [1, 2],       // Page loading: min-max seconds
    "hashtag_load_delay": [1, 2],       // Hashtag search delays  
    "search_load_delay": [1, 2],        // Search term delays
    "scroll_delay": [0.3, 0.8],         // Scrolling delays
    "human_thinking_delay": [0.3, 0.8], // Human-like pauses
    "human_thinking_chance": 0.1,       // Probability of extra thinking
    "extra_delay_chance": 0.15,         // Probability of random delays
    "rate_limit_wait_time": 20          // Wait time when rate limited
  }
}
```

---

## 🛡️ Security Features

🔸 **🔐 Advanced License Protection** - Hardware-based license validation system  
🔸 **🥸 Anti-Detection Technology** - Randomized delays and browser fingerprinting  
🔸 **🔒 Encrypted Storage** - Secure storage of credentials and configuration  
🔸 **⏱️ Intelligent Rate Limiting** - Smart request throttling to avoid restrictions  
🔸 **👻 Stealth Mode** - Headless browsing with randomized user agents  

---

## 🔄 Auto-Update System

The application includes a built-in update functionality:

✅ **🔍 Automatic Checking** - Update checking on every startup  
✅ **📋 Manual Updates** - Check for updates via Advanced Options menu  
✅ **🔒 Secure Downloads** - Safe download and installation from GitHub releases  
✅ **💾 Configuration Preservation** - All settings preserved during updates  

---

## 📜 License Information

This project is licensed under the **MIT License** - see the [LICENSE](LICENSE) file for complete details.

**⚠️ Important Note**: While the source code is MIT licensed, the application requires a valid license key from ARMIN-SOFT to operate in production environments.

---

## 👨‍💻 Developer Information

**🏢 ARMIN-SOFT**
🔸 🌐 **Website**: [https://armin-soft.ir/](https://armin-soft.ir/)  
🔸 📱 **Telegram**: [@ARMIN_SOFT](https://t.me/ARMIN_SOFT)  
🔸 🔖 **Version**: 1.0.0  

---

## 🤝 Support & Contact

For technical support, license inquiries, or feature requests:

🔸 🌐 **Visit Website**: [https://armin-soft.ir/](https://armin-soft.ir/)  
🔸 📞 **Contact Support**: [@ARMIN_SOFT](https://t.me/ARMIN_SOFT)  

---

## ⚠️ Legal Disclaimer

This tool is designed for **educational and research purposes only**. Users are fully responsible for:

🔸 **✖️ Platform Compliance** - Following X/Twitter's Terms of Service  
🔸 **📋 Legal Compliance** - Respecting all applicable data protection laws  
🔸 **⚖️ Ethical Usage** - Using the software ethically and legally  

**The developer assumes no responsibility for any misuse of this software.**

---

*🎯 Built with precision by ARMIN-SOFT | 🚀 Powered by Python*