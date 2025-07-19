#!/bin/bash

# RGB Linux Controller - Quick Start Examples
# Basic usage examples for RGB control

echo "🌈 RGB Linux Controller - Quick Start Examples"
echo "================================================"

# Check if script is run as root
if [[ $EUID -ne 0 ]]; then
   echo "❌ Please run as root: sudo $0"
   exit 1
fi

echo "📋 Listing detected RGB devices..."
rgb-controller --list

echo ""
echo "🎨 Basic color examples:"

echo "Setting all devices to RED..."
rgb-controller red
sleep 3

echo "Setting all devices to BLUE..."
rgb-controller blue  
sleep 3

echo "Setting all devices to GREEN..."
rgb-controller green
sleep 3

echo ""
echo "✨ Effect examples:"

echo "Purple with breathing effect..."
rgb-controller purple --mode Breathing
sleep 5

echo "Cyan with color pulse..."
rgb-controller cyan --mode "Color Pulse"
sleep 5

echo ""
echo "🌈 Advanced examples:"

echo "Custom hex color..."
rgb-controller "#FF6600"  # Orange
sleep 3

echo "Rainbow wave effect..."
rgb-controller rainbow --mode "Rainbow Wave"
sleep 5

echo ""
echo "🎉 Demo complete! Use 'rgb-controller --help' for more options."
echo "💡 Try: rgb-controller [color] --mode [effect]"