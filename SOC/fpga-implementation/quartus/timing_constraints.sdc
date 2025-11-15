# timing_constraints.sdc - Restricciones de timing para Quartus

# Clock principal - 50MHz (20ns periodo)
create_clock -name "clk" -period 20.000 [get_ports {clk}]

# Restricciones de entrada
set_input_delay -clock "clk" -max 2.0 [all_inputs]
set_input_delay -clock "clk" -min 0.5 [all_inputs]

# Restricciones de salida  
set_output_delay -clock "clk" -max 2.0 [all_outputs]
set_output_delay -clock "clk" -min 0.5 [all_outputs]

# Restricciones adicionales para reset
set_false_path -from [get_ports {reset_n}] -to [all_registers]

# Optimización para área vs velocidad
set_max_delay 18.0 -from [all_inputs] -to [all_outputs]