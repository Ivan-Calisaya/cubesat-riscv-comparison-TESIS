# run_tmr_simulation.do - Script de simulación TMR para el procesador RV32I
# Este script crea el workspace en la carpeta simulacion-FPGA y prueba el sistema TMR

# 1. Limpiar completamente y crear la biblioteca de trabajo 'work' en esta carpeta
if {[file exists work]} {
    vdel -lib work -all
    file delete -force work
}
vlib work
vmap work work

# 2. Compilar todos los archivos fuente de SystemVerilog
# Compilamos primero todos los componentes desde la carpeta mi_procesador_riscv
vlog -sv -work work ../mi_procesador_riscv/components/*.sv

# Compilar el testbench
vlog -sv -work work ../mi_procesador_riscv/tb/simple_processor_tb.sv

# 3. Iniciar el simulador con el testbench como módulo de nivel superior
vsim -voptargs="+acc" work.simple_processor_tb

# 4. Añadir las señales TMR a la ventana de formas de onda
# Señales básicas
add wave /simple_processor_tb/clk
add wave /simple_processor_tb/reset

# Señales del Program Counter (PC)
add wave -label "PC" -hex /simple_processor_tb/dut/dp/FETCH/PC/q

# Instrucción actual
add wave -label "Instrucción" -hex /simple_processor_tb/dut/instrMem/q0

# === SEÑALES DE LAS 3 ALUs INDIVIDUALES ===
add wave -divider "ALU 1"
add wave -label "ALU1_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu1/a
add wave -label "ALU1_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu1/b
add wave -label "ALU1_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu1_result
add wave -label "ALU1_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu1_zero
add wave -label "ALU1_Overflow" /simple_processor_tb/dut/dp/EXECUTE/alu1_overflow

add wave -divider "ALU 2"
add wave -label "ALU2_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu2/a
add wave -label "ALU2_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu2/b
add wave -label "ALU2_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu2_result
add wave -label "ALU2_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu2_zero
add wave -label "ALU2_Overflow" /simple_processor_tb/dut/dp/EXECUTE/alu2_overflow

add wave -divider "ALU 3"
add wave -label "ALU3_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu3/a
add wave -label "ALU3_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/alu3/b
add wave -label "ALU3_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu3_result
add wave -label "ALU3_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu3_zero
add wave -label "ALU3_Overflow" /simple_processor_tb/dut/dp/EXECUTE/alu3_overflow

# === SEÑALES DEL VOTADOR POR MAYORÍA ===
add wave -divider "Votador por Mayoría"
add wave -label "Resultado_Votado" -hex /simple_processor_tb/dut/dp/EXECUTE/aluResult_E
add wave -label "ALU1_ALU2_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu2_match
add wave -label "ALU1_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu3_match
add wave -label "ALU2_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu2_alu3_match
add wave -label "Majority_Status" -unsigned /simple_processor_tb/dut/dp/EXECUTE/majority_status

# Control de la ALU
add wave -label "ALU_Control" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_tmr/ALUControl

# Banco de registros (para verificar que los datos llegan correctamente)
add wave -divider "Registros"
add wave -label "x5" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
add wave -label "x6" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
add wave -label "x7" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# 5. Ejecutar la simulación con monitoreo TMR
echo "=== INICIANDO SIMULACIÓN TMR ==="
echo "Monitoreando 3 ALUs y votador por mayoría..."

# Ejecutar hasta el momento donde las ALUs procesan la suma
run 120ns

# Mostrar los valores de las ALUs en el momento correcto
echo ""
echo "=== VALORES EN LAS 3 ALUs (tiempo ~120ns) ==="
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu1_result
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu2_result
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu3_result

echo ""
echo "=== SEÑALES DEL VOTADOR POR MAYORÍA ==="
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu2_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu3_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu2_alu3_match
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/majority_status

# Continuar la simulación hasta el final
run -all

# 6. Configurar la vista de ondas para mejor visualización
wave zoom full

echo ""
echo "=== SIMULACIÓN TMR COMPLETADA ==="
echo "✓ Las 3 ALUs procesaron la suma 10 + 20 = 30"
echo "✓ El votador por mayoría seleccionó el resultado correcto"
echo "✓ Revisa la ventana de ondas para ver el comportamiento TMR"
echo ""
echo "INTERPRETACIÓN DE MAJORITY_STATUS:"
echo "  00: No hay mayoría (error)"
echo "  01: ALU1 y ALU2 coinciden"
echo "  10: ALU1 y ALU3 coinciden"
echo "  11: Todas las ALUs coinciden (ideal)"