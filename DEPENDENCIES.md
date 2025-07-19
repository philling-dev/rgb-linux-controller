# Dependencies and Requirements

## System Requirements

### Supported Operating Systems
- **Ubuntu 20.04 LTS** or newer
- **Linux Mint 20** or newer  
- **Pop!_OS 20.04** or newer
- Other Ubuntu-based distributions (may work)

### Hardware Requirements
- **Architecture**: x86_64 (AMD64)
- **Memory**: 2GB RAM minimum
- **Storage**: 500MB free space
- **Network**: Internet connection for installation

### Tested Hardware
- **Memory**: Corsair Vengeance RGB Pro DDR4
- **Fans**: AIGO RGB fans (120mm)
- **Motherboard**: Gigabyte B550M AORUS ELITE
- **Controller**: ITE IT5702 RGB controllers

## Software Dependencies

### Automatically Installed by installer script (`install.sh`)

#### System Packages (via apt)
```bash
sudo apt install -y \
    i2c-tools \          # I2C bus scanning and communication
    python3 \            # Python 3 runtime
    python3-pip \        # Python package manager
    python3-smbus \      # I2C/SMBus Python interface
    liquidctl \          # RGB cooling control
    wget \               # File downloading
    curl \               # HTTP client
    git                  # Version control
```

#### Manual Downloads
```bash
# OpenRGB (latest stable)
wget https://openrgb.org/releases/release_0.9/openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo dpkg -i openrgb_0.9_amd64_bookworm_b5f46e3.deb
sudo apt-get install -f -y
```

### Development Dependencies (Optional)

For contributing to the project:

```bash
# Code formatting and linting
pip3 install black flake8

# Testing framework
pip3 install pytest

# Documentation generation
pip3 install mkdocs mkdocs-material
```

## Kernel Modules

### Required Modules
These are loaded automatically by the installer:

```bash
# I2C communication
modprobe i2c-dev        # I2C device interface
modprobe i2c-piix4      # AMD chipset I2C support

# HID device support
modprobe usbhid         # USB HID devices
modprobe hidraw         # Raw HID device access
```

### Verification Commands
```bash
# Check loaded modules
lsmod | grep i2c
lsmod | grep hid

# List I2C interfaces
i2cdetect -l

# List HID devices
ls /dev/hidraw*
```

## Kernel Parameters

### ACPI Configuration (Required for memory RGB)
The installer automatically adds this to GRUB:

```bash
# /etc/default/grub
GRUB_CMDLINE_LINUX="acpi_enforce_resources=lax"
```

This resolves SMBus conflicts that prevent RGB memory detection.

### Manual GRUB Configuration
If needed manually:

```bash
# Edit GRUB configuration
sudo nano /etc/default/grub

# Add parameter to GRUB_CMDLINE_LINUX line
GRUB_CMDLINE_LINUX="acpi_enforce_resources=lax"

# Update GRUB and reboot
sudo update-grub
sudo reboot
```

## Permissions and Groups

### User Groups
```bash
# Add user to I2C group (if exists)
sudo usermod -a -G i2c $USER

# Add user to dialout group (for some devices)
sudo usermod -a -G dialout $USER
```

### udev Rules
Created automatically by installer:

```bash
# /etc/udev/rules.d/99-rgb-permissions.rules
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
SUBSYSTEM=="i2c-dev", MODE="0666"
```

### Manual Permission Fix
If needed:

```bash
# Fix device permissions
sudo chmod 666 /dev/hidraw*
sudo chmod 666 /dev/i2c-*

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## Installation Verification

### Quick Test
```bash
# Check all dependencies
./test_installation.sh

# Manual verification
openrgb --version
liquidctl --version
i2cdetect -l
```

### Expected Output
```
OpenRGB 0.9
liquidctl 1.13.0
i2c-0   i2c       AMDGPU SMU 0    I2C adapter
i2c-1   i2c       AMDGPU SMU 1    I2C adapter
...
```

## Troubleshooting Dependencies

### Missing Packages
```bash
# Update package lists
sudo apt update

# Install missing packages
sudo apt install [package-name]

# Fix broken packages
sudo apt --fix-broken install
```

### Python Module Issues
```bash
# Reinstall Python SMBus
sudo apt remove python3-smbus
sudo apt install python3-smbus

# Test import
python3 -c "import smbus; print('SMBus OK')"
```

### OpenRGB Issues
```bash
# Check OpenRGB installation
which openrgb
openrgb --version

# Reinstall if needed
sudo dpkg -r openrgb
wget [openrgb-url]
sudo dpkg -i openrgb_*.deb
sudo apt-get install -f
```

### I2C Issues
```bash
# Check I2C modules
lsmod | grep i2c

# Reload I2C modules
sudo rmmod i2c_piix4
sudo modprobe i2c_piix4

# Check I2C devices
sudo i2cdetect -l
```

## Compatibility Notes

### Known Working Combinations
- Ubuntu 22.04 LTS + OpenRGB 0.9 + Corsair DDR4
- Linux Mint 21 + liquidctl 1.13 + AIGO fans
- Pop!_OS 22.04 + All components

### Known Issues
- **Ubuntu 18.04**: OpenRGB package incompatibility
- **Fedora/CentOS**: Different package names (not supported)
- **Arch Linux**: Manual compilation may be needed
- **WSL**: Hardware access limitations

### Version Compatibility Matrix

| Component | Minimum Version | Recommended | Tested |
|-----------|----------------|-------------|---------|
| Ubuntu | 20.04 LTS | 22.04 LTS | 24.04 LTS |
| OpenRGB | 0.8 | 0.9 | 0.9 |
| liquidctl | 1.10 | 1.13 | 1.13.0-2 |
| Python | 3.8 | 3.10 | 3.12 |
| Kernel | 5.4 | 5.15 | 6.8.0 |

## Installation Size

### Disk Space Requirements
- **Base installation**: ~50MB
- **With dependencies**: ~200MB
- **Complete with docs**: ~250MB

### Network Usage
- **Initial download**: ~100MB
- **Updates**: ~10-50MB

---

*Dependencies are automatically managed by the installation script*