module fidget(
    input pin_clk_16M,

    // Computie Bus
    input pin_addr_strobe,
    input pin_read_write,
    inout [BITWIDTH-1:0] pins_ad,

    // Computie Bus Transceiver Control
    output pin_send_receive,
    output pin_ctrl_oe,
    output pin_addr_oe,
    output pin_data_oe,
    output pin_data_dir,

    /// Serial Port
    output pin_usart0_tx
);

    parameter BITWIDTH = 6;

    assign pin_ctrl_oe = 1'b1;

    wire demux_oe;
    wire [BITWIDTH-1:0] demux_from_bus;
    wire [BITWIDTH-1:0] demux_to_bus;

    computie_bus_demux #(
        .BITWIDTH(BITWIDTH)
    ) bus_demux (
        .output_enable(demux_oe),
        .pins_ad(pins_ad),
        .from_bus(demux_from_bus),
        .to_bus(demux_to_bus)
    );

    wire [BITWIDTH-1:0] addr_out;
    wire [BITWIDTH-1:0] data_in;
    wire [BITWIDTH-1:0] data_out;

    computie_bus_ctrl #(
        .BITWIDTH(BITWIDTH)
    ) bus (
        .clk(pin_clk_16M),

        .addr_out(addr_out),
        .data_in(data_in),
        .data_out(data_out),

        .addr_strobe(pin_addr_strobe),
        .read_write(pin_read_write),

        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_dir(pin_data_dir),
        .data_oe(pin_data_oe),

        .demux_oe(demux_oe),
        .from_bus(demux_from_bus),
        .to_bus(demux_to_bus)
    );

    reg usart_write;
    reg [2:0] usart_cmd;
    reg [7:0] usart_data;

    usart_ctrl usart(
        .clk(pin_clk_16M),
        .write(usart_write),
        .cmd_in(usart_cmd),
        .data_in(usart_data),
        .tx_pin(pin_usart0_tx)
    );

    always_comb begin
        if (pin_read_write == 1'b1) begin
            usart_write = 1'b0;
            usart_cmd = 0;
            usart_data = 0;
        end else begin
            usart_cmd = 2;
            usart_data = { 2'b0, data_in[5:0] };
            usart_write = 1'b1;
        end
    end

endmodule
 
