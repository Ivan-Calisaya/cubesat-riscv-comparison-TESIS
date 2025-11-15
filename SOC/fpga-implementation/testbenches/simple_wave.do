# simple_wave.do - Script de simulación para el procesador RV32I siguiendo el instructivo

# 1. Limpiar completamente y crear la biblioteca de trabajo 'work'
# Esto asegura que empezamos con una compilación limpia cada vez.
if {[file exists work]} {
    vdel -lib work -all
    file delete -force work
}
vlib work
vmap work work

# 2. Compilar todos los archivos fuente de SystemVerilog en la biblioteca 'work'.
# Compilamos primero todos los componentes
vlog -sv -work work ../components/*.sv

# Compilar el testbench
vlog -sv -work work simple_processor_tb.sv

# 3. Iniciar el simulador con el testbench como módulo de nivel superior.
# -voptargs="+acc" es importante para mantener la visibilidad de todas las señales internas
vsim -voptargs="+acc" work.simple_processor_tb

# 4. Añadir las señales más importantes a la ventana de formas de onda.
# Señales básicas
add wave /simple_processor_tb/clk
add wave /simple_processor_tb/reset

# Señales del Program Counter (PC)
add wave -hex /simple_processor_tb/dut/dp/FETCH/PC/q
add wave -label "PC" -hex /simple_processor_tb/dut/dp/FETCH/PC/q

# Instrucción actual
add wave -hex /simple_processor_tb/dut/instrMem/q0
add wave -label "Instrucción" -hex /simple_processor_tb/dut/instrMem/q0

# Banco de registros (los primeros 8 registros)
add wave -label "x0" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[0]
add wave -label "x1" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[1]
add wave -label "x2" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[2]
add wave -label "x3" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[3]
add wave -label "x4" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[4]
add wave -label "x5" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
add wave -label "x6" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
add wave -label "x7" -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

# Señales de la ALU
add wave -label "ALU_A" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/a
add wave -label "ALU_B" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/b
add wave -label "ALU_Result" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/result
add wave -label "ALU_Control" -hex /simple_processor_tb/dut/dp/EXECUTE/alu/ALUControl

# Todas las señales del DUT (para depuración detallada)
add wave -r /simple_processor_tb/dut/*

# 5. Ejecutar la simulación.
# 'run -all' ejecuta la simulación hasta que encuentra una sentencia '$finish' en el testbench.
run -all

echo "Simulación completada. Revisa la ventana de ondas para analizar:"
echo "1. Reset: PC debe ser 0, luego incrementar de 4 en 4"
echo "2. Instrucciones ADDI: valores 10 y 20 cargados en registros"
echo "3. Instrucción ADD: suma 10+20=30 (0x1E)"
echo "4. Bucle infinito: PC debe saltar a la misma dirección"