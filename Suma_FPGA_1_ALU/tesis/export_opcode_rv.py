#!/usr/bin/env python3
"""
Script para convertir un archivo binario RISC-V a formato hexadecimal
para ser cargado en la memoria de instrucciones de ModelSim.
Cada línea contiene una instrucción de 32 bits en formato hexadecimal.
"""

import sys
import struct

def bin_to_hex(bin_file, hex_file):
    """Convierte archivo .bin a formato .hex para ModelSim"""
    try:
        with open(bin_file, 'rb') as f:
            binary_data = f.read()
        
        # Asegurar que el tamaño sea múltiplo de 4 bytes (32 bits)
        while len(binary_data) % 4 != 0:
            binary_data += b'\x00'
        
        with open(hex_file, 'w') as f:
            # Procesar en chunks de 4 bytes (32 bits)
            for i in range(0, len(binary_data), 4):
                # Leer 4 bytes y convertir a entero little-endian
                instruction = struct.unpack('<I', binary_data[i:i+4])[0]
                # Escribir como hexadecimal de 8 dígitos
                f.write(f"{instruction:08x}\n")
        
        print(f"Conversión exitosa: {bin_file} -> {hex_file}")
        
    except FileNotFoundError:
        print(f"Error: No se pudo encontrar el archivo {bin_file}")
        sys.exit(1)
    except Exception as e:
        print(f"Error durante la conversión: {e}")
        sys.exit(1)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Uso: python3 export_opcode_rv.py <archivo.bin> <archivo.hex>")
        sys.exit(1)
    
    bin_file = sys.argv[1]
    hex_file = sys.argv[2]
    
    bin_to_hex(bin_file, hex_file)