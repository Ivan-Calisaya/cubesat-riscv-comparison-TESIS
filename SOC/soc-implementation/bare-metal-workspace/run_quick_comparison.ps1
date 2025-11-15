# run_quick_comparison.ps1
# Script rápido para obtener solo las métricas esenciales

Write-Host "=== ANÁLISIS RÁPIDO SoC vs FPGA ===" -ForegroundColor Green

# Verificar archivos
if (!(Test-Path "simple_add_minimal.elf")) {
    Write-Host "ERROR: No se encuentra simple_add_minimal.elf" -ForegroundColor Red
    Write-Host "Ejecutar primero: run_complete_analysis.ps1" -ForegroundColor Yellow
    exit 1
}

$SIZE = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin\riscv-none-elf-size.exe"

Write-Host "`n📊 RECURSOS SoC:" -ForegroundColor Yellow
& $SIZE simple_add_minimal.elf

Write-Host "`n⚡ INSTRUCCIONES:" -ForegroundColor Yellow
if (Test-Path "simple_add_minimal.dis") {
    $instructions = (Select-String -Path "simple_add_minimal.dis" -Pattern "^\s*[0-9a-f]+:\s+[0-9a-f]+\s+").Count
    $addOps = (Select-String -Path "simple_add_minimal.dis" -Pattern "\s+add\s+").Count
    Write-Host "Total instrucciones: $instructions"
    Write-Host "Operaciones ADD: $addOps"
} else {
    Write-Host "Archivo .dis no encontrado"
}

Write-Host "`n📝 PARA COMPLETAR EN REPORTE:" -ForegroundColor Cyan
Write-Host "- FPGA Logic Elements: [Tu valor de Quartus]"
Write-Host "- FPGA Max Frequency: [Tu valor de Quartus] MHz"  
Write-Host "- FPGA Core Dynamic Power: [Tu valor de Quartus] mW"
Write-Host "- FPGA Total Thermal Power: [Tu valor de Quartus] mW"