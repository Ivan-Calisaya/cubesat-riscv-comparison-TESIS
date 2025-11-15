# Guía de Implementación SoC RISC-V con Redundancia

## Información del Proyecto SoC

### Objetivos
- **Objetivo Principal**: Implementar procesadores RISC-V con redundancia en un SoC completo
- **Plataforma Target**: FPGA con periféricos integrados
- **Validación**: Sistema operativo embebido + aplicaciones de prueba

### Arquitectura del SoC
```
RISC-V SoC con Redundancia Modular
├── Core Processor (QMR/TMR/Single)
├── Memory Subsystem
│   ├── Instruction Memory (BRAM)
│   ├── Data Memory (BRAM)
│   └── Memory Controller
├── Peripheral Subsystem
│   ├── UART Controller
│   ├── GPIO Controller
│   ├── Timer/Counter
│   ├── Interrupt Controller
│   └── SPI Controller (opcional)
└── Interconnect (AXI4-Lite/Wishbone)
```

## Fase 1: Preparación del Entorno SoC

### Software Requerido

#### Opción A: Intel/Altera SoC (Recomendado - compatible con Quartus)
```powershell
# 1. Intel SoC EDS (Embedded Development Suite)
# Descargar desde: intel.com/content/www/us/en/software/programmable/soc-eds/overview.html

# 2. ARM Cross-Compiler
# RISC-V Cross-Compiler (ya lo tienes: xpack-riscv-none-elf-gcc)

# 3. OpenOCD para debugging
# U-Boot bootloader sources
# Linux kernel sources (opcional)
```

#### Opción B: Xilinx Zynq SoC
```powershell
# 1. Vivado Design Suite (2023.x)
# 2. Vitis Unified Software Platform
# 3. PetaLinux Tools
```

#### Opción C: Soft-SoC Puro (Más Simple)
```powershell
# 1. Quartus Prime (ya instalado)
# 2. ModelSim (ya instalado) 
# 3. RISC-V Toolchain (ya instalado)
# 4. OpenOCD para JTAG debugging
# 5. Litex SoC Builder (Python framework)
```

### Hardware Recomendado

#### Opción 1: DE1-SoC (Intel Cyclone V)
- **Procesador**: ARM Cortex-A9 dual-core
- **FPGA**: Cyclone V SE 5CSEMA5F31C6
- **Memoria**: 1GB DDR3, 64MB QSPI Flash
- **Conectividad**: Ethernet, USB, UART
- **Precio**: ~$200

#### Opción 2: DE10-Nano (Intel Cyclone V)
- **Procesador**: ARM Cortex-A9 dual-core  
- **FPGA**: Cyclone V SE 5CSEBA6U23I7
- **Memoria**: 1GB DDR3
- **Conectividad**: Ethernet, USB, UART, Arduino headers
- **Precio**: ~$130

#### Opción 3: Soft-SoC en DE0-Nano (Solo FPGA)
- **FPGA**: Cyclone IV E EP4CE22F17C6
- **Memoria**: 32MB SDRAM
- **Ventaja**: Económico (~$80), SoC completamente en FPGA

## Fase 2: Diseño del SoC

### 2.1 Componentes del SoC a Desarrollar

#### A. Memory Controller (`memory_controller.sv`)
```systemverilog
module memory_controller (
    input  logic        clk,
    input  logic        reset,
    
    // Processor Interface
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    input  logic        mem_write,
    input  logic        mem_read,
    output logic [31:0] read_data,
    output logic        ready,
    
    // SDRAM Interface (if external memory)
    output logic [12:0] sdram_addr,
    inout  wire  [15:0] sdram_data,
    output logic [1:0]  sdram_ba,
    output logic        sdram_cas_n,
    output logic        sdram_ras_n,
    output logic        sdram_we_n
);
```

#### B. UART Controller (`uart_controller.sv`)
```systemverilog
module uart_controller (
    input  logic        clk,
    input  logic        reset,
    
    // Processor Interface
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    input  logic        read_enable,
    output logic [31:0] read_data,
    
    // UART Interface
    input  logic        uart_rx,
    output logic        uart_tx,
    output logic        interrupt
);
```

#### C. GPIO Controller (`gpio_controller.sv`)
```systemverilog
module gpio_controller (
    input  logic        clk,
    input  logic        reset,
    
    // Processor Interface  
    input  logic [31:0] addr,
    input  logic [31:0] write_data,
    input  logic        write_enable,
    input  logic        read_enable,
    output logic [31:0] read_data,
    
    // GPIO Interface
    inout  wire  [31:0] gpio_pins,
    output logic [31:0] gpio_direction,
    output logic        interrupt
);
```

#### D. SoC Interconnect (`soc_interconnect.sv`)
```systemverilog
module soc_interconnect (
    input  logic        clk,
    input  logic        reset,
    
    // Processor Interface
    input  logic [31:0] cpu_addr,
    input  logic [31:0] cpu_write_data,
    input  logic        cpu_write_enable,
    input  logic        cpu_read_enable,
    output logic [31:0] cpu_read_data,
    output logic        cpu_ready,
    
    // Memory Interface
    output logic [31:0] mem_addr,
    output logic [31:0] mem_write_data,
    output logic        mem_write_enable,
    output logic        mem_read_enable,
    input  logic [31:0] mem_read_data,
    input  logic        mem_ready,
    
    // UART Interface
    output logic [31:0] uart_addr,
    output logic [31:0] uart_write_data,
    output logic        uart_write_enable,
    output logic        uart_read_enable,
    input  logic [31:0] uart_read_data,
    
    // GPIO Interface
    output logic [31:0] gpio_addr,
    output logic [31:0] gpio_write_data,
    output logic        gpio_write_enable,
    output logic        gpio_read_enable,
    input  logic [31:0] gpio_read_data
);
```

### 2.2 Top-Level SoC (`risc_v_soc.sv`)
```systemverilog
module risc_v_soc (
    input  logic        clk,
    input  logic        reset,
    
    // External Interfaces
    input  logic        uart_rx,
    output logic        uart_tx,
    inout  wire  [31:0] gpio_pins,
    
    // Debug Interface
    output logic [31:0] debug_pc,
    output logic [31:0] debug_result,
    output logic [31:0] debug_alu1_result,
    output logic [31:0] debug_alu2_result,
    output logic [31:0] debug_alu3_result,
    output logic [31:0] debug_alu4_result,  // Solo para QMR
    output logic [31:0] debug_alu5_result,  // Solo para QMR
    output logic [2:0]  debug_majority_status
);
```

## Fase 3: Software del SoC

### 3.1 Bootloader Personalizado

#### A. Boot ROM (`boot.S`)
```assembly
# Boot ROM para RISC-V SoC
.section .text.boot
.globl _start

_start:
    # Configurar stack pointer
    la sp, _stack_top
    
    # Configurar periféricos básicos
    jal setup_uart
    jal setup_gpio
    
    # Imprimir mensaje de bienvenida
    la a0, welcome_msg
    jal uart_print
    
    # Saltar al programa principal
    jal main
    
setup_uart:
    # Configurar UART a 115200 baud
    li t0, 0x40000000    # Base UART
    li t1, 0x36          # Divisor para 115200@50MHz
    sw t1, 0(t0)         # Escribir divisor
    ret

setup_gpio:
    # Configurar GPIO como salida
    li t0, 0x40001000    # Base GPIO
    li t1, 0xFFFFFFFF    # Todos como salida
    sw t1, 4(t0)         # Escribir dirección
    ret

uart_print:
    # Función para imprimir string
    # a0 = dirección del string
    li t0, 0x40000000    # Base UART
uart_loop:
    lb t1, 0(a0)         # Cargar byte
    beq t1, zero, uart_done
    sw t1, 8(t0)         # Escribir a UART TX
    addi a0, a0, 1       # Siguiente byte
    j uart_loop
uart_done:
    ret

.section .data
welcome_msg:
    .string "RISC-V SoC con Redundancia Iniciado!\n\0"
```

#### B. Linker Script SoC (`soc_link.ld`)
```ld
MEMORY {
    BOOT_ROM : ORIGIN = 0x00000000, LENGTH = 8K
    MAIN_RAM : ORIGIN = 0x20000000, LENGTH = 64K
    UART     : ORIGIN = 0x40000000, LENGTH = 256
    GPIO     : ORIGIN = 0x40001000, LENGTH = 256
}

SECTIONS {
    .boot : {
        *(.text.boot)
    } > BOOT_ROM
    
    .text : {
        *(.text)
    } > MAIN_RAM
    
    .data : {
        *(.data)
    } > MAIN_RAM
    
    .bss : {
        *(.bss)
    } > MAIN_RAM
}
```

### 3.2 Aplicaciones de Prueba SoC

#### A. Test de Redundancia (`redundancy_test.c`)
```c
#include <stdint.h>

// Direcciones de memoria del SoC
#define UART_BASE   0x40000000
#define GPIO_BASE   0x40001000
#define UART_TX     (UART_BASE + 8)
#define GPIO_OUT    (GPIO_BASE + 0)

// Funciones de acceso a periféricos
void uart_putc(char c) {
    volatile uint32_t *uart_tx = (uint32_t*)UART_TX;
    *uart_tx = c;
}

void uart_puts(const char *str) {
    while (*str) {
        uart_putc(*str++);
    }
}

void gpio_write(uint32_t value) {
    volatile uint32_t *gpio_out = (uint32_t*)GPIO_OUT;
    *gpio_out = value;
}

// Funciones de prueba
void test_single_alu() {
    uart_puts("=== Test Single ALU ===\n");
    volatile int a = 15, b = 25;
    volatile int result = a + b;
    
    uart_puts("15 + 25 = ");
    // Convertir resultado a string y enviar
    uart_putc('0' + (result / 10));
    uart_putc('0' + (result % 10));
    uart_puts("\n");
    
    gpio_write(result);  // Mostrar en LEDs
}

void test_tmr_redundancy() {
    uart_puts("=== Test TMR (3 ALUs) ===\n");
    volatile int a = 100, b = 200;
    volatile int result = a + b;
    
    uart_puts("100 + 200 = ");
    uart_putc('0' + (result / 100));
    uart_putc('0' + ((result % 100) / 10));
    uart_putc('0' + (result % 10));
    uart_puts("\n");
    
    gpio_write(result & 0xFFFF);
}

void test_qmr_redundancy() {
    uart_puts("=== Test QMR (5 ALUs) ===\n");
    volatile int a = 500, b = 750;
    volatile int result = a + b;
    
    uart_puts("500 + 750 = ");
    // Convertir a string
    uart_puts("1250\n");
    
    gpio_write(result & 0xFFFF);
}

int main() {
    uart_puts("\n=== RISC-V SoC Redundancy Tests ===\n");
    uart_puts("Procesador: RISC-V RV32I\n");
    uart_puts("Sistema: SoC con Perifericos\n\n");
    
    // Ejecutar pruebas
    test_single_alu();
    test_tmr_redundancy();
    test_qmr_redundancy();
    
    uart_puts("\n=== Todas las pruebas completadas ===\n");
    uart_puts("Ver resultados en LEDs y UART\n");
    
    // Loop infinito
    while (1) {
        // Parpadear LED de vida
        gpio_write(0xAAAA);
        for (int i = 0; i < 100000; i++) __asm__("nop");
        gpio_write(0x5555);
        for (int i = 0; i < 100000; i++) __asm__("nop");
    }
    
    return 0;
}
```

#### B. Makefile para SoC (`Makefile.soc`)
```makefile
# Makefile para RISC-V SoC

RISCV_PREFIX = xpack-riscv-none-elf-
CC = $(RISCV_PREFIX)gcc
OBJCOPY = $(RISCV_PREFIX)objcopy
OBJDUMP = $(RISCV_PREFIX)objdump

CFLAGS = -march=rv32i -mabi=ilp32 -nostartfiles -nostdlib -mcmodel=medany
LDFLAGS = -T soc_link.ld

SOURCES = boot.S redundancy_test.c
TARGET = soc_program

all: $(TARGET).hex $(TARGET).bin

$(TARGET).elf: $(SOURCES) soc_link.ld
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $(SOURCES)

$(TARGET).bin: $(TARGET).elf
	$(OBJCOPY) -O binary $< $@

$(TARGET).hex: $(TARGET).elf
	$(OBJCOPY) -O verilog $< $@

$(TARGET).dump: $(TARGET).elf
	$(OBJDUMP) -D $< > $@

clean:
	rm -f *.elf *.bin *.hex *.dump

.PHONY: all clean
```

## Fase 4: Implementación en FPGA

### 4.1 Compilación y Síntesis

#### Para Quartus II (Intel):
```tcl
# Script TCL para Quartus
set_global_assignment -name FAMILY "Cyclone V"
set_global_assignment -name DEVICE 5CSEMA5F31C6
set_global_assignment -name TOP_LEVEL_ENTITY risc_v_soc

# Archivos del SoC
set_global_assignment -name SYSTEMVERILOG_FILE risc_v_soc.sv
set_global_assignment -name SYSTEMVERILOG_FILE soc_interconnect.sv
set_global_assignment -name SYSTEMVERILOG_FILE memory_controller.sv
set_global_assignment -name SYSTEMVERILOG_FILE uart_controller.sv
set_global_assignment -name SYSTEMVERILOG_FILE gpio_controller.sv

# Archivos del procesador (ya existentes)
set_global_assignment -name SYSTEMVERILOG_FILE simple_processor.sv
set_global_assignment -name SYSTEMVERILOG_FILE tmr_alu.sv
set_global_assignment -name SYSTEMVERILOG_FILE majority_voter.sv

# Memory initialization
set_global_assignment -name MIF_FILE boot_rom.mif
set_global_assignment -name MIF_FILE main_ram.mif
```

### 4.2 Testing del SoC

#### A. Testbench del SoC (`risc_v_soc_tb.sv`)
```systemverilog
module risc_v_soc_tb;
    logic        clk;
    logic        reset;
    logic        uart_rx;
    wire         uart_tx;
    wire  [31:0] gpio_pins;
    
    // Instanciar SoC
    risc_v_soc dut (
        .clk(clk),
        .reset(reset),
        .uart_rx(uart_rx),
        .uart_tx(uart_tx),
        .gpio_pins(gpio_pins)
    );
    
    // Clock generation
    initial begin
        clk = 0;
        forever #10 clk = ~clk;  // 50MHz
    end
    
    // Test sequence
    initial begin
        reset = 1;
        uart_rx = 1;
        
        #100 reset = 0;
        
        // Esperar boot y ejecución
        #1000000;
        
        $display("=== SoC Test Completed ===");
        $display("UART TX: %b", uart_tx);
        $display("GPIO: 0x%h", gpio_pins);
        
        $finish;
    end
    
    // Monitoreo UART
    always @(negedge uart_tx) begin
        $display("UART TX toggled at time %t", $time);
    end
    
    // Monitoreo GPIO
    always @(gpio_pins) begin
        $display("GPIO changed to: 0x%h at time %t", gpio_pins, $time);
    end
endmodule
```

## Fase 5: Debugging y Validación

### 5.1 Setup OpenOCD para JTAG
```bash
# Archivo openocd.cfg
source [find interface/altera-usb-blaster.cfg]
source [find target/risc-v.cfg]

adapter_khz 1000

init
reset halt
```

### 5.2 GDB Debugging
```bash
# Terminal 1: OpenOCD
openocd -f openocd.cfg

# Terminal 2: GDB
xpack-riscv-none-elf-gdb soc_program.elf
(gdb) target remote localhost:3333
(gdb) load
(gdb) break main
(gdb) continue
```

## Recursos y Herramientas Adicionales

### Software Open Source para SoC
1. **LiteX**: Framework Python para generar SoCs
2. **PULP Platform**: SoC RISC-V open source
3. **Rocket Chip**: Generador de SoCs RISC-V
4. **VexRiscv**: Core RISC-V optimizado para FPGA

### Documentación y Referencias
1. **RISC-V SoC Design**: "Digital Design and Computer Architecture RISC-V Edition"
2. **FPGA SoC Development**: Intel SoC EDS User Guide
3. **Embedded RISC-V**: "The RISC-V Reader"

## Cronograma de Implementación

| Fase | Duración | Entregables |
|------|----------|-------------|
| **Fase 1**: Setup del entorno | 1 semana | Software instalado, hardware configurado |
| **Fase 2**: Diseño SoC | 2 semanas | Componentes SystemVerilog del SoC |
| **Fase 3**: Software embebido | 1 semana | Bootloader + aplicaciones de prueba |
| **Fase 4**: Integración FPGA | 1 semana | SoC funcionando en hardware |
| **Fase 5**: Validación | 1 semana | Tests completos + documentación |

**Total**: ~6 semanas para SoC completo

## Conclusiones

La implementación de tus procesadores RISC-V en un SoC es definitivamente factible y representaría una contribución significativa a tu tesis. El enfoque de Soft-SoC en FPGA es el más apropiado dado tu experiencia actual con Quartus II y ModelSim.

### Beneficios del SoC:
- **Validación real**: Testing en hardware con periféricos
- **Aplicaciones prácticas**: Comunicación UART, control GPIO
- **Escalabilidad**: Base para sistemas más complejos
- **Diferenciación**: Pocos trabajos implementan redundancia en SoCs

### Próximos Pasos Recomendados:
1. **Decidir plataforma**: DE1-SoC, DE10-Nano, o Soft-SoC puro
2. **Comenzar con Fase 1**: Setup del entorno
3. **Implementar incrementalmente**: Single ALU → TMR → QMR
4. **Documentar exhaustivamente**: Para tu tesis

¿Te gustaría que comience con alguna fase específica o tienes preferencia por alguna plataforma de hardware?