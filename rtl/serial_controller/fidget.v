module fidget(
    input pin_clk_3_6864M,

    input pin_ub1,

    output pin_ul1,
    output pin_ul2,
    output pin_ul3,
    output pin_ul4,

    output pin_ext_1,
    output pin_ext_2,

    input pin_usart1_rx,
    output pin_usart1_tx,
);

    assign pin_ul1 = 1'b0;
    assign pin_ul2 = 1'b0;
    assign pin_ul3 = 1'b0;
    assign pin_ul4 = !pin_ub1;

    usart_echo DTS(
        .comm_clock(pin_clk_3_6864M),
        .serial_clock(pin_clk_3_6864M),
        .bit_clock_x1(pin_ext_1),
        .bit_clock_x16(pin_ext_2),
        .clock_divider(12'd32),
        .tx_pin(pin_usart1_tx),
        .rx_pin(pin_usart1_rx)
    );

endmodule
