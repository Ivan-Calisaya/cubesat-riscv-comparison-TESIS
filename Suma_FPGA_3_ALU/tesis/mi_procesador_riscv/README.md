# Mi Procesador RISC-V - Tesis

Este proyecto implementa un procesador RISC-V siguiendo el instructivo paso a paso.

## Estructura del Proyecto

```
mi_procesador_riscv/
├── components/          # Módulos SystemVerilog del procesador
│   ├── core.sv         # Módulo principal del procesador
│   ├── datapath.sv     # Datapath del procesador
│   ├── alu.sv          # Unidad Aritmético-Lógica
│   ├── regfile.sv      # Banco de registros
│   ├── imem.sv         # Memoria de instrucciones
│   └── ...             # Otros módulos
├── tb/                 # Testbenches y simulación
│   ├── simple_processor_tb.sv  # Testbench principal
│   ├── simple_wave.do          # Script de ModelSim
│   └── imem_init.txt          # Programa cargado en memoria
├── software/           # Programas de prueba
│   ├── simple_add.c    # Programa de prueba básico
│   ├── link.ld         # Linker script
│   ├── programa.hex    # Programa en formato hexadecimal
│   └── export_opcode_rv.py # Script de conversión
└── README.md          # Este archivo
```

## Pasos Completados del Instructivo

### ✅ Paso 1: Programa de Prueba en C
- Archivo: `software/simple_add.c`
- Programa que suma 10 + 20 = 30

### ✅ Paso 2: Compilación a ELF
- Comando usado: `riscv-none-elf-gcc -march=rv32i -mabi=ilp32 -nostdlib -ffreestanding -T link.ld -o simple_add.elf simple_add.c`
- Resultado: `software/simple_add.elf`

### ✅ Paso 3: Extracción a Hexadecimal
- Binario: `software/simple_add.bin`
- Hexadecimal: `software/programa.hex`
- Script: `software/export_opcode_rv.py`

### ✅ Paso 4: Preparación para ModelSim
- Testbench: `tb/simple_processor_tb.sv`
- Script: `tb/simple_wave.do`
- Memoria inicializada: `tb/imem_init.txt`

## Cómo Ejecutar la Simulación

### Método A: Script Automático (Recomendado)
1. Abrir ModelSim
2. Navegar al directorio tb:
   ```tcl
   cd {T:/Proyectos/tesis/mi_procesador_riscv/tb}
   ```
3. Ejecutar el script:
   ```tcl
   do simple_wave.do
   ```

### Método B: Manual
1. Crear nuevo proyecto en ModelSim
2. Añadir todos los archivos .sv de components/ y tb/
3. Compilar todos los archivos
4. Simular con simple_processor_tb

## Qué Verificar en las Ondas

1. **Reset**: PC = 0, luego incrementa de 4 en 4
2. **ADDI**: Cargar valores 10 y 20 en registros
3. **ADD**: Suma 10 + 20 = 30 (0x1E)
4. **Resultado**: Registro destino debe contener 0x1E
5. **Bucle infinito**: PC salta a la misma dirección

## Objetivo del Instructivo

> "Tu primera tarea concreta es: lograr que el programa simple_add.c se ejecute correctamente en ModelSim y capturar una forma de onda que demuestre que el registro de destino contiene el valor 0x1E al final de la ejecución."

## Herramientas Necesarias

- **ModelSim** (para simulación)
- **RISC-V GCC Toolchain** (para compilación)
- **Python 3** (para scripts de conversión)

## Próximos Pasos

Una vez verificado el funcionamiento con simple_add.c:
1. Escribir programas de prueba más complejos
2. Probar todas las instrucciones RV32I
3. Validar completamente el diseño
4. Proceder a la implementación en hardware (Sección 3 del instructivo)