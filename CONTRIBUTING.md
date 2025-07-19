# Contributing to RGB Linux Controller

Thank you for your interest in contributing to RGB Linux Controller! This document provides guidelines for contributing to the project.

## 🚀 Quick Start

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/amazing-feature`
3. Make your changes
4. Test thoroughly
5. Commit with clear messages: `git commit -m 'Add amazing feature'`
6. Push to your branch: `git push origin feature/amazing-feature`
7. Open a Pull Request

## 🎯 Types of Contributions

### 🔧 Hardware Support
- Adding support for new RGB devices
- Improving existing device protocols
- Hardware compatibility testing

### 🐛 Bug Fixes
- Fixing device detection issues
- Resolving permission problems
- Correcting installation scripts

### 📚 Documentation
- Improving setup guides
- Adding troubleshooting steps
- Hardware compatibility lists

### ✨ Features
- New RGB effects
- Better user interfaces
- Performance improvements

## 🧪 Testing Guidelines

### Hardware Testing
Before submitting hardware support:

1. Test on clean Ubuntu/Mint installation
2. Document hardware specifications
3. Verify detection and control functionality
4. Test with different RGB modes

### Code Testing
```bash
# Run detection tests
sudo python3 src/detection/test_protocols.py

# Test installation script
sudo ./install_rgb_linux.sh

# Verify device control
sudo rgb-controller --list
sudo rgb-controller blue
```

## 📝 Hardware Support Submission

When adding new hardware support, include:

### 1. Hardware Information
```bash
# Device details
lsusb -v -d [vendor:product]
sudo i2cdetect -l
sudo i2cdetect -y -r [bus]

# System information  
lsb_release -a
uname -a
```

### 2. Detection Code
- Add detection logic to `src/detection/`
- Update hardware database
- Include fallback methods

### 3. Protocol Implementation
- Implement in `src/protocols/`
- Document command structure
- Add error handling

### 4. Testing Results
- Provide before/after photos
- Test multiple modes/colors
- Document any limitations

## 🎨 Code Style

### Python
- Follow PEP 8
- Use meaningful variable names
- Add docstrings for functions
- Handle exceptions properly

```python
def detect_corsair_memory():
    """
    Detect Corsair RGB memory modules via I2C scan.
    
    Returns:
        list: Detected memory modules with addresses
    """
    try:
        # Implementation
        pass
    except Exception as e:
        log_error(f"Memory detection failed: {e}")
        return []
```

### Shell Scripts
- Use `set -e` for error handling
- Quote variables: `"$variable"`
- Add comments for complex logic
- Test on multiple distributions

```bash
#!/bin/bash
set -e

detect_hardware() {
    local device_type="$1"
    echo "Detecting $device_type devices..."
    
    # Implementation
}
```

## 🗂️ File Organization

```
src/
├── controllers/           # Device-specific controllers
│   ├── corsair.py        # Corsair memory/devices
│   ├── aigo.py           # AIGO fans
│   └── gigabyte.py       # Gigabyte motherboards
├── detection/            # Hardware detection
│   ├── i2c_scanner.py    # I2C device detection
│   ├── usb_scanner.py    # USB device detection
│   └── auto_detect.py    # Main detection logic
├── protocols/            # Communication protocols
│   ├── i2c_protocol.py   # I2C communication
│   ├── hid_protocol.py   # HID communication
│   └── openrgb_proto.py  # OpenRGB integration
└── utils/                # Utility functions
    ├── colors.py         # Color conversion
    ├── logging.py        # Logging utilities
    └── permissions.py    # Permission handling
```

## 🐛 Bug Reports

When reporting bugs, include:

### System Information
```bash
# Distribution
lsb_release -a

# Kernel version
uname -a

# Installation method
cat /var/log/rgb-linux-installer.log | tail -50
```

### Hardware Information
```bash
# RGB devices
sudo openrgb --list-devices

# I2C devices
sudo i2cdetect -l

# USB devices
lsusb | grep -i rgb
```

### Error Details
- Complete error messages
- Steps to reproduce
- Expected vs actual behavior
- Screenshots if relevant

## 📋 Pull Request Checklist

- [ ] Code follows project style guidelines
- [ ] Changes are tested on target hardware
- [ ] Documentation is updated
- [ ] Commit messages are clear
- [ ] No sensitive information in commits
- [ ] Hardware compatibility is documented

## 🎪 New Feature Proposals

For major features, please:

1. Open an issue first to discuss
2. Provide use case and benefits
3. Consider backward compatibility
4. Plan testing approach

## 📞 Getting Help

- **Issues**: Use GitHub issues for bugs and feature requests
- **Discussions**: Use GitHub discussions for questions
- **Email**: Contact maintainer for sensitive issues

## 🏆 Recognition

Contributors will be recognized in:
- README.md contributors section
- Release notes
- Project documentation

Thank you for helping make RGB control accessible on Linux! 🌈