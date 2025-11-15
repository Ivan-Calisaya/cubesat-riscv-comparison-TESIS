// top_level.sv - Módulo top para síntesis en Quartus
// Versión optimizada para EP4CE22F17C6N (Cyclone IV E)

module top_level (
    input  logic        clk,           // Clock de 50MHz 
    input  logic        reset_n,       // Reset negativo
    output logic [9:0]  led            // LEDs para debug
);

    // Señal de reset positivo para el procesador
    logic reset_pos;
    assign reset_pos = ~reset_n;
    
    // Señales para la memoria de datos externa
    logic [63:0] DM_readData;
    logic [63:0] DM_writeData, DM_addr;
    logic DM_writeEnable, DM_readEnable;
    
    // Señales del coprocessor (todas conectadas a constantes)
    logic [14:0] coprocessorIOAddr;
    logic [4:0] coprocessorIOControl;
    logic [63:0] coprocessorIODataOut;
    logic [63:0] coprocessorIODataIn;
    logic [1:0] coprocessorIODebugFlags;
    
    // Conectar coprocessor a valores fijos para evitar problemas
    assign coprocessorIODataOut = 64'h0;
    assign coprocessorIOAddr = 15'h0;
    assign coprocessorIOControl = 5'h0;
    assign coprocessorIODebugFlags = 2'h0;
    assign coprocessorIODataIn = 64'h0;
    
    // Memoria de datos simple (siempre devuelve 0)
    assign DM_readData = 64'h0;
    
    // Instancia del procesador RISC-V con parámetro reducido
    core #(.N(32)) cpu_core (  // <-- Cambio a 32-bit para reducir recursos
        .clk(clk),
        .reset(reset_pos),
        .DM_readData(DM_readData),
        .DM_writeData(DM_writeData),
        .DM_addr(DM_addr),
        .DM_writeEnable(DM_writeEnable),
        .DM_readEnable(DM_readEnable),
        .coprocessorIOAddr(coprocessorIOAddr),
        .coprocessorIOControl(coprocessorIOControl),
        .coprocessorIODataOut(coprocessorIODataOut),
        .coprocessorIODataIn(coprocessorIODataIn),
        .coprocessorIODebugFlags(coprocessorIODebugFlags)
    );
    
    // Debug: Mostrar actividad del procesador en LEDs
    assign led[0] = reset_pos;                    // LED0: Reset status
    assign led[1] = DM_writeEnable;               // LED1: Memory write activity
    assign led[2] = DM_readEnable;                // LED2: Memory read activity
    assign led[9:3] = DM_addr[6:0];               // LED3-9: Lower bits of memory address
    
endmodule