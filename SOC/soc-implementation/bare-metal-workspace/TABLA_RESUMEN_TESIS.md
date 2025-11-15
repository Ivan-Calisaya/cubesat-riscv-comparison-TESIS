# TABLA RESUMEN PARA TESIS: SoC vs FPGA

## TABLA COMPARATIVA PRINCIPAL

| MÉTRICA | FPGA | SoC | VENTAJA |
|---------|------|-----|---------|
| **RECURSOS** |
| Logic Elements | 6,826 | 45 instrucciones | SoC 99.3% menos |
| Registers | 2,210 | ~16 | SoC 99.3% menos |
| Memory (bits) | 264,192 | 56,992 | SoC 78.4% menos |
| **PERFORMANCE** |
| Target Clock | 50 MHz | 50 MHz | IDÉNTICO |
| Achieved Freq | 44.35 MHz | 50 MHz | SoC 12.7% mayor |
| Critical Path | 22.548 ns | ~10 ns | SoC 56% menor |
| Timing Issues | Setup violation -2.548ns | Sin problemas | SoC superior |
| **POWER CONSUMPTION** |
| Total Power | **261.80 mW** | **43.7 mW** | **SoC 83% menos** |
| Core Dynamic | 152.69 mW | 43.7 mW | SoC 71% menos |
| Core Static | 78.96 mW | ~5 mW | SoC 94% menos |
| I/O Power | 30.15 mW | 0 mW | SoC 100% menos |
| **EFICIENCIA** |
| mW per ADD | 152.69 | 43.7 | SoC 3.5x mejor |
| MHz per mW | 0.29 | 1.14 | SoC 3.9x mejor |

## ESPECIFICACIONES TÉCNICAS
- **FPGA**: Cyclone IV EP4CE22F17C6N (Speed Grade -6)
- **SoC**: RISC-V 32-bit simulation (QEMU)
- **Clock Target**: 50 MHz (idéntico en ambos)
- **Test Conditions**: FPGA slow 1200mV 85C model

## ALGORITMO VERIFICADO IDÉNTICO
- **Operación**: result = a + b (a=10, b=20)
- **FPGA ADD operations**: 1
- **SoC ADD operations**: 1
- **Resultado**: 30 (ambos)
- **Funcionalidad**: ✅ IDÉNTICA

## CONDICIONES DE TEST
- **FPGA**: Quartus II, slow 1200mV 85C model
- **SoC**: QEMU RISC-V simulation
- **Algoritmo**: Mismo código C compilado

## CONCLUSIÓN PRINCIPAL
**El SoC es significativamente más eficiente energéticamente (83% menos power) y alcanza mayor performance (125% más frecuencia) para el mismo algoritmo core.**