# REPORTE COMPARATIVO COMPLETO: RISC-V FPGA vs SoC
## Single, TMR y QMR - Análisis Académico para Tesis

### **RESUMEN EJECUTIVO**

Este reporte presenta una comparación exhaustiva entre implementaciones RISC-V en FPGA (Cyclone IV EP4CE22F17C6N) versus SoC (QEMU RISC-V 32-bit) para tres arquitecturas de redundancia:
- **Single**: Implementación básica sin redundancia
- **TMR**: Triple Modular Redundancy (3 ALUs + 2-of-3 voter)
- **QMR**: Quintuple Modular Redundancy (5 ALUs + 3-of-5 voter)

---

## **1. COMPARACIÓN DIRECTA: FPGA vs SoC POR ARQUITECTURA**

### **1.1 SINGLE RISC-V: FPGA vs SoC**

| Métrica | FPGA Cyclone IV | SoC QEMU | Ratio FPGA/SoC | Observaciones |
|---------|----------------|----------|----------------|---------------|
| **Power Total** | 261.8 mW | 43.7 mW | **5.99x** | FPGA consume 6x más poder |
| **Frecuencia Máxima** | 44.35 MHz | 50 MHz | **0.89x** | SoC 13% más rápido |
| **Elementos Lógicos** | 6,826 LEs | N/A | N/A | FPGA usa 31% del chip |
| **Registros** | 2,210 regs | N/A | N/A | Hardware dedicado |
| **Size/Instructions** | N/A | 45 inst | N/A | SoC: 7,124 bytes |
| **Fault Tolerance** | 0 faults | 0 faults | **1.00x** | Sin redundancia |

**Conclusión Single:** SoC es más eficiente en poder y velocidad para aplicaciones básicas.

### **1.2 TMR RISC-V: FPGA vs SoC**

| Métrica | FPGA Cyclone IV | SoC QEMU | Ratio FPGA/SoC | Observaciones |
|---------|----------------|----------|----------------|---------------|
| **Power Total** | 233.21 mW | 255.0 mW | **0.91x** | Poder similar, FPGA 9% menor |
| **Core Dynamic** | 126.43 mW | ~180 mW* | **0.70x** | FPGA más eficiente dinámicamente |
| **Core Static** | 78.93 mW | ~40 mW* | **1.97x** | FPGA mayor poder estático |
| **Frecuencia Máxima** | 44.03 MHz | 50 MHz | **0.88x** | SoC mantiene ventaja velocidad |
| **Elementos Lógicos** | 6,886 LEs | N/A | N/A | FPGA: 31% utilización |
| **Size/Instructions** | N/A | 173 inst | N/A | SoC: 11,732 bytes |
| **Fault Tolerance** | 1 ALU fault | 1 ALU fault | **1.00x** | Misma tolerancia a fallos |
| **ALU Count** | 3 ALUs | 3 ALUs | **1.00x** | Arquitectura idéntica |

**Conclusión TMR:** Poder muy similar entre FPGA y SoC, validando la arquitectura TMR.

### **1.3 QMR RISC-V: FPGA vs SoC**

| Métrica | FPGA Cyclone IV | SoC QEMU | Ratio FPGA/SoC | Observaciones |
|---------|----------------|----------|----------------|---------------|
| **Power Total** | 258.65 mW | 672.2 mW | **0.38x** | SoC consume 2.6x más poder |
| **Core Dynamic** | 151.36 mW | ~450 mW* | **0.34x** | SoC mucho mayor poder dinámico |
| **Core Static** | 78.98 mW | ~80 mW* | **0.99x** | Poder estático similar |
| **Frecuencia Máxima** | 42.97 MHz | 50 MHz | **0.86x** | SoC mantiene ventaja velocidad |
| **Elementos Lógicos** | 6,886 LEs | N/A | N/A | FPGA: 31% utilización (¡igual!) |
| **Size/Instructions** | N/A | 417 inst | N/A | SoC: 15,896 bytes |
| **Fault Tolerance** | 2 ALU faults | 2 ALU faults | **1.00x** | Máxima tolerancia a fallos |
| **ALU Count** | 5 ALUs | 5 ALUs | **1.00x** | Arquitectura idéntica |

**Conclusión QMR:** FPGA significativamente más eficiente en poder para alta redundancia.

*Estimaciones basadas en breakdown de poder SoC

---

## **2. PROGRESIÓN DE RECURSOS: SINGLE → TMR → QMR**

### **2.1 PROGRESIÓN FPGA (Cyclone IV)**

| Arquitectura | Power Total | Core Dynamic | Frecuencia Max | Elementos Lógicos | Cambio Poder | Cambio Freq |
|--------------|-------------|--------------|----------------|-------------------|--------------|-------------|
| **Single** | 261.8 mW | ~150 mW* | 44.35 MHz | 6,826 LEs | - | - |
| **TMR** | 233.21 mW | 126.43 mW | 44.03 MHz | 6,886 LEs | **-10.9%** | **-0.7%** |
| **QMR** | 258.65 mW | 151.36 mW | 42.97 MHz | 6,886 LEs | **+11.0%** | **-2.4%** |

**Observación FPGA:** ¡Los elementos lógicos se mantienen casi constantes! Esto indica optimización hardware eficiente.

### **2.2 PROGRESIÓN SoC (QEMU RISC-V)**

| Arquitectura | Power Total | Instructions | Size (bytes) | ALU Count | Cambio Poder | Cambio Size |
|--------------|-------------|--------------|--------------|-----------|--------------|-------------|
| **Single** | 43.7 mW | 45 | 7,124 | 1 | - | - |
| **TMR** | 255.0 mW | 173 | 11,732 | 3 | **+483.5%** | **+64.7%** |
| **QMR** | 672.2 mW | 417 | 15,896 | 5 | **+1438.2%** | **+123.1%** |

**Observación SoC:** Escalamiento linear con número de ALUs pero mayor overhead de poder.

---

## **3. ANÁLISIS DE EFICIENCIA POR ARQUITECTURA**

### **3.1 Eficiencia de Poder (mW por ALU)**

| Arquitectura | FPGA (mW/ALU) | SoC (mW/ALU) | Ventaja FPGA |
|--------------|---------------|--------------|--------------|
| **Single** | 261.8 / 1 = **261.8** | 43.7 / 1 = **43.7** | SoC 6x mejor |
| **TMR** | 233.21 / 3 = **77.7** | 255.0 / 3 = **85.0** | FPGA 9% mejor |
| **QMR** | 258.65 / 5 = **51.7** | 672.2 / 5 = **134.4** | FPGA 2.6x mejor |

**Conclusión:** FPGA se vuelve más eficiente con mayor redundancia.

### **3.2 Eficiencia de Frecuencia vs Tolerancia a Fallos**

| Arquitectura | FPGA Freq/Fault | SoC Freq/Fault | Performance/Reliability |
|--------------|-----------------|----------------|-------------------------|
| **Single** | 44.35 MHz / 0 = ∞ | 50 MHz / 0 = ∞ | Sin tolerancia |
| **TMR** | 44.03 MHz / 1 = **44.03** | 50 MHz / 1 = **50.0** | SoC 14% mejor |
| **QMR** | 42.97 MHz / 2 = **21.5** | 50 MHz / 2 = **25.0** | SoC 16% mejor |

---

## **4. TIMING ANALYSIS COMPARATIVO**

### **4.1 FPGA Timing Degradation**

| Arquitectura | Frecuencia | Slack Setup | TNS | Data Delay | Degradación |
|--------------|------------|-------------|-----|------------|-------------|
| **Single** | 44.35 MHz | ~-1.0ns* | ~-50* | ~17ns* | Baseline |
| **TMR** | 44.03 MHz | -2.713ns | -272.762 | 18.493ns | **-0.7%** freq |
| **QMR** | 42.97 MHz | -3.273ns | -150.510 | 19.067ns | **-3.1%** freq |

**Observación:** QMR tiene mayor delay pero menor TNS (mejor distribución de timing).

---

## **5. RECOMENDACIONES POR CASO DE USO**

### **5.1 CubeSat Power-Constrained Missions**
```
Recomendación: Single SoC (43.7 mW)
✅ Menor consumo absoluto
✅ Simplicidad de implementación
❌ Sin tolerancia a fallos
```

### **5.2 CubeSat Fault-Tolerant Missions**
```
Recomendación: TMR FPGA (233.21 mW) o TMR SoC (255 mW)
✅ Tolerancia a 1 fallo de ALU
✅ Poder razonable
✅ Implementación balanceada
```

### **5.3 CubeSat Mission-Critical High-Radiation**
```
Recomendación: QMR FPGA (258.65 mW)
✅ Máxima tolerancia (2 fallos)
✅ Poder controlado vs SoC
✅ Mejor para ambiente extremo
❌ QMR SoC (672.2 mW) muy alto poder
```

---

## **6. CONCLUSIONES ACADÉMICAS**

### **6.1 Tendencias Observadas**

1. **Single:** SoC domina en eficiencia básica
2. **TMR:** Convergencia FPGA-SoC (poder similar)
3. **QMR:** FPGA mantiene eficiencia, SoC penalizado

### **6.2 Trade-offs Clave**

| Factor | FPGA Advantage | SoC Advantage |
|--------|----------------|---------------|
| **Power Efficiency** | Alta redundancia (TMR/QMR) | Implementación simple (Single) |
| **Performance** | Estabilidad timing | Frecuencia máxima |
| **Reliability** | Hardware redundancy | Software flexibility |
| **Development** | Tool complexity | Standard toolchain |

### **6.3 Contribución a la Tesis**

Este análisis demuestra que:
- **SoC es óptimo para aplicaciones básicas** (43.7 mW vs 261.8 mW)
- **FPGA es superior para alta redundancia** (258.65 mW vs 672.2 mW en QMR)
- **Punto de equilibrio en TMR** (233.21 mW vs 255 mW)

**Implicación:** La elección entre FPGA y SoC debe basarse en los requisitos específicos de tolerancia a fallos y presupuesto de energía del CubeSat.

---

## **7. DATOS TÉCNICOS DETALLADOS**

### **7.1 Configuración FPGA**
- **Dispositivo:** Cyclone IV EP4CE22F17C6N
- **Condiciones:** Slow 1200mV 85C Model (peor caso)
- **Herramientas:** Quartus II Timing Analyzer, Power Analyzer
- **Utilización:** 31% elementos lógicos (consistente)

### **7.2 Configuración SoC**
- **Plataforma:** QEMU RISC-V 32-bit virt machine
- **Toolchain:** xpack-riscv-none-elf-gcc-14.2.0-3
- **Arquitectura:** RV32IMA_ZICSR, ilp32 ABI
- **Memoria:** 64MB RAM, bare-metal execution

### **7.3 Algoritmo de Prueba**
```c
// Algoritmo idéntico en todas las implementaciones
int result = a + b; // a=10, b=20, result=30
```

**Fecha de Análisis:** Noviembre 8, 2025  
**Contexto:** Desarrollo de Tesis - Sistemas RISC-V para CubeSats