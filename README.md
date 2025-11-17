Los codigos del procesador RISC-V para FPGA se encuentra listos para ser utilizados en Quartus II
para poder utilizar el procesador en ModelSim se deben reemplazar los archivos

-core.sv
-imem.sv
-datamemory.sv

con los archivos de las carpetas Temporales ModelSim de su correspondiente versión 
esto debido a que ModelSim y Quartus II usan memorias diferentes.
Los codigos del procesador para FPGA se encuentran en la dirección 

cubesat-riscv-comparison-TESIS\Suma_FPGA_X_ALU\tesis\mi_procesador_riscv\components

Los comandos deben ser modificados segun la carpeta y direcciones de trabajo.

Todos los codigos de los procesadores RISC-V aplicados a SoC se encuentran en la carpeta SOC
