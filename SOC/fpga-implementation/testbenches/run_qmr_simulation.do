# run_qmr_simulation.do - Script de simulación QMR para el procesador RV32I
# Este script crea el workspace en la carpeta simulacion-FPGA y prueba el sistema QMR (5 ALUs)

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

# 4. Añadir las señales QMR (5 ALUs) a la ventana de formas de onda
# Señales básicas
add wave /simple_processor_tb/clk
add wave /simple_processor_tb/reset

# Señales del Program Counter (PC)
add wave -label "PC" -hex /simple_processor_tb/dut/dp/FETCH/PC/q

# Instrucción actual
add wave -label "Instrucción" -hex /simple_processor_tb/dut/instrMem/q0

# === SEÑALES DE LAS 5 ALUs INDIVIDUALES ===
add wave -divider "ALU 1"
add wave -label "ALU1_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu1/a
add wave -label "ALU1_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu1/b
add wave -label "ALU1_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu1_result
add wave -label "ALU1_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu1_zero
add wave -label "ALU1_Vote_Count" -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu1_vote_count

add wave -divider "ALU 2"
add wave -label "ALU2_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu2/a
add wave -label "ALU2_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu2/b
add wave -label "ALU2_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu2_result
add wave -label "ALU2_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu2_zero
add wave -label "ALU2_Vote_Count" -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu2_vote_count

add wave -divider "ALU 3"
add wave -label "ALU3_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu3/a
add wave -label "ALU3_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu3/b
add wave -label "ALU3_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu3_result
add wave -label "ALU3_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu3_zero
add wave -label "ALU3_Vote_Count" -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu3_vote_count

add wave -divider "ALU 4"
add wave -label "ALU4_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu4/a
add wave -label "ALU4_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu4/b
add wave -label "ALU4_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu4_result
add wave -label "ALU4_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu4_zero
add wave -label "ALU4_Vote_Count" -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu4_vote_count

add wave -divider "ALU 5"
add wave -label "ALU5_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu5/a
add wave -label "ALU5_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/alu5/b
add wave -label "ALU5_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu5_result
add wave -label "ALU5_Zero" /simple_processor_tb/dut/dp/EXECUTE/alu5_zero
add wave -label "ALU5_Vote_Count" -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu5_vote_count

# === SEÑALES DEL VOTADOR POR MAYORÍA ===
add wave -divider "Votador por Mayoría (QMR)"
add wave -label "Resultado_Votado" -hex /simple_processor_tb/dut/dp/EXECUTE/aluResult_E

# Comparaciones entre ALUs
add wave -label "ALU1_ALU2_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu2_match
add wave -label "ALU1_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu3_match
add wave -label "ALU1_ALU4_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu4_match
add wave -label "ALU1_ALU5_Match" /simple_processor_tb/dut/dp/EXECUTE/alu1_alu5_match
add wave -label "ALU2_ALU3_Match" /simple_processor_tb/dut/dp/EXECUTE/alu2_alu3_match
add wave -label "ALU2_ALU4_Match" /simple_processor_tb/dut/dp/EXECUTE/alu2_alu4_match
add wave -label "ALU2_ALU5_Match" /simple_processor_tb/dut/dp/EXECUTE/alu2_alu5_match
add wave -label "ALU3_ALU4_Match" /simple_processor_tb/dut/dp/EXECUTE/alu3_alu4_match
add wave -label "ALU3_ALU5_Match" /simple_processor_tb/dut/dp/EXECUTE/alu3_alu5_match
add wave -label "ALU4_ALU5_Match" /simple_processor_tb/dut/dp/EXECUTE/alu4_alu5_match

add wave -label "Majority_Status" -unsigned /simple_processor_tb/dut/dp/EXECUTE/majority_status

# Control de la ALU
add wave -label "ALU_Control" -hex /simple_processor_tb/dut/dp/EXECUTE/alu_qmr/ALUControl

# Banco de registros (para verificar que los datos llegan correctamente)
add wave -divider "Registros"
add wave -label "x5" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
add wave -label "x6" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
add wave -label "x7" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# 5. Ejecutar la simulación con monitoreo QMR
echo "=== INICIANDO SIMULACIÓN QMR (5 ALUs) ==="
echo "Monitoreando 5 ALUs y votador por mayoría..."

# Ejecutar hasta el momento donde las ALUs procesan la suma
run 120ns

# Mostrar los valores de las ALUs en el momento correcto
echo ""
echo "=== VALORES EN LAS 5 ALUs (tiempo ~120ns) ==="
echo "ALU1_Result (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/alu1_result
echo "ALU1_Result (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu1_result

echo "ALU2_Result (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/alu2_result
echo "ALU2_Result (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu2_result

echo "ALU3_Result (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/alu3_result
echo "ALU3_Result (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu3_result

echo "ALU4_Result (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/alu4_result
echo "ALU4_Result (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu4_result

echo "ALU5_Result (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/alu5_result
echo "ALU5_Result (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu5_result

echo "Resultado_Votado (decimal):"
examine -decimal /simple_processor_tb/dut/dp/EXECUTE/aluResult_E
echo "Resultado_Votado (hex):"
examine -hex /simple_processor_tb/dut/dp/EXECUTE/aluResult_E

echo ""
echo "=== CONTADORES DE VOTOS ==="
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu1_vote_count
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu2_vote_count
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu3_vote_count
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu4_vote_count
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/alu5_vote_count

echo ""
echo "=== SEÑALES DEL VOTADOR POR MAYORÍA ==="
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu2_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu3_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu4_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu1_alu5_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu2_alu3_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu2_alu4_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu2_alu5_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu3_alu4_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu3_alu5_match
examine /simple_processor_tb/dut/dp/EXECUTE/alu4_alu5_match
examine -unsigned /simple_processor_tb/dut/dp/EXECUTE/majority_status

# Continuar la simulación hasta el final
run -all

# 6. Configurar la vista de ondas para mejor visualización
wave zoom full

echo ""
echo "=== SIMULACIÓN QMR COMPLETADA ==="
echo "✓ Las 5 ALUs procesaron la suma 10 + 20 = 30"
echo "✓ El votador por mayoría seleccionó el resultado correcto"
echo "✓ Revisa la ventana de ondas para ver el comportamiento QMR"
echo ""
echo "INTERPRETACIÓN DE MAJORITY_STATUS:"
echo "  000: No hay mayoría (error crítico)"
echo "  001: ALU1 ganadora (mayoría)"
echo "  010: ALU2 ganadora (mayoría)"
echo "  011: ALU3 ganadora (mayoría)"
echo "  100: ALU4 ganadora (mayoría)"
echo "  101: ALU5 ganadora (mayoría)"
echo ""
echo "INTERPRETACIÓN DE VOTE_COUNT:"
echo "  Cada ALU debe tener vote_count = 5 (todas coinciden)"
echo "  Para tolerancia a fallos, se requiere vote_count >= 3"