# TMR RISC-V Bootloader (CORRECTED)
# Single core with 3 ALUs + Hardware Voter
# IDENTICAL to Single SoC bootloader (same core, different ALU)

.section .text
.global _start

_start:
    # Setup stack pointer (single core)
    la sp, _stack_top
    
    # Clear BSS section
    la t0, _bss_start
    la t1, _bss_end
clear_bss:
    beq t0, t1, bss_done
    sw zero, 0(t0)
    addi t0, t0, 4
    j clear_bss
bss_done:

    # Setup CSR registers (single core)
    li t0, 0x1800          # Machine mode
    csrw mstatus, t0
    
    # Setup trap handler
    la t0, trap_handler
    csrw mtvec, t0
    
    # Jump to TMR main function
    call main_tmr
    
    # Infinite loop if main returns
hang:
    j hang

# Trap handler (same as single SoC)
trap_handler:
    # Save context
    addi sp, sp, -32
    sw ra, 0(sp)
    sw t0, 4(sp)
    sw t1, 8(sp)
    sw t2, 12(sp)
    sw a0, 16(sp)
    sw a1, 20(sp)
    
    # Handle exceptions (TMR error handling could be added here)
    csrr t0, mcause
    csrr t1, mepc
    
    # Restore context
    lw ra, 0(sp)
    lw t0, 4(sp)
    lw t1, 8(sp)
    lw t2, 12(sp)
    lw a0, 16(sp)
    lw a1, 20(sp)
    addi sp, sp, 32
    
    mret

# Memory sections
.section .data
tmr_status: .word 0           # TMR system status

.section .bss
.align 4
_bss_start:
    .space 1024               # BSS space
_bss_end:

.align 4
_stack_bottom:
    .space 4096               # Single core stack (4KB)
_stack_top: