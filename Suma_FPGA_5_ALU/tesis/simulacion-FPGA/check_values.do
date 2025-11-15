# check_values.do - Script para verificar los valores de la ALU y registros
# Ejecutar después de la simulación principal

echo "=== VERIFICACIÓN DE VALORES ==="
echo ""

# Ir al tiempo donde ocurre la suma en la ALU
echo "Navegando al tiempo 120ns donde ocurre la suma..."
run 120ns

echo ""
echo "=== VALORES EN LA ALU (tiempo 120ns) ==="
echo -n "ALU_A (operando A): "
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/a
echo -n "ALU_B (operando B): "
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/b
echo -n "ALU_Result (10+20): "
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/result
echo -n "ALU_Control: "
examine -hex /simple_processor_tb/dut/dp/EXECUTE/alu/ALUControl

# Continuar hasta el final
echo ""
echo "Continuando simulación hasta el final..."
run -all

echo ""
echo "=== VALORES FINALES EN REGISTROS ==="
echo -n "x5 (debería contener a=10): "
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[5]
echo -n "x6 (debería contener b=20): "
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[6]
echo -n "x7 (debería contener result=30): "
examine -hex /simple_processor_tb/dut/dp/DECODE/registers/ram[7]

echo ""
echo "=== RESUMEN ==="
echo "✓ Esperado: ALU_A=0x0000000A, ALU_B=0x00000014, ALU_Result=0x0000001E"
echo "✓ Tiempo de la suma: ~115ns-125ns"
echo "✓ Resultado final: 10 + 20 = 30 (0x1E en hexadecimal)"