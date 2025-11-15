module imem #(parameter N = 32)(
    input  logic [5:0] addr0,          // 6 bits = 64 direcciones
    input  logic       clk,
    output logic [N-1:0] q0
);

    altsyncram #(
        .operation_mode                ("SINGLE_PORT"),
        .width_a                       (32),
        .widthad_a                     (6),                // 2^6 = 64
        .numwords_a                    (64),
        .outdata_reg_a                 ("UNREGISTERED"),
        .init_file                     ("imem_init.mif"),
        .intended_device_family        ("Cyclone IV E"),
        .ram_block_type                ("M9K"),            // 🚀 forzar Block RAM
        .read_during_write_mode_port_a ("NEW_DATA_WITH_NBE_READ")
    ) mem (
        .clock0   (clk),
        .address_a(addr0),
        .rden_a   (1'b1),
        .wren_a   (1'b0),
        .data_a   (32'b0),
        .q_a      (q0)
    );

endmodule
