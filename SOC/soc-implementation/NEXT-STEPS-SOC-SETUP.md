# Próximos Pasos: Configuración del Entorno SoC RISC-V

## 🎯 Estado Actual
✅ **QEMU 10.1.0** instalado y funcionando  
✅ **PATH configurado** (manualmente)  
✅ **RISC-V 64-bit** verificado  
✅ **Máquinas virtuales** disponibles: virt, spike, sifive_e, sifive_u  

## 🚀 Objetivos Inmediatos

### 1. Configurar Entorno SoC para ejecutar `simple_add.c`
### 2. Crear equivalencia con implementación FPGA  
### 3. Desarrollar framework de comparación

---

## 📋 Plan de Desarrollo SoC

### **Opción A: Bare-Metal RISC-V (Recomendado para empezar)**
- ✅ **Ventaja**: Control total, métricas precisas
- ✅ **Equivalencia**: Más cercano a tu implementación FPGA
- ⚠️ **Complejidad**: Requiere bootloader mínimo

### **Opción B: Linux Embebido**
- ✅ **Ventaja**: Ecosistema completo, tools disponibles
- ⚠️ **Desventaja**: Overhead del OS, métricas menos precisas
- ⚠️ **Complejidad**: Setup más complejo

### **Decisión**: Empezar con **Bare-Metal** para comparación directa

## 🔬 Justificación Académica: ¿Por qué Adaptar el Código FPGA?

### **Pregunta Clave para la Tesis**
*"¿Por qué no podemos usar directamente el código FPGA (`simple_add.c`) en el entorno SoC?"*

### **Respuesta Técnica:**

#### **Código FPGA Original:**
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

#### **Limitaciones en SoC:**
| Problema | FPGA | SoC | Impacto |
|----------|------|-----|---------|
| **Observabilidad** | Waveforms en ModelSim | ❌ Sin output visible | No podemos verificar resultados |
| **Startup** | HDL maneja reset | ❌ Necesita bootloader | Falla al ejecutar |
| **Memory Map** | Implícito en HDL | ❌ Requiere linker script | Direcciones incorrectas |
| **Stack** | Hardware configurado | ❌ Debe inicializarse | Crashes potenciales |

#### **Estrategia de Adaptación:**
✅ **Mantener LÓGICA CORE idéntica** (`result = a + b`)  
✅ **Agregar infraestructura SoC** (UART, bootloader, etc.)  
✅ **Documentar overhead separadamente** para comparación válida  

**Resultado:** Comparación académica válida manteniendo algoritmo constante.

*Ver análisis completo en: `FPGA-SOC-CODE-ANALYSIS.md`*

---

### 1.1 Verificar Programa Existente
```powershell
# Verificar que tenemos el programa de la implementación FPGA
Get-ChildItem "C:\Users\Usuario\Desktop\Ivan\SOC\fpga-implementation" -Recurse -Name "simple_add.*"
```

### 1.2 Copiar Archivos Necesarios
```powershell
# Crear directorio de trabajo SoC
cd "C:\Users\Usuario\Desktop\Ivan\SOC\soc-implementation"
mkdir bare-metal-workspace
cd bare-metal-workspace

# Copiar archivos fuente desde FPGA implementation
copy "..\fpga-implementation\software\simple_add.c" "."
copy "..\fpga-implementation\software\simple_add.elf" "."
copy "..\fpga-implementation\software\link.ld" "."

# Verificar archivos copiados
Get-ChildItem
```

### 1.3 Analizar Programa Actual
```powershell
# Verificar contenido del programa
Get-Content "simple_add.c"

# Si tienes el toolchain RISC-V disponible, analizar ELF:
# C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe -d simple_add.elf
```

---

## 🔧 Paso 2: Crear Bootloader Mínimo

### 2.1 Crear Startup Assembly
```assembly
# Archivo: startup.s
# Bootloader mínimo para RISC-V bare-metal

.section .text.init
.global _start

_start:
    # Setup stack pointer
    la sp, _stack_top
    
    # Setup global pointer
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    
    # Clear BSS section
    la t0, _bss_start
    la t1, _bss_end
clear_bss:
    bgeu t0, t1, clear_bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss
clear_bss_done:
    
    # Call main function
    call main
    
    # Infinite loop if main returns
halt:
    wfi
    j halt

.section .data
.section .bss
```

### 2.2 Crear Linker Script para SoC
```ld
/* Archivo: soc_link.ld */
/* Linker script para RISC-V SoC (QEMU virt machine) */

ENTRY(_start)

MEMORY
{
    RAM : ORIGIN = 0x80000000, LENGTH = 64M
}

SECTIONS
{
    . = 0x80000000;
    
    .text : {
        *(.text.init)
        *(.text)
    } > RAM
    
    .rodata : {
        *(.rodata)
    } > RAM
    
    .data : {
        *(.data)
    } > RAM
    
    .bss : {
        _bss_start = .;
        *(.bss)
        _bss_end = .;
    } > RAM
    
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
    
    PROVIDE(__global_pointer$ = _bss_start + 0x800);
}
```

### 2.3 Modificar simple_add.c para SoC
```c
// Archivo: simple_add_soc.c
// Versión SoC del programa simple_add

#include <stdint.h>

// Memory-mapped I/O para QEMU virt machine
#define UART_BASE 0x10000000
#define UART_THR  (UART_BASE + 0x00)  // Transmit Holding Register

// Función para escribir carácter vía UART
void uart_putchar(char c) {
    volatile uint32_t *uart_thr = (volatile uint32_t*)UART_THR;
    *uart_thr = c;
}

// Función para escribir string
void uart_puts(const char *str) {
    while (*str) {
        uart_putchar(*str);
        str++;
    }
}

// Función para escribir número en hexadecimal
void uart_put_hex(uint32_t val) {
    uart_puts("0x");
    for (int i = 28; i >= 0; i -= 4) {
        uint32_t nibble = (val >> i) & 0xF;
        char hex_char = (nibble < 10) ? ('0' + nibble) : ('A' + nibble - 10);
        uart_putchar(hex_char);
    }
}

// Programa principal (equivalente al FPGA)
int main(void) {
    // Operación simple: suma de dos números
    uint32_t a = 0x12345678;
    uint32_t b = 0x87654321;
    uint32_t resultado;
    
    uart_puts("=== RISC-V SoC Test ===\n");
    uart_puts("Iniciando suma simple...\n");
    
    uart_puts("A = ");
    uart_put_hex(a);
    uart_puts("\n");
    
    uart_puts("B = ");
    uart_put_hex(b);
    uart_puts("\n");
    
    // Realizar suma (operación equivalente al FPGA)
    resultado = a + b;
    
    uart_puts("A + B = ");
    uart_put_hex(resultado);
    uart_puts("\n");
    
    uart_puts("Test completado exitosamente!\n");
    
    // Loop infinito (equivalente a halt en FPGA)
    while (1) {
        __asm__ volatile ("wfi");  // Wait for interrupt
    }
    
    return 0;
}
```

---

## 🔧 Paso 3: Compilar para SoC

### 3.1 Script de Compilación
```powershell
# Archivo: build_soc.ps1
# Script para compilar programa RISC-V para SoC

$TOOLCHAIN_PATH = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin"
$GCC = "$TOOLCHAIN_PATH\riscv-none-elf-gcc.exe"
$OBJDUMP = "$TOOLCHAIN_PATH\riscv-none-elf-objdump.exe"
$OBJCOPY = "$TOOLCHAIN_PATH\riscv-none-elf-objcopy.exe"

Write-Host "=== Building RISC-V SoC Program ===" -ForegroundColor Green

# Compilar startup.s
Write-Host "Compiling startup assembly..." -ForegroundColor Yellow
& $GCC -march=rv32ima -mabi=ilp32 -c startup.s -o startup.o

# Compilar simple_add_soc.c
Write-Host "Compiling main program..." -ForegroundColor Yellow
& $GCC -march=rv32ima -mabi=ilp32 -c simple_add_soc.c -o simple_add_soc.o

# Enlazar con linker script
Write-Host "Linking..." -ForegroundColor Yellow
& $GCC -march=rv32ima -mabi=ilp32 -T soc_link.ld -nostartfiles -o simple_add_soc.elf startup.o simple_add_soc.o

# Generar archivo binario
Write-Host "Generating binary..." -ForegroundColor Yellow
& $OBJCOPY -O binary simple_add_soc.elf simple_add_soc.bin

# Generar disassembly para análisis
Write-Host "Generating disassembly..." -ForegroundColor Yellow
& $OBJDUMP -d simple_add_soc.elf > simple_add_soc.dis

Write-Host "Build completed successfully!" -ForegroundColor Green
Write-Host "Files generated:" -ForegroundColor Cyan
Get-ChildItem "simple_add_soc.*"
```

---

## 🔧 Paso 4: Ejecutar en QEMU SoC

### 4.1 Script de Ejecución
```powershell
# Archivo: run_soc.ps1
# Script para ejecutar programa en QEMU SoC

param(
    [string]$Program = "simple_add_soc.elf",
    [string]$LogFile = "soc_execution.log"
)

Write-Host "=== Running RISC-V SoC Simulation ===" -ForegroundColor Green

# Verificar que el programa existe
if (!(Test-Path $Program)) {
    Write-Host "Error: Program file '$Program' not found" -ForegroundColor Red
    exit 1
}

Write-Host "Program: $Program" -ForegroundColor Cyan
Write-Host "Log: $LogFile" -ForegroundColor Cyan

# Comando QEMU para SoC simulation
$qemu_cmd = @(
    "qemu-system-riscv32",
    "-machine", "virt",
    "-cpu", "rv32",
    "-m", "64M",
    "-nographic",
    "-serial", "stdio",
    "-bios", "none",
    "-kernel", $Program
)

Write-Host "QEMU Command: $($qemu_cmd -join ' ')" -ForegroundColor Gray
Write-Host "`nStarting simulation..." -ForegroundColor Yellow
Write-Host "Press Ctrl+A then X to exit QEMU" -ForegroundColor Magenta

# Ejecutar QEMU y capturar output
Start-Process -FilePath $qemu_cmd[0] -ArgumentList $qemu_cmd[1..($qemu_cmd.Length-1)] -Wait
```

### 4.2 Script de Análisis de Performance
```powershell
# Archivo: analyze_performance.ps1
# Análisis de métricas SoC vs FPGA

Write-Host "=== SoC Performance Analysis ===" -ForegroundColor Green

# Ejecutar con métricas habilitadas
$qemu_cmd = @(
    "qemu-system-riscv32",
    "-machine", "virt",
    "-cpu", "rv32",
    "-m", "64M",
    "-nographic",
    "-serial", "stdio",
    "-bios", "none",
    "-kernel", "simple_add_soc.elf",
    "-icount", "shift=0",  # Instrucciones por ciclo
    "-d", "exec",          # Log de ejecución
    "-D", "execution.log"  # Archivo de debug
)

Write-Host "Running with performance monitoring..." -ForegroundColor Yellow
# & $qemu_cmd

# Analizar resultados
Write-Host "Performance metrics will be available in execution.log" -ForegroundColor Cyan
Write-Host "Next: Compare with FPGA metrics" -ForegroundColor Yellow
```

---

## 🔧 Paso 5: Framework de Comparación

### 5.1 Estructura de Comparación
```
soc-implementation/
├── bare-metal-workspace/
│   ├── simple_add_soc.c      # Programa SoC
│   ├── startup.s             # Bootloader
│   ├── soc_link.ld          # Linker script
│   ├── build_soc.ps1        # Script compilación
│   ├── run_soc.ps1          # Script ejecución
│   └── analyze_performance.ps1
├── comparison-framework/
│   ├── metrics_collector.ps1  # Recolección métricas
│   ├── fpga_vs_soc.ps1       # Comparación
│   └── results/              # Resultados
└── documentation/
```

### 5.2 Plan de Métricas

| Métrica | FPGA | SoC (QEMU) | Comparación |
|---------|------|------------|-------------|
| **Latencia** | Ciclos de reloj | Instrucciones ejecutadas | Normalizar por frecuencia |
| **Throughput** | Operaciones/segundo | Operaciones/segundo | Directo |
| **Recursos** | LUTs/FFs usados | Memoria RAM usada | Eficiencia |
| **Energía** | Reporte Quartus | Estimación QEMU | Relativo |
| **Área** | Device utilization | N/A | Solo FPGA |

---

## ✅ Checklist Próximos Pasos

### Inmediato (Siguiente sesión):
- [ ] Crear archivos: `startup.s`, `soc_link.ld`, `simple_add_soc.c`
- [ ] Crear scripts: `build_soc.ps1`, `run_soc.ps1`
- [ ] Compilar programa para SoC
- [ ] Verificar ejecución en QEMU

### Corto plazo:
- [ ] Implementar métricas de performance
- [ ] Crear framework de comparación
- [ ] Documentar diferencias FPGA vs SoC

### Mediano plazo:
- [ ] Expandir test cases
- [ ] Análisis estadístico
- [ ] Documentación para tesis

---

## 🎯 Objetivo Final

**Ejecutar el mismo programa `simple_add.c` en:**
1. **FPGA**: Tu implementación actual (Single ALU, TMR, QMR)
2. **SoC**: QEMU simulation con métricas comparables

**Resultado**: Datos cuantitativos para comparación académica FPGA vs SoC en CubeSats.

---

¿Listo para empezar con la configuración del entorno bare-metal? ¡Vamos a crear los archivos necesarios!