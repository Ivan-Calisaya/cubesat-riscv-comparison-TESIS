# SoC Implementation - RISC-V Hardcore

Este directorio contiene la implementación SoC del procesador RISC-V para CubeSats.

## Características de la Implementación SoC

### Ventajas
- **Menor consumo**: Procesador hardcore optimizado
- **Mayor performance**: Frecuencias más altas
- **Menor área**: Diseño integrado eficiente
- **Tiempo de desarrollo**: Stack software estándar

### Desventajas
- **Menor flexibilidad**: Hardware fijo
- **Vulnerabilidad a radiación**: Menos opciones de protección
- **Actualizaciones limitadas**: Solo software, hardware fijo
- **Personalización restringida**: Dependiente del SoC disponible

## Arquitectura del Sistema

```
SoC RISC-V System  
├── Hardcore Processor (RV64GC)
│   ├── Multi-core capability
│   ├── Hardware FPU
│   └── Vector extensions
├── System Interconnect
│   ├── AXI4 Bus
│   ├── Cache coherency
│   └── DMA controllers  
├── Auto-Test System
│   ├── Software BIST
│   ├── Watchdog timers
│   └── ECC protection
└── CubeSat Peripherals
    ├── UART/SPI/I2C
    ├── GPIO controllers
    └── Timer/PWM units
```

## Subdirectorios

- **qemu-setup/**: Configuración simulación QEMU
- **linux-embedded/**: Sistema operativo embebido
- **peripherals/**: Drivers y configuración
- **software/**: Aplicaciones y servicios

## Entorno de Simulación

### QEMU RISC-V
- Simulación ciclo-exacta
- Múltiples configuraciones de core
- Periféricos virtualizados
- Debugging integrado

### Linux Embebido
- Buildroot/Yocto build system
- Real-time kernel options
- CubeSat-specific drivers
- Power management

## Próximos Pasos

1. Configurar entorno QEMU
2. Crear Linux embebido básico
3. Implementar drivers CubeSat
4. Desarrollar auto-test software