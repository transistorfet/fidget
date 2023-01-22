`timescale 1ns / 1ps

module usart_tx_tb();
    reg clock = 0;
    reg [7:0] tx_data = 0;

    reg serial_clock = 0;
    reg [3:0] serial_clock_counter = 0;
    reg tx_enable = 0;
    wire tx_pin = 0;

    usart_tx DTS(
        .clock(clock),
        .tx_data(tx_data),
        .serial_clock(serial_clock),
        .tx_enable(tx_enable),
        .tx_pin(tx_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_tx.vcd");
        $dumpvars(0, DTS);
    end

    always
        #10 clock = !clock;

    always
        #100 serial_clock = !serial_clock;

    initial begin
        #100;
            tx_data = 8'hAA;
            tx_enable = 1;
        #200;
            tx_enable = 0;
        #1000000 $finish;
    end

endmodule
