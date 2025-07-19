# Hardware Compatibility Guide

## 🎯 Fully Supported Hardware

These devices have been thoroughly tested and work perfectly:

### 💾 Memory Modules

#### ✅ Corsair Vengeance RGB Pro DDR4
- **Models**: CMWX16GC3600C18W2D, CMWX16GD3600C18W2D
- **Speeds**: DDR4-3600, DDR4-3200, DDR4-2666
- **Capacity**: 8GB, 16GB, 32GB modules
- **Detection**: I2C addresses 0x5A, 0x5B
- **Effects**: All RGB modes supported

### 🌪️ RGB Fans

#### ✅ AIGO RGB Fans
- **Models**: 120mm RGB fans (9-pack tested)
- **Connection**: Via motherboard RGB headers
- **Control**: Through motherboard RGB controller
- **Effects**: Static, Breathing, Rainbow, Custom

### 🔧 Motherboards

#### ✅ Gigabyte B550M AORUS ELITE
- **Controller**: IT5702-GIGABYTE V2.0.10.0
- **Interface**: HID (/dev/hidraw5)
- **RGB Zones**: D_LED1 Bottom, D_LED2 Top, Motherboard
- **Compatible**: AIGO fans, RGB strips, other RGB peripherals

#### ✅ Gigabyte X570 AORUS Series
- **Models**: X570 AORUS ELITE, X570 AORUS PRO
- **Controller**: IT5702 variants
- **Status**: Community tested

## 🧪 Community Tested Hardware

These devices work according to community reports:

### 💾 Memory Modules
- **Corsair Vengeance RGB Pro DDR5** - Working (limited testing)
- **Corsair Dominator Platinum RGB** - Partial support
- **G.Skill Trident Z RGB** - OpenRGB native support

### 🌪️ RGB Fans
- **Corsair iCUE RGB fans** - Via liquidctl
- **Thermaltake RGB fans** - Via motherboard
- **Cooler Master RGB fans** - OpenRGB compatible

### 🔧 Motherboards
- **ASUS ROG Strix B550** - OpenRGB compatible
- **MSI B550 Tomahawk** - Partial RGB support
- **ASRock B550M Pro4** - Basic RGB functionality

## ❓ Detection Process

### 🔍 Automatic Hardware Detection

The installer automatically detects:

```bash
# USB RGB Controllers
lsusb | grep -i -E "(rgb|led|corsair|aigo|cooler|deep|ite|gigabyte)"

# I2C Memory Modules  
sudo i2cdetect -y -r 0

# Motherboard RGB Controllers
openrgb --list-devices
```

### 📊 Detection Results Example

```
🔍 Hardware Detection Results:
USB RGB Controllers:
- ID 048d:5702 ITE RGB LED Controller
- ID 3633:0004 DeepCool AK500S-DIGITAL

I2C Devices (Bus 0):
- 0x5A: Corsair Memory Module 1
- 0x5B: Corsair Memory Module 2

OpenRGB Devices:
- Device 0: Corsair Vengeance Pro RGB
- Device 1: Corsair Vengeance Pro RGB  
- Device 2: B550M AORUS ELITE
```

## 🛠️ Manual Hardware Configuration

### Adding New Memory Modules

If your Corsair memory isn't detected:

1. **Check I2C addresses**:
```bash
sudo i2cdetect -y -r 0
```

2. **Look for devices at addresses**: 0x50-0x5F range

3. **Test communication**:
```bash
sudo i2cget -y 0 0x5A  # Should return a value
```

4. **Add to configuration** (if needed):
```python
# Add to src/detection/memory_scanner.py
CORSAIR_ADDRESSES = [0x5A, 0x5B, 0x5C, 0x5D]  # Add your address
```

### Adding New Motherboards

For unsupported motherboards:

1. **Check OpenRGB compatibility**:
```bash
sudo openrgb --list-devices
```

2. **Look for HID devices**:
```bash
ls /dev/hidraw*
sudo udevadm info /dev/hidraw*
```

3. **Test RGB control**:
```bash
sudo openrgb --device [N] --mode static --color FF0000
```

## 🔧 Hardware-Specific Setup

### Corsair Memory Setup

#### BIOS/UEFI Configuration
1. Enable **XMP/DOCP** profile
2. Set **Memory Frequency** to rated speed
3. Enable **RGB Lighting** (if available)
4. Disable **Fast Boot** temporarily

#### Linux Kernel Parameters
```bash
# Required for memory RGB detection
acpi_enforce_resources=lax
```

#### I2C Module Configuration
```bash
# Load I2C modules
sudo modprobe i2c-dev
sudo modprobe i2c-piix4

# Check loaded modules
lsmod | grep i2c
```

### AIGO Fans Setup

#### Motherboard Configuration
1. Connect fans to **RGB headers** (not PWM)
2. Set motherboard RGB to **Generic** mode in BIOS
3. Disable **Windows RGB software** if dual-booting

#### Detection Verification
```bash
# Should show motherboard RGB controller
sudo openrgb --list-devices | grep -i motherboard
```

### Gigabyte Motherboard Setup

#### BIOS Settings
1. **Advanced** → **Peripherals** → **RGB Fusion**
2. Set to **Enabled** or **Generic** mode
3. Disable **RGB Software Control** 

#### Linux Configuration
```bash
# Check HID device
ls -la /dev/hidraw*

# Test direct control
sudo openrgb --device [motherboard_id] --color 0000FF
```

## ⚠️ Known Issues & Workarounds

### Memory RGB Not Detected

**Symptoms**: OpenRGB doesn't show memory modules
**Cause**: ACPI SMBus conflicts
**Solution**: 
```bash
# Check if ACPI parameter is active
grep "acpi_enforce_resources=lax" /proc/cmdline

# If missing, reinstall or add manually
sudo nano /etc/default/grub
# Add: GRUB_CMDLINE_LINUX="acpi_enforce_resources=lax"
sudo update-grub
sudo reboot
```

### Fans Not Responding

**Symptoms**: Motherboard detected but fans don't change color
**Cause**: Wrong RGB mode or connection
**Solutions**:
1. Check physical connections to RGB headers
2. Set BIOS RGB mode to Generic/Manual
3. Test individual zones:
```bash
sudo openrgb --device 2 --zone 0 --color FF0000
sudo openrgb --device 2 --zone 1 --color 00FF00
```

### Permission Denied

**Symptoms**: "Operation not permitted" errors
**Cause**: Insufficient permissions for hardware access
**Solution**:
```bash
# Fix permissions
sudo chmod 666 /dev/hidraw*
sudo chmod 666 /dev/i2c-*

# Add user to groups
sudo usermod -a -G i2c $USER

# Reload udev rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

## 🆕 Adding New Hardware Support

### Contribute Your Hardware

Help expand compatibility:

1. **Generate hardware report**:
```bash
sudo rgb-controller --generate-report > my_hardware.txt
```

2. **Test detection**:
```bash
sudo ./scripts/detect_hardware.sh > detection_log.txt
```

3. **Submit GitHub issue** with:
   - Hardware specifications
   - Detection logs
   - Photos of RGB devices
   - Working/non-working status

### Development Testing

For developers adding new hardware:

```bash
# Test I2C communication
sudo python3 src/detection/test_protocols.py

# Test USB/HID detection  
sudo python3 src/detection/usb_scanner.py

# Test OpenRGB integration
sudo python3 src/openrgb_integration.py
```

## 📊 Hardware Database

Submit your hardware configuration to help others:

| Component | Model | Status | Contributor | Notes |
|-----------|-------|--------|-------------|-------|
| Memory | Corsair Vengeance RGB Pro DDR4 | ✅ Working | @guilherme | All modes |
| Fans | AIGO 120mm RGB 9-pack | ✅ Working | @guilherme | Via motherboard |
| Motherboard | Gigabyte B550M AORUS ELITE | ✅ Working | @guilherme | Full support |

**Add your hardware**: [Submit Issue](https://github.com/[username]/rgb-linux-controller/issues/new?template=hardware_report.md)

## 🔗 Related Projects

- **[OpenRGB](https://openrgb.org/)** - Core RGB device support
- **[liquidctl](https://github.com/liquidctl/liquidctl)** - Liquid cooling and RGB
- **[ckb-next](https://github.com/ckb-next/ckb-next)** - Corsair keyboards/mice

---

*Hardware compatibility is constantly expanding thanks to community contributions*