`timescale 1ns / 1ps

module usart_echo_tb();
    reg comm_clock = 1'b0;
    reg serial_clock = 1'b0;

    wire tx_pin;
    reg rx_pin = 1'b0;
    wire rts_pin;

    usart_echo DTS(
        .comm_clock(comm_clock),
        .serial_clock(serial_clock),
        .clocks_per_bit(12'd32),
        .tx_pin(tx_pin),
        .rx_pin(rx_pin),
        .rts_pin(rts_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_echo.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 comm_clock = !comm_clock;

    always
        #2 serial_clock = !serial_clock;

    initial begin
        rx_pin = 1;
        #100;
        // START TRANSMISSION
        // Start Bit
            rx_pin = 0;
        #128;
        // Data Bits
            rx_pin = 1;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 0;
        // Stop Bit
        #128;
            rx_pin = 1;
        // END TRANSMISSION

        #256;
        // START TRANSMISSION
        // Start Bit
            rx_pin = 0;
        #128;
        // Data Bits
            rx_pin = 0;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 1;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 0;
        #128;
            rx_pin = 1;
        // Stop Bit
        #128;
            rx_pin = 1;
        // END TRANSMISSION

        #8000 $finish;
    end

endmodule
