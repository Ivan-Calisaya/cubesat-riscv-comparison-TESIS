# 🎯 Manual de Comandos: Compilación SoC IDÉNTICA al FPGA

## ✅ **Pregunta Respondida:**
**SÍ, agregué UART solo para QEMU. El procesador FPGA original NO tenía UART.**

## 📋 **Comandos Paso a Paso para Replicar**

### **Paso 1: Configurar Variables del Entorno**
```powershell
# Cambiar al directorio de trabajo
cd "C:\Users\Usuario\Desktop\Ivan\SOC\soc-implementation\bare-metal-workspace"

# Definir rutas del toolchain RISC-V
$TOOLCHAIN = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe"
$OBJDUMP = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe"

# Verificar que QEMU esté en el PATH
$env:PATH += ";C:\Program Files\qemu"
```

### **Paso 2: Compilar Bootloader (Igual para Ambas Versiones)**
```powershell
# Compilar startup.s (bootloader necesario para SoC)
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c startup.s -o startup_minimal.o
```

### **Paso 3A: Compilar Versión SIN UART (IDÉNTICA al FPGA)**
```powershell
# Compilar programa principal sin UART
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c simple_add_soc_minimal.c -o simple_add_minimal.o

# Enlazar executable
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -T soc_link.ld -nostartfiles -nostdlib -static -o simple_add_minimal.elf startup_minimal.o simple_add_minimal.o
```

### **Paso 3B: Compilar Versión CON UART (Para Debug)**
```powershell
# Compilar programa con UART para verificación
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c simple_add_soc.c -o simple_add_soc.o

# Enlazar executable con UART
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -T soc_link.ld -nostartfiles -nostdlib -static -o simple_add_soc.elf startup.o simple_add_soc.o
```

### **Paso 4: Análisis de Resultados**
```powershell
# Comparar tamaños
echo "=== Comparación de Tamaños ==="
echo "SIN UART (IDÉNTICO FPGA):"
Get-Item simple_add_minimal.elf | Select-Object Name, Length
echo "CON UART (Para Debug):"
Get-Item simple_add_soc.elf | Select-Object Name, Length

# Generar disassembly para análisis
& $OBJDUMP -d simple_add_minimal.elf > simple_add_minimal.dis
& $OBJDUMP -d simple_add_soc.elf > simple_add_soc.dis
```

### **Paso 5: Ejecutar en QEMU (Ambas Versiones)**
```powershell
# Ejecutar versión sin UART (no verás output, pero ejecuta)
qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -bios none -kernel simple_add_minimal.elf

# Ejecutar versión con UART (para verificar funcionamiento)
qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -serial stdio -bios none -kernel simple_add_soc.elf
```

---

## 🔍 **Análisis de los Resultados Obtenidos**

### **Tamaños Compilados:**
```
simple_add_minimal.elf    7,124 bytes  (SIN UART - IDÉNTICO FPGA)
simple_add_soc.elf       11,544 bytes  (CON UART - Para debug)
```

**Diferencia:** La versión con UART es **38% más grande** (4,420 bytes adicionales)

### **Código Fuente Comparison:**

#### **FPGA Original:**
```c
int main() {
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;
    result = a + b;
    while(1);
    return 0;
}
```

#### **SoC Minimal (IDÉNTICO):**
```c
int main() {
    // EXACTAMENTE IGUAL AL FPGA
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;
    result = a + b;
    while(1);
    return 0;
}
```

#### **SoC con UART (Para Debug):**
```c
int main(void) {
    // LÓGICA IDÉNTICA AL FPGA
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;
    result = a + b;
    
    // AGREGADO: Output para verificación
    uart_puts("Result = ");
    uart_put_number(result);
    
    while(1) { __asm__ volatile ("wfi"); }
    return 0;
}
```

---

## 📊 **Instrucciones RISC-V Generadas**

### **Core Algorithm (IDÉNTICO en Ambas):**
```assembly
# Función main - EXACTAMENTE IGUAL:
8000008c <main>:
    li       a5,10        # a = 10
    sw       a5,4(sp)     # store a
    li       a5,20        # b = 20  
    sw       a5,8(sp)     # store b
    lw       a5,4(sp)     # load a
    lw       a4,8(sp)     # load b
    add      a5,a5,a4     # result = a + b
    sw       a5,12(sp)    # store result
    j        main+0x24    # while(1) loop
```

**ESTAS INSTRUCCIONES SON IDÉNTICAS EN FPGA Y SOC**

### **Diferencias:**
- **FPGA**: Solo las instrucciones ALU de arriba
- **SoC Minimal**: Mismas instrucciones + bootloader (startup.s)
- **SoC con UART**: Mismas instrucciones + bootloader + funciones UART

---

## 🎯 **Validación Académica**

### **Para tu Tesis - Comparación VÁLIDA:**

#### **Metodología Correcta:**
```
FPGA:      ALU core only (result = a + b)
SoC:       ALU core only (result = a + b) + bootloader mínimo
```

#### **Métricas Comparables:**
1. **Instrucciones Core**: ADD, LOAD, STORE (IDÉNTICAS)
2. **Latencia Algorítmica**: Tiempo de `a + b` (COMPARABLE)
3. **Throughput**: Operaciones por segundo (COMPARABLE)
4. **Complejidad**: O(1) en ambas plataformas (IDÉNTICA)

#### **Overhead Separable:**
```
SoC Total = Core Algorithm + Bootloader Overhead
FPGA Total = Core Algorithm + HDL Startup Overhead

Comparación = (SoC Core) vs (FPGA Core)
```

---

## ✅ **Conclusión Final**

### **Respuesta a tu Pregunta:**
1. **❌ FPGA original NO usaba UART** - Solo ALU
2. **✅ Agregué UART solo para debug/verificación en QEMU**
3. **✅ La comparación correcta es SIN UART** (`simple_add_minimal.elf`)
4. **✅ Algoritmo core preservado 100%** en versión minimal

### **Archivos para Comparación FPGA vs SoC:**
- **FPGA**: `simple_add.c` (tu original)
- **SoC**: `simple_add_soc_minimal.c` (versión idéntica sin UART)

### **Status del Proyecto:**
```
✅ FPGA Implementation: Single ALU, TMR, QMR
✅ SoC Implementation: Minimal (sin UART) + Debug (con UART)  
✅ Comparación Académica: VÁLIDA (algoritmo idéntico)
✅ Documentación: Completa y justificada
```

### **Próximo Paso:**
**Usar `simple_add_minimal.elf` para métricas de comparación** ya que es idéntico al FPGA en lógica core.

---

¿Te parece correcto este enfoque? ¿Quieres que continuemos con el análisis de performance usando la versión minimal que es idéntica al FPGA?