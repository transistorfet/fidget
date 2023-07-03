module usart_rx_tb ();
    reg bit_clock_x16 = 0;
    reg reset = 0;
    wire [7:0] data_out;
    wire available;
    wire error;
    reg acknowledge;

    reg rx_pin = 0;

    usart_rx DTS(
        .comm_clock(bit_clock_x16),
        .serial_clock(bit_clock_x16),
        .clocks_per_bit(12'b0),
        .reset(reset),
        .data_out(data_out),
        .available(available),
        .error(error),
        .acknowledge(acknowledge),
        .rx_pin(rx_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_rx.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 bit_clock_x16 = !bit_clock_x16;

    initial begin
            rx_pin = 1;
            reset = 0;
            acknowledge = 0;
        #100;
            reset = 1;
        #100;
            reset = 0;

        #100;
        // Start Bit
            rx_pin = 0;
        #64;
        // Data Bits
            rx_pin = 1;
        #64;
            rx_pin = 0;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 0;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 0;
        // Stop Bit
        #64;
            rx_pin = 1;
        #100;
            acknowledge = 1;
        #10;
            acknowledge = 0;


        #100;
        // Start Bit
            rx_pin = 0;
        #64;
        // Data Bits
            rx_pin = 1;
        #64;
            rx_pin = 0;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 0;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 1;
        #64;
            rx_pin = 1;
        // Stop Bit
        #64;
            rx_pin = 0;
        #100;
            acknowledge = 1;
        #10;
            acknowledge = 0;

        #100 $finish;
    end

endmodule
