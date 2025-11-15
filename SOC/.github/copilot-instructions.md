<!-- CubeSat RISC-V Comparison Project Instructions -->

# Proyecto de Tesis: DESARROLLO INCREMENTAL Y COMPARATIVO DE UN SISTEMA RISC-V CON AUTO TEST PARA CUBESATS: FPGA VERSUS SOC

## Contexto del Proyecto

Este workspace está diseñado para el desarrollo y comparación de implementaciones RISC-V para CubeSats en dos plataformas diferentes:

1. **FPGA Track**: Implementación softcore RISC-V con lógica configurable
2. **SoC Track**: Implementación hardcore RISC-V con procesador dedicado

## Estructura del Proyecto

```
/cubesat-riscv-comparison/
├── fpga-implementation/     # Implementación FPGA
├── soc-implementation/      # Implementación SoC  
├── comparative-analysis/    # Framework de comparación
├── auto-test-system/       # Sistema de auto-test
├── documentation/          # Documentación y investigación
└── tools/                 # Herramientas y utilidades
```

## Objetivos de Comparación

- **Performance**: Throughput, latencia, frecuencia máxima
- **Consumo de energía**: Potencia estática vs dinámica
- **Tolerancia a radiación**: Soft errors, total dose effects
- **Área/Recursos**: Utilización de hardware, costo
- **Flexibilidad**: Capacidad de reconfiguración

## Herramientas Requeridas

### FPGA Track:
- SystemVerilog para diseño HDL
- ModelSim para simulación
- Quartus Prime para síntesis
- Auto-test integrado en hardware

### SoC Track:
- QEMU para simulación de sistema
- GCC RISC-V toolchain
- Linux embedded stack
- Software-based testing

## Guidelines de Desarrollo

- Mantener implementaciones independientes pero comparables
- Usar métricas consistentes para ambas plataformas
- Documentar todas las decisiones de diseño
- Validar resultados con simulación exhaustiva
- Enfocarse en requisitos específicos de CubeSats