`timescale 1ns / 1ps

module synchronizer_tb();
    reg clock = 1'b1;
    reg reset = 1'b0;

    reg [7:0] in_data;
    wire [7:0] out_data;

    synchronizer #(
        .WIDTH(8)
    ) DTS (
        .clock(clock),
        .reset(reset),

        .in(in_data),
        .out(out_data)
    );

    initial begin
        $display("Starting");

        $dumpfile("synchronizer.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 clock = !clock;

    initial begin
        in_data = 8'h00;
        #10
        in_data = 8'h01;
        #10
        in_data = 8'h02;
        #10
        in_data = 8'h01;
        #10
        in_data = 8'h00;

        #10 $finish;
    end

endmodule
