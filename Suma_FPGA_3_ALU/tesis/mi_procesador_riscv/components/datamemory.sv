module datamemory #(parameter N=64,M=32) 
(
    input  logic clk,
    input  logic reset,
    input  logic [N-1:0] writeData,
    input  logic [11:0] wordAddr,
    input  logic readEnable,
    input  logic writeEnable,
    input  logic [2:0] memWidth,
    input  logic [2:0] byteOffset,
    output logic [N-1:0] readData
);

    // Señales internas
    logic [N-1:0] DM_writeData;
    logic [7:0]   DM_writeMask;
    logic [N-1:0] DM_readData;

    // Generar máscara de escritura
    memWriteMask MEMWRITE_MASK(
        .select(byteOffset),
        .memWidth(memWidth),
        .DM_writeData(writeData),
        .DM_writeData_M(DM_writeData),
        .byteenable(DM_writeMask)
    );

    // Instanciación del IP generado con el Megawizard
    dmem u_dmem (
        .address (wordAddr),
        .byteena (DM_writeMask),
        .clock   (clk),
        .data    (DM_writeData),
        .wren    (writeEnable),
        .q       (DM_readData)
    );

    // La lectura en la IP siempre está habilitada (rden no existe en este core)
    assign readData = DM_readData;

endmodule
