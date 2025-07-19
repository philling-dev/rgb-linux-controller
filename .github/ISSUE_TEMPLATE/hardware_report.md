---
name: Hardware Report
about: Report new hardware compatibility or issues
title: '[HARDWARE] Device Name - Model'
labels: hardware
assignees: ''
---

## Hardware Information

**Device Type**: Memory / Fans / Motherboard / Other

**Manufacturer**: 
**Model**: 
**Connection**: USB / I2C / HID / Other

## System Information

**Distribution**: Ubuntu/Mint/Pop!_OS version
**Kernel**: `uname -a`
**Architecture**: x86_64 / ARM

## Detection Results

```bash
# USB devices
lsusb | grep -i rgb

# I2C devices  
sudo i2cdetect -l
sudo i2cdetect -y -r 0

# OpenRGB detection
sudo openrgb --list-devices
```

## Working Status

- [ ] Device detected automatically
- [ ] RGB control works
- [ ] All modes/effects work
- [ ] Installation was successful

## Issues Found

Describe any problems:

## Additional Information

- BIOS/UEFI settings used
- Special configuration needed
- Photos of RGB devices (if helpful)

## Logs

```bash
# Installation log
sudo tail -50 /var/log/rgb-linux-installer.log

# RGB controller test
sudo rgb-controller --list
```