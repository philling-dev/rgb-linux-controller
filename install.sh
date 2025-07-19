#!/bin/bash

# RGB Linux Auto-Installer
# Automatic RGB hardware detection and control setup for Linux
# Supports: Corsair RGB Memory, AIGO Fans, Gigabyte motherboards
# Author: Guilherme Campos
# Repository: https://github.com/[username]/rgb-linux-controller

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Script info
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="RGB Linux Auto-Installer"

# URLs and paths
OPENRGB_URL="https://openrgb.org/releases/release_0.9/openrgb_0.9_amd64_bookworm_b5f46e3.deb"
INSTALL_DIR="/opt/rgb-linux-controller"
TEMP_DIR="/tmp/rgb-linux-installer"

# Logging
LOG_FILE="/var/log/rgb-linux-installer.log"

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

print_header() {
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    RGB Linux Controller                      ║"
    echo "║              Automatic Installation Script                   ║"
    echo "║                     Version $SCRIPT_VERSION                         ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_section() {
    echo -e "\n${BLUE}▓▓▓ $1 ▓▓▓${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        print_error "This script must be run as root"
        echo "Please run: sudo $0"
        exit 1
    fi
}

check_distribution() {
    print_section "Checking Linux Distribution"
    
    if command -v lsb_release &> /dev/null; then
        DISTRO=$(lsb_release -si)
        VERSION=$(lsb_release -sr)
        echo "Detected: $DISTRO $VERSION"
        
        case $DISTRO in
            "Ubuntu"|"LinuxMint"|"Pop")
                print_success "Supported distribution detected"
                ;;
            *)
                print_warning "Untested distribution. Proceeding anyway..."
                ;;
        esac
    else
        print_warning "Could not detect distribution. Assuming Ubuntu-based."
    fi
    
    log "Distribution check completed: $DISTRO $VERSION"
}

create_directories() {
    print_section "Creating Directories"
    
    mkdir -p "$INSTALL_DIR"
    mkdir -p "$TEMP_DIR"
    mkdir -p "/etc/rgb-linux-controller"
    
    print_success "Directories created"
    log "Directories created successfully"
}

backup_grub() {
    print_section "Backing up GRUB Configuration"
    
    if [[ -f /etc/default/grub ]]; then
        cp /etc/default/grub /etc/default/grub.backup.$(date +%Y%m%d_%H%M%S)
        print_success "GRUB configuration backed up"
        log "GRUB backup created"
    else
        print_error "GRUB configuration not found"
        exit 1
    fi
}

fix_acpi_conflict() {
    print_section "Fixing ACPI SMBus Conflicts"
    
    # Check if parameter already exists
    if grep -q "acpi_enforce_resources=lax" /etc/default/grub; then
        print_success "ACPI parameter already configured"
        return 0
    fi
    
    # Add ACPI parameter to GRUB
    sed -i 's/GRUB_CMDLINE_LINUX=""/GRUB_CMDLINE_LINUX="acpi_enforce_resources=lax"/' /etc/default/grub
    
    # If the line was empty, try the other format
    if ! grep -q "acpi_enforce_resources=lax" /etc/default/grub; then
        sed -i 's/GRUB_CMDLINE_LINUX="\(.*\)"/GRUB_CMDLINE_LINUX="\1 acpi_enforce_resources=lax"/' /etc/default/grub
    fi
    
    # Update GRUB
    update-grub
    
    print_success "ACPI SMBus conflict fix applied"
    print_warning "System reboot required for memory RGB detection"
    log "ACPI parameter added to GRUB"
}

install_system_dependencies() {
    print_section "Installing System Dependencies"
    
    echo "Updating package lists..."
    apt update -qq
    
    PACKAGES=(
        "i2c-tools"
        "python3"
        "python3-pip"
        "python3-smbus"
        "liquidctl"
        "wget"
        "curl"
        "git"
    )
    
    for package in "${PACKAGES[@]}"; do
        echo "Installing $package..."
        if apt install -y -qq "$package"; then
            print_success "$package installed"
        else
            print_warning "Failed to install $package, continuing..."
        fi
    done
    
    log "System dependencies installation completed"
}

install_openrgb() {
    print_section "Installing OpenRGB"
    
    cd "$TEMP_DIR"
    
    # Download OpenRGB
    echo "Downloading OpenRGB..."
    if wget -q "$OPENRGB_URL" -O openrgb.deb; then
        print_success "OpenRGB downloaded"
    else
        print_error "Failed to download OpenRGB"
        exit 1
    fi
    
    # Install OpenRGB
    echo "Installing OpenRGB..."
    if dpkg -i openrgb.deb 2>/dev/null; then
        print_success "OpenRGB installed successfully"
    else
        echo "Resolving dependencies..."
        apt-get install -f -y -qq
        print_success "OpenRGB installed with dependencies resolved"
    fi
    
    log "OpenRGB installation completed"
}

detect_rgb_hardware() {
    print_section "Detecting RGB Hardware"
    
    echo "Scanning for RGB devices..."
    
    # Detect USB devices
    echo "🔍 USB RGB Controllers:"
    lsusb | grep -i -E "(rgb|led|corsair|aigo|cooler|deep|ite|gigabyte)" || echo "  None detected"
    
    # Detect I2C devices
    echo -e "\n🔍 I2C Devices:"
    i2cdetect -l | head -5
    
    # Test OpenRGB detection
    echo -e "\n🔍 OpenRGB Device Detection:"
    if command -v openrgb &> /dev/null; then
        openrgb --list-devices 2>/dev/null | grep -E "^[0-9]+:" || echo "  Run after reboot for full detection"
    else
        echo "  OpenRGB not found"
    fi
    
    log "Hardware detection completed"
}

install_rgb_controller() {
    print_section "Installing RGB Controller Scripts"
    
    # Create main controller script
    cat > "$INSTALL_DIR/rgb-controller.py" << 'EOF'
#!/usr/bin/env python3
"""
RGB Linux Controller - Main Script
Supports Corsair Memory, AIGO Fans, Gigabyte motherboards
"""

import subprocess
import argparse
import os
import sys

class RGBController:
    def __init__(self):
        self.detected_devices = []
        self.detect_devices()
    
    def detect_devices(self):
        """Auto-detect RGB devices"""
        try:
            result = subprocess.run(['openrgb', '--list-devices'], 
                                  capture_output=True, text=True)
            if result.returncode == 0:
                lines = result.stdout.split('\n')
                for line in lines:
                    if line.strip() and line[0].isdigit() and ':' in line:
                        device_info = line.split(':', 1)
                        if len(device_info) == 2:
                            device_id = int(device_info[0])
                            device_name = device_info[1].strip()
                            self.detected_devices.append({
                                'id': device_id,
                                'name': device_name
                            })
        except Exception as e:
            print(f"Warning: Could not detect devices: {e}")
    
    def list_devices(self):
        """List all detected devices"""
        print("🌈 RGB DEVICES DETECTED")
        print("=" * 40)
        
        if not self.detected_devices:
            print("❌ No RGB devices detected")
            print("💡 Make sure OpenRGB is installed and you've rebooted after installation")
            return
        
        for device in self.detected_devices:
            device_type = "Unknown"
            if "corsair" in device['name'].lower() or "dram" in device['name'].lower():
                device_type = "💾 Memory"
            elif "aorus" in device['name'].lower() or "motherboard" in device['name'].lower():
                device_type = "🔧 Motherboard"
            
            print(f"{device_type} Device {device['id']}: {device['name']}")
    
    def set_color(self, color, mode='Static'):
        """Set color on all devices"""
        if not self.detected_devices:
            print("❌ No devices detected")
            return False
        
        print(f"🎨 Setting color {color} with mode {mode}")
        success_count = 0
        
        for device in self.detected_devices:
            try:
                cmd = ['openrgb', '--device', str(device['id']), 
                       '--mode', mode, '--color', color]
                result = subprocess.run(cmd, capture_output=True)
                
                if result.returncode == 0:
                    print(f"   ✅ Device {device['id']} configured")
                    success_count += 1
                else:
                    print(f"   ❌ Failed to configure device {device['id']}")
                    
            except Exception as e:
                print(f"   ❌ Error with device {device['id']}: {e}")
        
        if success_count == len(self.detected_devices):
            print("🎉 All devices configured successfully!")
        elif success_count > 0:
            print(f"⚠️  {success_count}/{len(self.detected_devices)} devices configured")
        else:
            print("❌ No devices could be configured")
        
        return success_count > 0

def main():
    if os.geteuid() != 0:
        print("❌ This script requires root privileges")
        print("Please run: sudo rgb-controller [options]")
        sys.exit(1)
    
    controller = RGBController()
    
    parser = argparse.ArgumentParser(description='RGB Linux Controller')
    parser.add_argument('color', nargs='?', help='Color (red, blue, green, etc. or #RRGGBB)')
    parser.add_argument('--mode', default='Static', help='RGB mode (Static, Breathing, etc.)')
    parser.add_argument('--list', action='store_true', help='List detected devices')
    
    args = parser.parse_args()
    
    if args.list:
        controller.list_devices()
        return
    
    if not args.color:
        parser.print_help()
        return
    
    controller.set_color(args.color, args.mode)

if __name__ == "__main__":
    main()
EOF

    chmod +x "$INSTALL_DIR/rgb-controller.py"
    
    # Create symlink for easy access
    ln -sf "$INSTALL_DIR/rgb-controller.py" /usr/local/bin/rgb-controller
    
    print_success "RGB Controller installed"
    log "RGB Controller scripts installed"
}

create_desktop_entry() {
    print_section "Creating Desktop Entry"
    
    cat > /usr/share/applications/rgb-controller.desktop << EOF
[Desktop Entry]
Name=RGB Controller
Comment=Control RGB lighting on Linux
Exec=gksu rgb-controller --list
Icon=preferences-color
Terminal=true
Type=Application
Categories=System;Settings;
EOF
    
    print_success "Desktop entry created"
    log "Desktop entry created"
}

create_documentation() {
    print_section "Creating Documentation"
    
    cat > "$INSTALL_DIR/README.md" << 'EOF'
# RGB Linux Controller

## Quick Start

```bash
# List detected devices
sudo rgb-controller --list

# Set colors
sudo rgb-controller red
sudo rgb-controller blue --mode Breathing
sudo rgb-controller "#FF6600"

# Advanced usage
sudo rgb-controller purple --mode "Rainbow Wave"
```

## Supported Colors
red, green, blue, white, purple, yellow, cyan, orange, pink, off
Or use hex codes: #FF0000, #00FF00, #0000FF

## Supported Modes
Static, Breathing, Rainbow Wave, Color Pulse, Color Shift

## Troubleshooting

If devices are not detected:
1. Reboot your system (required after installation)
2. Check BIOS RGB settings
3. Run: sudo openrgb --list-devices

## Hardware Compatibility
- ✅ Corsair Vengeance RGB Memory
- ✅ AIGO RGB Fans 
- ✅ Gigabyte AORUS motherboards
- ✅ Most OpenRGB compatible devices
EOF
    
    print_success "Documentation created"
    log "Documentation created"
}

setup_permissions() {
    print_section "Setting Up Permissions"
    
    # Add user to i2c group if exists
    if getent group i2c > /dev/null 2>&1; then
        if [[ -n "$SUDO_USER" ]]; then
            usermod -a -G i2c "$SUDO_USER"
            print_success "User added to i2c group"
        fi
    fi
    
    # Set permissions for hidraw devices
    cat > /etc/udev/rules.d/99-rgb-permissions.rules << EOF
# RGB Controller permissions
KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666"
SUBSYSTEM=="i2c-dev", MODE="0666"
EOF
    
    udevadm control --reload-rules
    
    print_success "Permissions configured"
    log "Permissions and udev rules configured"
}

run_system_test() {
    print_section "Running System Test"
    
    echo "Testing RGB detection..."
    
    # Test I2C
    if command -v i2cdetect &> /dev/null; then
        echo "✅ I2C tools available"
    else
        echo "❌ I2C tools missing"
    fi
    
    # Test OpenRGB
    if command -v openrgb &> /dev/null; then
        echo "✅ OpenRGB installed"
        
        # Quick device count
        device_count=$(openrgb --list-devices 2>/dev/null | grep -c "^[0-9]:" || echo "0")
        echo "📊 Detected $device_count RGB device(s)"
        
        if [[ $device_count -eq 0 ]]; then
            print_warning "No devices detected - reboot may be required"
        fi
    else
        echo "❌ OpenRGB not found"
    fi
    
    # Test RGB Controller
    if [[ -x "$INSTALL_DIR/rgb-controller.py" ]]; then
        echo "✅ RGB Controller installed"
    else
        echo "❌ RGB Controller missing"
    fi
    
    log "System test completed"
}

cleanup() {
    print_section "Cleaning Up"
    
    rm -rf "$TEMP_DIR"
    
    print_success "Cleanup completed"
    log "Installation cleanup completed"
}

print_final_instructions() {
    echo -e "\n${GREEN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                    INSTALLATION COMPLETE!                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}🔄 IMPORTANT: Please reboot your system now for full RGB support${NC}"
    echo ""
    echo "After reboot, test with:"
    echo "  sudo rgb-controller --list"
    echo "  sudo rgb-controller blue"
    echo ""
    echo "📚 Documentation: $INSTALL_DIR/README.md"
    echo "📝 Log file: $LOG_FILE"
    echo ""
    echo -e "${CYAN}🎉 Enjoy your RGB Linux setup!${NC}"
}

# Main installation flow
main() {
    print_header
    
    log "Starting RGB Linux installation v$SCRIPT_VERSION"
    
    check_root
    check_distribution
    create_directories
    backup_grub
    fix_acpi_conflict
    install_system_dependencies
    install_openrgb
    detect_rgb_hardware
    install_rgb_controller
    create_desktop_entry
    create_documentation
    setup_permissions
    run_system_test
    cleanup
    print_final_instructions
    
    log "RGB Linux installation completed successfully"
}

# Error handling
trap 'echo -e "\n${RED}Installation failed. Check log: $LOG_FILE${NC}"; exit 1' ERR

# Run main installation
main "$@"