module usart_rx_tb ();
    reg comm_clock = 0;
    reg bit_clock_x16 = 0;
    reg reset = 0;
    wire [7:0] data_out;
    wire valid;
    reg ready;
    wire error;

    reg rx_pin = 0;
    wire rts_pin;

    usart_rx DTS(
        .serial_clock(bit_clock_x16),
        .clocks_per_bit(12'b0),
        .reset(reset),
        .data_out(data_out),
        .valid(valid),
        .ready(ready),
        .error(error),
        .rx_pin(rx_pin),
        .rts_pin(rts_pin)
    );

    initial begin
        $display("Starting");

        $dumpfile("usart_rx.vcd");
        $dumpvars(0, DTS);
    end

    always
        #1 comm_clock = !comm_clock;

    always
        #2 bit_clock_x16 = !bit_clock_x16;

    initial begin
            rx_pin = 1;
            reset = 0;
            ready = 0;
        #200;
            reset = 1;
        #200;
            reset = 0;

        #200;
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
        #200;
            ready = 1;
        #2;
            ready = 0;


        #200;
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
            rx_pin = 1;
        // Stop Bit
        #128;
            rx_pin = 0;
        #200;
            ready = 1;
        #2;
            ready = 0;

        #400 $finish;
    end

endmodule
