# 📊 Scripts de Medición SoC vs FPGA

## 🔍 **Verificar Estado Actual**

Primero, sal de QEMU si está corriendo:
```
Ctrl+A luego X
```

## 📋 **1. RECURSOS - Análisis de Memory Usage**

### **Comando: Análisis de Tamaño del Programa**
```powershell
# Análizar secciones del programa
& $OBJDUMP -h simple_add_minimal.elf

# Obtener tamaños detallados
$SIZE = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-size.exe"
& $SIZE simple_add_minimal.elf

# Comparar con FPGA
echo "=== RECURSOS COMPARISON ==="
echo "SoC Program Size: 7,124 bytes"
echo "SoC Binary Size: 1,092 bytes"
echo "FPGA Logic Elements: [Tu valor de Quartus]"
```

## ⏱️ **2. PERFORMANCE - Medición de Latencia**

### **Comando: Contar Instrucciones de la Función Main**
```powershell
# Extraer solo la función main del disassembly
echo "=== PERFORMANCE ANALYSIS ==="
findstr /C:"main>" simple_add_minimal.dis
findstr /A:20 "main>" simple_add_minimal.dis | findstr "li\|sw\|lw\|add\|j"

# Contar instrucciones críticas
$mainInstructions = (findstr /A:20 "main>" simple_add_minimal.dis | findstr "li\|sw\|lw\|add").Count
echo "Instrucciones Core: $mainInstructions"
```

### **Comando: Simular con Conteo de Ciclos**
```powershell
# Ejecutar QEMU con logging de instrucciones
qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -bios none -kernel simple_add_minimal.elf -d exec,cpu -D execution_trace.log
```

## ⚡ **3. POWER - Estimación de Consumo**

### **Comando: Análisis de Complejidad Computacional**
```powershell
# Analizar tipos de instrucciones para estimación de power
echo "=== POWER ESTIMATION ==="
$arithmeticOps = (findstr "add\|sub\|mul" simple_add_minimal.dis).Count
$memoryOps = (findstr "lw\|sw\|lb\|sb" simple_add_minimal.dis).Count
$controlOps = (findstr "j\|beq\|bne" simple_add_minimal.dis).Count

echo "Arithmetic Operations: $arithmeticOps"
echo "Memory Operations: $memoryOps" 
echo "Control Operations: $controlOps"

# Power estimation (ejemplo)
$estimatedPower = ($arithmeticOps * 2.5) + ($memoryOps * 1.8) + ($controlOps * 1.2)
echo "Estimated Dynamic Power Index: $estimatedPower mW (relative)"
```

## 📈 **4. Comparación Directa FPGA vs SoC**

### **Template para tu Informe:**
```powershell
echo "=== FPGA vs SoC COMPARISON REPORT ==="
echo ""
echo "RECURSOS:"
echo "  FPGA Total Logic Elements: [Tu valor]"
echo "  SoC Program Memory: 7,124 bytes"
echo "  FPGA Total Memory Bits: [Tu valor]" 
echo "  SoC Binary Size: 1,092 bytes"
echo ""
echo "PERFORMANCE:"
echo "  FPGA Max Frequency: [Tu valor] MHz"
echo "  SoC Simulation Frequency: 100 MHz (estimado)"
echo "  FPGA Execution Cycles: [Tu valor]"
echo "  SoC Core Instructions: ~8 instructions"
echo ""
echo "POWER:"
echo "  FPGA Core Dynamic Power: [Tu valor] mW"
echo "  SoC Estimated Dynamic Power: $estimatedPower mW (relativo)"
echo "  FPGA Total Thermal Power: [Tu valor] mW"
echo ""
```

## 🎯 **5. Métricas Específicas para Tesis**

### **Comando: Generar Reporte Académico**
```powershell
# Crear reporte detallado
$report = @"
# SoC Implementation Metrics Report
Generated: $(Get-Date)

## Core Algorithm Analysis (IDENTICAL to FPGA):
- Operation: result = a + b
- Input A: 10 (constant)
- Input B: 20 (constant)
- Expected Result: 30

## Resource Utilization:
- Program Size: 7,124 bytes
- Code Section: $(& $SIZE simple_add_minimal.elf | Select-String "text")
- Data Section: $(& $SIZE simple_add_minimal.elf | Select-String "data") 
- BSS Section: $(& $SIZE simple_add_minimal.elf | Select-String "bss")

## Performance Metrics:
- Core Instructions: ~8 RISC-V instructions
- Memory Accesses: 6 (3 stores + 3 loads)
- Arithmetic Operations: 1 (ADD)
- Control Flow: 1 (infinite loop)

## Power Estimation:
- Instruction Types Distribution:
  * Load/Store: 75% (6/8 instructions)
  * Arithmetic: 12.5% (1/8 instructions)  
  * Control: 12.5% (1/8 instructions)

## Comparison with FPGA:
- Algorithm Complexity: O(1) (IDENTICAL)
- Data Path Width: 32-bit (IDENTICAL)
- Operation Sequence: LOAD-LOAD-ADD-STORE (IDENTICAL)

"@

$report | Out-File "soc_metrics_report.txt"
echo "Reporte guardado en: soc_metrics_report.txt"
```

---

## ✅ **Respuesta a tu Pregunta Principal**

### **Parámetros COMPARABLES para tu tesis:**

#### **✅ RECURSOS (2 parámetros):**
1. **Memory Usage**: SoC 7,124 bytes vs FPGA memory bits
2. **Logic Complexity**: SoC 8 instructions vs FPGA logic elements

#### **✅ PERFORMANCE (2 parámetros):**
1. **Execution Speed**: SoC instruction count vs FPGA clock cycles
2. **Throughput**: Operations per second en ambas plataformas

#### **✅ POWER (1 parámetro):**
1. **Dynamic Power**: Estimación SoC vs FPGA core dynamic power

### **❌ NO COMPARABLES:**
- Pines (SoC no tiene pines físicos)
- Setup/Hold timing (diferentes arquitecturas)
- I/O Power (diferentes interfaces)

---

¿Quieres que ejecutemos estos comandos para obtener las métricas específicas? Primero sal de QEMU (Ctrl+A, X) y luego podemos continuar con las mediciones.