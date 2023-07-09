module busdebugger_serial(
    input pin_clk_3_6864M,
    input pin_clk_16M,

    input dump_start,

    output pin_ext_1,
    output pin_ext_2,

    input pin_usart1_rx,
    output pin_usart1_tx,

    input pin_clk,
    input pin_as,
    input pin_ds,
    input pin_rw,
    input [31:0] pin_ad,
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

    reg record_start = 1'b1;
    wire record_end;
    reg record_trigger = 1'b0;
    reg reset = 1'b0;
    wire tx_valid;
    wire tx_ready;
    wire tx_done;
    wire [7:0] dump_data;

    assign pin_ext_10 = 1'b0;

    /*
    usart_rx rx(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .reset(reset),
        .clocks_per_bit(12'd32),
        .out_data(command_data),
        .available(available),
        .error(error),
        .acknowledge(acknowledge),
        .rx_pin(pin_usart1_rx)
    );
    */

    usart_tx tx(
        .comm_clock(pin_clk_16M),
        .serial_clock(pin_clk_3_6864M),
        .clocks_per_bit(12'd32),
        .data_in(dump_data),
        .valid(tx_valid),
        .ready(tx_ready),
        .done(tx_done),
        .tx_pin(pin_usart1_tx)
    );

    computie_bus_snooper #(
        .BITWIDTH(32),
        .DEPTH(32)
    ) bus (
        .comm_clock(pin_clk_16M),

        .record_start(record_start),
        .record_end(record_end),
        .record_trigger(record_trigger),

        .dump_start(dump_start),
        .dump_end(),
        .out_valid(tx_valid),
        .out_ready(tx_ready),
        .out_data(dump_data),

        .cb_clk(pin_clk),
        .cb_addr_strobe(pin_as),
        .cb_data_strobe(pin_ds),
        .cb_read_write(pin_rw),
        .cb_addr_data_bus(pin_ad),

        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_oe(pin_data_oe),
        .data_dir(pin_data_dir),
        .ctrl_oe(pin_ctrl_oe),
        .alt_ctrl_oe(pin_alt_ctrl_oe),
        .alt_ctrl_dir1(pin_alt_ctrl_dir1),
        .alt_ctrl_dir2(pin_alt_ctrl_dir2),
        .al_oe(pin_al_oe),
        .al_le(pin_al_le),

        .led()
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

