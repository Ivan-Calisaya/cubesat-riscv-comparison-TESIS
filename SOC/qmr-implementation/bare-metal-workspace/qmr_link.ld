/* QMR RISC-V Linker Script
 * Memory layout for Quintuple Modular Redundancy system
 * Based on TMR layout but with separate sections for 5 ALUs
 */

MEMORY
{
    /* QEMU virt machine memory layout */
    RAM (rwx) : ORIGIN = 0x80000000, LENGTH = 64M
}

/* QMR Memory Organization:
 * 0x80000000 - 0x80010000 : ALU 0 section (64KB)
 * 0x80010000 - 0x80020000 : ALU 1 section (64KB)  
 * 0x80020000 - 0x80030000 : ALU 2 section (64KB)
 * 0x80030000 - 0x80040000 : ALU 3 section (64KB)
 * 0x80040000 - 0x80050000 : ALU 4 section (64KB)
 * 0x80050000 - 0x80060000 : Shared QMR data (64KB)
 * 0x80060000 - 0x80070000 : 3-of-5 Voter section (64KB)
 * 0x80070000 - 0x84000000 : Stack and heap space
 */

SECTIONS
{
    /* Entry point at beginning of RAM */
    .text : {
        KEEP(*(.text._start))
        *(.text*)
        *(.rodata*)
    } > RAM
    
    /* ALU 0 Data Section */
    .data_alu0 : ALIGN(4) {
        _data_alu0_start = .;
        *(.data.alu0*)
        _data_alu0_end = .;
    } > RAM
    
    /* ALU 1 Data Section */
    .data_alu1 : ALIGN(4) {
        _data_alu1_start = .;
        *(.data.alu1*)
        _data_alu1_end = .;
    } > RAM
    
    /* ALU 2 Data Section */
    .data_alu2 : ALIGN(4) {
        _data_alu2_start = .;
        *(.data.alu2*)
        _data_alu2_end = .;
    } > RAM
    
    /* ALU 3 Data Section */
    .data_alu3 : ALIGN(4) {
        _data_alu3_start = .;
        *(.data.alu3*)
        _data_alu3_end = .;
    } > RAM
    
    /* ALU 4 Data Section */
    .data_alu4 : ALIGN(4) {
        _data_alu4_start = .;
        *(.data.alu4*)
        _data_alu4_end = .;
    } > RAM
    
    /* Shared QMR Data Section */
    .data_qmr_shared : ALIGN(4) {
        _data_qmr_shared_start = .;
        qmr_alu = .;
        *(.data.qmr_shared*)
        *(.data*)
        _data_qmr_shared_end = .;
    } > RAM
    
    /* 3-of-5 Voter Data Section */
    .data_voter : ALIGN(4) {
        _data_voter_start = .;
        *(.data.voter*)
        _data_voter_end = .;
    } > RAM
    
    /* BSS Section (uninitialized data) */
    .bss : ALIGN(4) {
        _bss_start = .;
        
        /* ALU 0 BSS */
        _bss_alu0_start = .;
        *(.bss.alu0*)
        _bss_alu0_end = .;
        
        /* ALU 1 BSS */
        _bss_alu1_start = .;
        *(.bss.alu1*)
        _bss_alu1_end = .;
        
        /* ALU 2 BSS */
        _bss_alu2_start = .;
        *(.bss.alu2*)
        _bss_alu2_end = .;
        
        /* ALU 3 BSS */
        _bss_alu3_start = .;
        *(.bss.alu3*)
        _bss_alu3_end = .;
        
        /* ALU 4 BSS */
        _bss_alu4_start = .;
        *(.bss.alu4*)
        _bss_alu4_end = .;
        
        /* Voter BSS */
        _bss_voter_start = .;
        *(.bss.voter*)
        _bss_voter_end = .;
        
        /* Shared BSS */
        _bss_shared_start = .;
        *(.bss*)
        *(COMMON)
        _bss_shared_end = .;
        
        _bss_end = .;
    } > RAM
    
    /* QMR Stack Organization */
    .stack : ALIGN(16) {
        _stack_start = .;
        
        /* Main Stack (8KB) */
        _stack_main_bottom = .;
        . = . + 0x2000;
        _stack_main_top = .;
        
        /* ALU Context Stacks (1KB each) */
        _stack_alu0_bottom = .;
        . = . + 0x400;
        _stack_alu0_top = .;
        
        _stack_alu1_bottom = .;
        . = . + 0x400;
        _stack_alu1_top = .;
        
        _stack_alu2_bottom = .;
        . = . + 0x400;
        _stack_alu2_top = .;
        
        _stack_alu3_bottom = .;
        . = . + 0x400;
        _stack_alu3_top = .;
        
        _stack_alu4_bottom = .;
        . = . + 0x400;
        _stack_alu4_top = .;
        
        /* Voter Stack (2KB) */
        _stack_voter_bottom = .;
        . = . + 0x800;
        _stack_voter_top = .;
        
        _stack_top = .;
    } > RAM
    
    /* QMR Error Logging Section */
    .qmr_error_log : ALIGN(4) {
        _qmr_error_log_start = .;
        . = . + 0x2000;  /* 8KB for comprehensive error logging */
        _qmr_error_log_end = .;
    } > RAM
    
    /* QMR Fault Analysis Section */
    .qmr_fault_analysis : ALIGN(4) {
        _qmr_fault_analysis_start = .;
        . = . + 0x1000;  /* 4KB for fault pattern analysis */
        _qmr_fault_analysis_end = .;
    } > RAM
    
    /* Heap space (remaining RAM) */
    .heap : ALIGN(4) {
        _heap_start = .;
        . = ORIGIN(RAM) + LENGTH(RAM) - 0x20000; /* Reserve 128KB at top */
        _heap_end = .;
    } > RAM
    
    /* Debug sections (not loaded) */
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_line 0 : { *(.debug_line) }
    .debug_str 0 : { *(.debug_str) }
    .debug_ranges 0 : { *(.debug_ranges) }
}

/* QMR Memory Map Summary:
 * 
 * Text/Code:        0x80000000 - 0x8000XXXX (shared, read-only)
 * ALU 0-4 Data:     Individual isolated sections  
 * Shared QMR Data:  Common voting results and coordination
 * Voter Data:       3-of-5 logic specific data
 * Individual Stacks: Contexts for each ALU + voter + main
 * Error Logging:    Comprehensive fault recording (8KB)
 * Fault Analysis:   Pattern analysis for 2-fault scenarios (4KB)
 * Heap:            Remaining space for dynamic allocation
 * 
 * Benefits:
 * - Memory isolation between ALUs
 * - Shared voting and coordination area
 * - Enhanced fault containment (5-way)
 * - Comprehensive debugging support
 * - 3-of-5 voter dedicated space
 * - Fault pattern analysis capability
 */