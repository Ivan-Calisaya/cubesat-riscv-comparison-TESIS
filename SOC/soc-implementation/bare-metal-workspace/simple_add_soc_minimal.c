/*
 * simple_add_soc_minimal.c
 * IDENTICAL to FPGA implementation - NO UART, NO I/O
 * Pure ALU operation for valid FPGA vs SoC comparison
 * 
 * This version is EXACTLY the same as FPGA version
 * The only difference: SoC needs bootloader (startup.s)
 * But the core algorithm is 100% identical
 */

// NO includes needed - pure bare metal like FPGA
// NO UART - NO I/O - just like FPGA implementation

int main() {
    // IDENTICAL to FPGA implementation line by line
    // Usamos 'volatile' para asegurar que el compilador no optimice
    // las variables y genere instrucciones de carga y almacenamiento.
    volatile int a = 10;
    volatile int b = 20;
    volatile int result;

    result = a + b;

    // Bucle infinito al final para detener el procesador.
    // En hardware real, esto evita que ejecute basura.
    // En simulación, nos da un punto estable para verificar el resultado.
    while(1);

    return 0; // Esta línea nunca se alcanzará.
}

/*
 * ACADEMIC NOTE FOR THESIS:
 * 
 * This implementation is IDENTICAL to FPGA version:
 * - Same algorithm: result = a + b
 * - Same variables: volatile int a=10, b=20, result
 * - Same behavior: infinite loop at end
 * - Same complexity: O(1) ALU operation
 * 
 * DIFFERENCES from FPGA:
 * - Requires bootloader (startup.s) for SoC initialization
 * - Requires linker script (soc_link.ld) for memory layout
 * - Result verification: FPGA uses ModelSim waveforms, SoC uses memory inspection
 * 
 * COMPARISON VALIDITY:
 * This allows pure ALU performance comparison between:
 * - FPGA: Hardware ALU + registers
 * - SoC: Simulated RISC-V ALU + memory
 * 
 * Both execute identical instructions:
 * - LOAD a
 * - LOAD b  
 * - ADD a, b
 * - STORE result
 * - INFINITE LOOP
 */