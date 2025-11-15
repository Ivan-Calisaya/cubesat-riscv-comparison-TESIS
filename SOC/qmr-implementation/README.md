# RISC-V QMR (Quintuple Modular Redundancy) Implementation

## 🎯 **Objetivo**
Implementar el mismo algoritmo `result = a + b` con **Quintuple Modular Redundancy** (5 ALUs + Voter) para comparar con:
- Single SoC implementation (43.7 mW)
- TMR SoC implementation (255 mW)  
- FPGA implementation (261.8 mW)

## 🔧 **Concepto QMR**
```
Input (a=10, b=20)
    ↓
┌─────────────────────┐
│   ALU 0: a + b      │ → result0
├─────────────────────┤
│   ALU 1: a + b      │ → result1  
├─────────────────────┤  
│   ALU 2: a + b      │ → result2
├─────────────────────┤
│   ALU 3: a + b      │ → result3
├─────────────────────┤
│   ALU 4: a + b      │ → result4
└─────────────────────┘
    ↓
┌─────────────────────┐
│ 3-of-5 Majority     │ → final_result
│ Voter Logic         │
└─────────────────────┘
```

## 📊 **Métricas Esperadas QMR vs TMR**
- **Power**: ~400 mW (vs 255 mW TMR)
- **Resources**: ~5x ALU logic + voter
- **Performance**: Same latency (parallel ALUs)
- **Reliability**: **2 ALU failures** tolerant (vs 1 in TMR)

## 🏗️ **Arquitectura QMR**
1. **5 Parallel ALUs**: Ejecutan algoritmo idéntico
2. **3-of-5 Majority Voter**: Selecciona resultado correcto
3. **Enhanced Error Detection**: Identifica hasta 2 failures
4. **Memory Layout**: Single core + 5 ALU sections

## 📂 **Estructura del Proyecto**
```
qmr-implementation/
├── bare-metal-workspace/
│   ├── startup_qmr.s           # QMR bootloader (single core)
│   ├── simple_add_qmr.c        # 5 ALUs + 3-of-5 voter
│   ├── qmr_link.ld            # Memory layout for 5 ALUs
│   ├── COMANDOS_MANUALES_QMR.ps1 # Manual execution script
│   └── QMR_vs_TMR_vs_Single.md # Comparison results
└── README.md                   # This file
```

## 🎯 **Comparación Final Esperada**
| Metric | Single SoC | TMR SoC | QMR SoC | FPGA | Winner |
|--------|------------|---------|---------|------|--------|
| Power | 43.7 mW | 255 mW | ~400 mW | 261.8 mW | Single |
| Reliability | None | 1 fault | **2 faults** | 1 fault | **QMR** |
| Resources | 45 inst | 173 inst | ~350 inst | 6826 LE | Single |
| Performance | 50 MHz | 50 MHz | 50 MHz | 44.35 MHz | SoCs |

## 🔬 **QMR Advantages vs TMR**
- **Higher Fault Tolerance**: 2 ALU failures vs 1
- **Better Error Detection**: Can identify specific failed ALUs
- **More Robust**: Works even with 2 simultaneous failures
- **Mission Critical**: Suitable for highest reliability requirements

## ⚠️ **QMR Trade-offs**
- **Higher Power**: ~60% more than TMR
- **More Complex**: 5 ALUs + sophisticated voter
- **Larger Size**: More memory and logic resources
- **Overkill**: For most applications, TMR sufficient

---
**Inicio**: 2025-11-08  
**Status**: En desarrollo  
**Comparación con**: Single SoC, TMR SoC, FPGA Cyclone IV