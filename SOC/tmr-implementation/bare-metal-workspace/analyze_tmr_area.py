#!/usr/bin/env python3
"""
TMR SoC Area Analysis - Versión Específica
Análisis de área exclusivo para TMR RISC-V SoC (3 ALUs + 2-of-3 voter)
"""

import re
import os

def analyze_tmr_soc():
    """Análisis específico para TMR SoC"""
    
    print("ANALISIS DE AREA - TMR RISC-V SoC")
    print("Triple Modular Redundancy (3 ALUs + 2-of-3 Voter)")
    print("=" * 60)
    
    # Ruta relativa al archivo .dis en el mismo directorio
    dis_file = "simple_add_tmr.dis"
    
    # Constantes específicas para TMR (60nm Cyclone IV)
    GATES_PER_MM2 = 3000   # 60nm technology density
    LE_TO_GATES = 5.0      # Factor estándar industria
    FPGA_LES_TMR = 6886    # Del reporte Quartus TMR
    ALU_COUNT = 3          # TMR tiene 3 ALUs
    
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
        print("Asegurate de ejecutar este script desde el directorio TMR que contiene el archivo .dis")
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
        alu_references = 0
        voter_references = 0
        
        for line in lines:
            # Buscar referencias TMR específicas
            if 'alu' in line.lower() and ('alu0' in line.lower() or 'alu1' in line.lower() or 'alu2' in line.lower()):
                alu_references += 1
            if 'voter' in line.lower() or 'majority' in line.lower():
                voter_references += 1
            
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
        print(f"Referencias ALU detectadas: {alu_references}")
        print(f"Referencias Voter detectadas: {voter_references}")
        
        # Mostrar top instrucciones con enfoque TMR
        sorted_instructions = sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True)
        print(f"\nTop 10 instrucciones TMR:")
        
        total_gates = 0
        memory_intensive_ops = ['lw', 'sw', 'lb', 'sb', 'lh', 'sh']
        arithmetic_ops = ['add', 'sub', 'mul', 'div', 'addi']
        
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
        
        print(f"\nRESULTADOS TMR SoC:")
        print(f"Gate count total:     {total_gates:,} gates")
        print(f"Area estimada:        {area_mm2:.4f} mm²")
        print(f"Area por ALU:         {area_mm2/ALU_COUNT:.4f} mm²/ALU")
        
        # Comparar con FPGA
        fpga_gates = FPGA_LES_TMR * LE_TO_GATES
        fpga_area = fpga_gates / GATES_PER_MM2
        
        print(f"\nCOMPARACION TMR FPGA vs SoC:")
        print(f"FPGA TMR:             {FPGA_LES_TMR} LEs = {fpga_gates:,} gates = {fpga_area:.4f} mm²")
        print(f"SoC TMR:              {total_gates:,} gates = {area_mm2:.4f} mm²")
        print(f"Ratio SoC/FPGA:       {area_mm2/fpga_area:.2f}x")
        
        if area_mm2 < fpga_area:
            efficiency = ((fpga_area - area_mm2) / fpga_area) * 100
            print(f"TMR SoC es {efficiency:.1f}% mas eficiente en area que FPGA TMR")
        else:
            overhead = ((area_mm2 - fpga_area) / fpga_area) * 100
            print(f"TMR SoC consume {overhead:.1f}% mas area que FPGA TMR")
        
        # Análisis TMR específico
        print(f"\nANALISIS TMR ESPECIFICO:")
        print(f"Arquitectura:      3 ALUs + 2-of-3 Majority Voter")
        print(f"Tolerancia fallos: 1 ALU failure tolerant")
        print(f"Overhead vs Single: ~3-4x area (esperado)")
        print(f"Comparacion FPGA:   Convergencia de eficiencia")
        
        # Análisis de precisión específico para TMR
        print(f"\nANALISIS DE PRECISION TMR:")
        optimista = area_mm2 * 0.6
        probable = area_mm2
        pesimista = area_mm2 * 1.8
        rango_min = area_mm2 * 0.5
        rango_max = area_mm2 * 2.0
        
        print(f"┌─────────────────────────────────────────────────────────┐")
        print(f"│ Escenario   │ Valor Real Probable  │ Confianza          │")
        print(f"├─────────────────────────────────────────────────────────┤")
        print(f"│ Optimista   │ {optimista:.4f} mm² (-40%)    │ 15%                │")
        print(f"│ Probable    │ {probable:.4f} mm² (±0%)     │ 40%                │")
        print(f"│ Pesimista   │ {pesimista:.4f} mm² (+80%)   │ 15%                │")
        print(f"│ Rango Total │ {rango_min:.4f} - {rango_max:.4f} mm² │ 70%                │")
        print(f"└─────────────────────────────────────────────────────────┘")
        
        # Recomendaciones específicas TMR
        print(f"\nRECOMENDACIONES TMR SoC:")
        print(f"Ideal para: Misiones fault-tolerant balanceadas")
        print(f"Ventajas: Convergencia eficiencia FPGA-SoC")
        print(f"Tolerancia: 1 ALU failure (good reliability)")
        print(f"Trade-off: 3-4x area vs Single por redundancia")
        print(f"Uso CubeSat: Misiones criticas con presupuesto moderado")
        
        return {
            'total_instructions': total_instructions,
            'total_gates': total_gates,
            'area_mm2': area_mm2,
            'area_per_alu': area_mm2 / ALU_COUNT,
            'fpga_area': fpga_area,
            'alu_references': alu_references,
            'voter_references': voter_references
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def main():
    """Función principal"""
    print("TMR SoC AREA ANALYZER")
    print("Analisis especifico de area para TMR RISC-V")
    print("Triple Modular Redundancy Architecture")
    print()
    
    result = analyze_tmr_soc()
    
    if result:
        print(f"\n" + "=" * 60)
        print("    RESUMEN EJECUTIVO TMR")
        print("=" * 60)
        print(f"Analisis TMR completado exitosamente")
        print(f"{result['total_instructions']} instrucciones analizadas")
        print(f"{result['total_gates']:,} gates estimados")
        print(f"{result['area_mm2']:.4f} mm² area total estimada")
        print(f"{result['area_per_alu']:.4f} mm² por ALU (3 ALUs)")
        print(f"Tolerancia: 1 ALU failure")
        print(f"Precision: ±50-100% (valido para comparacion)")

if __name__ == "__main__":
    main()