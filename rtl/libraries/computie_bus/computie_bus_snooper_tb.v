module computie_bus_snooper_tb();
    localparam BITWIDTH = 32;
    localparam DEPTH = 128;

    reg comm_clock = 1'b0;

    // Internal Interface
    reg record_start = 1'b0;
    wire record_end;
    reg record_trigger = 1'b0;

    wire dump_start;
    wire dump_end;
    wire [7:0] data_out;

    // Bus Control Signals
    reg cb_clk = 1'b1;
    reg cb_addr_strobe = 1'b1;
    reg cb_data_strobe = 1'b1;
    reg cb_read_write = 1'b0;
    reg [BITWIDTH-1:0] cb_addr_data_bus;

    // Transceiver Control
    wire send_receive;
    wire addr_oe;
    wire data_oe;
    wire data_dir;

    computie_bus_snooper #(
        .BITWIDTH(BITWIDTH),
        .DEPTH(DEPTH)
    ) DTS (
        .comm_clock(comm_clock),
        .record_start(record_start),
        .record_end(record_end),
        .record_trigger(record_trigger),
        .dump_start(dump_start),
        .dump_end(dump_end),
        .data_out(data_out),
        .cb_clk(cb_clk),
        .cb_addr_strobe(cb_addr_strobe),
        .cb_data_strobe(cb_data_strobe),
        .cb_read_write(cb_read_write),
        .cb_addr_data_bus(cb_addr_data_bus),
        .send_receive(send_receive),
        .addr_oe(addr_oe),
        .data_oe(data_oe),
        .data_dir(data_dir)
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

        #500 $finish;
    end

endmodule
