// majority_voter.sv - Votador por mayoría para 5 ALUs
// Implementa lógica de redundancia quíntuple modular (QMR - Quintuple Modular Redundancy)

module majority_voter #(
    parameter WIDTH = 64
)(
    input logic [WIDTH-1:0] alu1_result,
    input logic [WIDTH-1:0] alu2_result, 
    input logic [WIDTH-1:0] alu3_result,
    input logic [WIDTH-1:0] alu4_result,
    input logic [WIDTH-1:0] alu5_result,
    
    output logic [WIDTH-1:0] voted_result,
    
    // Señales de comparación individuales
    output logic alu1_alu2_match,
    output logic alu1_alu3_match,
    output logic alu1_alu4_match,
    output logic alu1_alu5_match,
    output logic alu2_alu3_match,
    output logic alu2_alu4_match,
    output logic alu2_alu5_match,
    output logic alu3_alu4_match,
    output logic alu3_alu5_match,
    output logic alu4_alu5_match,
    
    // Contadores de coincidencias para cada ALU
    output logic [2:0] alu1_vote_count,
    output logic [2:0] alu2_vote_count,
    output logic [2:0] alu3_vote_count,
    output logic [2:0] alu4_vote_count,
    output logic [2:0] alu5_vote_count,
    
    output logic [2:0] majority_status  // 000: no mayoría, 001-101: ALU ganadora
);

    // Comparaciones bit a bit entre todas las ALUs
    assign alu1_alu2_match = (alu1_result == alu2_result);
    assign alu1_alu3_match = (alu1_result == alu3_result);
    assign alu1_alu4_match = (alu1_result == alu4_result);
    assign alu1_alu5_match = (alu1_result == alu5_result);
    assign alu2_alu3_match = (alu2_result == alu3_result);
    assign alu2_alu4_match = (alu2_result == alu4_result);
    assign alu2_alu5_match = (alu2_result == alu5_result);
    assign alu3_alu4_match = (alu3_result == alu4_result);
    assign alu3_alu5_match = (alu3_result == alu5_result);
    assign alu4_alu5_match = (alu4_result == alu5_result);

    // Contar votos para cada ALU (cuántas ALUs coinciden con cada una)
    assign alu1_vote_count = {2'b0, alu1_alu2_match} + {2'b0, alu1_alu3_match} + 
                            {2'b0, alu1_alu4_match} + {2'b0, alu1_alu5_match} + 3'b001; // +1 por sí misma
    
    assign alu2_vote_count = {2'b0, alu1_alu2_match} + {2'b0, alu2_alu3_match} + 
                            {2'b0, alu2_alu4_match} + {2'b0, alu2_alu5_match} + 3'b001;
    
    assign alu3_vote_count = {2'b0, alu1_alu3_match} + {2'b0, alu2_alu3_match} + 
                            {2'b0, alu3_alu4_match} + {2'b0, alu3_alu5_match} + 3'b001;
    
    assign alu4_vote_count = {2'b0, alu1_alu4_match} + {2'b0, alu2_alu4_match} + 
                            {2'b0, alu3_alu4_match} + {2'b0, alu4_alu5_match} + 3'b001;
    
    assign alu5_vote_count = {2'b0, alu1_alu5_match} + {2'b0, alu2_alu5_match} + 
                            {2'b0, alu3_alu5_match} + {2'b0, alu4_alu5_match} + 3'b001;

    // Lógica de votación por mayoría (necesita al menos 3 votos de 5)
    always_comb begin
        if (alu1_vote_count >= 3) begin
            voted_result = alu1_result;
            majority_status = 3'b001;  // ALU1 ganadora
        end
        else if (alu2_vote_count >= 3) begin
            voted_result = alu2_result;
            majority_status = 3'b010;  // ALU2 ganadora
        end
        else if (alu3_vote_count >= 3) begin
            voted_result = alu3_result;
            majority_status = 3'b011;  // ALU3 ganadora
        end
        else if (alu4_vote_count >= 3) begin
            voted_result = alu4_result;
            majority_status = 3'b100;  // ALU4 ganadora
        end
        else if (alu5_vote_count >= 3) begin
            voted_result = alu5_result;
            majority_status = 3'b101;  // ALU5 ganadora
        end
        else begin
            // No hay mayoría (caso de error crítico)
            voted_result = alu1_result;  // Por defecto usar ALU1
            majority_status = 3'b000;   // No mayoría
        end
    end

endmodule