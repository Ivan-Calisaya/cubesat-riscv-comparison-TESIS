# QEMU vs Docker para SoC RISC-V - Comparación Detallada

## Conceptos Fundamentales

### QEMU (Quick Emulator)
- **Tipo**: Emulador de hardware completo
- **Propósito**: Simula una máquina RISC-V completa (CPU, memoria, periféricos)
- **Nivel**: Emulación a nivel de instrucciones de CPU
- **Output**: Métricas de hardware reales (ciclos, latencia, etc.)

### Docker
- **Tipo**: Plataforma de contenedores
- **Propósito**: Ambiente de software aislado y reproducible
- **Nivel**: Virtualización a nivel de sistema operativo
- **Output**: Entorno de desarrollo consistente

## Comparación Detallada para tu Tesis

### 🎯 **Para Simulación SoC RISC-V**

#### QEMU
```bash
# Simulación directa del hardware
qemu-system-riscv64 -machine virt -cpu rv64 -m 256M
# → Simula un chip RISC-V real con periféricos
```

#### Docker
```bash
# Container con herramientas RISC-V
docker run -it riscv/toolchain
# → Entorno de desarrollo, pero necesitas QEMU dentro del container
```

## Ventajas y Desventajas

### QEMU - Emulación Hardware

#### ✅ Ventajas para tu Tesis

**1. Métricas Reales de Hardware**
```
Performance Counters:
- Cycles per instruction (CPI)
- Cache miss rates  
- Branch prediction accuracy
- Memory bandwidth utilization
- Interrupt latency
```

**2. Comparación Justa vs FPGA**
```
FPGA Track          SoC Track
ModelSim cycles  ↔  QEMU cycles
Hardware timing  ↔  Emulated timing
Resource usage   ↔  Silicon estimation
```

**3. Control Total del Sistema**
```powershell
# Configuraciones precisas
qemu-system-riscv64 \
  -cpu rv32,mmu=false,pmp=false \  # Match FPGA capabilities
  -m 64M \                         # Constrain memory like CubeSat
  -machine virt,aclint=on \        # Specific peripherals
  -icount shift=0 \                # Deterministic execution
  -d cpu,exec,guest_errors         # Debug info
```

**4. Ciclo-Exacto (Deterministic)**
```
Tiempo Real ≠ Tiempo Simulado
- Cada instrucción cuenta correctamente
- Reproducible entre ejecuciones
- Timing analysis preciso
```

**5. Desarrollo de Bare Metal**
```c
// Tu simple_add.c funciona directamente
int main() {
    volatile int a = 10, b = 20;
    volatile int result = a + b;  // QEMU ve cada operación
    return result;
}
```

#### ⚠️ Desventajas QEMU

**1. Configuración Inicial**
```
Curva de aprendizaje:
- Opciones de línea de comandos
- Configuración de máquina virtual
- Setup de bootloader/kernel
```

**2. Debugging Complejo**
```
Multiple niveles:
- QEMU monitor (hardware)
- GDB (software)  
- Guest OS debugging
```

**3. Performance Overhead**
```
Simulación completa:
- Cada instrucción emulada
- Slower than native execution
- Memory overhead significativo
```

### Docker - Containerización

#### ✅ Ventajas Docker

**1. Entorno Reproducible**
```dockerfile
FROM ubuntu:22.04
RUN apt-get update && apt-get install -y \
    gcc-riscv64-linux-gnu \
    qemu-system-riscv64 \
    build-essential
# → Mismo entorno en cualquier máquina
```

**2. Setup Simplificado**
```powershell
# Un comando y listo
docker run -it --rm -v ${PWD}:/workspace riscv-dev
# vs múltiples pasos QEMU setup
```

**3. Herramientas Pre-instaladas**
```
Containers disponibles:
- riscv/riscv-gnu-toolchain
- sifive/freedom-tools
- lowrisc/opentitan-tools
```

**4. Versionado y Distribución**
```yaml
version: '3'
services:
  riscv-soc:
    image: riscv-cubesat:v1.0
    volumes:
      - ./workspace:/app
# → Comparte entorno con advisors/revisores
```

**5. Aislamiento Limpio**
```
Beneficios:
- No contamina sistema host
- Multiple versiones simultáneas
- Cleanup automático
```

#### ⚠️ Desventajas Docker

**1. Overhead de Virtualización**
```
Docker Layer → Windows → QEMU → RISC-V
- Múltiples capas de abstracción
- Performance penalty
- Métricas menos precisas
```

**2. Limitaciones Windows**
```
Docker Desktop issues:
- WSL2 dependency
- File system performance
- Network complexity
```

**3. Métricas Imprecisas**
```
Para tu tesis:
- Timer resolution afectado
- Network latency variable
- Resource contention
```

**4. Debugging Complejo**
```
Multiple niveles:
Docker → WSL2 → QEMU → RISC-V Guest
- Hard to trace performance issues
- Complex port forwarding
```

## Caso de Uso: Tu Tesis CubeSat

### Escenario QEMU Directo
```powershell
# Configuración específica CubeSat
qemu-system-riscv32 \
  -machine virt \
  -cpu rv32,mmu=false \
  -m 32M \                    # CubeSat memory constraint
  -nographic \
  -kernel cubesat_os.elf \
  -drive file=payload.img \
  -device virtio-serial \
  -chardev socket,id=sat_comm,port=1234 \
  -icount shift=auto,rr=record,rrfile=trace.bin

# Resultado: Trace exacto para análisis
```

### Escenario Docker + QEMU
```dockerfile
FROM ubuntu:22.04
RUN apt-get install qemu-system-riscv64
COPY cubesat_config.sh /
ENTRYPOINT ["/cubesat_config.sh"]

# Luego:
docker run -it cubesat-sim
# → Extra layer, menos control directo
```

## Recomendación Específica para tu Proyecto

### **QEMU Directo - Recomendado**

#### Razones para tu Tesis:
```
1. ✅ Métricas Precisas
   - Cycle counts reales
   - Performance comparisons válidos
   - Timing analysis confiable

2. ✅ Comparación Justa
   FPGA softcore ↔ QEMU hardcore
   - Similar abstraction level
   - Comparable measurement methodology

3. ✅ Control Total
   - Configuración exacta del hardware
   - Peripheral customization  
   - Debug capabilities completas

4. ✅ Professional Setup
   - Industry standard approach
   - Better for academic research
   - Easier to defend methodology
```

### Hybrid Approach (Lo Mejor de Ambos)

#### Setup Recomendado:
```powershell
# 1. QEMU nativo para simulación
qemu-system-riscv64 --version

# 2. Docker para herramientas auxiliares
docker run --rm -v ${PWD}:/work riscv/toolchain \
  riscv64-unknown-elf-gcc -o test.elf test.c

# 3. Combinar en scripts
./build_with_docker.ps1    # Compile en container
./run_with_qemu.ps1        # Execute en QEMU directo
```

## Timeline de Implementación

### Opción A: QEMU Directo
```
Semana 1: Setup QEMU + basic boot
Semana 2: Linux embebido + toolchain  
Semana 3: Test cases + benchmarks
Semana 4: Metrics collection + analysis
```

### Opción B: Docker + QEMU
```
Semana 1: Docker setup + container build
Semana 2: QEMU dentro de container
Semana 3: Debug container networking/volumes
Semana 4: Same as Option A pero más complex
```

## Decisión Final

### Para tu Tesis de Comparación FPGA vs SoC:

**🎯 QEMU Directo**: 
- Máxima precisión de métricas
- Comparación justa vs FPGA
- Control total del entorno
- Professional research approach

**🐳 Docker**: 
- Si necesitas colaboración fácil
- Si tu sistema tiene conflictos
- Si planeas distribuir herramientas

### Mi Recomendación: **QEMU Directo**

Razón: Tu objetivo es **comparar arquitecturas**, no desarrollar herramientas. QEMU te dará las métricas más precisas y la comparación más justa contra tu implementación FPGA.

¿Te convence el análisis? ¿Empezamos con QEMU directo o tienes dudas sobre algún aspecto específico?