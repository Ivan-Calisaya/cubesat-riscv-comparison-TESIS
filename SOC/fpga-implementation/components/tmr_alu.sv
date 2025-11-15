// qmr_alu.sv - Quintuple Modular Redundancy ALU con votador por mayoría
// Contiene 5 ALUs idénticas y un votador por mayoría

module tmr_alu #(parameter N=64) 
(
    input logic[N-1:0] a, b,
    input logic wArith,
    input logic[3:0] ALUControl,
    
    // Salidas originales (del votador)
    output logic zero, overflow, sign,
    output logic[N-1:0] result,
    
    // Salidas de cada ALU individual (para monitoreo)
    output logic[N-1:0] alu1_result, alu2_result, alu3_result, alu4_result, alu5_result,
    output logic alu1_zero, alu1_overflow, alu1_sign,
    output logic alu2_zero, alu2_overflow, alu2_sign,
    output logic alu3_zero, alu3_overflow, alu3_sign,
    output logic alu4_zero, alu4_overflow, alu4_sign,
    output logic alu5_zero, alu5_overflow, alu5_sign,
    
    // Salidas del votador por mayoría (señales de comparación)
    output logic alu1_alu2_match, alu1_alu3_match, alu1_alu4_match, alu1_alu5_match,
    output logic alu2_alu3_match, alu2_alu4_match, alu2_alu5_match,
    output logic alu3_alu4_match, alu3_alu5_match, alu4_alu5_match,
    
    // Contadores de votos y estado de mayoría
    output logic [2:0] alu1_vote_count, alu2_vote_count, alu3_vote_count,
    output logic [2:0] alu4_vote_count, alu5_vote_count,
    output logic [2:0] majority_status
);

    // Instancias de las 5 ALUs idénticas
    alu #(N) alu1 (
        .a(a),
        .b(b),
        .wArith(wArith),
        .ALUControl(ALUControl),
        .zero(alu1_zero),
        .overflow(alu1_overflow),
        .sign(alu1_sign),
        .result(alu1_result)
    );
    
    alu #(N) alu2 (
        .a(a),
        .b(b),
        .wArith(wArith),
        .ALUControl(ALUControl),
        .zero(alu2_zero),
        .overflow(alu2_overflow),
        .sign(alu2_sign),
        .result(alu2_result)
    );
    
    alu #(N) alu3 (
        .a(a),
        .b(b),
        .wArith(wArith),
        .ALUControl(ALUControl),
        .zero(alu3_zero),
        .overflow(alu3_overflow),
        .sign(alu3_sign),
        .result(alu3_result)
    );
    
    alu #(N) alu4 (
        .a(a),
        .b(b),
        .wArith(wArith),
        .ALUControl(ALUControl),
        .zero(alu4_zero),
        .overflow(alu4_overflow),
        .sign(alu4_sign),
        .result(alu4_result)
    );
    
    alu #(N) alu5 (
        .a(a),
        .b(b),
        .wArith(wArith),
        .ALUControl(ALUControl),
        .zero(alu5_zero),
        .overflow(alu5_overflow),
        .sign(alu5_sign),
        .result(alu5_result)
    );
    
    // Votador por mayoría para el resultado principal
    majority_voter #(N) result_voter (
        .alu1_result(alu1_result),
        .alu2_result(alu2_result),
        .alu3_result(alu3_result),
        .alu4_result(alu4_result),
        .alu5_result(alu5_result),
        .voted_result(result),
        .alu1_alu2_match(alu1_alu2_match),
        .alu1_alu3_match(alu1_alu3_match),
        .alu1_alu4_match(alu1_alu4_match),
        .alu1_alu5_match(alu1_alu5_match),
        .alu2_alu3_match(alu2_alu3_match),
        .alu2_alu4_match(alu2_alu4_match),
        .alu2_alu5_match(alu2_alu5_match),
        .alu3_alu4_match(alu3_alu4_match),
        .alu3_alu5_match(alu3_alu5_match),
        .alu4_alu5_match(alu4_alu5_match),
        .alu1_vote_count(alu1_vote_count),
        .alu2_vote_count(alu2_vote_count),
        .alu3_vote_count(alu3_vote_count),
        .alu4_vote_count(alu4_vote_count),
        .alu5_vote_count(alu5_vote_count),
        .majority_status(majority_status)
    );
    
    // Votadores para las señales de control (zero, overflow, sign)
    logic [2:0] zero_vote_counts [4:0];
    logic [2:0] overflow_vote_counts [4:0];
    logic [2:0] sign_vote_counts [4:0];
    
    // Calcular votos para zero
    assign zero_vote_counts[0] = {2'b0, (alu1_zero == alu2_zero)} + {2'b0, (alu1_zero == alu3_zero)} + 
                                {2'b0, (alu1_zero == alu4_zero)} + {2'b0, (alu1_zero == alu5_zero)} + 3'b001;
    assign zero_vote_counts[1] = {2'b0, (alu2_zero == alu1_zero)} + {2'b0, (alu2_zero == alu3_zero)} + 
                                {2'b0, (alu2_zero == alu4_zero)} + {2'b0, (alu2_zero == alu5_zero)} + 3'b001;
    assign zero_vote_counts[2] = {2'b0, (alu3_zero == alu1_zero)} + {2'b0, (alu3_zero == alu2_zero)} + 
                                {2'b0, (alu3_zero == alu4_zero)} + {2'b0, (alu3_zero == alu5_zero)} + 3'b001;
    assign zero_vote_counts[3] = {2'b0, (alu4_zero == alu1_zero)} + {2'b0, (alu4_zero == alu2_zero)} + 
                                {2'b0, (alu4_zero == alu3_zero)} + {2'b0, (alu4_zero == alu5_zero)} + 3'b001;
    assign zero_vote_counts[4] = {2'b0, (alu5_zero == alu1_zero)} + {2'b0, (alu5_zero == alu2_zero)} + 
                                {2'b0, (alu5_zero == alu3_zero)} + {2'b0, (alu5_zero == alu4_zero)} + 3'b001;
    
    // Calcular votos para overflow
    assign overflow_vote_counts[0] = {2'b0, (alu1_overflow == alu2_overflow)} + {2'b0, (alu1_overflow == alu3_overflow)} + 
                                    {2'b0, (alu1_overflow == alu4_overflow)} + {2'b0, (alu1_overflow == alu5_overflow)} + 3'b001;
    assign overflow_vote_counts[1] = {2'b0, (alu2_overflow == alu1_overflow)} + {2'b0, (alu2_overflow == alu3_overflow)} + 
                                    {2'b0, (alu2_overflow == alu4_overflow)} + {2'b0, (alu2_overflow == alu5_overflow)} + 3'b001;
    assign overflow_vote_counts[2] = {2'b0, (alu3_overflow == alu1_overflow)} + {2'b0, (alu3_overflow == alu2_overflow)} + 
                                    {2'b0, (alu3_overflow == alu4_overflow)} + {2'b0, (alu3_overflow == alu5_overflow)} + 3'b001;
    assign overflow_vote_counts[3] = {2'b0, (alu4_overflow == alu1_overflow)} + {2'b0, (alu4_overflow == alu2_overflow)} + 
                                    {2'b0, (alu4_overflow == alu3_overflow)} + {2'b0, (alu4_overflow == alu5_overflow)} + 3'b001;
    assign overflow_vote_counts[4] = {2'b0, (alu5_overflow == alu1_overflow)} + {2'b0, (alu5_overflow == alu2_overflow)} + 
                                    {2'b0, (alu5_overflow == alu3_overflow)} + {2'b0, (alu5_overflow == alu4_overflow)} + 3'b001;
    
    // Calcular votos para sign
    assign sign_vote_counts[0] = {2'b0, (alu1_sign == alu2_sign)} + {2'b0, (alu1_sign == alu3_sign)} + 
                                {2'b0, (alu1_sign == alu4_sign)} + {2'b0, (alu1_sign == alu5_sign)} + 3'b001;
    assign sign_vote_counts[1] = {2'b0, (alu2_sign == alu1_sign)} + {2'b0, (alu2_sign == alu3_sign)} + 
                                {2'b0, (alu2_sign == alu4_sign)} + {2'b0, (alu2_sign == alu5_sign)} + 3'b001;
    assign sign_vote_counts[2] = {2'b0, (alu3_sign == alu1_sign)} + {2'b0, (alu3_sign == alu2_sign)} + 
                                {2'b0, (alu3_sign == alu4_sign)} + {2'b0, (alu3_sign == alu5_sign)} + 3'b001;
    assign sign_vote_counts[3] = {2'b0, (alu4_sign == alu1_sign)} + {2'b0, (alu4_sign == alu2_sign)} + 
                                {2'b0, (alu4_sign == alu3_sign)} + {2'b0, (alu4_sign == alu5_sign)} + 3'b001;
    assign sign_vote_counts[4] = {2'b0, (alu5_sign == alu1_sign)} + {2'b0, (alu5_sign == alu2_sign)} + 
                                {2'b0, (alu5_sign == alu3_sign)} + {2'b0, (alu5_sign == alu4_sign)} + 3'b001;
    
    // Seleccionar ganadores por mayoría para las señales de control
    always_comb begin
        // Votación para zero
        if (zero_vote_counts[0] >= 3) zero = alu1_zero;
        else if (zero_vote_counts[1] >= 3) zero = alu2_zero;
        else if (zero_vote_counts[2] >= 3) zero = alu3_zero;
        else if (zero_vote_counts[3] >= 3) zero = alu4_zero;
        else zero = alu5_zero;
        
        // Votación para overflow
        if (overflow_vote_counts[0] >= 3) overflow = alu1_overflow;
        else if (overflow_vote_counts[1] >= 3) overflow = alu2_overflow;
        else if (overflow_vote_counts[2] >= 3) overflow = alu3_overflow;
        else if (overflow_vote_counts[3] >= 3) overflow = alu4_overflow;
        else overflow = alu5_overflow;
        
        // Votación para sign
        if (sign_vote_counts[0] >= 3) sign = alu1_sign;
        else if (sign_vote_counts[1] >= 3) sign = alu2_sign;
        else if (sign_vote_counts[2] >= 3) sign = alu3_sign;
        else if (sign_vote_counts[3] >= 3) sign = alu4_sign;
        else sign = alu5_sign;
    end

endmodule