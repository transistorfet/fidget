`timescale 1ns / 1ps

module computie_bus_snooper_tb();
    localparam BITWIDTH = 32;
    localparam DEPTH = 8;

    reg comm_clock = 1'b0;

    // Internal Interface
    reg record_start = 1'b0;
    wire record_end;
    reg record_trigger = 1'b0;

    wire record_valid;
    output reg record_ready;
    wire [BITWIDTH * 2 + 1 - 1:0] record_out;

    // Bus Control Signals
    reg cb_clk = 1'b1;
    reg cb_reset = 1'b1;
    reg cb_addr_strobe = 1'b1;
    reg cb_data_strobe = 1'b1;
    reg cb_read_write = 1'b0;
    reg [BITWIDTH-1:0] cb_addr_data_bus;

    // Transceiver Control
    wire send_receive;
    wire addr_oe;
    wire data_oe;
    wire data_dir;
    wire ctrl_oe;
    wire ctrl_dir;
    wire alt_ctrl_oe;
    wire alt_ctrl_dir1;
    wire alt_ctrl_dir2;
    wire al_oe;
    wire al_le;


    computie_bus_snooper #(
        .BITWIDTH(BITWIDTH),
        .DEPTH(DEPTH)
    ) DTS (
        .comm_clock(comm_clock),

        .cb_clk(cb_clk),
        .cb_reset(cb_reset),
        .cb_addr_strobe(cb_addr_strobe),
        .cb_data_strobe(cb_data_strobe),
        .cb_read_write(cb_read_write),
        .cb_addr_data_bus(cb_addr_data_bus),

        .send_receive(send_receive),
        .addr_oe(addr_oe),
        .data_oe(data_oe),
        .data_dir(data_dir),
        .ctrl_oe(ctrl_oe),
        .ctrl_dir2(ctrl_dir2),
        .alt_ctrl_oe(alt_ctrl_oe),
        .alt_ctrl_dir1(alt_ctrl_dir1),
        .alt_ctrl_dir2(alt_ctrl_dir2),
        .al_oe(al_oe),
        .al_le(al_le),

        .record_start(record_start),
        .record_end(record_end),
        .record_trigger(record_trigger),

        .record_valid(record_valid),
        .record_ready(record_ready),
        .record_out(record_out)
    );

    initial begin
        $display("Starting");

        $dumpfile("computie_bus_snooper.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 comm_clock = !comm_clock;

    always
        #10 cb_clk = !cb_clk;

    initial begin
            record_start = 1'b1;
        #80;
            cb_addr_strobe = 1'b0;
            cb_read_write = 1'b0;
            cb_addr_data_bus = 32'h2020FFFF;
        #20
            cb_data_strobe = 1'b0;
            cb_addr_data_bus = 32'hAAAAAAAA;
        #20
            cb_addr_strobe = 1'b1;
            cb_data_strobe = 1'b1;
            cb_addr_data_bus = 32'h11111111;

        #80
            cb_addr_strobe = 1'b0;
            cb_read_write = 1'b1;
            cb_addr_data_bus = 32'h12345678;
            cb_data_strobe = 1'b0;
        #20
            cb_addr_data_bus = 32'h55555555;
        #20
            cb_addr_strobe = 1'b1;
            cb_data_strobe = 1'b1;
            cb_addr_data_bus = 32'h33333333;

        #200
            record_start = 1'b0;

        #2000 $finish;
    end

    always @(cb_clk) begin
        record_ready <= 1'b0;
        if (record_valid) begin
            record_ready <= 1'b1;
        end
    end
endmodule
