module dmem #(parameter N=64,M=32) 
            (input logic clk,reset,
            input logic[N-1:0] writeData,
            input logic[11:0] wordAddr,
            input logic readEnable,
            input logic writeEnable,
            input logic[2:0] memWidth,
            input logic[2:0] byteOffset,
            // input logic [M-1:0] IM_readData,
            // input logic dataSelect,
            output logic[N-1:0] readData);

    logic [N-1:0] DM_readData, readROMData, DM_writeData;
    logic [7:0] DM_writeMask;
    memWriteMask MEMWRITE_MASK(.select(byteOffset),
                               .memWidth(memWidth),
                               .DM_writeData(writeData),
                               .DM_writeData_M(DM_writeData),
                               .byteenable(DM_writeMask));
    
    // dmemip m9kmem(.clock(clk),
    //               .data(DM_writeData),
    //               .address(wordAddr),
    //               .rden(readEnable),
    //               .byteena(DM_writeMask),
    //               .wren(writeEnable),
    //               .q(DM_readData));

    // Memoria de datos sintética para simulación (reemplaza altsyncram)
    logic [63:0] ram [0:4095]; // 4096 palabras de 64 bits cada una
    
    // Lógica de lectura y escritura con soporte para byte enable y reset
    always_ff @(posedge clk) begin
        if (reset) begin
            // Durante reset, inicializar memoria
            for (int i = 0; i < 4096; i++) begin
                ram[i] <= 64'h0;
            end
        end else if (writeEnable) begin
            // Escribir solo los bytes habilitados usando máscara
            logic [63:0] write_data, write_mask;
            write_mask = 64'h0;
            write_data = ram[wordAddr]; // Leer valor actual
            
            // Aplicar máscara de bytes
            if (DM_writeMask[0]) begin
                write_data[7:0] = DM_writeData[7:0];
            end
            if (DM_writeMask[1]) begin
                write_data[15:8] = DM_writeData[15:8];
            end
            if (DM_writeMask[2]) begin
                write_data[23:16] = DM_writeData[23:16];
            end
            if (DM_writeMask[3]) begin
                write_data[31:24] = DM_writeData[31:24];
            end
            if (DM_writeMask[4]) begin
                write_data[39:32] = DM_writeData[39:32];
            end
            if (DM_writeMask[5]) begin
                write_data[47:40] = DM_writeData[47:40];
            end
            if (DM_writeMask[6]) begin
                write_data[55:48] = DM_writeData[55:48];
            end
            if (DM_writeMask[7]) begin
                write_data[63:56] = DM_writeData[63:56];
            end
            
            ram[wordAddr] <= write_data;
        end
    end
    
    // Lógica de lectura
    assign DM_readData = ram[wordAddr];

    // assign readROMData = {{(N-M){1'b0}}, IM_readData};
    // assign readData = dataSelect ? readROMData : DM_readData;
    // always @(posedge clk) begin
    // end
    assign readData = DM_readData;

endmodule