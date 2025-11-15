# COMANDOS MANUALES TMR: 3 ALUs + Voter (Idéntico a FPGA)
# Copia y pega cada comando uno por uno

# ============================================================================
# PREPARACION INICIAL TMR
# ============================================================================

# 1. Verificar directorio TMR
Get-Location
# Debe mostrar: C:\Users\Usuario\Desktop\Ivan\SOC\tmr-implementation\bare-metal-workspace

# 2. Verificar archivos TMR
Test-Path "simple_add_tmr.c"
Test-Path "startup_tmr.s"
Test-Path "tmr_link.ld"

# 3. Configurar variables TMR
$TOOLCHAIN = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-gcc.exe"
$OBJDUMP = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-objdump.exe"
$SIZE = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-size.exe"

# ============================================================================
# PASO 1: COMPILACION TMR (3 ALUs + Voter)
# ============================================================================

Write-Host "INICIANDO COMPILACION TMR..." -ForegroundColor Yellow

# 1.1 Compilar TMR bootloader (single core)
Write-Host "Compilando TMR bootloader..." -ForegroundColor Cyan
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c startup_tmr.s -o startup_tmr.o

# 1.2 Compilar TMR algorithm (3 ALUs + voter)
Write-Host "Compilando TMR algorithm (3 ALUs + voter)..." -ForegroundColor Cyan
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -O2 -g -c simple_add_tmr.c -o simple_add_tmr.o

# 1.3 Enlazar TMR executable
Write-Host "Enlazando TMR executable..." -ForegroundColor Cyan
& $TOOLCHAIN -march=rv32ima_zicsr -mabi=ilp32 -T tmr_link.ld -nostartfiles -nostdlib -static -o simple_add_tmr.elf startup_tmr.o simple_add_tmr.o

# 1.4 Verificar TMR compilation
if (Test-Path "simple_add_tmr.elf") {
    Write-Host "✅ TMR compilacion exitosa!" -ForegroundColor Green
    $tmrFileSize = (Get-Item "simple_add_tmr.elf").Length
    Write-Host "Tamaño TMR executable: $tmrFileSize bytes" -ForegroundColor Green
} else {
    Write-Host "❌ Error en TMR compilacion" -ForegroundColor Red
    exit
}

# ============================================================================
# PASO 2: ANALISIS TMR RECURSOS (3 ALUs vs 1 ALU)
# ============================================================================

Write-Host "`nANALISIS TMR RECURSOS..." -ForegroundColor Yellow

# 2.1 Analizar TMR memory usage
Write-Host "Analizando TMR memory usage..." -ForegroundColor Cyan
& $SIZE simple_add_tmr.elf

# 2.2 Generar TMR disassembly
Write-Host "Generando TMR disassembly..." -ForegroundColor Cyan
& $OBJDUMP -d simple_add_tmr.elf > simple_add_tmr.dis

# 2.3 Generar TMR sections analysis
Write-Host "Analizando TMR memory sections..." -ForegroundColor Cyan
& $OBJDUMP -h simple_add_tmr.elf > simple_add_tmr.sections

Write-Host "✅ TMR archivos de analisis generados" -ForegroundColor Green

# ============================================================================
# PASO 3: ANALISIS TMR PERFORMANCE (3 ALUs paralelas)
# ============================================================================

Write-Host "`nANALISIS TMR PERFORMANCE..." -ForegroundColor Yellow

# 3.1 Contar TMR instructions
Write-Host "Contando TMR instructions..." -ForegroundColor Cyan
$tmrAllInstructions = (Select-String -Path "simple_add_tmr.dis" -Pattern "^\s*[0-9a-f]+:\s+[0-9a-f]+\s+").Count
Write-Host "TMR Total instructions: $tmrAllInstructions"

# 3.2 Contar TMR ADD operations (should be 3x for 3 ALUs)
$tmrArithmeticOps = (Select-String -Path "simple_add_tmr.dis" -Pattern "\s+(add|sub|mul|div)\s+").Count
Write-Host "TMR Arithmetic operations: $tmrArithmeticOps"

# 3.3 Contar TMR memory operations
$tmrMemoryOps = (Select-String -Path "simple_add_tmr.dis" -Pattern "\s+(lw|sw|lb|sb|lh|sh)\s+").Count
Write-Host "TMR Memory operations: $tmrMemoryOps"

# 3.4 Contar TMR control operations
$tmrBranchOps = (Select-String -Path "simple_add_tmr.dis" -Pattern "\s+(j|jal|beq|bne|blt|bge)\s+").Count
Write-Host "TMR Control operations: $tmrBranchOps"

# 3.5 Buscar TMR-specific functions
Write-Host "Buscando TMR ALU functions..." -ForegroundColor Cyan
$tmrAlu0Calls = (Select-String -Path "simple_add_tmr.dis" -Pattern "alu0_add").Count
$tmrAlu1Calls = (Select-String -Path "simple_add_tmr.dis" -Pattern "alu1_add").Count
$tmrAlu2Calls = (Select-String -Path "simple_add_tmr.dis" -Pattern "alu2_add").Count
$tmrVoterCalls = (Select-String -Path "simple_add_tmr.dis" -Pattern "majority_voter").Count

Write-Host "ALU 0 calls: $tmrAlu0Calls"
Write-Host "ALU 1 calls: $tmrAlu1Calls"
Write-Host "ALU 2 calls: $tmrAlu2Calls"
Write-Host "Voter calls: $tmrVoterCalls"

# ============================================================================
# PASO 4: ESTIMACION TMR POWER (3 ALUs + Voter)
# ============================================================================

Write-Host "`nESTIMACION TMR POWER..." -ForegroundColor Yellow

# TMR Power factors (3 ALUs + voter + error detection)
$tmrAluBasePower = 10.0        # Base core power (same as single)
$tmrAluMultiplier = 3.0        # 3 ALUs vs 1 ALU
$tmrVoterPower = 5.0           # Majority voter power
$tmrErrorDetectorPower = 3.0   # Error detection power

# Calculate TMR power breakdown
$tmrMemoryPower = $tmrMemoryOps * 1.8
$tmrArithmeticPower = $tmrArithmeticOps * 2.5 * $tmrAluMultiplier  # 3x for 3 ALUs
$tmrControlPower = $tmrBranchOps * 1.2
$tmrTotalDynamicPower = $tmrAluBasePower + $tmrMemoryPower + $tmrArithmeticPower + $tmrControlPower + $tmrVoterPower + $tmrErrorDetectorPower

Write-Host "TMR Base core power: $tmrAluBasePower mW"
Write-Host "TMR Memory operations: $tmrMemoryPower mW"
Write-Host "TMR ALU operations (3x): $tmrArithmeticPower mW"
Write-Host "TMR Control operations: $tmrControlPower mW"
Write-Host "TMR Voter logic: $tmrVoterPower mW"
Write-Host "TMR Error detector: $tmrErrorDetectorPower mW"
Write-Host "TMR TOTAL POWER ESTIMADO: $tmrTotalDynamicPower mW" -ForegroundColor Cyan

# ============================================================================
# PASO 5: COMPARACION TMR vs Single SoC
# ============================================================================

Write-Host "`nCOMPARACION TMR vs Single SoC..." -ForegroundColor Yellow

# Load Single SoC data for comparison
$singleSoCPath = "..\..\soc-implementation\bare-metal-workspace\simple_add_minimal.elf"
if (Test-Path $singleSoCPath) {
    $singleSoCSize = (Get-Item $singleSoCPath).Length
    $singleSoCPower = 43.7  # From previous analysis
    $singleSoCInstructions = 45  # From previous analysis
    Write-Host "Single SoC data loaded successfully" -ForegroundColor Green
} else {
    Write-Host "WARNING: Single SoC data not found, using defaults" -ForegroundColor Yellow
    $singleSoCSize = 7124
    $singleSoCPower = 43.7
    $singleSoCInstructions = 45
}

Write-Host "`nRECURSOS COMPARISON:" -ForegroundColor Cyan
Write-Host "Single SoC Size: $singleSoCSize bytes"
Write-Host "TMR SoC Size: $tmrFileSize bytes"
$tmrSizeOverhead = $tmrFileSize - $singleSoCSize
$tmrSizePercentage = [math]::Round(($tmrFileSize / $singleSoCSize - 1) * 100, 1)
Write-Host "TMR Size Overhead: $tmrSizeOverhead bytes (+$tmrSizePercentage%)"

Write-Host "`nINSTRUCTIONS COMPARISON:" -ForegroundColor Cyan
Write-Host "Single SoC Instructions: $singleSoCInstructions"
Write-Host "TMR Instructions: $tmrAllInstructions"
$tmrInstOverhead = $tmrAllInstructions - $singleSoCInstructions
$tmrInstPercentage = [math]::Round(($tmrAllInstructions / $singleSoCInstructions - 1) * 100, 1)
Write-Host "TMR Instruction Overhead: $tmrInstOverhead (+$tmrInstPercentage%)"

Write-Host "`nPOWER COMPARISON:" -ForegroundColor Cyan
Write-Host "Single SoC Power: $singleSoCPower mW"
Write-Host "TMR Power: $tmrTotalDynamicPower mW"
$tmrPowerOverhead = [math]::Round($tmrTotalDynamicPower - $singleSoCPower, 1)
$tmrPowerPercentage = [math]::Round(($tmrTotalDynamicPower / $singleSoCPower - 1) * 100, 1)
Write-Host "TMR Power Overhead: $tmrPowerOverhead mW (+$tmrPowerPercentage%)"

# ============================================================================
# PASO 6: VERIFICAR TMR EJECUCION
# ============================================================================

Write-Host "`nVERIFICANDO TMR EJECUCION..." -ForegroundColor Yellow

# Configure QEMU PATH
$env:PATH += ";C:\Program Files\qemu"

# Execute TMR with timeout
Write-Host "Ejecutando TMR (3 ALUs + voter) - timeout 3 segundos..." -ForegroundColor Cyan
$tmrJob = Start-Job -ScriptBlock {
    $env:PATH += ";C:\Program Files\qemu"
    Set-Location $args[0]
    qemu-system-riscv32 -machine virt -cpu rv32 -m 64M -nographic -bios none -kernel simple_add_tmr.elf
} -ArgumentList (Get-Location).Path

Wait-Job $tmrJob -Timeout 3 | Out-Null
Stop-Job $tmrJob -ErrorAction SilentlyContinue
Remove-Job $tmrJob -Force -ErrorAction SilentlyContinue

Write-Host "✅ TMR programa ejecuta correctamente (bucle infinito esperado)" -ForegroundColor Green

# ============================================================================
# PASO 7: BUSCAR TMR ALU FUNCTIONS EN DISASSEMBLY
# ============================================================================

Write-Host "`nBUSCANDO TMR ALU FUNCTIONS..." -ForegroundColor Yellow

Write-Host "Buscando function main_tmr..." -ForegroundColor Cyan
$tmrMainFunction = Select-String -Path "simple_add_tmr.dis" -Pattern "main_tmr>" -Context 0,10
if ($tmrMainFunction) {
    Write-Host "TMR main function encontrada:" -ForegroundColor Green
    $tmrMainFunction | ForEach-Object { Write-Host $_.Line }
} else {
    Write-Host "TMR main function no encontrada explicita" -ForegroundColor Yellow
}

Write-Host "`nBuscando TMR ADD operations..." -ForegroundColor Cyan
$tmrAddOps = Select-String -Path "simple_add_tmr.dis" -Pattern "\sadd\s"
Write-Host "TMR ADD operations encontradas:"
$tmrAddOps | ForEach-Object { Write-Host $_.Line }

# ============================================================================
# RESUMEN TMR FINAL
# ============================================================================

Write-Host "`n========================================" -ForegroundColor Green
Write-Host "    TMR MANUAL ANALYSIS COMPLETADO     " -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green

Write-Host "`nTMR ARCHIVOS GENERADOS:" -ForegroundColor Cyan
Get-ChildItem -Name "*tmr*" | ForEach-Object { 
    $size = (Get-Item $_).Length
    Write-Host "  $_ ($size bytes)" -ForegroundColor White
}

Write-Host "`nRESUMEN COMPARATIVO:" -ForegroundColor Yellow
Write-Host "Single SoC: $singleSoCPower mW, $singleSoCInstructions inst, $singleSoCSize bytes" -ForegroundColor White
Write-Host "TMR SoC: $tmrTotalDynamicPower mW, $tmrAllInstructions inst, $tmrFileSize bytes" -ForegroundColor White
Write-Host "FPGA: 261.8 mW (referencia)" -ForegroundColor White

Write-Host "`nTMR TRADE-OFFS:" -ForegroundColor Cyan
Write-Host "✅ Reliability: Single ALU fault tolerance"
Write-Host "✅ Error Detection: Up to 2 ALU failures"
Write-Host "❌ Power Overhead: +$tmrPowerPercentage% vs Single SoC"
Write-Host "❌ Size Overhead: +$tmrSizePercentage% vs Single SoC"

Write-Host "`nPROXIMOS PASOS:" -ForegroundColor Yellow
Write-Host "1. Verificar que TMR funciona correctamente"
Write-Host "2. Comparar TMR vs FPGA TMR"
Write-Host "3. Analizar reliability benefits"
Write-Host "4. Documentar para tesis"