module execute #(
    parameter N = 64
) (
    input logic [N-1: 0] PC_E, readData1_E, readData2_E, signImm_E,
    input logic [N-1: 0] CSRRead_E,
    input logic AluSrc, regSel1, wArith, aluSelect,
    input logic[3:0] AluControl,
    output logic [N-1: 0] writeData_E, aluResult_E, PCBranch_E, PC4_E,
    output logic [N-1: 0] result1_Atom,
    output logic zero_E, overflow_E, sign_E,
    
    // Nuevas salidas para monitoreo de TMR
    output logic [N-1: 0] alu1_result, alu2_result, alu3_result,
    output logic alu1_zero, alu1_overflow, alu1_sign,
    output logic alu2_zero, alu2_overflow, alu2_sign,
    output logic alu3_zero, alu3_overflow, alu3_sign,
    output logic alu1_alu2_match, alu1_alu3_match, alu2_alu3_match,
    output logic [1:0] majority_status
);
    logic[N-1: 0] readData1, readData2, signedImm_PC, aluResult;
    logic[N-1: 0] aluResultNormal, aluResultAtomic;

    // TMR ALU (Triple Modular Redundancy) con votador por mayoría
    tmr_alu #(N) alu_tmr(
        .a(wArith ? {{32'b0}, readData1[31:0]} : readData1), 
        .b(wArith ? {{32'b0}, readData2[31:0]} : readData2),
        .ALUControl(AluControl),
        .wArith(wArith),
        // Salidas principales (votadas)
        .zero(zero_E),
        .overflow(overflow_E),
        .sign(sign_E),
        .result(aluResult),
        // Salidas individuales de cada ALU
        .alu1_result(alu1_result),
        .alu2_result(alu2_result), 
        .alu3_result(alu3_result),
        .alu1_zero(alu1_zero),
        .alu1_overflow(alu1_overflow),
        .alu1_sign(alu1_sign),
        .alu2_zero(alu2_zero),
        .alu2_overflow(alu2_overflow),
        .alu2_sign(alu2_sign),
        .alu3_zero(alu3_zero),
        .alu3_overflow(alu3_overflow),
        .alu3_sign(alu3_sign),
        // Señales del votador
        .alu1_alu2_match(alu1_alu2_match),
        .alu1_alu3_match(alu1_alu3_match),
        .alu2_alu3_match(alu2_alu3_match),
        .majority_status(majority_status)
    );
    
    atom_alu aluA(.a(AluSrc ? signImm_E : readData1_E),
                  .b(CSRRead_E),
                  .ALUControl(AluControl),
                  .result0(aluResultAtomic),
                  .result1(result1_Atom));

    assign aluResultNormal = wArith ? 
                            {{32{aluResult[31]}}, aluResult[(N/2)-1:0]} :
                            aluResult;
    assign aluResult_E = aluSelect ? aluResultAtomic : aluResultNormal;
    
    assign writeData_E = readData2_E;
    assign readData1 = regSel1 ? PC_E : readData1_E;
    assign readData2 = AluSrc ? signImm_E : readData2_E;
    assign signedImm_PC = (signImm_E << 1);
    assign PCBranch_E  = AluSrc ? {signImm_E[N-1:1],1'b0} : signedImm_PC + PC_E;
    assign PC4_E = PC_E + 'h4;
    
endmodule