# CubeSat RISC-V Comparison Project

## Título de Tesis
**DESARROLLO INCREMENTAL Y COMPARATIVO DE UN SISTEMA RISC-V CON AUTO TEST PARA CUBESATS: FPGA VERSUS SOC**

## Descripción del Proyecto
Se trata de desarrollos incrementales para poder comparar detalladamente las ventajas y dificultades de implementar un sistema procesador RISC-V con auto test en dos tipos de plataformas: FPGA y SOC.

## Estructura del Proyecto

### 📁 fpga-implementation/
Implementación softcore RISC-V en FPGA
- `components/` - Módulos SystemVerilog del procesador
- `testbenches/` - Simulaciones ModelSim
- `quartus/` - Proyectos de síntesis
- `software/` - Software de prueba para FPGA

### 📁 soc-implementation/
Implementación hardcore RISC-V en SoC
- `qemu-setup/` - Configuración de simulación QEMU
- `linux-embedded/` - Sistema operativo embebido
- `peripherals/` - Controladores de periféricos
- `software/` - Aplicaciones SoC

### 📁 comparative-analysis/
Framework de análisis comparativo
- Scripts de benchmarking
- Métricas de performance
- Análisis de consumo
- Evaluación de tolerancia a fallos

### 📁 auto-test-system/
Sistema de auto-test para ambas plataformas
- Mecanismos BIST (Built-In Self Test)
- Inyección de fallos
- Monitoreo de sistema
- Estrategias de recuperación

### 📁 documentation/
Documentación de investigación
- Estado del arte
- Metodología de comparación
- Resultados experimentales
- Conclusiones

### 📁 tools/
Herramientas y utilidades
- Scripts de automatización
- Parsers de resultados
- Generadores de reportes

## Objetivos de Comparación

### Performance
- **Throughput**: Instrucciones por segundo
- **Latencia**: Tiempo de respuesta del sistema
- **Frecuencia**: Velocidad máxima de operación

### Consumo de Energía
- **Potencia estática**: Consumo en reposo
- **Potencia dinámica**: Consumo durante operación
- **Eficiencia energética**: MIPS/Watt

### Tolerancia a Radiación
- **Soft errors**: Errores transitorios
- **Total dose effects**: Efectos acumulativos
- **Mecanismos de protección**: TMR, ECC, scrubbing

### Área/Recursos
- **Utilización FPGA**: LUTs, registers, BRAM
- **Área SoC**: Tamaño del chip, costo
- **Complejidad**: Tiempo de desarrollo

### Flexibilidad
- **Reconfigurabilidad**: Capacidad de actualización
- **Personalización**: Adaptación a misión específica
- **Escalabilidad**: Crecimiento del sistema

## Metodología

### Desarrollo Incremental
1. **Fase 1**: Procesador básico RISC-V
2. **Fase 2**: Implementación con redundancia (TMR)
3. **Fase 3**: Sistema completo con auto-test
4. **Fase 4**: Optimización específica para CubeSats

### Validación por Simulación
- **FPGA**: ModelSim + Quartus Prime
- **SoC**: QEMU + GCC toolchain
- **Comparación**: Métricas estandarizadas

## Tecnologías Utilizadas

### FPGA Track
- **HDL**: SystemVerilog
- **Simulación**: ModelSim/Questa
- **Síntesis**: Quartus Prime
- **Target**: Intel Cyclone/Stratix FPGAs

### SoC Track
- **Simulación**: QEMU RISC-V
- **OS**: Linux embebido
- **Toolchain**: GCC RISC-V
- **Target**: SiFive/Rocket cores

## Contribuciones Esperadas

1. **Análisis comparativo detallado** FPGA vs SoC para aplicaciones espaciales
2. **Metodología de evaluación** para sistemas críticos
3. **Implementaciones optimizadas** para requisitos CubeSat
4. **Framework de auto-test** portable entre plataformas

## Requisitos del Sistema

### Software Mínimo
- SystemVerilog simulator (ModelSim/Questa)
- RISC-V GCC toolchain
- QEMU RISC-V
- Python 3.x para análisis

### Hardware Simulado
- FPGA Cyclone V/Stratix (simulación)
- SoC RISC-V (QEMU emulation)
- Periféricos CubeSat estándar

---

**Autor**: [Tu Nombre]  
**Institución**: [Tu Universidad]  
**Fecha**: Noviembre 2025