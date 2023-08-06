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
    input pin_reset_in,
    input pin_as,
    input pin_ds,
    input pin_rw,
    inout [31:0] pin_ad,
    input pin_dsack0,
    input pin_dsack1,
    input pin_berr,

    output pin_send_receive,
    output pin_data_dir,
    output pin_data_oe,
    output pin_addr_oe,

    output pin_ctrl_oe,
    output pin_alt_ctrl_oe,
    output pin_alt_ctrl_dir1,
    output pin_alt_ctrl_dir2,
    output pin_al_oe,
    output pin_al_le,

    output pin_ext_10
);

    //assign pin_ul1 = 1'b0;
    assign pin_ul2 = 1'b0;
    assign pin_ul3 = 1'b0;
    assign pin_ul4 = !pin_ub1;

    wire dump_start;
    assign dump_start = !pin_ub1;

    busdebugger_serial debugger(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),

        .dump_start(dump_start),

        .pin_ext_1(pin_ext_1),
        .pin_ext_2(pin_ext_2),

        .pin_usart1_rx(pin_usart1_rx),
        .pin_usart1_tx(pin_usart1_tx),

        .pin_clk(pin_clk),
        .pin_reset_in(pin_reset_in),
        .pin_as(pin_as),
        .pin_ds(pin_ds),
        .pin_rw(pin_rw),
        .pin_ad(pin_ad),
        .pin_dsack0(pin_dsack0),
        .pin_dsack1(pin_dsack1),
        .pin_berr(pin_berr),

        .pin_send_receive(pin_send_receive),
        .pin_data_dir(pin_data_dir),
        .pin_data_oe(pin_data_oe),
        .pin_addr_oe(pin_addr_oe),

        .pin_ctrl_oe(pin_ctrl_oe),
        .pin_alt_ctrl_oe(pin_alt_ctrl_oe),
        .pin_alt_ctrl_dir1(pin_alt_ctrl_dir1),
        .pin_alt_ctrl_dir2(pin_alt_ctrl_dir2),
        .pin_al_oe(pin_al_oe),
        .pin_al_le(pin_al_le),

        .pin_ext_10(pin_ext_10)
    );

    /*
    usart_echo echo(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .clocks_per_bit(12'd32),
        .tx_pin(pin_usart1_tx),
        .rx_pin(pin_usart1_rx)
    );
    */

endmodule
