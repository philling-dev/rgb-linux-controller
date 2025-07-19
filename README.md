# 🌈 RGB Linux Controller

**Complete RGB hardware control solution for Linux systems**

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Platform](https://img.shields.io/badge/Platform-Linux-blue.svg)](https://www.kernel.org/)
[![Distro](https://img.shields.io/badge/Distro-Ubuntu%20%7C%20Mint%20%7C%20Pop!_OS-orange.svg)](https://ubuntu.com/)

🎯 **One-click installation** for complete RGB control on Linux systems. No more Windows dependency for RGB lighting!

## ✨ Features

- 🚀 **Automatic installation** with single script
- 🧠 **Corsair Memory RGB** support (Vengeance Pro/RGB series)
- 🌪️ **AIGO Fan RGB** control via motherboard
- 🔧 **Gigabyte motherboard** RGB support
- 🎨 **Multiple effects**: Static, Breathing, Rainbow Wave, Color Pulse
- 🖥️ **GUI and CLI** interfaces available
- 🔄 **Auto-detection** of RGB hardware
- 💾 **Profile saving** and management

## 🎬 Quick Demo

```bash
# One-line installation
curl -fsSL https://raw.githubusercontent.com/philling-dev/rgb-linux-controller/main/install.sh | sudo bash

# Set all RGB to blue
sudo rgb-controller blue

# Breathing red effect
sudo rgb-controller red --mode Breathing

# Rainbow wave effect
sudo rgb-controller rainbow --mode "Rainbow Wave"
```

## 🖥️ Supported Hardware

### ✅ Fully Tested
- **Memory**: Corsair Vengeance RGB Pro DDR4/DDR5
- **Fans**: AIGO RGB fans (via motherboard controller)  
- **Motherboards**: Gigabyte B550M AORUS ELITE, X570 AORUS series
- **Controllers**: ITE IT5702 RGB controllers

### 🧪 Community Tested
- Most OpenRGB compatible devices
- Corsair RGB keyboards/mice (via ckb-next)
- Additional motherboard RGB zones

## 🚀 Installation

### Quick Install (Recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/philling-dev/rgb-linux-controller/main/install.sh | sudo bash
```

### Manual Install
```bash
git clone https://github.com/philling-dev/rgb-linux-controller.git
cd rgb-linux-controller
sudo chmod +x install_rgb_linux.sh
sudo ./install_rgb_linux.sh
```

### System Requirements
- Ubuntu 20.04+ / Linux Mint 20+ / Pop!_OS 20.04+
- Root/sudo access
- Internet connection for dependencies

## 📖 Usage

### Command Line Interface
```bash
# List detected RGB devices
sudo rgb-controller --list

# Basic color control
sudo rgb-controller red        # Set all devices to red
sudo rgb-controller blue       # Set all devices to blue
sudo rgb-controller "#FF6600"  # Custom hex color

# Advanced effects
sudo rgb-controller purple --mode Breathing
sudo rgb-controller cyan --mode "Rainbow Wave"
sudo rgb-controller white --mode "Color Pulse"
```

### Available Colors
`red`, `green`, `blue`, `white`, `purple`, `yellow`, `cyan`, `orange`, `pink`, `off`

Or use hex codes: `#FF0000`, `#00FF00`, `#0000FF`

### Available Modes
- **Static** - Solid color
- **Breathing** - Smooth fade in/out
- **Rainbow Wave** - Moving rainbow effect
- **Color Pulse** - Pulsing color effect
- **Color Shift** - Gradual color transitions

### GUI Interface
```bash
# Launch OpenRGB GUI (installed automatically)
openrgb

# Or use system menu: Applications → System → RGB Controller
```

## 🛠️ Technical Details

### Detection Process
1. **ACPI Conflict Resolution**: Automatically adds `acpi_enforce_resources=lax` to GRUB
2. **I2C Bus Scanning**: Detects memory modules on I2C addresses
3. **HID Device Detection**: Finds motherboard RGB controllers
4. **OpenRGB Integration**: Unified device management

### Solved Issues
- ✅ ACPI SMBus conflicts preventing memory detection
- ✅ Permission issues with I2C/HID devices
- ✅ Corsair memory protocol implementation
- ✅ AIGO fan controller communication via motherboard

## 🔧 Troubleshooting

### RGB devices not detected
```bash
# Check if reboot is needed (required after installation)
sudo reboot

# Verify ACPI parameter was added
grep "acpi_enforce_resources=lax" /proc/cmdline

# Manual device detection
sudo openrgb --list-devices
```

### Memory RGB not working
```bash
# Check I2C devices
sudo i2cdetect -l
sudo i2cdetect -y -r 0

# Verify GRUB configuration
sudo grep "acpi_enforce_resources" /etc/default/grub
```

### Permission denied errors
```bash
# Fix permissions
sudo udevadm control --reload-rules
sudo udevadm trigger

# Add user to i2c group
sudo usermod -a -G i2c $USER
```

### Fans not responding
```bash
# Check motherboard detection
sudo openrgb --list-devices | grep -i motherboard

# Test direct fan control
sudo openrgb --device 2 --mode static --color FF0000
```

## 🏗️ Project Structure

```
rgb-linux-controller/
├── install_rgb_linux.sh      # Main installer script
├── src/
│   ├── rgb-controller.py      # CLI controller
│   ├── openrgb_full_control.py # Advanced controller
│   └── detection/
│       ├── detect_hardware.sh # Hardware detection
│       └── test_protocols.py  # Protocol testing
├── docs/
│   ├── INSTALLATION.md        # Detailed install guide
│   ├── HARDWARE_GUIDE.md      # Hardware compatibility
│   └── TROUBLESHOOTING.md     # Common issues
└── examples/
    ├── basic_usage.sh         # Basic examples
    └── advanced_effects.py    # Custom effects
```

## 🤝 Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

### Development Setup
```bash
git clone https://github.com/philling-dev/rgb-linux-controller.git
cd rgb-linux-controller
sudo apt install python3-dev i2c-tools
pip3 install -r requirements.txt
```

### Adding New Hardware
1. Add detection logic to `src/detection/`
2. Implement protocol in `src/protocols/`
3. Update documentation in `docs/HARDWARE_GUIDE.md`
4. Test with `src/detection/test_protocols.py`

## 📊 Hardware Database

Help us expand hardware support! Submit your hardware info:

```bash
# Generate hardware report
sudo rgb-controller --generate-report

# Submit at: https://github.com/philling-dev/rgb-linux-controller/issues
```

## 📝 Changelog

### v1.0.0 (2025-01-XX)
- 🎉 Initial release
- ✅ Corsair Vengeance RGB Pro DDR4 support
- ✅ AIGO RGB fan support via motherboard
- ✅ Gigabyte B550M AORUS ELITE support
- ✅ Automatic ACPI conflict resolution
- ✅ One-click installer

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [OpenRGB Project](https://openrgb.org/) - Foundation for RGB device control
- [liquidctl](https://github.com/liquidctl/liquidctl) - RGB cooling control
- Linux RGB community for hardware testing and feedback

## 💖 Support the Project

If this project helped you achieve RGB control on Linux, consider supporting development:

### 💳 PayPal
**Email:** guicampos1992@gmail.com

### 🪙 Bitcoin
**Address:** `1Lyy8GJignLbTUoTkR1HKSe8VTkzAvBMLm`

### 🇧🇷 PIX (Brazil)
**Key:** `7b1e2d82-ae62-40cf-bdb1-1c791832bd99`

---

*Made with ❤️ for the Linux RGB community*

**⭐ Star this repo if it helped you bring RGB to Linux!**