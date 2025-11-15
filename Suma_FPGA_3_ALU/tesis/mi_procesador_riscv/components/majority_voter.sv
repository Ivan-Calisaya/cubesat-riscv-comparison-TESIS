// majority_voter.sv - Votador por mayoría para 3 ALUs
// Implementa lógica de redundancia triple modular (TMR)

module majority_voter #(
    parameter WIDTH = 64
)(
    input logic [WIDTH-1:0] alu1_result,
    input logic [WIDTH-1:0] alu2_result, 
    input logic [WIDTH-1:0] alu3_result,
    
    output logic [WIDTH-1:0] voted_result,
    output logic alu1_alu2_match,
    output logic alu1_alu3_match,
    output logic alu2_alu3_match,
    output logic [1:0] majority_status  // 00: no majority, 01: 1&2 match, 10: 1&3 match, 11: 2&3 match
);

    // Comparaciones bit a bit
    assign alu1_alu2_match = (alu1_result == alu2_result);
    assign alu1_alu3_match = (alu1_result == alu3_result);
    assign alu2_alu3_match = (alu2_result == alu3_result);

    // Lógica de votación por mayoría
    always_comb begin
        if (alu1_alu2_match && alu1_alu3_match) begin
            // Todas las ALUs coinciden (caso ideal)
            voted_result = alu1_result;
            majority_status = 2'b11;  // Todas coinciden
        end
        else if (alu1_alu2_match) begin
            // ALU1 y ALU2 coinciden
            voted_result = alu1_result;
            majority_status = 2'b01;
        end
        else if (alu1_alu3_match) begin
            // ALU1 y ALU3 coinciden
            voted_result = alu1_result;
            majority_status = 2'b10;
        end
        else if (alu2_alu3_match) begin
            // ALU2 y ALU3 coinciden
            voted_result = alu2_result;
            majority_status = 2'b11;
        end
        else begin
            // No hay mayoría (caso de error)
            voted_result = alu1_result;  // Por defecto usar ALU1
            majority_status = 2'b00;
        end
    end

endmodule