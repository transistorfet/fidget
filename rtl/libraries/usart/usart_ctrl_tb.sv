`timescale 1ns / 1ps

module usart_ctrl_tb();
    reg clk = 0;

    reg write = 0;
    reg [2:0] cmd_in = 0;
    reg [7:0] data_in = 0;

    wire tx_pin;

    usart_ctrl DTS(
        .clk(clk),
        .write(write),
        .cmd_in(cmd_in),
        .data_in(data_in),
        .tx_pin(tx_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_ctrl.vcd");
        $dumpvars(0, DTS);
    end

    always
        #10 clk = !clk;

    initial begin
        #100;
            cmd_in = 2;
            data_in = 8'hAA;
            write = 1;
        #200;
            write = 0;
        #1000000 $finish;
    end

endmodule
