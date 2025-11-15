// tmr_alu.sv - Triple Modular Redundancy ALU con votador por mayoría
// Contiene 3 ALUs idénticas y un votador por mayoría

module tmr_alu #(parameter N=64) 
(
    input logic[N-1:0] a, b,
    input logic wArith,
    input logic[3:0] ALUControl,
    
    // Salidas originales (del votador)
    output logic zero, overflow, sign,
    output logic[N-1:0] result,
    
    // Salidas de cada ALU individual (para monitoreo)
    output logic[N-1:0] alu1_result, alu2_result, alu3_result,
    output logic alu1_zero, alu1_overflow, alu1_sign,
    output logic alu2_zero, alu2_overflow, alu2_sign,
    output logic alu3_zero, alu3_overflow, alu3_sign,
    
    // Salidas del votador por mayoría
    output logic alu1_alu2_match,
    output logic alu1_alu3_match, 
    output logic alu2_alu3_match,
    output logic [1:0] majority_status
);

    // Instancias de las 3 ALUs idénticas
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
    
    // Votador por mayoría para el resultado principal
    majority_voter #(N) result_voter (
        .alu1_result(alu1_result),
        .alu2_result(alu2_result),
        .alu3_result(alu3_result),
        .voted_result(result),
        .alu1_alu2_match(alu1_alu2_match),
        .alu1_alu3_match(alu1_alu3_match),
        .alu2_alu3_match(alu2_alu3_match),
        .majority_status(majority_status)
    );
    
    // Votadores para las señales de control (zero, overflow, sign)
    logic zero1_zero2_match, zero1_zero3_match, zero2_zero3_match;
    logic overflow1_overflow2_match, overflow1_overflow3_match, overflow2_overflow3_match;
    logic sign1_sign2_match, sign1_sign3_match, sign2_sign3_match;
    
    // Votación para zero
    assign zero1_zero2_match = (alu1_zero == alu2_zero);
    assign zero1_zero3_match = (alu1_zero == alu3_zero);
    assign zero2_zero3_match = (alu2_zero == alu3_zero);
    
    always_comb begin
        if (zero1_zero2_match)
            zero = alu1_zero;
        else if (zero1_zero3_match)
            zero = alu1_zero;
        else
            zero = alu2_zero;
    end
    
    // Votación para overflow
    assign overflow1_overflow2_match = (alu1_overflow == alu2_overflow);
    assign overflow1_overflow3_match = (alu1_overflow == alu3_overflow);
    assign overflow2_overflow3_match = (alu2_overflow == alu3_overflow);
    
    always_comb begin
        if (overflow1_overflow2_match)
            overflow = alu1_overflow;
        else if (overflow1_overflow3_match)
            overflow = alu1_overflow;
        else
            overflow = alu2_overflow;
    end
    
    // Votación para sign
    assign sign1_sign2_match = (alu1_sign == alu2_sign);
    assign sign1_sign3_match = (alu1_sign == alu3_sign);
    assign sign2_sign3_match = (alu2_sign == alu3_sign);
    
    always_comb begin
        if (sign1_sign2_match)
            sign = alu1_sign;
        else if (sign1_sign3_match)
            sign = alu1_sign;
        else
            sign = alu2_sign;
    end

endmodule