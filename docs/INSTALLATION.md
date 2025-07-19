# Installation Guide

## 🚀 Quick Installation (Recommended)

### One-line Install
```bash
curl -fsSL https://raw.githubusercontent.com/[username]/rgb-linux-controller/main/install.sh | sudo bash
```

This will automatically:
- ✅ Install all dependencies (OpenRGB, liquidctl, i2c-tools)
- ✅ Fix ACPI SMBus conflicts
- ✅ Configure system permissions
- ✅ Set up RGB controller scripts
- ✅ Create desktop shortcuts

**⚠️ Reboot required after installation for full RGB memory support**

## 📋 System Requirements

### Supported Distributions
- Ubuntu 20.04 LTS or newer
- Linux Mint 20 or newer  
- Pop!_OS 20.04 or newer
- Other Ubuntu-based distributions (untested)

### Hardware Requirements
- RGB memory: Corsair Vengeance RGB Pro DDR4/DDR5
- RGB fans: AIGO or compatible (via motherboard controller)
- Motherboard: Gigabyte AORUS series or OpenRGB compatible
- CPU: x86_64 architecture

### System Access
- Root/sudo privileges required
- Internet connection for downloading dependencies

## 🛠️ Manual Installation

### Step 1: Download
```bash
git clone https://github.com/[username]/rgb-linux-controller.git
cd rgb-linux-controller
```

### Step 2: Make executable
```bash
sudo chmod +x install.sh
```

### Step 3: Run installer
```bash
sudo ./install.sh
```

### Step 4: Reboot
```bash
sudo reboot
```

## 🔧 Advanced Installation

### Custom Installation Directory
```bash
export INSTALL_DIR="/opt/my-rgb-controller"
sudo ./install.sh
```

### Skip GRUB Modification
```bash
export SKIP_GRUB=1
sudo ./install.sh
```

### Development Installation
```bash
git clone https://github.com/[username]/rgb-linux-controller.git
cd rgb-linux-controller
sudo apt install python3-dev python3-pip i2c-tools
pip3 install -r requirements.txt

# Manual dependency installation
sudo apt install liquidctl
wget https://openrgb.org/releases/release_0.9/openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo dpkg -i openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo apt-get install -f
```

## 🧪 Installation Testing

### Verify Installation
```bash
# Check if RGB controller is installed
which rgb-controller

# Test device detection
sudo rgb-controller --list

# Test color control
sudo rgb-controller blue
```

### Expected Output
```
🌈 RGB DEVICES DETECTED
========================================
💾 Memory Device 0: Corsair Vengeance Pro RGB
💾 Memory Device 1: Corsair Vengeance Pro RGB  
🔧 Motherboard Device 2: B550M AORUS ELITE
```

## 🔍 Installation Logs

### Check Installation Status
```bash
# View full installation log
sudo cat /var/log/rgb-linux-installer.log

# Check last 50 lines
sudo tail -50 /var/log/rgb-linux-installer.log
```

### Verify GRUB Configuration
```bash
# Check if ACPI parameter was added
grep "acpi_enforce_resources=lax" /etc/default/grub

# Verify it's active (after reboot)
grep "acpi_enforce_resources=lax" /proc/cmdline
```

## ⚠️ Common Installation Issues

### OpenRGB Download Fails
```bash
# Manual OpenRGB installation
wget https://openrgb.org/releases/release_0.9/openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo dpkg -i openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo apt-get install -f -y
```

### Permission Denied Errors
```bash
# Fix permissions
sudo chmod +x install.sh
sudo chown root:root install.sh
```

### Network/Firewall Issues
```bash
# Alternative download method
wget --no-check-certificate [URL]

# Or download manually and install
```

### Dependency Installation Fails
```bash
# Update package lists
sudo apt update

# Install missing dependencies manually
sudo apt install i2c-tools python3-smbus liquidctl
```

## 🔄 Post-Installation Setup

### 1. Reboot System
```bash
sudo reboot
```
**This is required for memory RGB detection**

### 2. Verify Hardware Detection
```bash
sudo rgb-controller --list
```

### 3. Test RGB Control
```bash
sudo rgb-controller red
sudo rgb-controller blue --mode Breathing
```

### 4. Configure Auto-start (Optional)
```bash
# Add to startup applications
echo "@rgb-controller blue" >> ~/.config/autostart/rgb-controller.desktop
```

## 🗑️ Uninstallation

### Complete Removal
```bash
# Remove RGB controller
sudo rm -rf /opt/rgb-linux-controller
sudo rm /usr/local/bin/rgb-controller

# Remove desktop entry
sudo rm /usr/share/applications/rgb-controller.desktop

# Remove udev rules
sudo rm /etc/udev/rules.d/99-rgb-permissions.rules
sudo udevadm control --reload-rules

# Restore GRUB (optional)
sudo cp /etc/default/grub.backup.* /etc/default/grub
sudo update-grub
```

### Keep OpenRGB
If you want to keep OpenRGB for manual use:
```bash
# OpenRGB will remain installed and functional
openrgb --list-devices
```

## 🆘 Getting Help

### Before Reporting Issues

1. **Check installation log**: `sudo cat /var/log/rgb-linux-installer.log`
2. **Verify reboot**: RGB memory requires reboot after installation
3. **Test OpenRGB directly**: `sudo openrgb --list-devices`
4. **Check hardware compatibility**: See [HARDWARE_GUIDE.md](HARDWARE_GUIDE.md)

### Reporting Installation Problems

Include this information:
```bash
# System info
lsb_release -a
uname -a

# Installation log
sudo tail -100 /var/log/rgb-linux-installer.log

# Hardware detection
sudo openrgb --list-devices
lsusb | grep -i rgb
sudo i2cdetect -l
```

### Community Support
- **GitHub Issues**: Report bugs and installation problems
- **GitHub Discussions**: Ask questions and share experiences  
- **Hardware Database**: Submit your hardware configuration

---

*Installation usually takes 2-5 minutes depending on internet speed*