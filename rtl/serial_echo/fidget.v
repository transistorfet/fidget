module fidget(
    input pin_clk_3_6864M,
    input pin_clk_16M,

    input pin_ub1,

    output pin_ul1,
    output pin_ul2,
    output pin_ul3,
    output pin_ul4,

    input pin_usart1_rx,
    output pin_usart1_rts,
    output pin_usart1_tx
);

    //assign pin_ul1 = 1'b0;
    assign pin_ul2 = 1'b0;
    assign pin_ul3 = 1'b0;
    assign pin_ul4 = !pin_ub1;

    assign dump_start = !pin_ub1;

    usart_echo echo(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .clocks_per_bit(12'd32),
        .tx_pin(pin_usart1_tx),
        .rx_pin(pin_usart1_rx),
        .rts_pin(pin_usart1_rts),
        .rx_led(pin_ul1)
    );

endmodule
