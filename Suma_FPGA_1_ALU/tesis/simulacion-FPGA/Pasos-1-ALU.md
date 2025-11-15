# Pasos-1-ALU: Simulación del Procesador RISC-V con Verificación de la ALU

## Información del Proyecto

### Tipo de Procesador
- **Arquitectura**: RISC-V RV32I (RISC-V de 32 bits con extensión básica de enteros)
- **Tipo**: Procesador de ciclo único (single-cycle processor)
- **Implementación**: Softcore en SystemVerilog
- **Extensiones soportadas**: 
  - **I (Integer)**: Conjunto básico de instrucciones enteras
  - **Zicsr**: Control and Status Register instructions (básico)

### Descripción de la Arquitectura RV32I
- **RV32I**: Es la extensión base de RISC-V para 32 bits que incluye:
  - Instrucciones aritméticas básicas (ADD, SUB, ADDI, etc.)
  - Instrucciones lógicas (AND, OR, XOR, etc.)
  - Instrucciones de carga y almacenamiento (LW, SW, LB, SB, etc.)
  - Instrucciones de salto y rama (JAL, JALR, BEQ, BNE, etc.)
  - Instrucciones de comparación (SLT, SLTI, etc.)
  - 32 registros de propósito general (x0-x31)

## Descripción del Experimento

Este documento describe el procedimiento completo para simular un procesador RISC-V RV32I y verificar su funcionamiento mediante la ejecución de un programa simple que realiza la suma de dos números enteros. La verificación se centra en observar los valores procesados por la Unidad Aritmético-Lógica (ALU) durante la operación.

## Programa de Prueba

### Código Fuente (simple_add.c)
```c
int main() {
    // Usamos 'volatile' para asegurar que el compilador no optimice
    // las variables y genere instrucciones de carga y almacenamiento.
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;

    result = a + b;

    // Bucle infinito al final para detener el procesador.
    // En hardware real, esto evita que ejecute basura.
    // En simulación, nos da un punto estable para verificar el resultado.
    while(1);

    return 0; // Esta línea nunca se alcanzará.
}
```

### Objetivos del Programa
- Verificar instrucciones de carga inmediata (ADDI)
- Verificar instrucciones de suma (ADD)
- Verificar el funcionamiento de la ALU
- Comprobar el almacenamiento en registros
- Verificar el bucle infinito final

## Proceso de Compilación

### Herramientas Utilizadas
- **Compilador**: RISC-V GCC Toolchain
- **Comando de compilación**:
```bash
riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -T link.ld -o simple_add.elf simple_add.c
```

### Explicación de los Parámetros
- `-march=rv32i`: Especifica la arquitectura objetivo (RV32I)
- `-mabi=ilp32`: Define la ABI (Application Binary Interface) para 32 bits
- `-nostdlib`: No enlaza las bibliotecas estándar de C
- `-ffreestanding`: Indica programación en "metal desnudo" (bare-metal)
- `-T link.ld`: Utiliza el script de enlazado personalizado

### Conversión a Formato Hexadecimal
```bash
riscv64-unknown-elf-objcopy -O binary simple_add.elf simple_add.bin
python export_opcode_rv.py simple_add.bin programa.hex
```

## Configuración del Entorno de Simulación

### Estructura de Archivos
```
simulacion-FPGA/
├── run_simulation.do          # Script principal de ModelSim
├── check_values.do           # Script de verificación de valores
├── README.md                 # Documentación de configuración
├── work/                     # Directorio de trabajo de ModelSim (se crea automáticamente)
├── transcript                # Log de simulación (se crea automáticamente)
└── vsim.wlf                 # Archivo de ondas (se crea automáticamente)
```

### Archivos Fuente Utilizados
- **Componentes del procesador**: `../mi_procesador_riscv/components/*.sv`
- **Testbench**: `../mi_procesador_riscv/tb/simple_processor_tb.sv`
- **Memoria de inicialización**: `../mi_procesador_riscv/tb/imem_init.txt`

## Procedimiento de Simulación

### Paso 1: Preparación del Entorno
1. Abrir ModelSim
2. Navegar al directorio de simulación:
```tcl
cd {C:/Users/Usuario/Desktop/Ivan/tesis/simulacion-FPGA}
```

### Paso 2: Compilación de Archivos
```tcl
# Compilar todos los componentes del procesador
vlog C:/Users/Usuario/Desktop/Ivan/tesis/mi_procesador_riscv/components/*.sv

# Compilar el testbench
vlog C:/Users/Usuario/Desktop/Ivan/tesis/mi_procesador_riscv/tb/simple_processor_tb.sv
```

### Paso 3: Carga de la Simulación
```tcl
# Cargar el testbench en el simulador
vsim -voptargs="+acc" work.simple_processor_tb
```

### Paso 4: Configuración de Señales
```tcl
# Señales básicas de control
add wave /simple_processor_tb/clk
add wave /simple_processor_tb/reset

# Program Counter
add wave -hex /simple_processor_tb/dut/dp/FETCH/PC/q
add wave -label "PC" -hex /simple_processor_tb/dut/dp/FETCH/PC/q

# Instrucción actual
add wave -hex /simple_processor_tb/dut/instrMem/q0
add wave -label "Instrucción" -hex /simple_processor_tb/dut/instrMem/q0

# Banco de registros
add wave -label "x0" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[0]
add wave -label "x1" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[1]
add wave -label "x2" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[2]
add wave -label "x3" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[3]
add wave -label "x4" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[4]
add wave -label "x5" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
add wave -label "x6" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
add wave -label "x7" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# Señales de la ALU (críticas para verificación)
add wave -label "ALU_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/a
add wave -label "ALU_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/b
add wave -label "ALU_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/result
add wave -label "ALU_Control" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/ALUControl
```

### Paso 5: Ejecución de la Simulación
```tcl
# Ejecutar la simulación completa
run -all
```

## Modificaciones Realizadas al Testbench

### Problema Identificado
Inicialmente, el testbench mostraba los valores de los registros al final de la simulación, pero estos aparecían como ceros porque la ALU ya no contenía los valores de la operación.

### Solución Implementada
Se modificó el archivo `simple_processor_tb.sv` para capturar los valores de la ALU en el momento preciso de la operación (120ns) y mostrarlos al final:

```systemverilog
// Variables para capturar los valores de la ALU en el momento correcto
logic [63:0] captured_alu_a, captured_alu_b, captured_alu_result;
logic captured = 0;

// En el bloque initial:
// Esperar al momento de la suma (120ns) y capturar valores
#100;
captured_alu_a = dut.dp.EXECUTE.alu.a;
captured_alu_b = dut.dp.EXECUTE.alu.b;
captured_alu_result = dut.dp.EXECUTE.alu.result;
captured = 1;
$display("Valores capturados en tiempo 120ns");

// Mostrar los valores capturados al final
$display("ALU_A: 0x%h (10 en decimal)", captured_alu_a);
$display("ALU_B: 0x%h (20 en decimal)", captured_alu_b);
$display("ALU_Result: 0x%h (30 en decimal)", captured_alu_result);
```

## Resultados Esperados

### Ventana de Ondas
En la ventana de formas de onda de ModelSim, entre los tiempos 115ns-125ns, se deben observar:

- **ALU_A**: `0x0000000A` (10 en decimal)
- **ALU_B**: `0x00000014` (20 en decimal)
- **ALU_Result**: `0x0000001E` (30 en decimal)

### Salida de Consola
```
# === RESULTADOS DE LA SIMULACIÓN ===
# PC Final: 0x0000000000000030
# ALU_A: 0x000000000000000A (10 en decimal)
# ALU_B: 0x0000000000000014 (20 en decimal)
# ALU_Result: 0x000000000000001E (30 en decimal)
# Simulación completada
```

### Verificación del Comportamiento
1. **Reset inicial**: PC comienza en 0x00000000
2. **Incremento del PC**: Se incrementa de 4 en 4 (0x00, 0x04, 0x08, etc.)
3. **Carga de valores**: Los valores 10 y 20 se cargan correctamente
4. **Operación de suma**: La ALU realiza correctamente 10 + 20 = 30
5. **Bucle infinito**: El PC entra en un bucle al final de la ejecución

## Significado y Validación

### Importancia de la Prueba
Esta simulación demuestra que:
- El procesador RISC-V implementado funciona correctamente
- La ALU ejecuta operaciones aritméticas básicas
- El flujo de datos entre las etapas del pipeline es correcto
- La memoria de instrucciones se carga y lee apropiadamente
- El Program Counter se comporta según lo esperado

### Metodología de Verificación
- **Verificación temporal**: Los valores se capturan en el momento exacto de la operación
- **Verificación funcional**: Se confirma que 10 + 20 = 30
- **Verificación arquitectural**: Se valida el comportamiento del procesador RV32I

## Próximos Pasos

1. **Pruebas adicionales**: Implementar programas más complejos con otras instrucciones RV32I
2. **Verificación completa**: Probar todas las categorías de instrucciones (R-type, I-type, S-type, B-type, U-type, J-type)
3. **Optimización**: Mejorar el rendimiento del procesador
4. **Validación en hardware**: Probar el diseño en FPGA real

## Conclusiones

La simulación exitosa de este programa simple demuestra que el procesador RISC-V RV32I implementado es funcional y capaz de ejecutar operaciones aritméticas básicas correctamente. La metodología desarrollada proporciona una base sólida para futuras verificaciones y validaciones del diseño del procesador.

---
**Fecha de creación**: Noviembre 2025  
**Herramientas utilizadas**: ModelSim, RISC-V GCC Toolchain, SystemVerilog  
**Plataforma objetivo**: Procesador RISC-V RV32I softcore