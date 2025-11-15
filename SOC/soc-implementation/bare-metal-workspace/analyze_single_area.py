#!/usr/bin/env python3
"""
Single SoC Area Analysis - Versión Específica
Análisis de área exclusivo para Single RISC-V SoC
"""

import re
import os

def analyze_single_soc():
    """Análisis específico para Single SoC"""
    
    print("ANALISIS DE AREA - SINGLE RISC-V SoC")
    print("=" * 60)
    
    # Ruta relativa al archivo .dis en el mismo directorio
    dis_file = "simple_add_minimal.dis"
    
    # Constantes específicas para Single (60nm Cyclone IV)
    GATES_PER_MM2 = 3000   # 60nm technology density
    LE_TO_GATES = 5.0      # Factor estándar industria
    FPGA_LES_SINGLE = 6826 # Del reporte Quartus
    
    instruction_complexity = {
        'add': 100, 'addi': 80, 'sub': 100, 'subi': 80,
        'mul': 500, 'div': 1000,
        'lw': 200, 'sw': 200, 'lb': 180, 'sb': 180, 'lh': 180, 'sh': 180,
        'beq': 150, 'bne': 150, 'blt': 150, 'bge': 150,
        'jal': 100, 'jalr': 120,
        'lui': 60, 'auipc': 80,
        'csrw': 200, 'csrr': 180, 'csrwi': 180,
        'wfi': 80, 'li': 80, 'j': 80, 'ret': 80, 'ori': 80,
        'default': 80
    }
    
    if not os.path.exists(dis_file):
        print(f"Archivo no encontrado: {dis_file}")
        print("Asegurate de ejecutar este script desde el directorio que contiene el archivo .dis")
        return None
    
    print(f"Analizando: {dis_file}")
    
    # Leer y procesar archivo
    try:
        encodings = ['utf-8-sig', 'utf-8', 'utf-16', 'latin1']
        content = None
        
        for encoding in encodings:
            try:
                with open(dis_file, 'r', encoding=encoding) as f:
                    content = f.read()
                print(f"Archivo leido con encoding: {encoding}")
                break
            except:
                continue
        
        if not content:
            print("No se pudo leer el archivo")
            return None
        
        # Analizar instrucciones
        lines = content.split('\n')
        instruction_counts = {}
        total_instructions = 0
        
        for line in lines:
            patterns = [
                r'^\s*([0-9a-f]+):\s+[0-9a-f]+\s+(\w+)',
                r'^([0-9a-f]+):\s+[0-9a-f]+\s+(\w+)',
            ]
            
            for pattern in patterns:
                match = re.search(pattern, line, re.IGNORECASE)
                if match:
                    instruction = match.group(2).lower()
                    instruction_counts[instruction] = instruction_counts.get(instruction, 0) + 1
                    total_instructions += 1
                    break
        
        if total_instructions == 0:
            print("No se encontraron instrucciones validas")
            return None
        
        print(f"Total instrucciones encontradas: {total_instructions}")
        
        # Mostrar top instrucciones
        sorted_instructions = sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True)
        print(f"\nTop 10 instrucciones mas frecuentes:")
        
        total_gates = 0
        for i, (inst, count) in enumerate(sorted_instructions[:10]):
            complexity = instruction_complexity.get(inst, instruction_complexity['default'])
            gates = count * complexity
            total_gates += gates
            print(f"{i+1:2}. {inst:8} : {count:3}x × {complexity:4} gates = {gates:6,} gates")
        
        # Agregar resto de instrucciones
        for inst, count in instruction_counts.items():
            if inst not in [x[0] for x in sorted_instructions[:10]]:
                complexity = instruction_complexity.get(inst, instruction_complexity['default'])
                total_gates += count * complexity
        
        # Calcular área
        area_mm2 = total_gates / GATES_PER_MM2
        
        print(f"\nRESULTADOS SINGLE SoC:")
        print(f"Gate count total:     {total_gates:,} gates")
        print(f"Area estimada:        {area_mm2:.4f} mm²")
        
        # Comparar con FPGA
        fpga_gates = FPGA_LES_SINGLE * LE_TO_GATES
        fpga_area = fpga_gates / GATES_PER_MM2
        
        print(f"\nCOMPARACION SINGLE FPGA vs SoC:")
        print(f"FPGA Single:          {FPGA_LES_SINGLE} LEs = {fpga_gates:,.0f} gates = {fpga_area:.4f} mm²")
        print(f"SoC Single:           {total_gates:,} gates = {area_mm2:.4f} mm²")
        print(f"Ratio SoC/FPGA:       {area_mm2/fpga_area:.2f}x")
        
        if area_mm2 < fpga_area:
            efficiency = ((fpga_area - area_mm2) / fpga_area) * 100
            print(f"SoC Single es {efficiency:.1f}% mas eficiente en area que FPGA Single")
        else:
            overhead = ((area_mm2 - fpga_area) / fpga_area) * 100
            print(f"SoC Single consume {overhead:.1f}% mas area que FPGA Single")
        
        # Análisis de precisión específico para Single
        print(f"\nANALISIS DE PRECISION SINGLE:")
        optimista = area_mm2 * 0.6
        probable = area_mm2
        pesimista = area_mm2 * 1.8
        rango_min = area_mm2 * 0.5
        rango_max = area_mm2 * 2.0
        
        print(f"┌─────────────────────────────────────────────────────────┐")
        print(f"│ Escenario   │ Valor Real Probable │ Confianza           │")
        print(f"├─────────────────────────────────────────────────────────┤")
        print(f"│ Optimista   │ {optimista:.4f} mm² (-40%)   │ 15%                 │")
        print(f"│ Probable    │ {probable:.4f} mm² (±0%)    │ 40%                 │")
        print(f"│ Pesimista   │ {pesimista:.4f} mm² (+80%)   │ 15%                 │")
        print(f"│ Rango Total │ {rango_min:.4f} - {rango_max:.4f} mm² │ 70%                 │")
        print(f"└─────────────────────────────────────────────────────────┘")
        
        # Recomendaciones específicas Single
        print(f"\nRECOMENDACIONES SINGLE SoC:")
        print(f"Ideal para: Aplicaciones power-constrained")
        print(f"Ventajas: Maxima eficiencia de area vs FPGA")
        print(f"Limitacion: Sin tolerancia a fallos")
        print(f"Uso CubeSat: Misiones basicas, bajo presupuesto energia")
        
        return {
            'total_instructions': total_instructions,
            'total_gates': total_gates,
            'area_mm2': area_mm2,
            'fpga_area': fpga_area,
            'efficiency_vs_fpga': efficiency if area_mm2 < fpga_area else -overhead
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def main():
    """Función principal"""
    print("SINGLE SoC AREA ANALYZER")
    print("Analisis especifico de area para Single RISC-V")
    print()
    
    result = analyze_single_soc()
    
    if result:
        print(f"\n" + "=" * 60)
        print("    RESUMEN EJECUTIVO SINGLE")
        print("=" * 60)
        print(f"Analisis completado exitosamente")
        print(f"{result['total_instructions']} instrucciones analizadas")
        print(f"{result['total_gates']:,} gates estimados")
        print(f"{result['area_mm2']:.4f} mm² area estimada")
        print(f"{result['efficiency_vs_fpga']:.1f}% eficiencia vs FPGA")
        print(f"Precision: ±50-100% (valido para comparacion)")

if __name__ == "__main__":
    main()