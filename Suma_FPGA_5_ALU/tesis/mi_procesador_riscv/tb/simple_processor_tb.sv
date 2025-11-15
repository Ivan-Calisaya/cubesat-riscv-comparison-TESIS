// simple_processor_tb.sv: Testbench para el procesador RISC-V siguiendo el instructivo

`timescale 1ns/1ps

module simple_processor_tb;

    // 1. Señales para conectar al DUT (Device Under Test)
    logic clk;
    logic reset;
    
    // Señales para la memoria de datos (requeridas por el core)
    logic [63:0] DM_readData;
    logic [63:0] DM_writeData, DM_addr;
    logic DM_writeEnable, DM_readEnable;
    
    // Señales del coprocessor (requeridas por el core)
    logic [14:0] coprocessorIOAddr;
    logic [4:0] coprocessorIOControl;
    logic [63:0] coprocessorIODataOut;
    logic [63:0] coprocessorIODataIn;
    logic [1:0] coprocessorIODebugFlags;

    // Instancia del procesador (DUT)
    // Usamos el módulo 'core' del repositorio pfr-v
    core #(64) dut (
       .clk(clk),
       .reset(reset),
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

    // Simulación simple de la memoria de datos
    assign DM_readData = 64'h0; // No usaremos memoria de datos en este test simple
    
    // Simulación del coprocessor (no usado en este test)
    assign coprocessorIODataOut = 64'h0;
    assign coprocessorIOAddr = 15'h0;
    assign coprocessorIOControl = 5'h0;

    // 2. Generador de Reloj
    // Genera un pulso de reloj cada 10ns (frecuencia de 100MHz)
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Variables para capturar los valores de las 5 ALUs y el votador en el momento correcto
    logic [63:0] captured_alu1_result, captured_alu2_result, captured_alu3_result;
    logic [63:0] captured_alu4_result, captured_alu5_result;
    logic [63:0] captured_voted_result;
    logic captured_alu1_alu2_match, captured_alu1_alu3_match, captured_alu1_alu4_match, captured_alu1_alu5_match;
    logic captured_alu2_alu3_match, captured_alu2_alu4_match, captured_alu2_alu5_match;
    logic captured_alu3_alu4_match, captured_alu3_alu5_match, captured_alu4_alu5_match;
    logic [2:0] captured_alu1_vote_count, captured_alu2_vote_count, captured_alu3_vote_count;
    logic [2:0] captured_alu4_vote_count, captured_alu5_vote_count;
    logic [2:0] captured_majority_status;
    logic captured = 0;

    // 3. Secuencia de Estímulos (Reset y Carga de Programa)
    initial begin
        $display("Iniciando simulación del procesador RISC-V");
        $display("Cargando programa simple_add.c...");
        
        // El programa se carga automáticamente en imem.sv desde imem_init.txt
        
        // Aplicar pulso de reset al inicio
        reset = 1;
        $display("Reset activado");
        #20; // Mantener el reset por 2 ciclos de reloj
        reset = 0;
        $display("Reset desactivado - comenzando ejecución");

        // Esperar al momento de la suma (120ns) y capturar valores de QMR (5 ALUs)
        #100;
        captured_alu1_result = dut.dp.EXECUTE.alu1_result;
        captured_alu2_result = dut.dp.EXECUTE.alu2_result;
        captured_alu3_result = dut.dp.EXECUTE.alu3_result;
        captured_alu4_result = dut.dp.EXECUTE.alu4_result;
        captured_alu5_result = dut.dp.EXECUTE.alu5_result;
        captured_voted_result = dut.dp.EXECUTE.aluResult_E;
        captured_alu1_alu2_match = dut.dp.EXECUTE.alu1_alu2_match;
        captured_alu1_alu3_match = dut.dp.EXECUTE.alu1_alu3_match;
        captured_alu1_alu4_match = dut.dp.EXECUTE.alu1_alu4_match;
        captured_alu1_alu5_match = dut.dp.EXECUTE.alu1_alu5_match;
        captured_alu2_alu3_match = dut.dp.EXECUTE.alu2_alu3_match;
        captured_alu2_alu4_match = dut.dp.EXECUTE.alu2_alu4_match;
        captured_alu2_alu5_match = dut.dp.EXECUTE.alu2_alu5_match;
        captured_alu3_alu4_match = dut.dp.EXECUTE.alu3_alu4_match;
        captured_alu3_alu5_match = dut.dp.EXECUTE.alu3_alu5_match;
        captured_alu4_alu5_match = dut.dp.EXECUTE.alu4_alu5_match;
        captured_alu1_vote_count = dut.dp.EXECUTE.alu1_vote_count;
        captured_alu2_vote_count = dut.dp.EXECUTE.alu2_vote_count;
        captured_alu3_vote_count = dut.dp.EXECUTE.alu3_vote_count;
        captured_alu4_vote_count = dut.dp.EXECUTE.alu4_vote_count;
        captured_alu5_vote_count = dut.dp.EXECUTE.alu5_vote_count;
        captured_majority_status = dut.dp.EXECUTE.majority_status;
        captured = 1;
        $display("Valores QMR (5 ALUs) capturados en tiempo 120ns");

        // Dejar que la simulación corra hasta el final
        #4880; // 5000 - 120 = 4880
        
        // Mostrar los valores capturados del sistema QMR (5 ALUs)
        $display("=== RESULTADOS DE LA SIMULACIÓN QMR (5 ALUs) ===");
        $display("PC Final: 0x%h", dut.dp.FETCH.PC.q);
        $display("--- Resultados de las 5 ALUs ---");
        $display("ALU1_Result: %d (decimal) / 0x%h (hex)", captured_alu1_result, captured_alu1_result);
        $display("ALU2_Result: %d (decimal) / 0x%h (hex)", captured_alu2_result, captured_alu2_result);
        $display("ALU3_Result: %d (decimal) / 0x%h (hex)", captured_alu3_result, captured_alu3_result);
        $display("ALU4_Result: %d (decimal) / 0x%h (hex)", captured_alu4_result, captured_alu4_result);
        $display("ALU5_Result: %d (decimal) / 0x%h (hex)", captured_alu5_result, captured_alu5_result);
        $display("Resultado Votado: %d (decimal) / 0x%h (hex)", captured_voted_result, captured_voted_result);
        $display("--- Señales de Comparación del Votador ---");
        $display("ALU1_ALU2_Match: %b", captured_alu1_alu2_match);
        $display("ALU1_ALU3_Match: %b", captured_alu1_alu3_match);
        $display("ALU1_ALU4_Match: %b", captured_alu1_alu4_match);
        $display("ALU1_ALU5_Match: %b", captured_alu1_alu5_match);
        $display("ALU2_ALU3_Match: %b", captured_alu2_alu3_match);
        $display("ALU2_ALU4_Match: %b", captured_alu2_alu4_match);
        $display("ALU2_ALU5_Match: %b", captured_alu2_alu5_match);
        $display("ALU3_ALU4_Match: %b", captured_alu3_alu4_match);
        $display("ALU3_ALU5_Match: %b", captured_alu3_alu5_match);
        $display("ALU4_ALU5_Match: %b", captured_alu4_alu5_match);
        $display("--- Contadores de Votos ---");
        $display("ALU1_Vote_Count: %d", captured_alu1_vote_count);
        $display("ALU2_Vote_Count: %d", captured_alu2_vote_count);
        $display("ALU3_Vote_Count: %d", captured_alu3_vote_count);
        $display("ALU4_Vote_Count: %d", captured_alu4_vote_count);
        $display("ALU5_Vote_Count: %d", captured_alu5_vote_count);
        $display("Majority_Status: %b (001=ALU1, 010=ALU2, 011=ALU3, 100=ALU4, 101=ALU5, 000=no mayoría)", captured_majority_status);
        
        // Finalizar la simulación
        $display("Simulación completada");
        $finish;
    end

    // Monitor para seguir la ejecución
    always @(posedge clk) begin
        if (!reset) begin
            $display("Ciclo %0d: PC=0x%h, Instrucción=0x%h", 
                     $time/10, dut.dp.FETCH.PC.q, dut.instrMem.q0);
        end
    end

endmodule