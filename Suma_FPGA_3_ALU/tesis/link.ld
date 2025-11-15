MEMORY
{
    rom : ORIGIN = 0x00000000, LENGTH = 0x1000
}

SECTIONS
{
    .text : {
        *(.text*)
        *(.rodata*)
    } > rom
    
    .data : {
        *(.data*)
        *(.bss*)
    } > rom
}