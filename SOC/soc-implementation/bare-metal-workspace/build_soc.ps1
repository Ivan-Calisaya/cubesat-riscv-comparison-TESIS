# build_soc.ps1
# Build script for RISC-V SoC bare-metal implementation
# Compiles startup.s, simple_add_soc.c and links with soc_link.ld

param(
    [switch]$Clean,
    [switch]$Verbose,
    [string]$Target = "simple_add_soc"
)

# Configuration
$TOOLCHAIN_PATH = "C:\Users\Usuario\Desktop\Ivan\tesis\xpack-riscv-none-elf-gcc-14.2.0-3\bin"
$GCC = "$TOOLCHAIN_PATH\riscv-none-elf-gcc.exe"
$OBJDUMP = "$TOOLCHAIN_PATH\riscv-none-elf-objdump.exe"
$OBJCOPY = "$TOOLCHAIN_PATH\riscv-none-elf-objcopy.exe"
$SIZE = "$TOOLCHAIN_PATH\riscv-none-elf-size.exe"

# Compiler flags for RV32IMA + Zicsr (32-bit RISC-V with CSR support)
$ARCH_FLAGS = "-march=rv32ima_zicsr", "-mabi=ilp32"
$COMPILE_FLAGS = "-O2", "-g", "-Wall", "-Wextra"
$LINK_FLAGS = "-nostartfiles", "-nostdlib", "-static"

Write-Host "=== RISC-V SoC Build Script ===" -ForegroundColor Green
Write-Host "Target: $Target" -ForegroundColor Cyan
Write-Host "Toolchain: $TOOLCHAIN_PATH" -ForegroundColor Gray

# Check if toolchain exists
if (!(Test-Path $GCC)) {
    Write-Host "ERROR: RISC-V toolchain not found at: $TOOLCHAIN_PATH" -ForegroundColor Red
    Write-Host "Please verify the toolchain installation path." -ForegroundColor Red
    exit 1
}

# Clean previous build if requested
if ($Clean) {
    Write-Host "`nCleaning previous build..." -ForegroundColor Yellow
    Remove-Item -Path "*.o", "*.elf", "*.bin", "*.hex", "*.dis", "*.map" -ErrorAction SilentlyContinue
    Write-Host "Clean completed." -ForegroundColor Green
    if ($Target -eq "clean") { exit 0 }
}

# Create build timestamp
$BuildTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "`nBuild started: $BuildTime" -ForegroundColor Cyan

try {
    # Step 1: Compile startup assembly
    Write-Host "`n[1/5] Compiling startup.s..." -ForegroundColor Yellow
    $cmd = @($GCC) + $ARCH_FLAGS + $COMPILE_FLAGS + @("-c", "startup.s", "-o", "startup.o")
    if ($Verbose) { Write-Host "Command: $($cmd -join ' ')" -ForegroundColor Gray }
    
    & $GCC @ARCH_FLAGS @COMPILE_FLAGS -c startup.s -o startup.o
    if ($LASTEXITCODE -ne 0) { throw "Failed to compile startup.s" }
    Write-Host "✅ startup.o created" -ForegroundColor Green

    # Step 2: Compile main C program
    Write-Host "`n[2/5] Compiling simple_add_soc.c..." -ForegroundColor Yellow
    $cmd = @($GCC) + $ARCH_FLAGS + $COMPILE_FLAGS + @("-c", "simple_add_soc.c", "-o", "simple_add_soc.o")
    if ($Verbose) { Write-Host "Command: $($cmd -join ' ')" -ForegroundColor Gray }
    
    & $GCC @ARCH_FLAGS @COMPILE_FLAGS -c simple_add_soc.c -o simple_add_soc.o
    if ($LASTEXITCODE -ne 0) { throw "Failed to compile simple_add_soc.c" }
    Write-Host "✅ simple_add_soc.o created" -ForegroundColor Green

    # Step 3: Link executable
    Write-Host "`n[3/5] Linking executable..." -ForegroundColor Yellow
    $cmd = @($GCC) + $ARCH_FLAGS + $LINK_FLAGS + @("-T", "soc_link.ld", "-Wl,-Map,$Target.map", "-o", "$Target.elf", "startup.o", "simple_add_soc.o")
    if ($Verbose) { Write-Host "Command: $($cmd -join ' ')" -ForegroundColor Gray }
    
    & $GCC @ARCH_FLAGS @LINK_FLAGS -T soc_link.ld "-Wl,-Map,$Target.map" -o "$Target.elf" startup.o simple_add_soc.o
    if ($LASTEXITCODE -ne 0) { throw "Failed to link executable" }
    Write-Host "✅ $Target.elf created" -ForegroundColor Green

    # Step 4: Generate binary and hex files
    Write-Host "`n[4/5] Generating binary files..." -ForegroundColor Yellow
    
    # Generate raw binary
    & $OBJCOPY -O binary "$Target.elf" "$Target.bin"
    if ($LASTEXITCODE -ne 0) { throw "Failed to generate binary" }
    Write-Host "✅ $Target.bin created" -ForegroundColor Green
    
    # Generate Intel HEX format
    & $OBJCOPY -O ihex "$Target.elf" "$Target.hex"
    if ($LASTEXITCODE -ne 0) { throw "Failed to generate hex file" }
    Write-Host "✅ $Target.hex created" -ForegroundColor Green

    # Step 5: Generate disassembly and analysis files
    Write-Host "`n[5/5] Generating analysis files..." -ForegroundColor Yellow
    
    # Disassembly for analysis
    & $OBJDUMP -d "$Target.elf" | Out-File -Encoding UTF8 "$Target.dis"
    if ($LASTEXITCODE -ne 0) { throw "Failed to generate disassembly" }
    Write-Host "✅ $Target.dis created" -ForegroundColor Green
    
    # Size information
    & $SIZE "$Target.elf" | Out-File -Encoding UTF8 "$Target.size"
    Write-Host "✅ $Target.size created" -ForegroundColor Green
    
    # Memory map summary
    & $OBJDUMP -h "$Target.elf" | Out-File -Encoding UTF8 "$Target.sections"
    Write-Host "✅ $Target.sections created" -ForegroundColor Green

    # Build summary
    Write-Host "`n=== Build Summary ===" -ForegroundColor Green
    
    # File sizes
    $files = @("$Target.elf", "$Target.bin", "$Target.hex")
    foreach ($file in $files) {
        if (Test-Path $file) {
            $size = (Get-Item $file).Length
            Write-Host "$file`: $size bytes" -ForegroundColor Cyan
        }
    }
    
    # Memory usage (from size command)
    Write-Host "`nMemory Usage:" -ForegroundColor Yellow
    & $SIZE "$Target.elf"
    
    # Quick verification
    Write-Host "`nQuick Verification:" -ForegroundColor Yellow
    $elfInfo = & $OBJDUMP -f "$Target.elf" | Select-String "start address"
    Write-Host "$elfInfo" -ForegroundColor Cyan
    
    $BuildEndTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Host "`nBuild completed successfully: $BuildEndTime" -ForegroundColor Green
    Write-Host "Ready for QEMU execution!" -ForegroundColor Cyan
    
    # Generate build report
    $BuildReport = @"
# Build Report - RISC-V SoC Implementation
Build Time: $BuildTime - $BuildEndTime
Target: $Target
Toolchain: riscv-none-elf-gcc (from xpack)
Architecture: RV32IMA (32-bit with Integer, Multiply, Atomic)
ABI: ilp32

## Files Generated:
- $Target.elf (executable)
- $Target.bin (raw binary)  
- $Target.hex (Intel HEX)
- $Target.dis (disassembly)
- $Target.map (memory map)
- $Target.size (size analysis)
- $Target.sections (section info)

## Memory Layout:
$(& $SIZE "$Target.elf" | Out-String)

## Entry Point:
$($elfInfo | Out-String)

## Next Steps:
1. Run with: .\run_soc.ps1
2. Verify output matches expected: "A=10, B=20, Result=30"
3. Compare performance with FPGA implementation

Build Status: SUCCESS ✅
"@
    
    $BuildReport | Out-File -Encoding UTF8 "build_report.txt"
    Write-Host "`nBuild report saved to: build_report.txt" -ForegroundColor Cyan

} catch {
    Write-Host "`nBUILD FAILED: $($_.Exception.Message)" -ForegroundColor Red
    Write-Host "Check the error messages above for details." -ForegroundColor Red
    exit 1
}

# Final check
if (Test-Path "$Target.elf") {
    Write-Host "`n🎉 BUILD SUCCESS! Ready to run on QEMU." -ForegroundColor Green
    Write-Host "Next: .\run_soc.ps1 -Program $Target.elf" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ BUILD FAILED: $Target.elf not found" -ForegroundColor Red
    exit 1
}