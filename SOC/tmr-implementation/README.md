# RISC-V TMR (Triple Modular Redundancy) Implementation

## 🎯 **Objetivo**
Implementar el mismo algoritmo `result = a + b` con **Triple Modular Redundancy** para comparar con:
- Single SoC implementation (ya completada)
- FPGA implementation (referencia)

## 🔧 **Concepto TMR**
```
Input (a=10, b=20)
    ↓
┌─────────────────────┐
│   Core 1: a + b     │ → result1
├─────────────────────┤
│   Core 2: a + b     │ → result2  
├─────────────────────┤  
│   Core 3: a + b     │ → result3
└─────────────────────┘
    ↓
┌─────────────────────┐
│   Majority Voter    │ → final_result
│ (2 de 3 wins)       │
└─────────────────────┘
```

## 📊 **Métricas a Comparar**
- **Recursos**: Memory usage vs Single SoC
- **Performance**: Latency overhead del voting
- **Power**: 3x cores + voter logic
- **Reliability**: Fault tolerance capability

## 🏗️ **Arquitectura TMR**
1. **3 Core Replicas**: Ejecutan algoritmo idéntico
2. **Majority Voter**: Compara los 3 resultados  
3. **Error Detection**: Identifica discrepancias
4. **Memory Isolation**: Cada core en sector separado

## 📂 **Estructura del Proyecto**
```
tmr-implementation/
├── bare-metal-workspace/
│   ├── startup_tmr.s           # TMR bootloader
│   ├── simple_add_tmr.c        # Core algorithm x3
│   ├── tmr_voter.c             # Majority voting logic
│   ├── tmr_link.ld            # Memory layout for 3 cores
│   ├── run_tmr_analysis.ps1   # TMR compilation script
│   └── TMR_vs_Single_SoC.md   # Comparison results
└── README.md                   # This file
```

## 🎯 **Comparación Final Esperada**
| Metric | Single SoC | TMR SoC | FPGA | Winner |
|--------|------------|---------|------|--------|
| Power | 43.7 mW | ~150 mW | 261.8 mW | Single |
| Reliability | Low | High | Medium | TMR |
| Resources | 45 inst | ~135 inst | 6826 LE | Single |
| Performance | 50 MHz | ~45 MHz | 44.35 MHz | Single |

---
**Inicio**: 2025-11-08  
**Status**: En desarrollo  
**Comparación con**: SoC Single (completado), FPGA Cyclone IV