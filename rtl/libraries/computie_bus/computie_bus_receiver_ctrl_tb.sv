`timescale 1ns / 1ps

module computie_bus_receiver_ctrl_tb();
    localparam BITWIDTH = 32;

    reg clk = 0;

    reg data_wait;
    reg [BITWIDTH-1:0] addr_out;
    reg [BITWIDTH-1:0] data_in;
    reg [BITWIDTH-1:0] data_out;

    reg pin_addr_strobe = 1'b1;
    reg pin_data_strobe = 1'b1;
    reg pin_read_write = 1'b0;

    reg pin_send_receive;
    reg pin_addr_oe;
    reg pin_data_dir;
    reg pin_data_oe;

    reg demux_oe;
    reg [BITWIDTH-1:0] demux_from_bus = 32'h00;
    reg [BITWIDTH-1:0] demux_to_bus;

    computie_bus_receiver_ctrl #(
        .BITWIDTH(BITWIDTH)
    ) DTS (
        .clk(clk),

        .data_wait(data_wait),
        .addr_out(addr_out),
        .data_in(data_in),
        .data_out(data_out),

        .addr_strobe(pin_addr_strobe),
        .data_strobe(pin_data_strobe),
        .read_write(pin_read_write),

        .send_receive(pin_send_receive),
        .addr_oe(pin_addr_oe),
        .data_oe(pin_data_oe),
        .data_dir(pin_data_dir),

        .demux_oe(demux_oe),
        .from_bus(demux_from_bus),
        .to_bus(demux_to_bus)
    );

    initial begin
        $display("Starting");

        $dumpfile("computie_bus_ctrl.vcd");
        $dumpvars(0, DTS);
    end

    always
        #10 clk = !clk;

    initial begin
        #105;
            pin_addr_strobe = 1'b0;
            pin_read_write = 1'b0;
            demux_from_bus = 32'h2020FFFF;
        #25
            pin_data_strobe = 1'b0;
            demux_from_bus = 32'hAAAAAAAA;
        #20
            pin_addr_strobe = 1'b1;
            pin_data_strobe = 1'b1;
            demux_from_bus = 32'h00000000;

        #100
            pin_addr_strobe = 1'b0;
            pin_read_write = 1'b1;
            demux_from_bus = 32'h12345678;
        #25
            pin_data_strobe = 1'b0;
            data_in = 32'h55555555;
        #25
            pin_addr_strobe = 1'b1;
            pin_data_strobe = 1'b1;
            data_in = 32'h00000000;

        #500 $finish;
    end

endmodule
