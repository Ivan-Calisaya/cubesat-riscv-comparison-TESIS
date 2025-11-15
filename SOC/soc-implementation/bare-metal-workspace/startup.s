# startup.s
# Bootloader mínimo para RISC-V bare-metal en QEMU virt machine
# Compatible con RV32IMA architecture

.section .text.init
.global _start

_start:
    # Disable interrupts initially
    csrw mie, zero
    csrw mip, zero
    
    # Setup stack pointer
    # QEMU virt machine: RAM starts at 0x80000000, 64MB size
    # Stack grows downward from top of RAM
    li sp, 0x84000000    # 0x80000000 + 64MB = stack top
    
    # Setup global pointer for optimized access to globals
    # Standard RISC-V convention
    .option push
    .option norelax
    la gp, __global_pointer$
    .option pop
    
    # Clear BSS section (uninitialized global variables)
    la t0, _bss_start
    la t1, _bss_end
    
clear_bss_loop:
    # Check if we've reached end of BSS
    bgeu t0, t1, clear_bss_done
    
    # Clear 4 bytes (word) at a time
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss_loop
    
clear_bss_done:
    # Setup trap vector (basic exception handling)
    la t0, trap_handler
    csrw mtvec, t0
    
    # Enable machine timer interrupt (if needed)
    # For this simple test, we'll keep interrupts disabled
    
    # Call main function (our simple_add program)
    call main
    
    # If main returns (shouldn't happen), halt the processor
halt:
    # Wait for interrupt (power saving)
    wfi
    # Infinite loop
    j halt

# Basic trap handler (for debugging)
trap_handler:
    # Save context (minimal for this test)
    addi sp, sp, -16
    sw ra, 12(sp)
    sw t0, 8(sp)
    sw t1, 4(sp)
    sw t2, 0(sp)
    
    # Read trap cause
    csrr t0, mcause
    csrr t1, mepc
    csrr t2, mtval
    
    # For this simple test, just infinite loop on trap
    # In real system, would handle different trap types
trap_loop:
    wfi
    j trap_loop
    
    # Restore context (never reached in this simple version)
    lw t2, 0(sp)
    lw t1, 4(sp)
    lw t0, 8(sp)
    lw ra, 12(sp)
    addi sp, sp, 16
    mret

# Data section (empty for this simple test)
.section .data

# BSS section (uninitialized data)
.section .bss