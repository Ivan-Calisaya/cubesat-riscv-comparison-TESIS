#!/usr/bin/env python3
"""
SOC Area Analysis Tool
Estimación de área equivalente para implementaciones SoC RISC-V
Basado en gate count y complejidad de instrucciones
"""

import os
import re
import math

class SocAreaAnalyzer:
    def __init__(self):
        # Constantes de tecnología (28nm ejemplo)
        self.GATES_PER_MM2 = 10000  # Gates por mm² en 28nm
        self.LE_TO_GATES = 5        # 1 LE FPGA ≈ 5 gates ASIC
        
        # Complejidad por tipo de instrucción (gates)
        self.instruction_complexity = {
            'add': 100,     # ALU básica
            'sub': 100,     # ALU básica  
            'mul': 500,     # Multiplicador
            'div': 1000,    # Divisor
            'lw': 200,      # Load word
            'sw': 200,      # Store word
            'beq': 150,     # Branch equal
            'jal': 100,     # Jump and link
            'default': 80   # Instrucción promedio
        }
    
    def analyze_disassembly(self, dis_file):
        """Analiza archivo .dis para contar tipos de instrucciones"""
        if not os.path.exists(dis_file):
            print(f"❌ Archivo {dis_file} no encontrado")
            return {}
        
        instruction_counts = {}
        total_instructions = 0
        
        with open(dis_file, 'r', encoding='utf-8', errors='ignore') as f:
            for line in f:
                # Buscar patrones de instrucciones RISC-V
                match = re.search(r'^\s*[0-9a-f]+:\s+[0-9a-f]+\s+(\w+)', line)
                if match:
                    instruction = match.group(1).lower()
                    instruction_counts[instruction] = instruction_counts.get(instruction, 0) + 1
                    total_instructions += 1
        
        return instruction_counts, total_instructions
    
    def calculate_gate_count(self, instruction_counts):
        """Calcula gate count total basado en tipos de instrucciones"""
        total_gates = 0
        
        for instruction, count in instruction_counts.items():
            complexity = self.instruction_complexity.get(instruction, 
                                                       self.instruction_complexity['default'])
            gates = count * complexity
            total_gates += gates
            print(f"  {instruction}: {count}x instructions × {complexity} gates = {gates} gates")
        
        return total_gates
    
    def estimate_area_mm2(self, total_gates):
        """Estima área en mm² basada en gate count"""
        area_mm2 = total_gates / self.GATES_PER_MM2
        return area_mm2
    
    def compare_with_fpga(self, fpga_les, soc_gates):
        """Compara área SoC vs FPGA equivalente"""
        fpga_equivalent_gates = fpga_les * self.LE_TO_GATES
        fpga_area_mm2 = fpga_equivalent_gates / self.GATES_PER_MM2
        soc_area_mm2 = soc_gates / self.GATES_PER_MM2
        
        print(f"\n📊 COMPARACIÓN ÁREA FPGA vs SoC:")
        print(f"FPGA: {fpga_les} LEs × {self.LE_TO_GATES} = {fpga_equivalent_gates} gates = {fpga_area_mm2:.3f} mm²")
        print(f"SoC:  {soc_gates} gates = {soc_area_mm2:.3f} mm²")
        print(f"Ratio SoC/FPGA: {soc_area_mm2/fpga_area_mm2:.2f}x")
        
        return fpga_area_mm2, soc_area_mm2
    
    def analyze_soc_implementation(self, workspace_path, name):
        """Análisis completo de una implementación SoC"""
        dis_file = os.path.join(workspace_path, f"simple_add_{name}.dis")
        
        print(f"\n🔬 ANÁLISIS ÁREA {name.upper()} SoC:")
        print(f"Archivo: {dis_file}")
        
        if not os.path.exists(dis_file):
            print(f"❌ Archivo no encontrado: {dis_file}")
            return None
        
        # Analizar instrucciones
        instruction_counts, total_instructions = self.analyze_disassembly(dis_file)
        print(f"Total instrucciones: {total_instructions}")
        
        if not instruction_counts:
            print("❌ No se encontraron instrucciones válidas")
            return None
        
        # Calcular gates
        total_gates = self.calculate_gate_count(instruction_counts)
        
        # Estimar área
        area_mm2 = self.estimate_area_mm2(total_gates)
        
        print(f"\n📐 RESULTADOS ÁREA {name.upper()}:")
        print(f"Total gates: {total_gates:,}")
        print(f"Área estimada: {area_mm2:.3f} mm²")
        
        return {
            'name': name,
            'total_instructions': total_instructions,
            'total_gates': total_gates,
            'area_mm2': area_mm2,
            'instruction_counts': instruction_counts
        }

def main():
    analyzer = SocAreaAnalyzer()
    
    # Rutas de los proyectos
    base_path = r"C:\Users\Usuario\Desktop\Ivan\SOC"
    
    implementations = [
        ("soc-implementation/bare-metal-workspace", "minimal"),
        ("tmr-implementation/bare-metal-workspace", "tmr"), 
        ("qmr-implementation/bare-metal-workspace", "qmr")
    ]
    
    results = []
    
    print("=" * 60)
    print("    SoC AREA ANALYSIS TOOL")
    print("    Estimación de Área por Gate Count")
    print("=" * 60)
    
    for impl_path, name in implementations:
        full_path = os.path.join(base_path, impl_path)
        result = analyzer.analyze_soc_implementation(full_path, name)
        if result:
            results.append(result)
    
    # Comparación final
    if results:
        print("\n" + "=" * 60)
        print("    COMPARACIÓN ÁREA SOC IMPLEMENTATIONS")
        print("=" * 60)
        
        # Datos FPGA de referencia
        fpga_les = {
            'single': 6826,  # Del reporte
            'tmr': 6886,
            'qmr': 6886
        }
        
        for result in results:
            name = result['name'] 
            if name == 'minimal':
                name = 'single'  # Ajuste de nombre
                
            if name in fpga_les:
                print(f"\n📊 {name.upper()} FPGA vs SoC:")
                analyzer.compare_with_fpga(fpga_les[name], result['total_gates'])
        
        # Tabla resumen
        print("\n" + "=" * 80)
        print("    TABLA RESUMEN ÁREA")
        print("=" * 80)
        print(f"{'Implementation':<15} {'Instructions':<12} {'Gates':<12} {'Area (mm²)':<12} {'vs Single'}")
        print("-" * 80)
        
        single_area = next(r['area_mm2'] for r in results if r['name'] == 'minimal')
        
        for result in results:
            name = result['name'].upper()
            if name == 'MINIMAL':
                name = 'SINGLE'
            
            instructions = result['total_instructions']
            gates = result['total_gates']
            area = result['area_mm2']
            ratio = area / single_area
            
            print(f"{name:<15} {instructions:<12} {gates:<12,} {area:<12.3f} {ratio:.2f}x")

if __name__ == "__main__":
    main()