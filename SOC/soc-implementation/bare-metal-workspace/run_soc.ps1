# run_soc.ps1
# Execution script for RISC-V SoC bare-metal implementation in QEMU
# Runs the compiled program and captures output for analysis

param(
    [string]$Program = "simple_add_soc.elf",
    [string]$LogFile = "",
    [switch]$Debug,
    [switch]$Monitor,
    [switch]$Verbose,
    [int]$TimeoutSeconds = 10
)

Write-Host "=== RISC-V SoC Execution Script ===" -ForegroundColor Green

# Verify QEMU is available
try {
    $qemuVersion = qemu-system-riscv32 --version | Select-Object -First 1
    Write-Host "QEMU Version: $qemuVersion" -ForegroundColor Cyan
} catch {
    Write-Host "ERROR: QEMU not found. Please ensure QEMU is installed and in PATH." -ForegroundColor Red
    Write-Host "Run: qemu-system-riscv32 --version" -ForegroundColor Red
    exit 1
}

# Verify program file exists
if (!(Test-Path $Program)) {
    Write-Host "ERROR: Program file '$Program' not found" -ForegroundColor Red
    Write-Host "Please run .\build_soc.ps1 first to compile the program." -ForegroundColor Red
    exit 1
}

# Set default log file if not specified
if ($LogFile -eq "") {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $LogFile = "soc_execution_$timestamp.log"
}

Write-Host "Program: $Program" -ForegroundColor Cyan
Write-Host "Log: $LogFile" -ForegroundColor Cyan

# QEMU command configuration
$qemu_base_cmd = @(
    "qemu-system-riscv32",
    "-machine", "virt",
    "-cpu", "rv32",
    "-m", "64M",
    "-nographic",
    "-serial", "stdio",
    "-bios", "none",
    "-kernel", $Program
)

# Add debug options if requested
if ($Debug) {
    $qemu_base_cmd += @("-s", "-S")  # Wait for GDB connection
    Write-Host "Debug mode enabled. QEMU will wait for GDB connection on port 1234." -ForegroundColor Yellow
    Write-Host "Connect with: riscv-none-elf-gdb $Program" -ForegroundColor Yellow
    Write-Host "Then in GDB: target remote localhost:1234" -ForegroundColor Yellow
}

# Add monitor if requested
if ($Monitor) {
    $qemu_base_cmd += @("-monitor", "telnet:localhost:55555,server,nowait")
    Write-Host "Monitor enabled on telnet://localhost:55555" -ForegroundColor Yellow
}

Write-Host "`nQEMU Command: $($qemu_base_cmd -join ' ')" -ForegroundColor Gray

# Execution modes
if ($Debug) {
    Write-Host "`n=== Debug Mode ===" -ForegroundColor Yellow
    Write-Host "Starting QEMU in debug mode..." -ForegroundColor Yellow
    Write-Host "QEMU will wait for GDB connection." -ForegroundColor Yellow
    Write-Host "Press Ctrl+C to stop QEMU." -ForegroundColor Magenta
    
    # Run in debug mode (blocking)
    & $qemu_base_cmd[0] $qemu_base_cmd[1..($qemu_base_cmd.Length-1)]
    
} else {
    Write-Host "`n=== Normal Execution Mode ===" -ForegroundColor Yellow
    Write-Host "Starting SoC simulation..." -ForegroundColor Yellow
    Write-Host "Expected output: Simple addition test results" -ForegroundColor Yellow
    Write-Host "Timeout: $TimeoutSeconds seconds" -ForegroundColor Yellow
    Write-Host "Press Ctrl+A then X to exit QEMU manually" -ForegroundColor Magenta
    Write-Host "`n--- QEMU Output Start ---" -ForegroundColor Gray
    
    # Create a job for QEMU execution with timeout
    $job = Start-Job -ScriptBlock {
        param($qemu_cmd, $log_file)
        
        # Redirect both stdout and stderr to capture all output
        $process = Start-Process -FilePath $qemu_cmd[0] -ArgumentList $qemu_cmd[1..($qemu_cmd.Length-1)] -NoNewWindow -PassThru -RedirectStandardOutput $log_file -RedirectStandardError "${log_file}.err"
        
        # Wait for process to complete
        $process.WaitForExit()
        
        return @{
            ExitCode = $process.ExitCode
            Output = Get-Content $log_file -ErrorAction SilentlyContinue
            Errors = Get-Content "${log_file}.err" -ErrorAction SilentlyContinue
        }
    } -ArgumentList $qemu_base_cmd, $LogFile
    
    # Wait for job with timeout
    $jobResult = Wait-Job $job -Timeout $TimeoutSeconds
    
    if ($jobResult) {
        # Job completed within timeout
        $result = Receive-Job $job
        Remove-Job $job
        
        Write-Host "--- QEMU Output End ---" -ForegroundColor Gray
        
        # Display output
        if (Test-Path $LogFile) {
            $output = Get-Content $LogFile
            foreach ($line in $output) {
                Write-Host $line -ForegroundColor White
            }
        }
        
        # Display errors if any
        if (Test-Path "${LogFile}.err") {
            $errors = Get-Content "${LogFile}.err"
            if ($errors) {
                Write-Host "`nERRORS:" -ForegroundColor Red
                foreach ($line in $errors) {
                    Write-Host $line -ForegroundColor Red
                }
            }
        }
        
    } else {
        # Timeout occurred
        Write-Host "--- QEMU Timeout ($TimeoutSeconds seconds) ---" -ForegroundColor Yellow
        Stop-Job $job
        Remove-Job $job
        
        # Kill any remaining QEMU processes
        Get-Process -Name "qemu-system-riscv32" -ErrorAction SilentlyContinue | Stop-Process -Force
        
        Write-Host "QEMU execution timed out. This might be normal if the program entered an infinite loop." -ForegroundColor Yellow
        Write-Host "Check log file for any output: $LogFile" -ForegroundColor Cyan
        
        # Try to display any captured output
        if (Test-Path $LogFile) {
            $output = Get-Content $LogFile
            if ($output) {
                Write-Host "`nCaptured output:" -ForegroundColor Cyan
                foreach ($line in $output) {
                    Write-Host $line -ForegroundColor White
                }
            }
        }
    }
}

# Analysis and verification
Write-Host "`n=== Execution Analysis ===" -ForegroundColor Green

# Check if log file exists and analyze
if (Test-Path $LogFile) {
    $logContent = Get-Content $LogFile -ErrorAction SilentlyContinue
    
    if ($logContent) {
        Write-Host "Output captured to: $LogFile" -ForegroundColor Cyan
        Write-Host "Output lines: $($logContent.Count)" -ForegroundColor Cyan
        
        # Verify expected output
        $expectedResults = @("A = 10", "B = 20", "Result = 30", "TEST PASSED")
        $verificationResults = @()
        
        foreach ($expected in $expectedResults) {
            $found = $logContent | Where-Object { $_ -match [regex]::Escape($expected) }
            if ($found) {
                $verificationResults += "✅ Found: $expected"
                Write-Host "✅ Found: $expected" -ForegroundColor Green
            } else {
                $verificationResults += "❌ Missing: $expected"
                Write-Host "❌ Missing: $expected" -ForegroundColor Red
            }
        }
        
        # Overall result
        $passedChecks = ($verificationResults | Where-Object { $_ -like "✅*" }).Count
        $totalChecks = $expectedResults.Count
        
        Write-Host "`nVerification: $passedChecks/$totalChecks checks passed" -ForegroundColor Cyan
        
        if ($passedChecks -eq $totalChecks) {
            Write-Host "🎉 SoC TEST PASSED! All expected outputs found." -ForegroundColor Green
        } else {
            Write-Host "⚠️ SoC test incomplete. Check output for issues." -ForegroundColor Yellow
        }
        
    } else {
        Write-Host "⚠️ No output captured. Program may not have executed properly." -ForegroundColor Yellow
    }
} else {
    Write-Host "⚠️ Log file not created. Execution may have failed." -ForegroundColor Yellow
}

# Generate execution report
$executionTime = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$report = @"
# SoC Execution Report
Execution Time: $executionTime
Program: $Program
Log File: $LogFile
QEMU Version: $qemuVersion
Timeout: $TimeoutSeconds seconds
Debug Mode: $Debug
Monitor Mode: $Monitor

## Execution Command:
$($qemu_base_cmd -join ' ')

## Verification Results:
$($verificationResults -join "`n")

## Next Steps:
1. Compare results with FPGA implementation
2. Analyze performance metrics
3. Document differences for thesis

Status: $(if ($passedChecks -eq $totalChecks) { "SUCCESS ✅" } else { "INCOMPLETE ⚠️" })
"@

$report | Out-File -Encoding UTF8 "execution_report.txt"
Write-Host "`nExecution report saved to: execution_report.txt" -ForegroundColor Cyan

# Final summary
Write-Host "`n=== Summary ===" -ForegroundColor Green
Write-Host "SoC implementation execution completed." -ForegroundColor White
Write-Host "Core algorithm (result = a + b) executed on RISC-V SoC simulation." -ForegroundColor White
Write-Host "Results can now be compared with FPGA implementation metrics." -ForegroundColor Cyan

if ($Verbose) {
    Write-Host "`nFiles generated:" -ForegroundColor Yellow
    Get-ChildItem "*.log", "*report.txt", "*.err" -ErrorAction SilentlyContinue | ForEach-Object {
        Write-Host "  $($_.Name) ($($_.Length) bytes)" -ForegroundColor Gray
    }
}