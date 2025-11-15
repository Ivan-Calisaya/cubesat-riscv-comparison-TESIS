# FPGA Implementation - RISC-V Softcore

Este directorio contiene la implementación FPGA del procesador RISC-V para CubeSats.

## Características de la Implementación FPGA

### Ventajas
- **Máxima flexibilidad**: Reconfiguración completa del hardware
- **Tolerancia a radiación**: Implementación TMR/QMR en lógica
- **Personalización**: Optimización específica para CubeSat
- **Upgradabilidad**: Actualización remota del firmware

### Desventajas
- **Mayor consumo**: Lógica configurable menos eficiente
- **Complejidad**: Desarrollo HDL más complejo
- **Área**: Mayor utilización de recursos
- **Tiempo**: Ciclos de desarrollo más largos

## Arquitectura del Sistema

```
FPGA RISC-V System
├── Core Processor (RV32I)
│   ├── Single ALU (baseline)
│   ├── TMR ALU (3-way redundancy)
│   └── QMR ALU (5-way redundancy)
├── Memory Subsystem
│   ├── Instruction Cache
│   ├── Data Cache  
│   └── BRAM Controllers
├── Auto-Test System
│   ├── BIST Controllers
│   ├── Fault Injection
│   └── Error Detection
└── CubeSat Peripherals
    ├── Attitude Control
    ├── Communication
    └── Power Management
```

## Subdirectorios

- **components/**: Módulos SystemVerilog del procesador
- **testbenches/**: Simulaciones y validación
- **quartus/**: Proyectos de síntesis y place&route
- **software/**: Software de prueba embebido

## Próximos Pasos

1. Implementar procesador RISC-V base
2. Agregar redundancia TMR/QMR
3. Integrar sistema de auto-test
4. Optimizar para métricas CubeSat