`timescale 1ns / 1ps

module usart_echo_tb();
    reg clock = 1'b0;

    wire tx_pin;
    reg rx_pin = 1'b0;

    usart_echo DTS(
        .comm_clock(clock),
        .serial_clock(clock),
        .clock_divider(12'd64),
        .tx_pin(tx_pin),
        .rx_pin(rx_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_echo.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 clock = !clock;

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

        #100;
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

        #3000 $finish;
    end

endmodule
