module fidget(
    input pin_clk_3_6864M,
    input pin_clk_16M,

    input pin_ub1,

    output pin_ul1,
    output pin_ul2,
    output pin_ul3,
    output pin_ul4,

    output pin_ext_1,
    output pin_ext_2,

    input pin_usart1_rx,
    output pin_usart1_tx,

    input pin_clk,
    input pin_as,
    input pin_ds,
    input pin_rw,
    inout [31:0] pin_ad,

    output pin_send_receive,
    output pin_data_dir,
    output pin_data_oe,
    output pin_addr_oe
);

    assign pin_ul1 = 1'b0;
    assign pin_ul2 = 1'b0;
    assign pin_ul3 = 1'b0;
    assign pin_ul4 = !pin_ub1;

    reg record_start = 1'b0;
    wire record_end;
    reg record_trigger = 1'b0;

    usart_rx rx(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .clocks_per_bit(12'd32),
        .rx_pin(pin_usart1_rx)
    );

    computie_bus_snooper #(
        .BITWIDTH(32),
        .DEPTH(128)
    ) bus (
        .comm_clock(pin_clk_16M),
        .record_start(record_start),
        .record_end(record_end),
        .record_trigger(record_trigger),
        .dump_start(),
        .dump_end(),
        .data_out(),
        .cb_clk(pin_clk),
        .cb_addr_strobe(pin_as),
        .cb_data_strobe(pin_ds),
        .cb_read_write(pin_rw),
        .cb_addr_data_bus(pin_ad),
        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_oe(pin_data_oe),
        .data_dir(pin_data_dir)
    );

    /*
    usart_echo DTS(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .clocks_per_bit(12'd32),
        .tx_pin(pin_usart1_tx),
        .rx_pin(pin_usart1_rx)
    );
    */

endmodule
