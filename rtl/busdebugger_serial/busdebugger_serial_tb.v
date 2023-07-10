module busdebugger_serial_tb();

    reg pin_clk_3_6864M = 1'b0;
    reg pin_clk_16M = 1'b0;

    reg dump_start;

    wire pin_ext_1;
    wire pin_ext_2;

    reg pin_usart1_rx;
    wire pin_usart1_tx;

    reg pin_clk = 1'b1;
    reg pin_reset_in = 1'b1;
    reg pin_as = 1'b1;
    reg pin_ds = 1'b1;
    reg pin_rw = 1'b1;
    reg [31:0] pin_ad;
    reg pin_dsack0 = 1'b1;
    reg pin_dsack1 = 1'b1;
    reg pin_berr = 1'b1;

    wire pin_send_receive;
    wire pin_data_dir;
    wire pin_data_oe;
    wire pin_addr_oe;

    wire pin_ctrl_oe;
    wire pin_alt_ctrl_oe;
    wire pin_alt_ctrl_dir1;
    wire pin_alt_ctrl_dir2;
    wire pin_al_oe;
    wire pin_al_le;

    wire pin_ext_10;

    busdebugger_serial DTS(
        .pin_clk_3_6864M(pin_clk_3_6864M),
        .pin_clk_16M(pin_clk_16M),

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

        .pin_ul1(pin_ul1),
        .pin_ext_10(pin_ext_10)
    );

    initial begin
        $display("Starting");

        $dumpfile("busdebugger_serial.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 pin_clk_16M = !pin_clk_16M;

    always
        #3 pin_clk = !pin_clk;

    always
        #5 pin_clk_3_6864M = !pin_clk_3_6864M;

    initial begin
            dump_start = 1'b0;
            pin_ad = 32'h00000000;

        #80;
            pin_as = 1'b0;
            pin_ad = 1'b0;
            pin_ad = 32'h2020FFFF;
        #20
            pin_ds = 1'b0;
            pin_ad = 32'hAAAAAAAA;
        #20
            pin_as = 1'b1;
            pin_ds = 1'b1;
            pin_ad = 32'h11111111;

        #80
            pin_as = 1'b0;
            pin_rw = 1'b1;
            pin_ad = 32'h12345678;
            pin_ds = 1'b0;
        #20
            pin_ad = 32'h55555555;
        #20
            pin_as = 1'b1;
            pin_ds = 1'b1;
            pin_ad = 32'h33333333;

        #200
            dump_start = 1'b1;

        #400000 $finish;
    end
endmodule
