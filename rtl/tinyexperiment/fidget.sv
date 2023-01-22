module fidget(
    input pin_clk_16M,

    // Computie Bus
    output pin_send_receive,
    output pin_read_write,
    output pin_addr_oe,
    output pin_data_oe,
    output pin_data_dir,
    inout [BITWIDTH-1:0] pins_ad,

    /// Serial Port
    output pin_usart0_tx,
);

    parameter BITWIDTH = 2;

    assign pin_ctrl_oe = 1'b1;

    wire demux_oe;
    wire [BITWIDTH-1:0] from_bus;
    wire [BITWIDTH-1:0] to_bus;

    computie_bus_demux #(
        .BITWIDTH(BITWIDTH)
    ) bus_demux (
        .output_enable(demux_oe),
        .pins_ad(pins_ad),
        .from_bus(from_bus),
        .to_bus(to_bus)
    );

    computie_bus_ctrl #(
        .BITWIDTH(BITWIDTH)
    ) bus (
        .clk(pin_clk_16M),
        .read_write(pin_read_write),
        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_dir(pin_data_dir),
        .data_oe(pin_data_oe),

        .demux_oe(demux_oe),
        .from_bus(from_bus),
        .to_bus(to_bus)
    );

    reg usart_write;
    reg [2:0] usart_cmd;
    reg [7:0] usart_data;

    usart_ctrl usart(
        .clk(pin_clk_16M),
        .write(usart_write),
        .cmd_in(usart_cmd),
        .data_in(usart_data),
        .tx_pin(pin_usart0_tx),
    );

    always @(posedge pin_clk_16M) begin
        if (pin_read_write == 1'b1)
            usart_write <= 1'b0;
        else begin
            usart_cmd <= 1;
            usart_data <= { 5'b0, from_bus };
            usart_write <= 1'b1;
        end
    end

endmodule
 
