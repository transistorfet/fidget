`timescale 1ns / 1ps

module usart_fifo_tb();
    reg clock = 1'b0;
    reg reset = 1'b0;

    reg in_valid;
    wire in_ready;
    wire in_full;
    reg [7:0] in_data;

    reg out_ready;
    wire out_valid;
    wire out_empty;
    wire [7:0] out_data;

    usart_fifo DTS(
        .comm_clock(clock),
        .reset(reset),
        .in_valid(in_valid),
        .in_ready(in_ready),
        .in_full(in_full),
        .in_data(in_data),

        .out_ready(out_ready),
        .out_valid(out_valid),
        .out_empty(out_empty),
        .out_data(out_data)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_fifo.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 clock = !clock;

    initial begin
        in_valid = 1'b0;
        in_data = 8'h0;
        out_ready = 1'b0;

        #10;
        in_valid = 1'b1;
        in_data = 8'hAA;
        #2;
        in_valid = 1'b0;

        #10;
        in_valid = 1'b1;
        in_data = 8'hBB;
        #2;
        in_valid = 1'b0;

        #20;
        out_ready = 1'b1;
        #2;
        out_ready = 1'b0;

        #10;
        out_ready = 1'b1;
        #2;
        out_ready = 1'b0;

        #10;
        out_ready = 1'b1;
        #2;
        out_ready = 1'b0;

        #10;
        out_ready = 1'b1;
        #2;
        out_ready = 1'b0;

        #100 $finish;
    end

endmodule

