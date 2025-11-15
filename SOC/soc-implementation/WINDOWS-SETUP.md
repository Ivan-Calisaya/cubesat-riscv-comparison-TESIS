# QEMU RISC-V Setup para Windows

## Instalación QEMU en Windows

### Método 1: Binarios Oficiales (Más Simple)
```powershell
# 1. Descargar QEMU para Windows
# URL: https://www.qemu.org/download/#windows
# Archivo: qemu-w64-setup-[version].exe

# 2. Instalar usando el instalador
# Instala en: C:\Program Files\qemu\

# 3. Agregar al PATH
$env:PATH += ";C:\Program Files\qemu"
```

### Método 2: Chocolatey Package Manager
```powershell
# 1. Instalar Chocolatey (si no lo tienes)
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# 2. Instalar QEMU
choco install qemu

# 3. Verificar instalación
qemu-system-riscv64 --version
```

## Configuración RISC-V Virtual Machine

### QEMU RISC-V Machines Disponibles
```powershell
# Listar machines disponibles
qemu-system-riscv64 -machine help

# Machines principales:
# - virt         : Generic RISC-V Virtual Platform
# - sifive_e     : SiFive E-series (microcontroller)
# - sifive_u     : SiFive U-series (application processor)
```

### Test Básico QEMU
```powershell
# Test simple - boot sin OS
qemu-system-riscv64 -machine virt -m 128 -nographic -kernel [tu_programa.elf]

# Con monitor QEMU
qemu-system-riscv64 -machine virt -m 128 -monitor stdio
```

## Linux Embebido en Windows

### Opción A: Buildroot Cross-Compilation
```powershell
# 1. Instalar dependencias Windows
# - MSYS2 (para herramientas Unix-like)
# - Git for Windows
# - Python 3.x

# 2. Clonar Buildroot
git clone https://git.buildroot.net/buildroot
cd buildroot

# 3. Configurar para RISC-V
make qemu_riscv64_virt_defconfig

# 4. Customizar configuración
make menuconfig

# 5. Compilar (toma tiempo)
make
```

### Opción B: Pre-built Images
```powershell
# Descargar imágenes pre-compiladas
# URL: https://github.com/buildroot/buildroot/releases
# O desde: https://wiki.qemu.org/Documentation/Platforms/RISCV

# Boot con imagen pre-built
qemu-system-riscv64 \
    -machine virt \
    -cpu rv64 \
    -m 256M \
    -kernel Image \
    -append "root=/dev/vda ro console=ttyS0" \
    -drive file=rootfs.ext2,format=raw,id=hd0 \
    -device virtio-blk-device,drive=hd0 \
    -nographic
```

## Herramientas de Desarrollo Windows

### RISC-V Toolchain (Ya tienes)
```powershell
# Verificar tu toolchain existente
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe --version

# Compatible para SoC development también
```

### Debugging Tools
```powershell
# GDB multiarch para RISC-V
# Incluido en tu xpack toolchain:
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gdb.exe

# OpenOCD para hardware debugging
# Descargar desde: https://github.com/xpack-dev-tools/openocd-xpack/releases
```

### Performance Analysis
```powershell
# QEMU tiene performance counters built-in
qemu-system-riscv64 -machine virt -cpu rv64,pmu=true -m 256M

# Dentro del sistema guest:
# - perf tools (si Linux)
# - custom benchmarking software
```

## Ventajas QEMU + Windows

### ✅ Pros
- **No VM overhead**: QEMU nativo en Windows
- **Cycle-accurate**: Simulación precisa
- **Debugging integrado**: GDB + QEMU monitor
- **Performance counters**: Métricas detalladas
- **Scriptable**: Automatización completa

### ⚠️ Contras vs Linux Host
- **Toolchain setup**: Más pasos iniciales
- **Documentation**: Más ejemplos para Linux
- **Package management**: Menos herramientas automatizadas

## Ejemplo de Configuración SoC

### simple_soc.py (Script de configuración)
```python
#!/usr/bin/env python3
"""
QEMU RISC-V SoC Configuration for CubeSat Comparison
"""

import subprocess
import os

def start_qemu_soc():
    """Start QEMU RISC-V SoC simulation"""
    
    qemu_args = [
        "qemu-system-riscv64",
        "-machine", "virt",
        "-cpu", "rv64",
        "-m", "256M",
        "-smp", "1",  # Single core para comparación fair vs FPGA
        "-nographic",
        "-monitor", "telnet:127.0.0.1:1234,server,nowait",
        "-kernel", "linux_kernel",
        "-append", "root=/dev/vda console=ttyS0",
        "-drive", "file=rootfs.ext2,format=raw,id=hd0",
        "-device", "virtio-blk-device,drive=hd0",
        "-device", "virtio-net-device,netdev=net0",
        "-netdev", "user,id=net0,hostfwd=tcp::2222-:22"
    ]
    
    print("Starting QEMU RISC-V SoC...")
    print("Command:", " ".join(qemu_args))
    
    subprocess.run(qemu_args)

if __name__ == "__main__":
    start_qemu_soc()
```

## Comparación Justa FPGA vs SoC

### Configuraciones Equivalentes
| Parámetro | FPGA Track | SoC Track |
|-----------|------------|-----------|
| **ISA** | RV32I | RV32I (compatible) |
| **Cores** | 1 | 1 (single core) |
| **Memory** | BRAM (configurable) | 256MB DDR (simulado) |
| **Frequency** | ModelSim cycles | QEMU cycle-accurate |
| **Software** | Bare metal C | Linux + applications |

### Métricas Comparables
- **Performance**: Instructions/second, latency
- **Power**: Estimation tools en ambos
- **Resource**: LUTs vs silicon area estimation  
- **Fault Tolerance**: Hardware TMR vs software redundancy
- **Development**: Time-to-market, complexity

## Próximos Pasos SoC

1. **Instalar QEMU**: Método Chocolatey recomendado
2. **Test básico**: Boot simple RISC-V machine
3. **Linux setup**: Buildroot o pre-built image
4. **Port test cases**: Equivalentes a tu simple_add.c
5. **Benchmark framework**: Automated comparison scripts

¿Te gustaría que empecemos con la instalación de QEMU o prefieres otra opción?