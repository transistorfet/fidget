module busdebugger_serial #(
    parameter DEPTH = 16
) (
    input comm_clock,
    input serial_clock,

    input dump_start,

    output pin_ext_1,
    output pin_ext_2,

    input pin_usart1_rx,
    input pin_usart1_rts,
    output pin_usart1_tx,

    input pin_clk,
    input pin_reset_in,
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

    output pin_ul1,
    output pin_ul3,
    output pin_ext_10
);

    reg record_start = 1'b1;
    wire record_end;
    reg record_trigger = 1'b0;
    reg reset = 1'b0;

    wire dump_valid;
    wire dump_ready;
    wire [7:0] dump_data_out;

    wire tx_bit_clock;
    wire tx_valid;
    wire tx_ready;
    wire [7:0] tx_data_in;

    // Record Output
    wire record_valid;
    wire record_ready;
    wire [32 * 2 + 1 - 1:0] record_out;

    // Record Input
    wire in_valid;
    wire in_ready;
    wire in_empty;
    wire [32 * 2 + 1 - 1:0] in_data;

    /*
    usart_rx rx(
        .serial_clock(serial_clock),
        .reset(reset),
        .clocks_per_bit(12'd32),
        .out_data(command_data),
        .available(available),
        .error(error),
        .acknowledge(acknowledge),
        .rx_pin(pin_usart1_rx),
        .rts_pin(pin_usart_rts)
    );
    */

    computie_bus_snooper #(
        .BITWIDTH(32),
        .DEPTH(DEPTH)
    ) snooper (
        .comm_clock(comm_clock),

        .cb_clk(pin_clk),
        .cb_reset(pin_reset_in),
        .cb_addr_strobe(pin_as),
        .cb_data_strobe(pin_ds),
        .cb_read_write(pin_rw),
        .cb_addr_data_bus(pin_ad),

        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_oe(pin_data_oe),
        .data_dir(pin_data_dir),
        .ctrl_oe(pin_ctrl_oe),
        .ctrl_dir2(pin_ext_10),
        .alt_ctrl_oe(pin_alt_ctrl_oe),
        .alt_ctrl_dir1(pin_alt_ctrl_dir1),
        .alt_ctrl_dir2(pin_alt_ctrl_dir2),
        .al_oe(pin_al_oe),
        .al_le(pin_al_le),

        .record_start(record_start),
        .record_end(record_end),
        .record_trigger(record_trigger),

        .record_valid(record_valid),
        .record_ready(record_ready),
        .record_out(record_out),

        .led(pin_ul1)
    );

    async_fifo #(
        .WIDTH(80),
        .DEPTH(DEPTH)
    ) record_fifo (
        .reset(pin_reset_in),

        .in_clock(pin_clk),
        .in_valid(record_valid),
        .in_ready(record_ready),
        .in_data(record_out),
        .in_almost_full(),

        .out_clock(comm_clock),
        .out_valid(in_valid),
        .out_ready(in_ready),
        .out_data(in_data),
        .out_almost_empty(in_empty)
    );

    computie_bus_dumper #(
        .BITWIDTH(32),
    ) dumper (
        .comm_clock(comm_clock),

        .dump_start(dump_start),
        .dump_end(),

        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .in_empty(in_empty),

        .out_valid(dump_valid),
        .out_ready(dump_ready),
        .out_data(dump_data_out),

        .led(pin_ul3)
    );

    async_fifo #(
        .DEPTH(256)
    ) serial_fifo (
        .reset(pin_reset_in),

        .in_clock(comm_clock),
        .in_valid(dump_valid),
        .in_ready(dump_ready),
        .in_data(dump_data_out),
        .in_almost_full(),

        .out_clock(tx_bit_clock),
        .out_valid(tx_valid),
        .out_ready(tx_ready),
        .out_data(tx_data_in),
        .out_almost_empty()
    );

    usart_tx tx(
        .serial_clock(serial_clock),
        .clocks_per_bit(12'd32),
        .bit_clock(tx_bit_clock),
        .data_in(tx_data_in),
        .valid(tx_valid),
        .ready(tx_ready),
        .tx_pin(pin_usart1_tx)
    );
endmodule

