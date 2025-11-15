# FPGA Implementation - RISC-V Processors

## ✅ Procesadores Migrados Exitosamente

Se han migrado **3 implementaciones funcionando** desde el proyecto original:

### 1. **Single ALU Processor** (Baseline)
- **Descripción**: Procesador RISC-V RV32I básico con una sola ALU
- **Testbench**: `simple_processor_tb.sv` configurado para single ALU
- **Script ModelSim**: `run_simulation.do`
- **Estado**: ✅ Funcionando correctamente

### 2. **TMR Processor** (Triple Modular Redundancy)
- **Descripción**: Procesador con 3 ALUs + votador por mayoría
- **Redundancia**: Tolerancia a 1 fallo simultáneo
- **Script ModelSim**: `run_tmr_simulation.do`
- **Documentación**: `Pasos-2-TMR.md`
- **Estado**: ✅ Funcionando correctamente

### 3. **QMR Processor** (Quintuple Modular Redundancy) 
- **Descripción**: Procesador con 5 ALUs + votador por mayoría avanzado
- **Redundancia**: Tolerancia a 2 fallos simultáneos
- **Script ModelSim**: `run_qmr_simulation.do`
- **Documentación**: `Pasos-3-QMR.md`
- **Estado**: ✅ Funcionando correctamente

## Estructura de Archivos Migrados

### 📁 components/ (37 archivos)
```
components/
├── alu.sv                 # ALU básica
├── tmr_alu.sv            # ALU con redundancia TMR/QMR
├── majority_voter.sv     # Votador por mayoría
├── core.sv               # Núcleo del procesador
├── datapath.sv           # Ruta de datos
├── execute.sv            # Etapa de ejecución
├── controller.sv         # Controlador principal
├── memory.sv             # Sistema de memoria
└── [otros componentes SystemVerilog]
```

### 📁 testbenches/ (22 archivos)
```
testbenches/
├── simple_processor_tb.sv    # Testbench principal
├── run_simulation.do         # Script Single ALU
├── run_tmr_simulation.do     # Script TMR
├── run_qmr_simulation.do     # Script QMR
├── Pasos-1-ALU.md           # Documentación Single ALU
├── Pasos-2-TMR.md           # Documentación TMR
├── Pasos-3-QMR.md           # Documentación QMR
├── imem_init.txt            # Memoria de instrucciones
└── work/                    # Compilación ModelSim
```

### 📁 software/ (6 archivos)
```
software/
├── simple_add.c            # Programa de prueba (10+20=30)
├── simple_add.elf          # Ejecutable compilado
├── simple_add.bin          # Binario
├── programa.hex             # Hexadecimal para memoria
├── link.ld                  # Linker script
└── export_opcode_rv.py     # Herramienta de conversión
```

### 📁 quartus/ (101 archivos)
```
quartus/
├── riscv_processor.qpf      # Proyecto Quartus
├── riscv_processor.qsf      # Configuración
├── top_level.sv             # Top level entity
├── timing_constraints.sdc   # Constrains de timing
├── riscv_processor.sof      # Archivo de programación
└── db/, incremental_db/     # Base de datos de compilación
```

## Configuración de Simulación

### ModelSim Setup
```tcl
# Cambiar al directorio de testbenches
cd "C:/Users/Usuario/Desktop/Ivan/SOC/fpga-implementation/testbenches"

# Ejecutar simulación según el procesador:
# Single ALU:
do run_simulation.do

# TMR (3 ALUs):
do run_tmr_simulation.do  

# QMR (5 ALUs):
do run_qmr_simulation.do
```

### Compilación RISC-V
```powershell
# En el directorio software/
cd "C:\Users\Usuario\Desktop\Ivan\SOC\fpga-implementation\software"

# Compilar programa de prueba
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe -march=rv32i -mabi=ilp32 -nostartfiles -T link.ld -o simple_add.elf simple_add.c

# Generar hexadecimal
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objcopy.exe -O verilog simple_add.elf programa.hex
```

## Validación de Migración

### Test de Funcionamiento
Para verificar que la migración fue exitosa:

1. **Single ALU Test**:
   ```tcl
   cd "C:/Users/Usuario/Desktop/Ivan/SOC/fpga-implementation/testbenches"
   vsim -do "do run_simulation.do"
   # Resultado esperado: ResultW = 0x1E (30 decimal)
   ```

2. **TMR Test**:
   ```tcl
   cd "C:/Users/Usuario/Desktop/Ivan/SOC/fpga-implementation/testbenches"  
   vsim -do "do run_tmr_simulation.do"
   # Resultado esperado: 3 ALUs = 0x1E, Majority_Status = 01
   ```

3. **QMR Test**:
   ```tcl
   cd "C:/Users/Usuario/Desktop/Ivan/SOC/fpga-implementation/testbenches"
   vsim -do "do run_qmr_simulation.do"
   # Resultado esperado: 5 ALUs = 30 decimal, Majority_Status = 001
   ```

## Próximos Pasos - Expansión para CubeSats

### Características a Agregar

#### 1. **CubeSat-Specific Peripherals**
- UART Controller (comunicaciones)
- GPIO Controller (sensores/actuadores)
- Timer/PWM (control de actitud)
- SPI/I2C (sensores)

#### 2. **Auto-Test System**
- BIST (Built-In Self Test) controllers
- Fault injection mechanisms
- Health monitoring
- Error recovery procedures

#### 3. **Performance Metrics**
- Cycle count analysis
- Resource utilization reports
- Power estimation (Quartus PowerPlay)
- Timing analysis

#### 4. **CubeSat Workloads**
- Kalman filter (attitude determination)
- Image compression algorithms
- Communication protocol processing
- Real-time control loops

## Diferencias vs SoC Track

### FPGA Characteristics
✅ **Ventajas**:
- Máxima flexibilidad de diseño
- Redundancia implementada en hardware
- Reconfiguración completa posible
- Control total del pipeline

⚠️ **Desventajas**:
- Mayor consumo de potencia
- Complejidad de desarrollo HDL
- Menor frecuencia de operación
- Mayor área de silicio

### Métricas a Comparar
- **Performance**: Ciclos de reloj, throughput
- **Power**: Estimación Quartus PowerPlay
- **Area**: LUTs, DSPs, BRAM utilizados
- **Fault Tolerance**: Cobertura TMR/QMR
- **Development**: Tiempo de diseño, complejidad

La migración fue **100% exitosa**. Los 3 procesadores están listos para ser expandidos hacia un sistema completo CubeSat FPGA.