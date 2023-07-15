`timescale 1ns / 1ps

module computie_bus_receiver_tb();
    localparam BITWIDTH = 32;

    reg comm_clock = 0;

    wire data_wait;
    wire [BITWIDTH-1:0] addr_out;
    reg [BITWIDTH-1:0] data_in = 32'h0;
    wire [BITWIDTH-1:0] data_out;

    // Bus Control Signals
    reg cb_clk = 1'b1;
    reg cb_reset = 1'b1;
    reg cb_addr_strobe = 1'b1;
    reg cb_data_strobe = 1'b1;
    reg cb_read_write = 1'b0;

    // Transceiver Control
    wire send_receive;
    wire addr_oe;
    wire data_oe;
    wire data_dir;
    wire ctrl_oe;
    wire ctrl_dir2;
    wire alt_ctrl_oe;
    wire alt_ctrl_dir1;
    wire alt_ctrl_dir2;
    wire al_oe;
    wire al_le;

    wire cb_demux_oe;
    reg [BITWIDTH-1:0] cb_demux_from_bus = 32'h00;
    wire [BITWIDTH-1:0] cb_demux_to_bus;

    computie_bus_receiver #(
        .BITWIDTH(BITWIDTH),
        .DEVICE_ADDRESS(32'h20200000)
    ) DTS (
        .comm_clock(comm_clock),

        .data_wait(data_wait),
        .addr_out(addr_out),
        .data_in(data_in),
        .data_out(data_out),

        .cb_clk(cb_clk),
        .cb_reset(cb_reset),
        .cb_addr_strobe(cb_addr_strobe),
        .cb_data_strobe(cb_data_strobe),
        .cb_read_write(cb_read_write),

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

        .cb_demux_oe(cb_demux_oe),
        .cb_from_bus(cb_demux_from_bus),
        .cb_to_bus(cb_demux_to_bus)
    );

    initial begin
        $display("Starting");

        $dumpfile("computie_bus_receiver.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 comm_clock = !comm_clock;

    always
        #10 cb_clk = !cb_clk;

    initial begin
        #105;
            cb_addr_strobe = 1'b0;
            cb_read_write = 1'b0;
            cb_demux_from_bus = 32'h2020FFFF;
        #25
            cb_data_strobe = 1'b0;
            cb_demux_from_bus = 32'hAAAAAAAA;
        #20
            cb_addr_strobe = 1'b1;
            cb_data_strobe = 1'b1;
            cb_demux_from_bus = 32'h00000000;

        #100
            cb_addr_strobe = 1'b0;
            cb_read_write = 1'b1;
            cb_demux_from_bus = 32'h12345678;
        #25
            cb_data_strobe = 1'b0;
            data_in = 32'h55555555;
        #25
            cb_addr_strobe = 1'b1;
            cb_data_strobe = 1'b1;
            data_in = 32'h00000000;

        #500 $finish;
    end

endmodule
