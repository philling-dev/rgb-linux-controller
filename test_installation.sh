#!/bin/bash

# RGB Linux Controller - Installation Test
# Tests the complete installation and functionality

echo "🧪 RGB Linux Controller - Installation Test"
echo "============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_test() {
    echo -e "${BLUE}▶ Testing: $1${NC}"
}

print_pass() {
    echo -e "${GREEN}✅ PASS: $1${NC}"
}

print_fail() {
    echo -e "${RED}❌ FAIL: $1${NC}"
}

print_warn() {
    echo -e "${YELLOW}⚠️  WARN: $1${NC}"
}

# Test 1: Check if running as root
print_test "Root privileges"
if [[ $EUID -eq 0 ]]; then
    print_pass "Running as root"
else
    print_fail "Not running as root - some tests may fail"
fi

# Test 2: Check system compatibility
print_test "System compatibility"
if command -v lsb_release &> /dev/null; then
    DISTRO=$(lsb_release -si)
    VERSION=$(lsb_release -sr)
    case $DISTRO in
        "Ubuntu"|"LinuxMint"|"Pop")
            print_pass "Supported distribution: $DISTRO $VERSION"
            ;;
        *)
            print_warn "Untested distribution: $DISTRO $VERSION"
            ;;
    esac
else
    print_warn "Could not detect distribution"
fi

# Test 3: Check dependencies
print_test "Required dependencies"

# Check OpenRGB
if command -v openrgb &> /dev/null; then
    print_pass "OpenRGB installed"
else
    print_fail "OpenRGB not found"
fi

# Check liquidctl
if command -v liquidctl &> /dev/null; then
    print_pass "liquidctl installed"
else
    print_fail "liquidctl not found"
fi

# Check i2c-tools
if command -v i2cdetect &> /dev/null; then
    print_pass "i2c-tools installed"
else
    print_fail "i2c-tools not found"
fi

# Check Python dependencies
if python3 -c "import smbus" 2>/dev/null; then
    print_pass "python3-smbus available"
else
    print_fail "python3-smbus not found"
fi

# Test 4: Check GRUB configuration
print_test "GRUB ACPI configuration"
if grep -q "acpi_enforce_resources=lax" /etc/default/grub; then
    print_pass "ACPI parameter configured in GRUB"
    
    # Check if it's active (requires reboot)
    if grep -q "acpi_enforce_resources=lax" /proc/cmdline 2>/dev/null; then
        print_pass "ACPI parameter active in kernel"
    else
        print_warn "ACPI parameter not active - reboot required"
    fi
else
    print_fail "ACPI parameter not configured"
fi

# Test 5: Hardware detection
print_test "Hardware detection"

# USB RGB devices
usb_rgb=$(lsusb | grep -i -E "(rgb|led|corsair|aigo|cooler|ite)" | wc -l)
if [[ $usb_rgb -gt 0 ]]; then
    print_pass "Found $usb_rgb USB RGB device(s)"
else
    print_warn "No USB RGB devices detected"
fi

# I2C devices
if [[ $EUID -eq 0 ]]; then
    i2c_devices=$(i2cdetect -y -r 0 2>/dev/null | grep -v "^     " | grep -o "[0-9a-f][0-9a-f]" | wc -l)
    if [[ $i2c_devices -gt 0 ]]; then
        print_pass "Found $i2c_devices I2C device(s)"
    else
        print_warn "No I2C devices detected"
    fi
else
    print_warn "Skipping I2C test (requires root)"
fi

# OpenRGB device detection
if command -v openrgb &> /dev/null; then
    if [[ $EUID -eq 0 ]]; then
        rgb_devices=$(openrgb --list-devices 2>/dev/null | grep -c "^[0-9]:")
        if [[ $rgb_devices -gt 0 ]]; then
            print_pass "OpenRGB detected $rgb_devices RGB device(s)"
        else
            print_warn "OpenRGB found no devices (may need reboot)"
        fi
    else
        print_warn "Skipping OpenRGB test (requires root)"
    fi
fi

# Test 6: RGB Controller installation
print_test "RGB Controller installation"

if [[ -f "/opt/rgb-linux-controller/rgb-controller.py" ]]; then
    print_pass "RGB Controller script installed"
elif [[ -f "./src/openrgb_full_control.py" ]]; then
    print_pass "RGB Controller found in development location"
else
    print_fail "RGB Controller not found"
fi

if command -v rgb-controller &> /dev/null; then
    print_pass "RGB Controller command available"
else
    print_warn "RGB Controller command not in PATH"
fi

# Test 7: Permissions
print_test "System permissions"

# Check hidraw permissions
hidraw_count=$(ls /dev/hidraw* 2>/dev/null | wc -l)
if [[ $hidraw_count -gt 0 ]]; then
    print_pass "Found $hidraw_count HID device(s)"
    
    # Check permissions
    if ls -la /dev/hidraw* 2>/dev/null | grep -q "rw-rw-rw-"; then
        print_pass "HID devices have correct permissions"
    else
        print_warn "HID devices may need permission fix"
    fi
else
    print_warn "No HID devices found"
fi

# Check i2c permissions
i2c_count=$(ls /dev/i2c-* 2>/dev/null | wc -l)
if [[ $i2c_count -gt 0 ]]; then
    print_pass "Found $i2c_count I2C interface(s)"
else
    print_warn "No I2C interfaces found"
fi

# Test 8: Functional test (if root)
if [[ $EUID -eq 0 ]] && command -v rgb-controller &> /dev/null; then
    print_test "Functional RGB control test"
    
    # Test device listing
    if rgb-controller --list &> /dev/null; then
        print_pass "RGB device listing works"
        
        # Test color control (brief test)
        if timeout 5 rgb-controller blue &> /dev/null; then
            print_pass "RGB color control works"
        else
            print_warn "RGB color control may have issues"
        fi
    else
        print_warn "RGB device listing failed"
    fi
else
    print_warn "Skipping functional test (requires root and installation)"
fi

# Summary
echo ""
echo "🏁 Test Summary"
echo "==============="

# Count passed tests (simple heuristic)
if command -v openrgb &> /dev/null && command -v liquidctl &> /dev/null && command -v i2cdetect &> /dev/null; then
    echo "✅ Core dependencies: INSTALLED"
else
    echo "❌ Core dependencies: MISSING"
fi

if grep -q "acpi_enforce_resources=lax" /etc/default/grub; then
    echo "✅ ACPI configuration: CONFIGURED"
else
    echo "❌ ACPI configuration: MISSING"
fi

if [[ -f "/opt/rgb-linux-controller/rgb-controller.py" ]] || command -v rgb-controller &> /dev/null; then
    echo "✅ RGB Controller: INSTALLED"
else
    echo "❌ RGB Controller: MISSING"
fi

echo ""
echo "💡 Next steps:"
echo "   1. If ACPI shows MISSING: Run installer script"
echo "   2. If tests show MISSING: Reboot system"  
echo "   3. If everything shows OK: Try 'sudo rgb-controller blue'"

echo ""
echo "📋 For installation: curl -fsSL [URL] | sudo bash"
echo "🆘 For help: Create issue with this test output"