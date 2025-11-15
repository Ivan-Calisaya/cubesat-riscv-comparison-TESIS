# create_quartus_project.tcl - Script para crear proyecto Quartus automáticamente

# Configuración del proyecto
set project_name "riscv_processor"
set top_level_entity "top_level"
set device_family "Cyclone IV E"
set device_part "EP4CE115F29C7"

# Crear nuevo proyecto
project_new $project_name -overwrite

# Configurar dispositivo
set_global_assignment -name FAMILY $device_family
set_global_assignment -name DEVICE $device_part
set_global_assignment -name TOP_LEVEL_ENTITY $top_level_entity

# Añadir archivos fuente
set_global_assignment -name SYSTEMVERILOG_FILE "top_level.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/core.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/datapath.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/controller.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/alu.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/regfile.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/imem.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/datamemory.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/fetch.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/decode.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/execute.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/memory.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/writeback.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/maindec.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/aludec.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/aludec_atomic.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/atom_alu.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/signext.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/flopr.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/flopre.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/flopre_init.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/branching.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/memReadMask.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/memWriteMask.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/wideXOR.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/core_status.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/csr_dec.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/exceptDecode.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/interruptDecode.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/except_controller.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/except_e.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/except_f.sv"
set_global_assignment -name SYSTEMVERILOG_FILE "../components/mux4.sv"

# Añadir restricciones de timing
set_global_assignment -name SDC_FILE "timing_constraints.sdc"

# Configuraciones de síntesis y análisis
set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name ERROR_CHECK_FREQUENCY_DIVISOR 1
set_global_assignment -name NOMINAL_CORE_SUPPLY_VOLTAGE 1.2V

# Configurar para análisis de área y potencia
set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "23 MM HEAT SINK WITH 200 LFPM AIRFLOW"
set_global_assignment -name POWER_BOARD_THERMAL_MODEL "NONE (CONSERVATIVE)"

# Configurar optimización
set_global_assignment -name OPTIMIZATION_MODE "HIGH PERFORMANCE EFFORT"
set_global_assignment -name SYNTHESIS_EFFORT AUTO
set_global_assignment -name FITTER_EFFORT "STANDARD FIT"

# Habilitar reportes detallados
set_global_assignment -name FLOW_ENABLE_POWER_ANALYZER ON
set_global_assignment -name POWER_DEFAULT_INPUT_IO_TOGGLE_RATE "12.5 %"

# Guardar y cerrar proyecto
project_close

puts "Proyecto Quartus creado exitosamente!"
puts "Archivos generados:"
puts "- $project_name.qpf (archivo de proyecto)"
puts "- $project_name.qsf (configuración del proyecto)"
puts ""
puts "Para continuar:"
puts "1. Abre Quartus II"
puts "2. File -> Open Project -> $project_name.qpf"
puts "3. Processing -> Start Compilation"
puts "4. Tools -> PowerPlay Power Analyzer (análisis de potencia)"
puts "5. Compilation Report -> Flow Summary (resumen de recursos)"