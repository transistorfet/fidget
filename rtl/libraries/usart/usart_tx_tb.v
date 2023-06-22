`timescale 1ns / 1ps

module usart_tx_tb();
    reg bit_clock_x1 = 1'b0;
    reg start_latch_in = 1'b0;
    reg [7:0] data_in = 1'b0;

    wire latch_in;
    wire ready;
    wire done;
    wire tx_pin;

    usart_tx DTS(
        .bit_clock_x1(bit_clock_x1),
        .data_in(data_in),
        .latch_in(latch_in),
        .ready(ready),
        .done(done),
        .tx_pin(tx_pin)
    );

    initial b0egin
        $display("Starting");

        $dumpfile("usart_tx.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 bit_clock_x1 = !bit_clock_x1;

    assign latch_in = start_latch_in && !ready;

    initial begin
            start_latch_in = 1'b0;
            data_in = 8'h00;
        #50;
            start_latch_in = 1'b1;
            data_in = 8'hAA;
        #4;
            start_latch_in = 1'b0;
        #100 $finish;
    end

endmodule
