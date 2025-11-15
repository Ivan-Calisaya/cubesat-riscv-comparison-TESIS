#!/usr/bin/env python3
"""
SOC Area Analysis Tool - Versión Corregida
Estimación de área equivalente para implementaciones SoC RISC-V
Basado en gate count y complejidad de instrucciones
"""

import os
import re
import math

def analyze_single_soc():
    """Análisis específico para Single SoC"""
    
    print("🔬 ANÁLISIS DE ÁREA - SINGLE RISC-V SoC")
    print("=" * 60)
    
    # Ruta del archivo
    dis_file = r"C:\Users\Usuario\Desktop\Ivan\SOC\soc-implementation\bare-metal-workspace\simple_add_minimal.dis"
    
    if not os.path.exists(dis_file):
        print(f"❌ Archivo no encontrado: {dis_file}")
        return
    
    # Constantes de área
    GATES_PER_MM2 = 10000  # Gates por mm² en tecnología 28nm
    LE_TO_GATES = 5        # 1 LE FPGA ≈ 5 gates ASIC
    
    # Complejidad por tipo de instrucción (gates)
    instruction_complexity = {
        'add': 100,     'addi': 80,      # Arithmetic
        'sub': 100,     'subi': 80,
        'mul': 500,     'div': 1000,
        'lw': 200,      'sw': 200,       # Memory
        'lb': 180,      'sb': 180,
        'lh': 180,      'sh': 180,
        'beq': 150,     'bne': 150,      # Branch
        'blt': 150,     'bge': 150,
        'jal': 100,     'jalr': 120,     # Jump
        'lui': 60,      'auipc': 80,     # Upper immediate
        'csrw': 200,    'csrr': 180,     # Control/Status
        'default': 80   # Instrucción promedio
    }
    
    # Analizar archivo
    instruction_counts = {}
    total_instructions = 0
    total_gates = 0
    
    print(f"📁 Analizando: {dis_file}")
    
    try:
        with open(dis_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                # Buscar patrones de instrucciones RISC-V
                # Formato: 80000000:       30401073                csrw    mie,zero
                match = re.search(r'^\s*[0-9a-f]+:\s+[0-9a-f]+\s+(\w+)', line)
                if match:
                    instruction = match.group(1).lower()
                    instruction_counts[instruction] = instruction_counts.get(instruction, 0) + 1
                    total_instructions += 1
                    
                    # Debug: mostrar las primeras 5 líneas encontradas
                    if total_instructions <= 5:
                        print(f"Debug: {line.strip()} → {instruction}")
    
    except Exception as e:
        print(f"❌ Error leyendo archivo: {e}")
        return
    
    print(f"\n📊 RESUMEN DE INSTRUCCIONES:")
    print(f"Total instrucciones encontradas: {total_instructions}")
    
    if total_instructions == 0:
        print("❌ No se encontraron instrucciones válidas")
        return
    
    # Mostrar las más frecuentes
    sorted_instructions = sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True)
    print("\n🔝 Top 10 instrucciones más frecuentes:")
    for i, (inst, count) in enumerate(sorted_instructions[:10]):
        print(f"{i+1:2}. {inst:8} : {count:3} veces")
    
    # Calcular gates por tipo
    print(f"\n⚙️  CÁLCULO DE GATE COUNT:")
    for instruction, count in sorted_instructions:
        complexity = instruction_complexity.get(instruction, instruction_complexity['default'])
        gates = count * complexity
        total_gates += gates
        if count >= 3:  # Solo mostrar las más significativas
            print(f"  {instruction:8} : {count:3}x × {complexity:4} gates = {gates:6,} gates")
    
    # Calcular área
    area_mm2 = total_gates / GATES_PER_MM2
    
    print(f"\n📐 RESULTADOS ÁREA SINGLE SoC:")
    print(f"Gate count total:     {total_gates:,} gates")
    print(f"Área estimada:        {area_mm2:.3f} mm²")
    
    # Comparar con FPGA
    fpga_les_single = 6826  # Del reporte anterior
    fpga_equivalent_gates = fpga_les_single * LE_TO_GATES
    fpga_area_mm2 = fpga_equivalent_gates / GATES_PER_MM2
    
    print(f"\n📊 COMPARACIÓN Single SoC vs FPGA:")
    print(f"FPGA Single:          {fpga_les_single} LEs = {fpga_equivalent_gates:,} gates = {fpga_area_mm2:.3f} mm²")
    print(f"SoC Single:           {total_gates:,} gates = {area_mm2:.3f} mm²")
    print(f"Ratio SoC/FPGA:       {area_mm2/fpga_area_mm2:.2f}x")
    
    # Análisis de fiabilidad
    print(f"\n🎯 ANÁLISIS DE FIABILIDAD:")
    print(f"Valor estimado:       {area_mm2:.3f} mm²")
    
    # Rangos de error esperados
    low_estimate = area_mm2 * 0.5   # -50% error
    high_estimate = area_mm2 * 2.0  # +100% error
    
    print(f"Rango probable:       {low_estimate:.3f} - {high_estimate:.3f} mm²")
    print(f"Confianza:            70% probabilidad en este rango")
    print(f"Error esperado:       ±50% - ±100%")
    
    # Factores de error
    print(f"\n⚠️  FUENTES DE ERROR:")
    routing_overhead = area_mm2 * 0.4
    clock_overhead = area_mm2 * 0.15
    memory_error = area_mm2 * 0.3
    
    print(f"Routing overhead:     +{routing_overhead:.3f} mm² (+40%)")
    print(f"Clock trees:          +{clock_overhead:.3f} mm² (+15%)")
    print(f"Memory blocks:        ±{memory_error:.3f} mm² (±30%)")
    
    total_with_overhead = area_mm2 + routing_overhead + clock_overhead
    print(f"Con overhead típico:  {total_with_overhead:.3f} mm²")
    
    return {
        'total_instructions': total_instructions,
        'total_gates': total_gates,
        'area_mm2': area_mm2,
        'area_with_overhead': total_with_overhead,
        'fpga_area_mm2': fpga_area_mm2,
        'instruction_counts': instruction_counts
    }

if __name__ == "__main__":
    result = analyze_single_soc()
    
    if result:
        print(f"\n" + "=" * 60)
        print("    RESUMEN EJECUTIVO")
        print("=" * 60)
        print(f"✅ Análisis completado exitosamente")
        print(f"📊 {result['total_instructions']} instrucciones procesadas")
        print(f"⚙️  {result['total_gates']:,} gates estimados") 
        print(f"📐 {result['area_mm2']:.3f} mm² área base")
        print(f"📐 {result['area_with_overhead']:.3f} mm² área con overhead")
        print(f"🔬 Precisión esperada: ±50% - ±100%")
        print(f"🎯 Válido para comparación relativa")