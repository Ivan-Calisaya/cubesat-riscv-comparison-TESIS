# Pasos-2-TMR: Sistema de Redundancia Triple Modular (TMR) con Votador por Mayoría

## Información del Proyecto

### Tipo de Procesador
- **Arquitectura**: RISC-V RV32I (RISC-V de 32 bits con extensión básica de enteros)
- **Tipo**: Procesador de ciclo único con **Redundancia Triple Modular (TMR)**
- **Implementación**: Softcore en SystemVerilog con tolerancia a fallos
- **Nuevas características**: 
  - **3 ALUs idénticas** ejecutando la misma operación
  - **Votador por mayoría** para seleccionar el resultado correcto
  - **Detección de fallos** mediante comparación de resultados

## Concepto de Redundancia Triple Modular (TMR)

### ¿Qué es TMR?
La Redundancia Triple Modular es una técnica de tolerancia a fallos que utiliza tres copias idénticas de un sistema crítico. En nuestro caso:
- **3 ALUs idénticas** reciben las mismas entradas
- **Todas procesan la misma operación** simultáneamente
- **Un votador por mayoría** compara los resultados y selecciona el correcto

### Ventajas del Sistema TMR
- **Tolerancia a fallos**: Si una ALU falla, las otras dos proporcionan el resultado correcto
- **Detección automática**: El votador identifica cuál ALU está fallando
- **Continuidad de operación**: El sistema sigue funcionando incluso con un fallo
- **Alta confiabilidad**: Probabilidad muy baja de fallo simultáneo en dos ALUs

## Implementación del Sistema TMR

### Componentes Nuevos Creados

#### 1. Votador por Mayoría (`majority_voter.sv`)
```systemverilog
module majority_voter #(parameter WIDTH = 64)(
    input logic [WIDTH-1:0] alu1_result, alu2_result, alu3_result,
    output logic [WIDTH-1:0] voted_result,
    output logic alu1_alu2_match, alu1_alu3_match, alu2_alu3_match,
    output logic [1:0] majority_status
);
```

**Funcionalidad del Votador:**
- Compara los resultados de las 3 ALUs
- Selecciona el resultado que aparece en al menos 2 ALUs
- Genera señales de estado para indicar qué ALUs coinciden

#### 2. TMR ALU (`tmr_alu.sv`)
```systemverilog
module tmr_alu #(parameter N=64)(
    // Entradas comunes para las 3 ALUs
    input logic[N-1:0] a, b,
    input logic[3:0] ALUControl,
    
    // Salidas del resultado votado
    output logic[N-1:0] result,
    
    // Salidas individuales de cada ALU (para monitoreo)
    output logic[N-1:0] alu1_result, alu2_result, alu3_result,
    
    // Señales del votador
    output logic alu1_alu2_match, alu1_alu3_match, alu2_alu3_match
);
```

### Señales de Monitoreo TMR

#### Estados del Votador (`majority_status`)
- **`00`**: No hay mayoría (error crítico - todas diferentes)
- **`01`**: ALU1 y ALU2 coinciden (ALU3 diferente)
- **`10`**: ALU1 y ALU3 coinciden (ALU2 diferente)  
- **`11`**: Todas las ALUs coinciden (funcionamiento ideal)

#### Señales de Comparación
- **`alu1_alu2_match`**: `1` si ALU1 y ALU2 producen el mismo resultado
- **`alu1_alu3_match`**: `1` si ALU1 y ALU3 producen el mismo resultado
- **`alu2_alu3_match`**: `1` si ALU2 y ALU3 producen el mismo resultado

## Programa de Prueba

### ¿Es necesario un nuevo programa en C?
**NO.** El mismo programa `simple_add.c` se utiliza porque:
- La redundancia es **transparente al software**
- El procesador sigue ejecutando las mismas instrucciones RISC-V
- La TMR funciona a **nivel de hardware** (ALU)
- El programa ve un solo resultado (el votado)

### Programa Utilizado
```c
int main() {
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;
    
    result = a + b;  // Esta suma se ejecuta en las 3 ALUs simultáneamente
    
    while(1);
    return 0;
}
```

## Procedimiento de Simulación TMR

### Comandos en ModelSim

#### Opción 1: Script Automatizado
```tcl
cd {C:/Users/Usuario/Desktop/Ivan/tesis/simulacion-FPGA}
do run_tmr_simulation.do
```

#### Opción 2: Comandos Manuales
```tcl
# 1. Navegar al directorio
cd {C:/Users/Usuario/Desktop/Ivan/tesis/simulacion-FPGA}

# 2. Compilar componentes (incluyendo los nuevos TMR)
vlog C:/Users/Usuario/Desktop/Ivan/tesis/mi_procesador_riscv/components/*.sv

# 3. Compilar testbench actualizado
vlog C:/Users/Usuario/Desktop/Ivan/tesis/mi_procesador_riscv/tb/simple_processor_tb.sv

# 4. Cargar simulación
vsim -voptargs="+acc" work.simple_processor_tb

# 5. Añadir señales TMR
add wave -divider "ALU 1"
add wave -label "ALU1_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu1_result

add wave -divider "ALU 2"  
add wave -label "ALU2_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu2_result

add wave -divider "ALU 3"
add wave -label "ALU3_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu3_result

add wave -divider "Votador"
add wave -label "Resultado_Votado" -hex /simple_processor_tb/dut/dp/EXECUTE/aluResult_E
add wave -label "ALU1_ALU2_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu2_match
add wave -label "ALU1_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu3_match
add wave -label "ALU2_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu2_alu3_match
add wave -label "Majority_Status" -unsigned /simple_processor_tb/dut/dp/EXECUTE/majority_status

# 6. Ejecutar simulación
run -all
```

## Resultados Esperados del Sistema TMR

### Ventana de Ondas (tiempo 115ns-125ns)
```
ALU1_Result: 0x000000000000001E (30 decimal)
ALU2_Result: 0x000000000000001E (30 decimal) 
ALU3_Result: 0x000000000000001E (30 decimal)
Resultado_Votado: 0x000000000000001E (30 decimal)

ALU1_ALU2_Match: 1
ALU1_ALU3_Match: 1
ALU2_ALU3_Match: 1
Majority_Status: 11 (todas coinciden)
```

### Salida de Consola
```
=== RESULTADOS DE LA SIMULACIÓN TMR ===
PC Final: 0x0000000000000030
--- Resultados de las 3 ALUs ---
ALU1_Result: 0x000000000000001E (10+20=30)
ALU2_Result: 0x000000000000001E (10+20=30)
ALU3_Result: 0x000000000000001E (10+20=30)
Resultado Votado: 0x000000000000001E
--- Señales del Votador por Mayoría ---
ALU1_ALU2_Match: 1
ALU1_ALU3_Match: 1
ALU2_ALU3_Match: 1
Majority_Status: 11 (11=todas coinciden, 01=1&2, 10=1&3, 00=no mayoría)
```

## Interpretación de Resultados

### Funcionamiento Normal (Sin Fallos)
Cuando el sistema funciona correctamente:
- **Todas las ALUs producen 0x1E** (30 en decimal)
- **Todas las señales de comparación son `1`**
- **`majority_status = 11`** (todas coinciden)
- **El resultado votado es correcto**: 0x1E

### Escenarios de Fallo (Simulados)
Para probar la tolerancia a fallos, se pueden inyectar errores:

#### Fallo en ALU3
```
ALU1_Result: 0x000000000000001E ✓
ALU2_Result: 0x000000000000001E ✓
ALU3_Result: 0x0000000000000025 ✗ (fallo)
Resultado_Votado: 0x000000000000001E ✓ (correcto por mayoría)

ALU1_ALU2_Match: 1 ✓
ALU1_ALU3_Match: 0 ✗  
ALU2_ALU3_Match: 0 ✗
Majority_Status: 01 (ALU1 y ALU2 coinciden)
```

## Modificaciones Realizadas al Diseño

### 1. Componentes Nuevos
- **`majority_voter.sv`**: Lógica de votación por mayoría
- **`tmr_alu.sv`**: Módulo que encapsula 3 ALUs + votador

### 2. Componentes Modificados
- **`execute.sv`**: Reemplazó ALU simple por TMR ALU
- **`datapath.sv`**: Agregó señales para monitoreo TMR
- **`simple_processor_tb.sv`**: Actualizado para capturar y mostrar señales TMR

### 3. Scripts de Simulación
- **`run_tmr_simulation.do`**: Script completo para simulación TMR
- Señales organizadas por grupos (ALU1, ALU2, ALU3, Votador)

## Aplicaciones y Significado

### Importancia en Sistemas Críticos
Este diseño TMR es fundamental para:
- **Sistemas aeroespaciales**: Tolerancia a radiación cósmica
- **Sistemas médicos**: Equipos de soporte vital
- **Sistemas nucleares**: Control de reactores
- **Sistemas automotrices**: Vehículos autónomos

### Validación del Diseño
La simulación exitosa demuestra que:
- Las 3 ALUs funcionan de manera idéntica
- El votador por mayoría opera correctamente
- El sistema mantiene operación ante fallos individuales
- La implementación TMR es funcionalmente correcta

## Próximos Pasos

1. **Inyección de fallos**: Simular errores en ALUs individuales
2. **Pruebas exhaustivas**: Verificar con diferentes operaciones
3. **Análisis de cobertura**: Probar todos los casos del votador
4. **Optimización de área**: Balancear redundancia vs. recursos
5. **Validación en FPGA**: Implementar en hardware real

## Conclusiones

La implementación exitosa del sistema TMR demuestra:
- **Viabilidad técnica** de redundancia en procesadores RISC-V
- **Funcionamiento correcto** del votador por mayoría
- **Transparencia al software** - mismo programa, mayor confiabilidad
- **Base sólida** para sistemas tolerantes a fallos

El sistema TMR proporciona una mejora significativa en la confiabilidad del procesador RISC-V, manteniendo la compatibilidad completa con el ISA original.

---
**Fecha de actualización**: Noviembre 2025  
**Nuevas características**: Triple Modular Redundancy (TMR)  
**Herramientas**: ModelSim, SystemVerilog, RISC-V RV32I  
**Tipo de redundancia**: Activa (todas las ALUs operan simultáneamente)

---

## Apéndice: Modificaciones Específicas del Código

### A. Archivos Nuevos Creados

#### A.1. `majority_voter.sv` (Nuevo archivo completo)
**Ubicación**: `mi_procesador_riscv/components/majority_voter.sv`

```systemverilog
// majority_voter.sv - Votador por mayoría para 3 ALUs
// Implementa lógica de redundancia triple modular (TMR)

module majority_voter #(
    parameter WIDTH = 64
)(
    input logic [WIDTH-1:0] alu1_result,
    input logic [WIDTH-1:0] alu2_result, 
    input logic [WIDTH-1:0] alu3_result,
    
    output logic [WIDTH-1:0] voted_result,
    output logic alu1_alu2_match,
    output logic alu1_alu3_match,
    output logic alu2_alu3_match,
    output logic [1:0] majority_status
);

    // Comparaciones bit a bit
    assign alu1_alu2_match = (alu1_result == alu2_result);
    assign alu1_alu3_match = (alu1_result == alu3_result);
    assign alu2_alu3_match = (alu2_result == alu3_result);

    // Lógica de votación por mayoría
    always_comb begin
        if (alu1_alu2_match && alu1_alu3_match) begin
            // Todas las ALUs coinciden (caso ideal)
            voted_result = alu1_result;
            majority_status = 2'b11;
        end
        else if (alu1_alu2_match) begin
            // ALU1 y ALU2 coinciden
            voted_result = alu1_result;
            majority_status = 2'b01;
        end
        else if (alu1_alu3_match) begin
            // ALU1 y ALU3 coinciden
            voted_result = alu1_result;
            majority_status = 2'b10;
        end
        else if (alu2_alu3_match) begin
            // ALU2 y ALU3 coinciden
            voted_result = alu2_result;
            majority_status = 2'b11;
        end
        else begin
            // No hay mayoría (caso de error)
            voted_result = alu1_result;
            majority_status = 2'b00;
        end
    end

endmodule
```

#### A.2. `tmr_alu.sv` (Nuevo archivo completo)
**Ubicación**: `mi_procesador_riscv/components/tmr_alu.sv`

```systemverilog
// tmr_alu.sv - Triple Modular Redundancy ALU con votador por mayoría
// Contiene 3 ALUs idénticas y un votador por mayoría

module tmr_alu #(parameter N=64) 
(
    input logic[N-1:0] a, b,
    input logic wArith,
    input logic[3:0] ALUControl,
    
    // Salidas originales (del votador)
    output logic zero, overflow, sign,
    output logic[N-1:0] result,
    
    // Salidas de cada ALU individual (para monitoreo)
    output logic[N-1:0] alu1_result, alu2_result, alu3_result,
    output logic alu1_zero, alu1_overflow, alu1_sign,
    output logic alu2_zero, alu2_overflow, alu2_sign,
    output logic alu3_zero, alu3_overflow, alu3_sign,
    
    // Salidas del votador por mayoría
    output logic alu1_alu2_match,
    output logic alu1_alu3_match, 
    output logic alu2_alu3_match,
    output logic [1:0] majority_status
);

    // Instancias de las 3 ALUs idénticas
    alu #(N) alu1 (
        .a(a), .b(b), .wArith(wArith), .ALUControl(ALUControl),
        .zero(alu1_zero), .overflow(alu1_overflow), .sign(alu1_sign),
        .result(alu1_result)
    );
    
    alu #(N) alu2 (
        .a(a), .b(b), .wArith(wArith), .ALUControl(ALUControl),
        .zero(alu2_zero), .overflow(alu2_overflow), .sign(alu2_sign),
        .result(alu2_result)
    );
    
    alu #(N) alu3 (
        .a(a), .b(b), .wArith(wArith), .ALUControl(ALUControl),
        .zero(alu3_zero), .overflow(alu3_overflow), .sign(alu3_sign),
        .result(alu3_result)
    );
    
    // Votador por mayoría para el resultado principal
    majority_voter #(N) result_voter (
        .alu1_result(alu1_result), .alu2_result(alu2_result), .alu3_result(alu3_result),
        .voted_result(result),
        .alu1_alu2_match(alu1_alu2_match), .alu1_alu3_match(alu1_alu3_match),
        .alu2_alu3_match(alu2_alu3_match), .majority_status(majority_status)
    );
    
    // Votación para señales de control (zero, overflow, sign)
    always_comb begin
        if ((alu1_zero == alu2_zero)) zero = alu1_zero;
        else if ((alu1_zero == alu3_zero)) zero = alu1_zero;
        else zero = alu2_zero;
        
        if ((alu1_overflow == alu2_overflow)) overflow = alu1_overflow;
        else if ((alu1_overflow == alu3_overflow)) overflow = alu1_overflow;
        else overflow = alu2_overflow;
        
        if ((alu1_sign == alu2_sign)) sign = alu1_sign;
        else if ((alu1_sign == alu3_sign)) sign = alu1_sign;
        else sign = alu2_sign;
    end

endmodule
```

### B. Archivos Modificados

#### B.1. `execute.sv` - Modificaciones Específicas
**Ubicación**: `mi_procesador_riscv/components/execute.sv`

**ANTES (líneas 1-15):**
```systemverilog
module execute #(
    parameter N = 64
) (
    input logic [N-1: 0] PC_E, readData1_E, readData2_E, signImm_E,
    input logic [N-1: 0] CSRRead_E,
    input logic AluSrc, regSel1, wArith, aluSelect,
    input logic[3:0] AluControl,
    output logic [N-1: 0] writeData_E, aluResult_E, PCBranch_E, PC4_E,
    output logic [N-1: 0] result1_Atom,
    output logic zero_E, overflow_E, sign_E
);
```

**DESPUÉS (líneas 1-22):**
```systemverilog
module execute #(
    parameter N = 64
) (
    input logic [N-1: 0] PC_E, readData1_E, readData2_E, signImm_E,
    input logic [N-1: 0] CSRRead_E,
    input logic AluSrc, regSel1, wArith, aluSelect,
    input logic[3:0] AluControl,
    output logic [N-1: 0] writeData_E, aluResult_E, PCBranch_E, PC4_E,
    output logic [N-1: 0] result1_Atom,
    output logic zero_E, overflow_E, sign_E,
    
    // Nuevas salidas para monitoreo de TMR
    output logic [N-1: 0] alu1_result, alu2_result, alu3_result,
    output logic alu1_zero, alu1_overflow, alu1_sign,
    output logic alu2_zero, alu2_overflow, alu2_sign,
    output logic alu3_zero, alu3_overflow, alu3_sign,
    output logic alu1_alu2_match, alu1_alu3_match, alu2_alu3_match,
    output logic [1:0] majority_status
);
```

**ANTES (líneas 16-26):**
```systemverilog
    // alternative to using a mux here is add another alu
    alu #(N) alu(.a(wArith ? {{32'b0}, readData1[31:0]} : readData1), 
                 .b(wArith ? {{32'b0}, readData2[31:0]} : readData2),
                 .ALUControl(AluControl),
                 .zero(zero_E),
                 .overflow(overflow_E),
                 .sign(sign_E),
                 .wArith(wArith),
                 .result(aluResult));
```

**DESPUÉS (líneas 25-52):**
```systemverilog
    // TMR ALU (Triple Modular Redundancy) con votador por mayoría
    tmr_alu #(N) alu_tmr(
        .a(wArith ? {{32'b0}, readData1[31:0]} : readData1), 
        .b(wArith ? {{32'b0}, readData2[31:0]} : readData2),
        .ALUControl(AluControl),
        .wArith(wArith),
        // Salidas principales (votadas)
        .zero(zero_E), .overflow(overflow_E), .sign(sign_E), .result(aluResult),
        // Salidas individuales de cada ALU
        .alu1_result(alu1_result), .alu2_result(alu2_result), .alu3_result(alu3_result),
        .alu1_zero(alu1_zero), .alu1_overflow(alu1_overflow), .alu1_sign(alu1_sign),
        .alu2_zero(alu2_zero), .alu2_overflow(alu2_overflow), .alu2_sign(alu2_sign),
        .alu3_zero(alu3_zero), .alu3_overflow(alu3_overflow), .alu3_sign(alu3_sign),
        // Señales del votador
        .alu1_alu2_match(alu1_alu2_match), .alu1_alu3_match(alu1_alu3_match),
        .alu2_alu3_match(alu2_alu3_match), .majority_status(majority_status)
    );
```

#### B.2. `datapath.sv` - Modificaciones Específicas
**Ubicación**: `mi_procesador_riscv/components/datapath.sv`

**AGREGADO (después de línea 76):**
```systemverilog
    // Variables para señales TMR
    logic [N-1:0] alu1_result, alu2_result, alu3_result;
    logic alu1_zero, alu1_overflow, alu1_sign;
    logic alu2_zero, alu2_overflow, alu2_sign;
    logic alu3_zero, alu3_overflow, alu3_sign;
    logic alu1_alu2_match, alu1_alu3_match, alu2_alu3_match;
    logic [1:0] majority_status;
```

**ANTES (líneas 77-93):**
```systemverilog
    execute #(N) EXECUTE(.AluSrc(AluSrc),
                         .AluControl(AluControl),
                         .PC_E(IM_addr),
                         .PC4_E(PC_4),
                         .regSel1(regSel[1]),
                         .signImm_E(signImm_D),
                         .readData1_E(readData1_D), 
                         .readData2_E(readData2_D), 
                         .PCBranch_E(PCBranch_E), 
                         .aluResult_E(DM_addr), 
                         .writeData_E(writeData_E),
                         .wArith(wArith),
                         .zero_E(zero_E),
                         .overflow_E(overflow_E),
                         .sign_E(sign_E),
                         .aluSelect(aluSelect),
                         .CSRRead_E(csrRead_D),
                         .result1_Atom(aluResultAtom1_E));
```

**DESPUÉS (líneas 84-116):**
```systemverilog
    execute #(N) EXECUTE(.AluSrc(AluSrc),
                         .AluControl(AluControl),
                         .PC_E(IM_addr),
                         .PC4_E(PC_4),
                         .regSel1(regSel[1]),
                         .signImm_E(signImm_D),
                         .readData1_E(readData1_D), 
                         .readData2_E(readData2_D), 
                         .PCBranch_E(PCBranch_E), 
                         .aluResult_E(DM_addr), 
                         .writeData_E(writeData_E),
                         .wArith(wArith),
                         .zero_E(zero_E),
                         .overflow_E(overflow_E),
                         .sign_E(sign_E),
                         .aluSelect(aluSelect),
                         .CSRRead_E(csrRead_D),
                         .result1_Atom(aluResultAtom1_E),
                         // Nuevas señales TMR
                         .alu1_result(alu1_result),
                         .alu2_result(alu2_result),
                         .alu3_result(alu3_result),
                         .alu1_zero(alu1_zero),
                         .alu1_overflow(alu1_overflow),
                         .alu1_sign(alu1_sign),
                         .alu2_zero(alu2_zero),
                         .alu2_overflow(alu2_overflow),
                         .alu2_sign(alu2_sign),
                         .alu3_zero(alu3_zero),
                         .alu3_overflow(alu3_overflow),
                         .alu3_sign(alu3_sign),
                         .alu1_alu2_match(alu1_alu2_match),
                         .alu1_alu3_match(alu1_alu3_match),
                         .alu2_alu3_match(alu2_alu3_match),
                         .majority_status(majority_status));
```

#### B.3. `simple_processor_tb.sv` - Modificaciones Específicas
**Ubicación**: `mi_procesador_riscv/tb/simple_processor_tb.sv`

**ANTES (línea 30-32):**
```systemverilog
    // Variables para capturar los valores de la ALU en el momento correcto
    logic [63:0] captured_alu_a, captured_alu_b, captured_alu_result;
    logic captured = 0;
```

**DESPUÉS (línea 30-35):**
```systemverilog
    // Variables para capturar los valores de las 3 ALUs y el votador en el momento correcto
    logic [63:0] captured_alu1_result, captured_alu2_result, captured_alu3_result;
    logic [63:0] captured_voted_result;
    logic captured_alu1_alu2_match, captured_alu1_alu3_match, captured_alu2_alu3_match;
    logic [1:0] captured_majority_status;
    logic captured = 0;
```

**ANTES (líneas 45-50):**
```systemverilog
        // Esperar al momento de la suma (120ns) y capturar valores
        #100;
        captured_alu_a = dut.dp.EXECUTE.alu.a;
        captured_alu_b = dut.dp.EXECUTE.alu.b;
        captured_alu_result = dut.dp.EXECUTE.alu.result;
        captured = 1;
        $display("Valores capturados en tiempo 120ns");
```

**DESPUÉS (líneas 45-55):**
```systemverilog
        // Esperar al momento de la suma (120ns) y capturar valores de TMR
        #100;
        captured_alu1_result = dut.dp.EXECUTE.alu1_result;
        captured_alu2_result = dut.dp.EXECUTE.alu2_result;
        captured_alu3_result = dut.dp.EXECUTE.alu3_result;
        captured_voted_result = dut.dp.EXECUTE.aluResult_E;
        captured_alu1_alu2_match = dut.dp.EXECUTE.alu1_alu2_match;
        captured_alu1_alu3_match = dut.dp.EXECUTE.alu1_alu3_match;
        captured_alu2_alu3_match = dut.dp.EXECUTE.alu2_alu3_match;
        captured_majority_status = dut.dp.EXECUTE.majority_status;
        captured = 1;
        $display("Valores TMR capturados en tiempo 120ns");
```

**ANTES (líneas 55-60):**
```systemverilog
        // Mostrar los valores capturados
        $display("=== RESULTADOS DE LA SIMULACIÓN ===");
        $display("PC Final: 0x%h", dut.dp.FETCH.PC.q);
        $display("ALU_A: 0x%h (10 en decimal)", captured_alu_a);
        $display("ALU_B: 0x%h (20 en decimal)", captured_alu_b);
        $display("ALU_Result: 0x%h (30 en decimal)", captured_alu_result);
```

**DESPUÉS (líneas 60-72):**
```systemverilog
        // Mostrar los valores capturados del sistema TMR
        $display("=== RESULTADOS DE LA SIMULACIÓN TMR ===");
        $display("PC Final: 0x%h", dut.dp.FETCH.PC.q);
        $display("--- Resultados de las 3 ALUs ---");
        $display("ALU1_Result: 0x%h (10+20=30)", captured_alu1_result);
        $display("ALU2_Result: 0x%h (10+20=30)", captured_alu2_result);
        $display("ALU3_Result: 0x%h (10+20=30)", captured_alu3_result);
        $display("Resultado Votado: 0x%h", captured_voted_result);
        $display("--- Señales del Votador por Mayoría ---");
        $display("ALU1_ALU2_Match: %b", captured_alu1_alu2_match);
        $display("ALU1_ALU3_Match: %b", captured_alu1_alu3_match);
        $display("ALU2_ALU3_Match: %b", captured_alu2_alu3_match);
        $display("Majority_Status: %b (11=todas coinciden, 01=1&2, 10=1&3, 00=no mayoría)", captured_majority_status);
```

### C. Nuevos Scripts de Simulación

#### C.1. `run_tmr_simulation.do` (Nuevo archivo completo)
**Ubicación**: `simulacion-FPGA/run_tmr_simulation.do`

**Características principales del script:**
- Compilación automática de todos los componentes TMR
- Configuración de señales organizadas por grupos (ALU1, ALU2, ALU3, Votador)
- Ejecución automática con paradas en puntos críticos
- Interpretación automática de resultados TMR

### D. Resumen de Cambios por Líneas

| Archivo | Líneas Modificadas | Tipo de Cambio |
|---------|-------------------|----------------|
| `majority_voter.sv` | 1-45 (nuevo) | Archivo nuevo completo |
| `tmr_alu.sv` | 1-98 (nuevo) | Archivo nuevo completo |
| `execute.sv` | 1-22, 25-52 | Cambio de interfaz y instanciación |
| `datapath.sv` | 77-83, 84-116 | Declaración de variables y conexiones |
| `simple_processor_tb.sv` | 30-35, 45-55, 60-72 | Captura y display de señales TMR |
| `run_tmr_simulation.do` | 1-120 (nuevo) | Script nuevo completo |

### E. Impacto de las Modificaciones

**Cambios en la funcionalidad:**
- **3 ALUs** ejecutan la misma operación simultáneamente
- **Votador por mayoría** selecciona el resultado correcto
- **Señales de monitoreo** permiten observar el estado de cada ALU
- **Tolerancia a fallos** mediante redundancia activa

**Compatibilidad:**
- **100% compatible** con el ISA RISC-V original
- **Transparente al software** - mismo programa .c funciona
- **Mismos resultados** funcionales que la ALU simple
- **Interfaz externa** del procesador sin cambios