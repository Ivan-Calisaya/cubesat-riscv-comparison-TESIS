/* TMR RISC-V Linker Script
 * Memory layout for Triple Modular Redundancy system
 * Based on single SoC layout but with separate sections for each core
 */

MEMORY
{
    /* QEMU virt machine memory layout */
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64M
}

/* TMR Memory Organization:
 * 0x80000000 - 0x80010000 : Core 0 section (64KB)
 * 0x80010000 - 0x80020000 : Core 1 section (64KB)  
 * 0x80020000 - 0x80030000 : Core 2 section (64KB)
 * 0x80030000 - 0x80040000 : Shared TMR data (64KB)
 * 0x80040000 - 0x84000000 : Stack and heap space
 */

SECTIONS
{
    /* Entry point at beginning of RAM */
    .text : {
        KEEP(*(.text._start))
        *(.text*)
        *(.rodata*)
    } > RAM
    
    /* Core 0 Data Section */
    .data_core0 : ALIGN(4) {
        _data_core0_start = .;
        *(.data.core0*)
        _data_core0_end = .;
    } > RAM
    
    /* Core 1 Data Section */
    .data_core1 : ALIGN(4) {
        _data_core1_start = .;
        *(.data.core1*)
        _data_core1_end = .;
    } > RAM
    
    /* Core 2 Data Section */
    .data_core2 : ALIGN(4) {
        _data_core2_start = .;
        *(.data.core2*)
        _data_core2_end = .;
    } > RAM
    
    /* Shared TMR Data Section */
    .data_tmr_shared : ALIGN(4) {
        _data_tmr_shared_start = .;
        tmr_data = .;
        *(.data.tmr_shared*)
        *(.data*)
        _data_tmr_shared_end = .;
    } > RAM
    
    /* BSS Section (uninitialized data) */
    .bss : ALIGN(4) {
        _bss_start = .;
        
        /* Core 0 BSS */
        _bss_core0_start = .;
        *(.bss.core0*)
        _bss_core0_end = .;
        
        /* Core 1 BSS */
        _bss_core1_start = .;
        *(.bss.core1*)
        _bss_core1_end = .;
        
        /* Core 2 BSS */
        _bss_core2_start = .;
        *(.bss.core2*)
        _bss_core2_end = .;
        
        /* Shared BSS */
        _bss_shared_start = .;
        *(.bss*)
        *(COMMON)
        _bss_shared_end = .;
        
        _bss_end = .;
    } > RAM
    
    /* TMR Stack Organization */
    .stack : ALIGN(16) {
        _stack_start = .;
        
        /* Core 0 Stack (4KB) */
        _stack_core0_bottom = .;
        . = . + 0x1000;
        _stack_core0_top = .;
        
        /* Core 1 Stack (4KB) */
        _stack_core1_bottom = .;
        . = . + 0x1000;
        _stack_core1_top = .;
        
        /* Core 2 Stack (4KB) */
        _stack_core2_bottom = .;
        . = . + 0x1000;
        _stack_core2_top = .;
        
        /* Supervisor/Shared Stack (4KB) */
        _stack_supervisor_bottom = .;
        . = . + 0x1000;
        _stack_supervisor_top = .;
        
        _stack_top = .;
    } > RAM
    
    /* TMR Error Logging Section */
    .tmr_error_log : ALIGN(4) {
        _tmr_error_log_start = .;
        . = . + 0x1000;  /* 4KB for error logging */
        _tmr_error_log_end = .;
    } > RAM
    
    /* Heap space (remaining RAM) */
    .heap : ALIGN(4) {
        _heap_start = .;
        . = ORIGIN(RAM) + LENGTH(RAM) - 0x10000; /* Reserve 64KB at top */
        _heap_end = .;
    } > RAM
    
    /* Debug sections (not loaded) */
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_line 0 : { *(.debug_line) }
    .debug_str 0 : { *(.debug_str) }
    .debug_ranges 0 : { *(.debug_ranges) }
}

/* TMR Memory Map Summary:
 * 
 * Text/Code:        0x80000000 - 0x8000XXXX (shared, read-only)
 * Core 0 Data:      Isolated section  
 * Core 1 Data:      Isolated section
 * Core 2 Data:      Isolated section
 * Shared TMR Data:  Common voting results
 * Individual Stacks: 4KB per core + supervisor
 * Error Logging:    Centralized fault recording
 * Heap:            Remaining space for dynamic allocation
 * 
 * Benefits:
 * - Memory isolation between cores
 * - Shared voting area
 * - Fault containment
 * - Debugging support
 */