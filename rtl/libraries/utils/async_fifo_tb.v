`timescale 1ns / 1ps

module async_fifo_tb();
    reg reset = 1'b0;

    reg in_clock = 1'b0;
    reg in_valid = 1'b0;
    wire in_ready;
    wire in_almost_full;
    reg [7:0] in_data;

    reg out_clock = 1'b0;
    wire out_valid;
    reg out_ready = 1'b0;
    wire out_almost_empty;
    wire [7:0] out_data;

    async_fifo DTS(
        .reset(reset),

        .in_clock(in_clock),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_almost_full(in_almost_full),
        .in_data(in_data),

        .out_clock(out_clock),
        .out_ready(out_ready),
        .out_valid(out_valid),
        .out_almost_empty(out_almost_empty),
        .out_data(out_data)
    );

    initial begin
        $display("Starting");

        $dumpfile("async_fifo.vcd");
        $dumpvars(0, DTS);
    end

    always
        #10 in_clock = !in_clock;

    always
        #1 out_clock = !out_clock;

    initial begin
        in_valid = 1'b0;
        in_data = 8'h0;
        out_ready = 1'b0;

        #100;
        in_valid = 1'b1;
        in_data = 8'hAA;
        while (!in_ready) #1;
        in_valid = 1'b0;

        #100;
        in_valid = 1'b1;
        in_data = 8'hBB;
        while (!in_ready) #1;
        in_valid = 1'b0;

        #200;
        if (out_valid) begin
            out_ready = 1'b1;
        end
        while (out_valid) #1;
        out_ready = 1'b0;

        #100;
        if (out_valid) begin
            out_ready = 1'b1;
        end
        while (out_valid) #1;
        out_ready = 1'b0;

        #100;
        if (out_valid) begin
            out_ready = 1'b1;
        end
        while (out_valid) #1;
        out_ready = 1'b0;

        #100;
        if (out_valid) begin
            out_ready = 1'b1;
        end
        while (out_valid) #1;
        out_ready = 1'b0;

        #1000 $finish;
    end

endmodule
