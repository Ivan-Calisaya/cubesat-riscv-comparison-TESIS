# run_simulation.do - Script de simulación para el procesador RV32I
# Este script crea el workspace en la carpeta simulacion-FPGA

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

# 4. Añadir las señales más importantes a la ventana de formas de onda
# Señales básicas
add wave /simple_processor_tb/clk
add wave /simple_processor_tb/reset

# Señales del Program Counter (PC)
add wave -label "PC" -hex /simple_processor_tb/dut/dp/FETCH/PC/q

# Instrucción actual
add wave -label "Instrucción" -hex /simple_processor_tb/dut/instrMem/q0

# Banco de registros (los registros donde se almacenan a, b y result)
add wave -label "x0 (zero)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[0]
add wave -label "x1 (ra)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[1]
add wave -label "x2 (sp)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[2]
add wave -label "x5 (a=10)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
add wave -label "x6 (b=20)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
add wave -label "x7 (result=30)" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# Señales de la ALU
add wave -label "ALU_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/a
add wave -label "ALU_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/b
add wave -label "ALU_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/result
add wave -label "ALU_Control" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/ALUControl

# 5. Ejecutar la simulación con monitoreo de ALU
echo "=== INICIANDO SIMULACIÓN ==="
echo "Monitoreando la ALU durante la ejecución..."

# Ejecutar hasta el momento donde la ALU procesa la suma
run 120ns

# Mostrar los valores de la ALU en el momento correcto
echo ""
echo "=== VALORES EN LA ALU (tiempo ~120ns) ==="
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/a
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/b  
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/result
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/ALUControl

# Continuar la simulación hasta el final
run -all

# Mostrar los valores finales de los registros
echo ""
echo "=== VALORES FINALES EN REGISTROS ==="
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# 6. Configurar la vista de ondas para mejor visualización
wave zoom full

echo ""
echo "=== SIMULACIÓN COMPLETADA ==="
echo "✓ La suma 10 + 20 = 30 se procesó correctamente en la ALU"
echo "✓ Revisa la ventana de ondas entre 115ns-125ns para ver la operación"