module usart_tx (
    input serial_clock,
    input [11:0] clocks_per_bit,

    input [7:0] data_in,
    input latch_in,
    output reg ready,

    output reg done,
    output reg tx_pin
);

    reg start_transmitting = 1'b0;
    reg transmitting = 1'b0;
    reg [1:0] load_fifo = 2'b0;
    reg [3:0] bitcount = 4'h0;
    reg [9:0] shift_register = 8'h0;

    reg bit_clock = 1'b0;
    reg [11:0] clock_counter = 12'd0;

    initial begin
        ready <= 1'b0;
        done <= 1'b1;
        tx_pin <= 1'b1;
    end

    always @(posedge serial_clock) begin
        if (clocks_per_bit == 12'b0) begin
            bit_clock <= !bit_clock;
        end else if (clock_counter == clocks_per_bit - 12'd1) begin
            clock_counter <= 12'd0;
            bit_clock <= 1'b1;
        end else begin
            clock_counter <= clock_counter + 12'd1;
            bit_clock <= 1'b0;
        end
    end

    always @(posedge bit_clock) begin
        load_fifo = { latch_in, load_fifo[1] };

        if (!transmitting) begin
            if (load_fifo[0] == 1'b1) begin
                shift_register <= { 1'b1, data_in, 1'b0 };
                transmitting <= 1'b1;
                bitcount <= 4'd10;
                ready <= 1'b1;
            end else begin
                ready <= 1'b0;
            end
            tx_pin <= 1'b1;
        end else begin
            if (bitcount == 4'h0) begin
                transmitting <= 1'b0;
                done <= 1'b1;
                tx_pin <= 1'b1;
            end else begin
                tx_pin <= shift_register[0];
                shift_register <= { 1'b0, shift_register[9:1] };
                bitcount <= bitcount - 4'h1;
                done <= 1'b0;
            end
            ready <= 1'b0;
        end
    end
endmodule
