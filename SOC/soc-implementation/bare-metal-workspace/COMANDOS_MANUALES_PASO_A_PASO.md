# COMANDOS MANUALES PARA REPLICAR EL ANÁLISIS SoC vs FPGA

## PASO 1: COMPILACIÓN

### 1.1 Compilar bootloader:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c startup.s -o startup_minimal.o
```

### 1.2 Compilar programa principal:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c simple_add_soc_minimal.c -o simple_add_minimal.o
```

### 1.3 Enlazar ejecutable:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe -march=rv32ima_zicsr -mabi=ilp32 -T soc_link.ld -nostartfiles -nostdlib -static -o simple_add_minimal.elf startup_minimal.o simple_add_minimal.o
```

## PASO 2: ANÁLISIS DE RECURSOS

### 2.1 Analizar tamaños de secciones:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-size.exe simple_add_minimal.elf
```

### 2.2 Generar código desensamblado:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe -d simple_add_minimal.elf > simple_add_minimal.dis
```

### 2.3 Analizar secciones de memoria:
```powershell
C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe -h simple_add_minimal.elf > simple_add_minimal.sections
```

## PASO 3: ANÁLISIS DE PERFORMANCE

### 3.1 Contar total de instrucciones:
```powershell
(Select-String -Path "simple_add_minimal.dis" -Pattern "^\s*[0-9a-f]+:\s+[0-9a-f]+\s+").Count
```

### 3.2 Contar operaciones aritméticas:
```powershell
(Select-String -Path "simple_add_minimal.dis" -Pattern "\s+(add|sub|mul|div)\s+").Count
```

### 3.3 Contar operaciones de memoria:
```powershell
(Select-String -Path "simple_add_minimal.dis" -Pattern "\s+(lw|sw|lb|sb|lh|sh)\s+").Count
```

### 3.4 Contar operaciones de control:
```powershell
(Select-String -Path "simple_add_minimal.dis" -Pattern "\s+(j|jal|beq|bne|blt|bge)\s+").Count
```

## PASO 4: VERIFICAR EJECUCIÓN (OPCIONAL)

### 4.1 Ejecutar con timeout (3 segundos):
```powershell
# Configurar PATH
$env:PATH += ";C:\Program Files\qemu"

# Ejecutar con timeout usando Start-Job
$job = Start-Job -ScriptBlock {
    $env:PATH += ";C:\Program Files\qemu"
    Set-Location $args[0]
    qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -bios none -kernel simple_add_minimal.elf
} -ArgumentList (Get-Location).Path

Wait-Job $job -Timeout 3
Stop-Job $job -ErrorAction SilentlyContinue
Remove-Job $job -Force -ErrorAction SilentlyContinue
```

## PASO 5: ANALIZAR RESULTADOS

### 5.1 Ver tamaño del archivo:
```powershell
(Get-Item "simple_add_minimal.elf").Length
```

### 5.2 Revisar archivos generados:
```powershell
Get-ChildItem -Name "simple_add_minimal.*"
```

### 5.3 Ver función main en el desensamblado:
```powershell
Select-String -Path "simple_add_minimal.dis" -Pattern "main>" -Context 10,10
```

## RESULTADOS ESPERADOS:

- **Tamaño ejecutable**: 7,124 bytes
- **Instrucciones totales**: 45
- **Operaciones ADD**: 1 (la suma core)
- **Operaciones memoria**: 14
- **Operaciones control**: 5

## ARCHIVOS PARA COMPARACIÓN CON FPGA:

1. **REPORTE_COMPARATIVO_SoC_vs_FPGA.txt** - Reporte principal
2. **simple_add_minimal.dis** - Código RISC-V generado
3. **simple_add_minimal.sections** - Análisis de memoria
4. **simple_add_minimal.elf** - Ejecutable final

## VALORES A COMPLETAR EN REPORTE:

Necesitas agregar tus valores de Quartus II:
- FPGA Total Logic Elements: [Tu valor]
- FPGA Max Frequency: [Tu valor] MHz
- FPGA Core Dynamic Power: [Tu valor] mW
- FPGA Total Thermal Power: [Tu valor] mW
- FPGA Total Memory Bits: [Tu valor]