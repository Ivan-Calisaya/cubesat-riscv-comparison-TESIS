# COMANDOS PASO A PASO QMR - Para Ejecutar Manualmente

## Preparación Inicial
```powershell
# 1. Ir al directorio QMR
cd "C:\Users\Usuario\Desktop\Ivan\SOC\qmr-implementation\bare-metal-workspace"

# 2. Verificar archivos QMR
Test-Path "simple_add_qmr.c"
Test-Path "startup_qmr.s"  
Test-Path "qmr_link.ld"

# 3. Definir variables del toolchain
$TOOLCHAIN = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe"
$OBJDUMP = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe"
$SIZE = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-size.exe"
```

## Compilación QMR (Copiar uno por uno)
```powershell
# 4. Compilar QMR bootloader
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c startup_qmr.s -o startup_qmr.o

# 5. Compilar QMR algorithm (5 ALUs + 3-of-5 voter)  
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c simple_add_qmr.c -o simple_add_qmr.o

# 6. Enlazar QMR executable
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -T qmr_link.ld -nostartfiles -nostdlib -static -o simple_add_qmr.elf startup_qmr.o simple_add_qmr.o

# 7. Verificar QMR compilation
Test-Path "simple_add_qmr.elf"
```

## Análisis QMR Recursos
```powershell
# 8. Analizar QMR memory usage
& $SIZE simple_add_qmr.elf

# 9. Generar QMR disassembly
& $OBJDUMP -d simple_add_qmr.elf > simple_add_qmr.dis

# 10. Generar QMR sections analysis
& $OBJDUMP -h simple_add_qmr.elf > simple_add_qmr.sections
```

## Análisis QMR Performance
```powershell
# 11. Contar QMR total instructions
$qmrAllInstructions = (Select-String -Path "simple_add_qmr.dis" -Pattern "^\s*[0-9a-f]+:\s+[0-9a-f]+\s+").Count
Write-Host "QMR Total instructions: $qmrAllInstructions"

# 12. Contar QMR ADD operations (debe ser 5x para 5 ALUs)
$qmrArithmeticOps = (Select-String -Path "simple_add_qmr.dis" -Pattern "\s+(add|sub|mul|div)\s+").Count
Write-Host "QMR Arithmetic operations: $qmrArithmeticOps"

# 13. Contar QMR memory operations
$qmrMemoryOps = (Select-String -Path "simple_add_qmr.dis" -Pattern "\s+(lw|sw|lb|sb|lh|sh)\s+").Count
Write-Host "QMR Memory operations: $qmrMemoryOps"
```

## Verificar 5 ALUs QMR
```powershell
# 14. Buscar las 5 ALU functions individualmente
$qmrAlu0Calls = (Select-String -Path "simple_add_qmr.dis" -Pattern "alu0_add").Count
$qmrAlu1Calls = (Select-String -Path "simple_add_qmr.dis" -Pattern "alu1_add").Count  
$qmrAlu2Calls = (Select-String -Path "simple_add_qmr.dis" -Pattern "alu2_add").Count
$qmrAlu3Calls = (Select-String -Path "simple_add_qmr.dis" -Pattern "alu3_add").Count
$qmrAlu4Calls = (Select-String -Path "simple_add_qmr.dis" -Pattern "alu4_add").Count
$qmrVoterCalls = (Select-String -Path "simple_add_qmr.dis" -Pattern "majority_voter").Count

Write-Host "ALU 0 calls: $qmrAlu0Calls"
Write-Host "ALU 1 calls: $qmrAlu1Calls"
Write-Host "ALU 2 calls: $qmrAlu2Calls"
Write-Host "ALU 3 calls: $qmrAlu3Calls"
Write-Host "ALU 4 calls: $qmrAlu4Calls"
Write-Host "3-of-5 Voter calls: $qmrVoterCalls"
```

## Buscar QMR main function
```powershell
# 15. Buscar function main_qmr
$qmrMainFunction = Select-String -Path "simple_add_qmr.dis" -Pattern "main_qmr>" -Context 0,10
if ($qmrMainFunction) {
    Write-Host "QMR main function encontrada:"
    $qmrMainFunction | ForEach-Object { Write-Host $_.Line }
}
```

## Ver ADD operations reales
```powershell
# 16. Ver QMR ADD operations (primeras 10)
$qmrAddOps = Select-String -Path "simple_add_qmr.dis" -Pattern "\sadd\s"
Write-Host "QMR ADD operations encontradas (primeras 10):"
$qmrAddOps | Select-Object -First 10 | ForEach-Object { Write-Host $_.Line }
```

## Ejecutar QMR en QEMU
```powershell
# 17. Configurar QEMU PATH
$env:PATH += ";C:\Program Files\qemu"

# 18. Ejecutar QMR con timeout (IMPORTANTE: debe hacer bucle infinito)
Write-Host "Ejecutando QMR (5 ALUs + 3-of-5 voter) - timeout 3 segundos..."
$qmrJob = Start-Job -ScriptBlock {
    $env:PATH += ";C:\Program Files\qemu"
    Set-Location $args[0] 
    qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -bios none -kernel simple_add_qmr.elf
} -ArgumentList (Get-Location).Path

Wait-Job $qmrJob -Timeout 3 | Out-Null
Stop-Job $qmrJob -ErrorAction SilentlyContinue
Remove-Job $qmrJob -Force -ErrorAction SilentlyContinue
```

## Estimación QMR Power
```powershell
# 19. QMR Power calculation manual
$qmrAluBasePower = 10.0        # Base core power
$qmrAluMultiplier = 5.0        # 5 ALUs vs 1 ALU
$qmrVoterPower = 12.0          # 3-of-5 majority voter power
$qmrErrorDetectorPower = 8.0   # Enhanced error detection

$qmrMemoryPower = $qmrMemoryOps * 1.8
$qmrArithmeticPower = $qmrArithmeticOps * 2.5 * $qmrAluMultiplier
$qmrControlPower = $qmrBranchOps * 1.2
$qmrTotalDynamicPower = $qmrAluBasePower + $qmrMemoryPower + $qmrArithmeticPower + $qmrControlPower + $qmrVoterPower + $qmrErrorDetectorPower

Write-Host "QMR TOTAL POWER ESTIMADO: $qmrTotalDynamicPower mW"
```

## Comparación Final
```powershell
# 20. Comparar QMR vs TMR vs Single
Write-Host "RESUMEN COMPARATIVO:"
Write-Host "Single SoC: 43.7 mW, 45 inst, 7124 bytes, 0 faults"
Write-Host "TMR SoC: 255 mW, 173 inst, 11732 bytes, 1 fault tolerant"  
Write-Host "QMR SoC: $qmrTotalDynamicPower mW, $qmrAllInstructions inst, bytes, 2 faults tolerant"
Write-Host "FPGA: 261.8 mW (referencia)"
```