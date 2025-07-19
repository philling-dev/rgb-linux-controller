#!/bin/bash

# Script de Detecção Automática de Hardware RGB
# Criado para Linux Mint / Ubuntu

echo "🔍 Iniciando detecção de hardware RGB..."
echo "=================================================="

# Verificar se está rodando como root para comandos que precisam
if [[ $EUID -eq 0 ]]; then
   echo "⚠️  Rodando como root - alguns comandos podem ser perigosos"
fi

echo ""
echo "📋 1. DISPOSITIVOS USB CONECTADOS"
echo "----------------------------------"
echo "Listando todos os dispositivos USB:"
lsusb

echo ""
echo "🔍 Dispositivos RGB potenciais encontrados:"
lsusb | grep -i -E "(rgb|led|corsair|aigo|cooler|deep|ite|gigabyte)"

echo ""
echo "📋 2. INFORMAÇÕES DETALHADAS DA MEMÓRIA RAM"
echo "-------------------------------------------"
if command -v dmidecode &> /dev/null; then
    echo "Fabricantes de memória detectados:"
    sudo dmidecode -t memory | grep -E "(Manufacturer|Product|Serial)" | head -20
else
    echo "⚠️  dmidecode não disponível"
fi

if command -v lshw &> /dev/null; then
    echo ""
    echo "Detalhes das memórias instaladas:"
    sudo lshw -class memory -short
else
    echo "⚠️  lshw não disponível"
fi

echo ""
echo "📋 3. INTERFACES I2C DISPONÍVEIS"
echo "--------------------------------"
if command -v i2cdetect &> /dev/null; then
    echo "Interfaces I2C detectadas:"
    sudo i2cdetect -l 2>/dev/null || echo "❌ Erro ao listar interfaces I2C"
else
    echo "⚠️  i2c-tools não instalado"
fi

echo ""
echo "📋 4. DISPOSITIVOS PCI (PLACA DE VÍDEO E ÁUDIO)"
echo "-----------------------------------------------"
echo "Placa de vídeo:"
lspci | grep -i vga
echo ""
echo "Dispositivos de áudio:"
lspci | grep -i audio

echo ""
echo "📋 5. VERIFICANDO FERRAMENTAS RGB INSTALADAS"
echo "--------------------------------------------"

# Verificar OpenRGB
if command -v openrgb &> /dev/null; then
    echo "✅ OpenRGB encontrado"
    echo "Versão: $(openrgb --version 2>/dev/null || echo 'Não foi possível determinar')"
    echo ""
    echo "Dispositivos RGB detectados pelo OpenRGB:"
    openrgb --list-devices 2>/dev/null || echo "❌ Erro ao executar OpenRGB"
else
    echo "❌ OpenRGB não instalado"
fi

echo ""

# Verificar liquidctl
if command -v liquidctl &> /dev/null; then
    echo "✅ liquidctl encontrado"
    echo "Versão: $(liquidctl --version 2>/dev/null || echo 'Não foi possível determinar')"
    echo ""
    echo "Dispositivos detectados pelo liquidctl:"
    liquidctl list 2>/dev/null || echo "❌ Erro ao executar liquidctl"
else
    echo "❌ liquidctl não instalado"
fi

echo ""
echo "📋 6. MÓDULOS DO KERNEL RELACIONADOS"
echo "-----------------------------------"
echo "Módulos I2C carregados:"
lsmod | grep i2c

echo ""
echo "Módulos USB HID carregados:"
lsmod | grep -E "(hid|usb)"

echo ""
echo "📋 7. DISPOSITIVOS HID (HUMAN INTERFACE DEVICE)"
echo "-----------------------------------------------"
if [ -d "/dev/hidraw*" ]; then
    echo "Dispositivos HID raw encontrados:"
    ls -la /dev/hidraw* 2>/dev/null || echo "Nenhum dispositivo hidraw encontrado"
else
    echo "Nenhum dispositivo HID raw encontrado"
fi

echo ""
echo "📋 8. RESUMO E RECOMENDAÇÕES"
echo "============================"

# Verificar se as principais ferramentas estão instaladas
OPENRGB_INSTALLED=$(command -v openrgb &> /dev/null && echo "1" || echo "0")
LIQUIDCTL_INSTALLED=$(command -v liquidctl &> /dev/null && echo "1" || echo "0")
I2C_TOOLS_INSTALLED=$(command -v i2cdetect &> /dev/null && echo "1" || echo "0")

echo "Status das ferramentas:"
echo "- OpenRGB: $([ $OPENRGB_INSTALLED -eq 1 ] && echo '✅ Instalado' || echo '❌ Não instalado')"
echo "- liquidctl: $([ $LIQUIDCTL_INSTALLED -eq 1 ] && echo '✅ Instalado' || echo '❌ Não instalado')"
echo "- i2c-tools: $([ $I2C_TOOLS_INSTALLED -eq 1 ] && echo '✅ Instalado' || echo '❌ Não instalado')"

echo ""
echo "Para instalar as ferramentas faltantes:"
if [ $OPENRGB_INSTALLED -eq 0 ]; then
    echo "# Instalar OpenRGB:"
    echo "wget https://openrgb.org/releases/release_0.9/openrgb_0.9_amd64_bookworm_b5f46e3.deb"
    echo "sudo dpkg -i openrgb_0.9_amd64_bookworm_b5f46e3.deb"
    echo "sudo apt-get install -f -y"
    echo ""
fi

if [ $LIQUIDCTL_INSTALLED -eq 0 ]; then
    echo "# Instalar liquidctl:"
    echo "sudo apt install liquidctl"
    echo ""
fi

if [ $I2C_TOOLS_INSTALLED -eq 0 ]; then
    echo "# Instalar i2c-tools:"
    echo "sudo apt install i2c-tools"
    echo ""
fi

echo "🎯 Detecção concluída!"
echo "Consulte o arquivo DETECCAO_RGB_HARDWARE.md para análise completa dos resultados."