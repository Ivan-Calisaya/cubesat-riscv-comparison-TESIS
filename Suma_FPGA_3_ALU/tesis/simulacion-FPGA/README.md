# Configuración de simulación para el procesador RISC-V
# Carpeta: simulacion-FPGA

## Estructura de archivos:
- run_simulation.do    -> Script principal de ModelSim
- work/               -> Directorio de trabajo de ModelSim (se crea automáticamente)
- transcript          -> Log de la simulación (se crea automáticamente)
- vsim.wlf            -> Archivo de ondas (se crea automáticamente)

## Archivos fuente utilizados:
- ../mi_procesador_riscv/components/*.sv  -> Todos los módulos del procesador
- ../mi_procesador_riscv/tb/simple_processor_tb.sv -> Testbench
- ../mi_procesador_riscv/tb/imem_init.txt -> Programa compilado (simple_add.c)

## Comando para ejecutar:
En ModelSim, ejecutar:
1. cd {C:/Users/Usuario/Desktop/Ivan/tesis/simulacion-FPGA}
2. do run_simulation.do

## Resultados esperados:
- Registro x5: 0x0000000A (variable a = 10)
- Registro x6: 0x00000014 (variable b = 20)
- Registro x7: 0x0000001E (result = a + b = 30)