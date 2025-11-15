# CubeSat RISC-V Processor - Project Documentation

## Estado del Arte

### Procesadores para Aplicaciones Espaciales

#### Procesadores Tradicionales Espaciales
- **RAD750**: PowerPC 750 radiation-hardened
- **LEON**: SPARC V8 open-source space processor  
- **ARM Cortex-R**: Real-time ARM cores with ECC
- **Microblaze**: Xilinx soft-core processor

#### RISC-V en Aplicaciones Espaciales
- **ESA NOEL-V**: European Space Agency RISC-V
- **Cobham GR765**: Radiation-hardened RISC-V
- **SiFive Intelligence**: AI-focused RISC-V cores
- **Open-source initiatives**: PULP Platform, Rocket Chip

### Tolerancia a Fallos en Sistemas Embebidos

#### Hardware Redundancy
- **TMR (Triple Modular Redundancy)**: 3-way voting
- **Duplex Systems**: Dual redundancy with checking
- **N-Version Programming**: Software diversity
- **Error Correcting Codes**: Memory protection

#### Software Techniques
- **Watchdog Timers**: Execution monitoring
- **Checkpointing**: State saving/restoration
- **Exception Handling**: Graceful error recovery
- **Heartbeat Monitoring**: Liveness detection

## Metodología de Investigación

### Approach Comparativo
1. **Literature Review**: Análisis del estado del arte
2. **Requirements Analysis**: Especificaciones CubeSat
3. **Architecture Design**: Diseño de ambas implementaciones
4. **Implementation**: Desarrollo FPGA y SoC
5. **Validation**: Testing y verificación
6. **Comparison**: Análisis comparativo detallado
7. **Conclusions**: Recomendaciones y trabajo futuro

### Métricas de Evaluación
- **Performance**: Throughput, latency, efficiency
- **Power**: Static/dynamic consumption, thermal
- **Reliability**: MTBF, fault tolerance, availability
- **Cost**: Development time, silicon area, tools
- **Flexibility**: Reconfigurability, upgradability

### Experimental Design
- **Controlled Variables**: Same test cases, conditions
- **Independent Variables**: FPGA vs SoC platform
- **Dependent Variables**: Performance, power, reliability
- **Statistical Analysis**: Confidence intervals, significance tests

## CubeSat Requirements Specification

### Size, Weight, Power (SWaP) Constraints
- **Size**: 1U, 2U, 3U form factors
- **Weight**: <1kg per unit
- **Power**: <2W typical, <5W peak
- **Thermal**: -40°C to +85°C operational

### Performance Requirements
- **Computation**: Scientific payload processing
- **Real-time**: Attitude control, communication
- **Memory**: Program storage, data buffering
- **I/O**: Sensor interfaces, actuator control

### Reliability Requirements
- **Mission Duration**: 1-5 years typical
- **Success Probability**: >90% mission success
- **Fault Tolerance**: Radiation, temperature, aging
- **Autonomy**: Limited ground contact windows

### Communication and Control
- **Uplink/Downlink**: Command and telemetry
- **Protocol Handling**: Space communication standards
- **Encryption**: Secure communications
- **Compression**: Data volume reduction

## Research Questions

### Primary Questions
1. **Performance**: Which platform provides better computational performance for CubeSat workloads?
2. **Power Efficiency**: Which approach achieves better energy efficiency?
3. **Fault Tolerance**: How do hardware vs software redundancy compare?
4. **Development Complexity**: What are the trade-offs in design effort?

### Secondary Questions
1. **Scalability**: How do solutions scale with mission complexity?
2. **Cost**: What are the total cost implications?
3. **Time-to-Market**: Which approach enables faster deployment?
4. **Technology Evolution**: How do solutions adapt to advancing technology?

## Expected Contributions

### Academic Contributions
- **Comprehensive Comparison**: First detailed FPGA vs SoC analysis for CubeSats
- **Methodology**: Replicable comparison framework
- **Benchmark Suite**: CubeSat-specific test cases
- **Guidelines**: Design decision support

### Practical Contributions
- **Reference Designs**: Open-source implementations
- **Auto-Test Framework**: Portable fault tolerance system
- **Tool Chain**: Automated comparison tools
- **Documentation**: Best practices guide

## Timeline and Milestones

### Phase 1: Foundation (Weeks 1-4)
- Literature review completion
- Requirements specification
- Tool setup and validation
- Baseline implementations

### Phase 2: FPGA Implementation (Weeks 5-8)
- RISC-V softcore development
- TMR/QMR redundancy implementation
- Auto-test system integration
- FPGA synthesis and validation

### Phase 3: SoC Implementation (Weeks 9-12)
- QEMU environment setup
- Linux embedded system
- Software-based fault tolerance
- Application development

### Phase 4: Comparison and Analysis (Weeks 13-16)
- Benchmark execution
- Data collection and analysis
- Comparative evaluation
- Results documentation

### Phase 5: Documentation and Presentation (Weeks 17-20)
- Thesis writing
- Paper preparation
- Presentation development
- Final validation

## Risk Management

### Technical Risks
- **Complexity**: Underestimating implementation effort
- **Tools**: Simulation environment limitations
- **Validation**: Insufficient test coverage
- **Integration**: Platform compatibility issues

### Schedule Risks
- **Learning Curve**: New tools and technologies
- **Debugging**: Complex system debug time
- **Iteration**: Multiple design iterations
- **Documentation**: Writing and review time

### Mitigation Strategies
- **Incremental Development**: Phased implementation
- **Regular Reviews**: Weekly progress assessment
- **Backup Plans**: Alternative approaches
- **External Support**: Advisor and peer consultation