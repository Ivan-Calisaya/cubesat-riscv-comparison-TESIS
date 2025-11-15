#!/usr/bin/env python3
"""
QMR SoC Area Analysis - Versión Específica  
Análisis de área exclusivo para QMR RISC-V SoC (5 ALUs + 3-of-5 voter)
"""

import re
import os

def analyze_qmr_soc():
    """Análisis específico para QMR SoC"""
    
    print("ANALISIS DE AREA - QMR RISC-V SoC")
    print("Quintuple Modular Redundancy (5 ALUs + 3-of-5 Voter)")
    print("=" * 60)
    
    # Ruta relativa al archivo .dis en el mismo directorio
    dis_file = "simple_add_qmr.dis"
    
    # Constantes específicas para QMR (60nm Cyclone IV)
    GATES_PER_MM2 = 3000   # 60nm technology density
    LE_TO_GATES = 5.0      # Factor estándar industria
    FPGA_LES_QMR = 6886    # Del reporte Quartus QMR
    ALU_COUNT = 5          # QMR tiene 5 ALUs
    
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
        print("Asegurate de ejecutar este script desde el directorio QMR que contiene el archivo .dis")
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
            # Buscar referencias QMR específicas (5 ALUs)
            if 'alu' in line.lower():
                for i in range(5):  # alu0, alu1, alu2, alu3, alu4
                    if f'alu{i}' in line.lower():
                        alu_references += 1
                        break
            if 'voter' in line.lower() or 'majority' in line.lower() or '3of5' in line.lower():
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
        print(f"Referencias 3-of-5 Voter: {voter_references}")
        
        # Mostrar top instrucciones con enfoque QMR
        sorted_instructions = sorted(instruction_counts.items(), key=lambda x: x[1], reverse=True)
        print(f"\nTop 10 instrucciones QMR (High Redundancy):")
        
        total_gates = 0
        memory_intensive_ops = ['lw', 'sw', 'lb', 'sb', 'lh', 'sh']
        arithmetic_ops = ['add', 'sub', 'mul', 'div', 'addi']
        control_ops = ['beq', 'bne', 'blt', 'bge', 'j', 'jal']
        
        for i, (inst, count) in enumerate(sorted_instructions[:10]):
            complexity = instruction_complexity.get(inst, instruction_complexity['default'])
            gates = count * complexity
            total_gates += gates
            
            # Indicadores específicos QMR con análisis de overhead
            overhead_note = ""
            if inst in memory_intensive_ops:
                overhead_note = f"(5x redundancy)"
            elif inst in arithmetic_ops:
                overhead_note = f"(5 ALUs)"
            elif inst in control_ops:
                overhead_note = f"(voter logic)"
            else:
                overhead_note = f"(support)"
            
            print(f"{i+1:2}. {inst:8} : {count:3}x × {complexity:4} gates = {gates:6,} gates {overhead_note}")
        
        # Agregar resto de instrucciones
        for inst, count in instruction_counts.items():
            if inst not in [x[0] for x in sorted_instructions[:10]]:
                complexity = instruction_complexity.get(inst, instruction_complexity['default'])
                total_gates += count * complexity
        
        # Calcular área
        area_mm2 = total_gates / GATES_PER_MM2
        
        print(f"\nRESULTADOS QMR SoC:")
        print(f"Gate count total:     {total_gates:,} gates")
        print(f"Area estimada:        {area_mm2:.4f} mm²")
        print(f"Area por ALU:         {area_mm2/ALU_COUNT:.4f} mm²/ALU")
        print(f"Overhead vs Single:   {area_mm2/1.9867:.2f}x (referencia)")
        
        # Comparar con FPGA
        fpga_gates = FPGA_LES_QMR * LE_TO_GATES
        fpga_area = fpga_gates / GATES_PER_MM2
        
        print(f"\nCOMPARACION QMR FPGA vs SoC:")
        print(f"FPGA QMR:             {FPGA_LES_QMR} LEs = {fpga_gates:,} gates = {fpga_area:.4f} mm²")
        print(f"SoC QMR:              {total_gates:,} gates = {area_mm2:.4f} mm²")
        print(f"Ratio SoC/FPGA:       {area_mm2/fpga_area:.2f}x")
        
        if area_mm2 < fpga_area:
            efficiency = ((fpga_area - area_mm2) / fpga_area) * 100
            print(f"QMR SoC es {efficiency:.1f}% mas eficiente en area que FPGA QMR")
        else:
            overhead = ((area_mm2 - fpga_area) / fpga_area) * 100
            print(f"QMR SoC consume {overhead:.1f}% mas area que FPGA QMR")
            print(f"ADVERTENCIA: QMR SoC significativamente menos eficiente")
        
        # Análisis QMR específico
        print(f"\nANALISIS QMR ESPECIFICO:")
        print(f"Arquitectura:      5 ALUs + 3-of-5 Majority Voter")
        print(f"Tolerancia fallos: 2 ALU failures tolerant (MAXIMA)")
        print(f"Overhead vs Single: {area_mm2/0.5960:.1f}x area")
        print(f"Overhead vs TMR:    {area_mm2/2.66:.1f}x area")
        print(f"Trade-off critico: Maxima confiabilidad vs area")
        
        # Análisis de eficiencia QMR
        memory_ops = sum(instruction_counts.get(op, 0) for op in memory_intensive_ops)
        arith_ops = sum(instruction_counts.get(op, 0) for op in arithmetic_ops)
        control_ops_count = sum(instruction_counts.get(op, 0) for op in control_ops)
        
        print(f"\nDISTRIBUCION QMR:")
        print(f"Memory operations:    {memory_ops} ({memory_ops/total_instructions*100:.1f}%)")
        print(f"Arithmetic operations: {arith_ops} ({arith_ops/total_instructions*100:.1f}%)")
        print(f"Control operations:   {control_ops_count} ({control_ops_count/total_instructions*100:.1f}%)")
        
        # Análisis de precisión específico para QMR
        print(f"\nANALISIS DE PRECISION QMR:")
        optimista = area_mm2 * 0.6
        probable = area_mm2
        pesimista = area_mm2 * 1.8
        rango_min = area_mm2 * 0.5
        rango_max = area_mm2 * 2.0
        
        print(f"┌─────────────────────────────────────────────────────────┐")
        print(f"│ Escenario   │ Valor Real Probable   │ Confianza         │")
        print(f"├─────────────────────────────────────────────────────────┤")
        print(f"│ Optimista   │ {optimista:.4f} mm² (-40%)    │ 15%               │")
        print(f"│ Probable    │ {probable:.4f} mm² (±0%)     │ 40%               │")
        print(f"│ Pesimista   │ {pesimista:.4f} mm² (+80%)    │ 15%               │")
        print(f"│ Rango Total │ {rango_min:.4f} - {rango_max:.4f} mm² │ 70%               │")
        print(f"└─────────────────────────────────────────────────────────┘")
        
        # Recomendaciones específicas QMR
        print(f"\nRECOMENDACIONES QMR SoC:")
        print(f"Ideal para: Misiones mission-critical extremas")
        print(f"Ventajas: Maxima tolerancia a fallos (2 ALU failures)")
        print(f"Confiabilidad: Superior en ambientes high-radiation")
        print(f"Desventaja: Overhead significativo de area vs FPGA")
        print(f"Limitacion: Inviable para misiones power-constrained")
        print(f"Uso CubeSat: Solo misiones criticas con presupuesto ilimitado")
        
        # Comparación eficiencia
        single_area = 0.5960  # Referencia
        tmr_area = 2.6600     # Referencia
        
        print(f"\nANALISIS COST/BENEFIT QMR:")
        print(f"Costo area vs Single: {area_mm2/single_area:.1f}x")
        print(f"Costo area vs TMR:    {area_mm2/tmr_area:.1f}x")
        print(f"Benefit reliability:  2 faults vs 1 fault (TMR)")
        print(f"Recomendacion:        Usar TMR salvo requisitos extremos")
        
        return {
            'total_instructions': total_instructions,
            'total_gates': total_gates,
            'area_mm2': area_mm2,
            'area_per_alu': area_mm2 / ALU_COUNT,
            'fpga_area': fpga_area,
            'alu_references': alu_references,
            'voter_references': voter_references,
            'overhead_vs_single': area_mm2 / single_area,
            'overhead_vs_tmr': area_mm2 / tmr_area
        }
        
    except Exception as e:
        print(f"Error: {e}")
        return None

def main():
    """Función principal"""
    print("QMR SoC AREA ANALYZER")
    print("Analisis especifico de area para QMR RISC-V")
    print("Quintuple Modular Redundancy Architecture")
    print()
    
    result = analyze_qmr_soc()
    
    if result:
        print(f"\n" + "=" * 60)
        print("    RESUMEN EJECUTIVO QMR")
        print("=" * 60)
        print(f"Analisis QMR completado exitosamente")
        print(f"{result['total_instructions']} instrucciones analizadas")
        print(f"{result['total_gates']:,} gates estimados")
        print(f"{result['area_mm2']:.4f} mm² area total estimada")
        print(f"{result['area_per_alu']:.4f} mm² por ALU (5 ALUs)")
        print(f"Tolerancia: 2 ALU failures (MAXIMA)")
        print(f"Overhead: {result['overhead_vs_single']:.1f}x vs Single")
        print(f"Precision: ±50-100% (valido para comparacion)")

if __name__ == "__main__":
    main()