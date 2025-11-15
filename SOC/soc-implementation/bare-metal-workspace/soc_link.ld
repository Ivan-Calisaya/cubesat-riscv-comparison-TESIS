/* soc_link.ld */
/* Linker script para RISC-V SoC en QEMU virt machine */
/* Compatible con bare-metal implementation */

ENTRY(_start)

/* Memory layout para QEMU virt machine RISC-V */
MEMORY
{
    /* QEMU virt machine memory map:
     * RAM: 0x80000000 - 0x84000000 (64MB)
     * Boot ROM: 0x1000 - 0x12000 (but we use -bios none)
     * UART: 0x10000000 - 0x10000100
     */
    RAM : ORIGIN = 0x80000000, LENGTH = 64M
}

/* Define memory regions */
SECTIONS
{
    /* Start at RAM base address */
    . = 0x80000000;
    
    /* Text section: executable code */
    .text : {
        /* Startup code first */
        *(.text.init)
        /* Then all other code */
        *(.text)
        *(.text.*)
        
        /* Keep text section word-aligned */
        . = ALIGN(4);
    } > RAM
    
    /* Read-only data section */
    .rodata : {
        *(.rodata)
        *(.rodata.*)
        . = ALIGN(4);
    } > RAM
    
    /* Initialized data section */
    .data : {
        /* Mark start of data section */
        _data_start = .;
        *(.data)
        *(.data.*)
        . = ALIGN(4);
        _data_end = .;
    } > RAM
    
    /* Uninitialized data section (BSS) */
    .bss : {
        /* Mark BSS boundaries for startup.s */
        _bss_start = .;
        *(.bss)
        *(.bss.*)
        *(COMMON)
        . = ALIGN(4);
        _bss_end = .;
    } > RAM
    
    /* Stack grows downward from end of RAM */
    _stack_top = ORIGIN(RAM) + LENGTH(RAM);
    
    /* Global pointer for RISC-V optimized access */
    /* Points to middle of small data section */
    PROVIDE(__global_pointer$ = _bss_start + 0x800);
    
    /* Mark end of program for memory usage calculation */
    _heap_start = _bss_end;
    _heap_end = _stack_top;
    
    /* Debug sections (don't load into memory) */
    .debug_info 0 : { *(.debug_info) }
    .debug_abbrev 0 : { *(.debug_abbrev) }
    .debug_line 0 : { *(.debug_line) }
    .debug_frame 0 : { *(.debug_frame) }
    .debug_str 0 : { *(.debug_str) }
    .debug_ranges 0 : { *(.debug_ranges) }
    .debug_loc 0 : { *(.debug_loc) }
    
    /* Discard sections we don't need */
    /DISCARD/ : {
        *(.note.*)
        *(.comment)
        *(.eh_frame*)
    }
}

/* Provide symbols for memory usage reporting */
PROVIDE(_text_size = SIZEOF(.text));
PROVIDE(_data_size = SIZEOF(.data));
PROVIDE(_bss_size = SIZEOF(.bss));
PROVIDE(_total_ram_used = _bss_end - 0x80000000);
PROVIDE(_stack_size = _stack_top - _heap_end);