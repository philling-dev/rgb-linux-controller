#!/usr/bin/env python3
"""
Controlador RGB Completo via OpenRGB
Controla: Memórias Corsair + Ventoinhas AIGO + Placa-mãe
"""

import subprocess
import argparse
import os

class OpenRGBFullController:
    def __init__(self):
        self.devices = {
            'memory1': 0,      # Corsair Vengeance Pro RGB (0x5A)
            'memory2': 1,      # Corsair Vengeance Pro RGB (0x5B) 
            'motherboard': 2   # B550M AORUS ELITE (ventoinhas)
        }
    
    def check_root(self):
        """Verifica se está executando como root"""
        if os.geteuid() != 0:
            print("❌ Este script precisa ser executado como root")
            return False
        return True
    
    def hex_to_rgb(self, hex_color):
        """Converte hex para OpenRGB format"""
        hex_color = hex_color.lstrip('#')
        return hex_color.upper()
    
    def get_color_hex(self, color):
        """Converte string de cor para hex OpenRGB"""
        if isinstance(color, str):
            if color.startswith('#'):
                return self.hex_to_rgb(color)
            else:
                colors = {
                    'red': 'FF0000',
                    'green': '00FF00',
                    'blue': '0000FF',
                    'white': 'FFFFFF',
                    'purple': '800080',
                    'yellow': 'FFFF00',
                    'cyan': '00FFFF',
                    'orange': 'FF6500',
                    'pink': 'FF69B4',
                    'off': '000000'
                }
                return colors.get(color.lower(), 'FFFFFF')
        return color
    
    def control_device(self, device_id, color, mode='Static'):
        """Controla dispositivo específico via OpenRGB"""
        hex_color = self.get_color_hex(color)
        
        cmd = [
            'openrgb',
            '--device', str(device_id),
            '--mode', mode,
            '--color', hex_color
        ]
        
        try:
            result = subprocess.run(cmd, capture_output=True, text=True)
            return result.returncode == 0, result.stderr
        except Exception as e:
            return False, str(e)
    
    def sync_all(self, color, mode='Static'):
        """Sincroniza cor em todos os dispositivos"""
        print("🌈 CONTROLE RGB COMPLETO VIA OPENRGB")
        print("=" * 55)
        print(f"🎯 Aplicando cor: {color}")
        print(f"🎭 Modo: {mode}")
        print("-" * 55)
        
        results = {}
        
        # Controla memórias
        print("🧠 Controlando memórias Corsair...")
        for i, (name, device_id) in enumerate([('memory1', 0), ('memory2', 1)]):
            success, error = self.control_device(device_id, color, mode)
            results[name] = success
            
            if success:
                print(f"   ✅ Memória {i+1} configurada")
            else:
                print(f"   ❌ Erro na memória {i+1}: {error}")
        
        # Controla ventoinhas/placa-mãe
        print("🌪️  Controlando ventoinhas AIGO...")
        success, error = self.control_device(2, color, mode)
        results['motherboard'] = success
        
        if success:
            print("   ✅ Ventoinhas/placa-mãe configuradas")
        else:
            print(f"   ❌ Erro nas ventoinhas: {error}")
        
        print("-" * 55)
        
        # Resumo
        success_count = sum(results.values())
        total_devices = len(results)
        
        if success_count == total_devices:
            print("🎉 SUCESSO TOTAL: Todos os dispositivos configurados!")
        elif success_count > 0:
            print(f"⚠️  SUCESSO PARCIAL: {success_count}/{total_devices} dispositivos")
        else:
            print("❌ FALHA: Nenhum dispositivo configurado")
        
        return success_count > 0
    
    def list_devices(self):
        """Lista dispositivos via OpenRGB"""
        print("📋 DISPOSITIVOS RGB DETECTADOS")
        print("=" * 40)
        
        try:
            result = subprocess.run(['openrgb', '--list-devices'], 
                                  capture_output=True, text=True)
            
            if result.returncode == 0:
                lines = result.stdout.split('\n')
                current_device = None
                
                for line in lines:
                    line = line.strip()
                    if line and ':' in line and not line.startswith('['):
                        if line[0].isdigit():
                            # Nova linha de dispositivo
                            parts = line.split(': ', 1)
                            if len(parts) == 2:
                                device_num = parts[0]
                                device_name = parts[1]
                                print(f"\n🔸 Dispositivo {device_num}: {device_name}")
                                current_device = device_num
                        else:
                            # Informações do dispositivo
                            print(f"   {line}")
            else:
                print("❌ Erro ao listar dispositivos")
                
        except Exception as e:
            print(f"❌ Erro: {e}")
    
    def demo_effects(self, color='red'):
        """Demonstra diferentes efeitos"""
        print("🎪 DEMONSTRAÇÃO DE EFEITOS")
        print("=" * 40)
        
        effects = ['Static', 'Breathing', 'Rainbow Wave', 'Color Pulse']
        
        for effect in effects:
            print(f"\n🎭 Testando efeito: {effect}")
            
            if effect == 'Rainbow Wave':
                # Para rainbow wave, não precisa de cor específica
                for device_id in [0, 1, 2]:
                    subprocess.run(['openrgb', '--device', str(device_id), 
                                  '--mode', effect], capture_output=True)
            else:
                self.sync_all(color, effect)
            
            input("   ⌨️  Pressione Enter para próximo efeito...")

def main():
    controller = OpenRGBFullController()
    
    parser = argparse.ArgumentParser(
        description='Controlador RGB Completo via OpenRGB',
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Cores disponíveis:
  red, green, blue, white, purple, yellow, cyan, orange, pink, off
  ou código hex: #FF0000, #00FF00, #0000FF

Modos disponíveis:
  Static, Breathing, 'Rainbow Wave', 'Color Pulse', 'Color Shift'

Exemplos:
  sudo python3 openrgb_full_control.py blue
  sudo python3 openrgb_full_control.py red --mode Breathing
  sudo python3 openrgb_full_control.py --list
  sudo python3 openrgb_full_control.py --demo
        """
    )
    
    parser.add_argument('color', nargs='?', help='Cor para aplicar')
    parser.add_argument('--mode', default='Static', 
                       help='Modo RGB (Static, Breathing, etc.)')
    parser.add_argument('--list', action='store_true', 
                       help='Lista dispositivos detectados')
    parser.add_argument('--demo', action='store_true', 
                       help='Demonstração de efeitos')
    
    args = parser.parse_args()
    
    # Verificações
    if not controller.check_root():
        return
    
    if args.list:
        controller.list_devices()
        return
    
    if args.demo:
        controller.demo_effects()
        return
    
    if not args.color:
        parser.print_help()
        return
    
    # Executa controle
    controller.sync_all(args.color, args.mode)

if __name__ == "__main__":
    main()