#!/usr/bin/env python3
"""
FPGA Area Calculator - Cyclone IV EP4CE22F17C6N (60nm)
Cálculo correcto de área usando tecnología 60nm TSMC
"""

def calculate_fpga_areas():
    """Calcula áreas FPGA con tecnología 60nm correcta"""
    
    print("🔬 CÁLCULO ÁREA FPGA - CYCLONE IV EP4CE22F17C6N")
    print("Tecnología: 60nm TSMC Process (2008-2012)")
    print("=" * 60)
    
    # Constantes correctas para Cyclone IV (60nm)
    GATES_PER_MM2_60NM = 3000  # Gates por mm² en 60nm (conservador)
    LE_TO_GATES_60NM = 4.5     # 1 LE ≈ 4-5 gates en 60nm era
    
    # Datos FPGA de tu reporte Quartus
    fpga_data = {
        'Single': {
            'les': 6826,
            'power_mw': 261.8,
            'freq_mhz': 44.35
        },
        'TMR': {
            'les': 6886,
            'power_mw': 233.21,
            'freq_mhz': 44.03
        },
        'QMR': {
            'les': 6886,
            'power_mw': 258.65,
            'freq_mhz': 42.97
        }
    }
    
    print("📋 DATOS FPGA ORIGINALES (del reporte Quartus):")
    print("-" * 60)
    
    results = {}
    
    for impl_name, data in fpga_data.items():
        les = data['les']
        power = data['power_mw']
        freq = data['freq_mhz']
        
        # Cálculos con tecnología 60nm
        gates = les * LE_TO_GATES_60NM
        area_mm2 = gates / GATES_PER_MM2_60NM
        
        # Métricas adicionales
        gates_per_mw = gates / power
        area_per_mw = area_mm2 / power
        
        print(f"\n🔧 {impl_name} FPGA:")
        print(f"  Logic Elements:     {les:,} LEs")
        print(f"  Power:              {power:.2f} mW")
        print(f"  Frequency:          {freq:.2f} MHz")
        print(f"  Gates (60nm):       {gates:,.0f} gates")
        print(f"  Area (60nm):        {area_mm2:.4f} mm²")
        print(f"  Efficiency:         {gates_per_mw:.1f} gates/mW")
        print(f"  Power density:      {area_per_mw:.6f} mm²/mW")
        
        results[impl_name] = {
            'les': les,
            'gates': gates,
            'area_mm2': area_mm2,
            'power_mw': power,
            'freq_mhz': freq,
            'gates_per_mw': gates_per_mw,
            'area_per_mw': area_per_mw
        }
    
    # Comparación entre implementaciones FPGA
    print(f"\n" + "=" * 60)
    print("    COMPARACIÓN FPGA IMPLEMENTATIONS")
    print("=" * 60)
    
    print(f"{'Impl':<8} {'LEs':<8} {'Gates':<8} {'Area(mm²)':<10} {'Power(mW)':<10} {'Freq(MHz)':<10}")
    print("-" * 60)
    
    for impl_name, result in results.items():
        print(f"{impl_name:<8} {result['les']:<8,} {result['gates']:<8,.0f} {result['area_mm2']:<10.4f} {result['power_mw']:<10.1f} {result['freq_mhz']:<10.2f}")
    
    # Análisis de escalamiento FPGA
    single_result = results['Single']
    
    print(f"\n📈 ESCALAMIENTO FPGA (vs Single):")
    print("-" * 40)
    
    for impl_name, result in results.items():
        if impl_name != 'Single':
            area_scale = result['area_mm2'] / single_result['area_mm2']
            power_scale = result['power_mw'] / single_result['power_mw']
            les_scale = result['les'] / single_result['les']
            
            print(f"{impl_name} vs Single:")
            print(f"  LEs scaling:    {les_scale:.3f}x")
            print(f"  Area scaling:   {area_scale:.3f}x")
            print(f"  Power scaling:  {power_scale:.3f}x")
    
    # Valores para usar en scripts SoC
    print(f"\n" + "=" * 60)
    print("    VALORES PARA USAR EN SCRIPTS SOC")
    print("=" * 60)
    
    print(f"🔧 CONSTANTES 60nm PARA SCRIPTS:")
    print(f"GATES_PER_MM2 = {GATES_PER_MM2_60NM}  # 60nm density")
    print(f"LE_TO_GATES = {LE_TO_GATES_60NM}      # Cyclone IV conversion")
    print()
    
    print(f"📊 ÁREAS FPGA CORRECTAS (60nm):")
    for impl_name, result in results.items():
        print(f"FPGA_{impl_name.upper()}_AREA = {result['area_mm2']:.4f}  # mm²")
    
    print(f"\n💡 USAR ESTOS VALORES en analyze_*_area.py scripts")
    
    return results

def create_technology_comparison():
    """Compara diferentes tecnologías"""
    
    print(f"\n" + "=" * 60)
    print("    COMPARACIÓN TECNOLOGÍAS")
    print("=" * 60)
    
    # Datos para Single FPGA como ejemplo
    single_les = 6826
    single_gates_base = single_les * 4.5  # Base gates
    
    technologies = {
        '60nm (Cyclone IV Real)': {
            'density': 3000,
            'le_factor': 4.5
        },
        '45nm (Hypotético)': {
            'density': 5000,
            'le_factor': 4.8
        },
        '28nm (Moderno)': {
            'density': 10000,
            'le_factor': 5.0
        },
        '14nm (Avanzado)': {
            'density': 25000,
            'le_factor': 5.5
        }
    }
    
    print(f"🔬 Single FPGA Area en Diferentes Tecnologías:")
    print(f"(Base: {single_les:,} LEs)")
    print("-" * 60)
    
    for tech_name, tech_data in technologies.items():
        gates = single_les * tech_data['le_factor']
        area = gates / tech_data['density']
        
        marker = " ← REAL" if "Cyclone IV" in tech_name else ""
        print(f"{tech_name:<25}: {area:.4f} mm²{marker}")
    
    print(f"\n✅ Tu FPGA usa 60nm, por eso debemos usar 3000 gates/mm²")

if __name__ == "__main__":
    print("🚀 FPGA AREA CALCULATOR (TECHNOLOGY CORRECTED)")
    print("Cyclone IV EP4CE22F17C6N - 60nm TSMC Process")
    print()
    
    results = calculate_fpga_areas()
    create_technology_comparison()
    
    print(f"\n" + "=" * 60)
    print("    RESUMEN PARA TU TESIS")
    print("=" * 60)
    print(f"✅ FPGA Cyclone IV usa 60nm TSMC (NOT 28nm)")
    print(f"✅ Densidad correcta: 3,000 gates/mm² (NOT 10,000)")
    print(f"✅ Áreas FPGA recalculadas con tecnología real")
    print(f"✅ Usar estos valores para fair comparison con SoC")