# Auto-Test System

Sistema de auto-test para ambas implementaciones (FPGA y SoC).

## Objetivos del Auto-Test

### Detección de Fallos
- **Permanent Faults**: Defectos de fabricación, degradación
- **Transient Faults**: SEUs, EMI, voltage variations
- **Intermittent Faults**: Timing violations, thermal issues
- **Design Faults**: Bugs de hardware/software

### Cobertura de Pruebas
- **Functional Coverage**: Todas las operaciones
- **Structural Coverage**: Todos los componentes
- **Fault Coverage**: Tipos de fallo detectables
- **Temporal Coverage**: Pruebas continuas/periódicas

## Estrategias por Plataforma

### FPGA Auto-Test
```
Hardware-Based Testing
├── BIST Controllers
│   ├── Memory BIST
│   ├── Logic BIST  
│   └── Interconnect BIST
├── Fault Injection
│   ├── SEU simulation
│   ├── Stuck-at faults
│   └── Delay faults
└── Online Monitoring
    ├── Signature analysis
    ├── Duplication checking
    └── TMR/QMR voting
```

### SoC Auto-Test
```
Software-Based Testing
├── Software BIST
│   ├── CPU instruction tests
│   ├── Cache coherency tests
│   └── Peripheral tests
├── Watchdog Systems
│   ├── Task monitoring
│   ├── Heartbeat checking
│   └── Timeout detection
└── Error Handling
    ├── Exception handling
    ├── Recovery procedures
    └── Graceful degradation
```

## Test Methodologies

### Built-In Self-Test (BIST)
- **LBIST**: Logic BIST for combinational/sequential logic
- **MBIST**: Memory BIST for SRAM/cache structures
- **ABIST**: Analog BIST for mixed-signal components
- **SBIST**: Software BIST for processor validation

### Fault Injection
- **Hardware Injection**: Physical fault insertion
- **Simulation Injection**: Model-based fault injection
- **Software Injection**: Runtime error insertion
- **Environmental Stress**: Temperature, voltage, radiation

### Continuous Monitoring
- **Health Monitoring**: System vital signs
- **Performance Monitoring**: Degradation detection
- **Error Logging**: Fault history tracking
- **Predictive Maintenance**: Failure prediction

## Implementation Strategy

### Test Scheduling
- **Power-On Self-Test**: Boot-time validation
- **Periodic Testing**: Background health checks
- **On-Demand Testing**: User-triggered diagnostics
- **Emergency Testing**: Fault response procedures

### Test Isolation
- **Non-Intrusive Testing**: No performance impact
- **Intrusive Testing**: Scheduled downtime
- **Partial Testing**: Subsystem isolation
- **Full System Testing**: Complete validation

### Recovery Mechanisms
- **Automatic Recovery**: Self-healing systems
- **Manual Recovery**: Ground intervention
- **Graceful Degradation**: Reduced functionality
- **Emergency Mode**: Survival operations

## Validation Framework

### Test Effectiveness
- **Fault Coverage Analysis**: Detectable fault percentage
- **False Positive Rate**: Incorrect fault indication
- **Detection Latency**: Time to fault detection
- **Recovery Time**: Fault to normal operation

### Mission Integration
- **CubeSat Requirements**: Mission-specific needs
- **Resource Constraints**: SWaP limitations
- **Reliability Targets**: Mission success criteria
- **Operational Procedures**: Ground operation integration