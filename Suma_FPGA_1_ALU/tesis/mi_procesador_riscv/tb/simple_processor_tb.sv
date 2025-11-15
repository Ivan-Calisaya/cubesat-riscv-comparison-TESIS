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

    // Variables para capturar los valores de la ALU en el momento correcto
    logic [63:0] captured_alu_a, captured_alu_b, captured_alu_result;
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

        // Esperar al momento de la suma (120ns) y capturar valores
        #100;
        captured_alu_a = dut.dp.EXECUTE.alu.a;
        captured_alu_b = dut.dp.EXECUTE.alu.b;
        captured_alu_result = dut.dp.EXECUTE.alu.result;
        captured = 1;
        $display("Valores capturados en tiempo 120ns");

        // Dejar que la simulación corra hasta el final
        #4880; // 5000 - 120 = 4880
        
        // Mostrar los valores capturados
        $display("=== RESULTADOS DE LA SIMULACIÓN ===");
        $display("PC Final: 0x%h", dut.dp.FETCH.PC.q);
        $display("ALU_A: 0x%h (10 en decimal)", captured_alu_a);
        $display("ALU_B: 0x%h (20 en decimal)", captured_alu_b);
        $display("ALU_Result: 0x%h (30 en decimal)", captured_alu_result);
        
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