`timescale 1ns / 1ps

module computie_bus_dumper_tb();
    localparam BITWIDTH = 32;
    localparam DEPTH = 8;

    reg comm_clock = 1'b0;

    reg dump_start = 1'b0;
    wire dump_end;

    // Bus-oriented Input (computie bus)
    output reg in_valid;
    input in_ready;
    output reg [BITWIDTH * 2 + 1 - 1:0] in_data;
    output reg in_empty;

    wire out_valid;
    reg out_ready;
    wire [7:0] out_data;

    computie_bus_dumper #(
        .BITWIDTH(BITWIDTH),
        .DEPTH(DEPTH)
    ) DTS (
        .comm_clock(comm_clock),

        .dump_start(dump_start),
        .dump_end(dump_end),

        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_data(in_data),
        .in_empty(in_empty),

        .out_valid(out_valid),
        .out_ready(out_ready),
        .out_data(out_data)
    );

    initial begin
        $display("Starting");

        $dumpfile("computie_bus_dumper.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 comm_clock = !comm_clock;

    initial begin
            in_data = 65'h0;
            in_empty = 1'b0;

        #10;
            dump_start = 1'b1;

        #1;
            in_valid = 1'b1;
            in_data = 65'h12020FFFFAAAAAAAA;

            while (!in_ready) begin
                #1;
            end
            in_valid = 1'b0;

        #10;
            in_valid = 1'b1;
            in_data = 65'h012345678BBBBBBBB;
            in_empty = 1'b1;

            while (!in_ready) begin
                #1;
            end
            in_valid = 1'b0;

        #200 $finish;
    end

    always @(comm_clock) begin
        if (out_valid) begin
            out_ready <= 1'b1;
        end else begin
            out_ready <= 1'b0;
        end
    end

endmodule
