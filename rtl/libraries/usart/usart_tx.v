module usart_tx (
    input comm_clock,
    input serial_clock,
    input [11:0] clocks_per_bit,

    input [7:0] data_in,
    input valid,
    output reg ready,

    output reg done,
    output reg tx_pin
);

    reg transmitting = 1'b0;
    reg load_next = 1'b0;
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

    always @(posedge comm_clock) begin
        ready <= 1'b0;

        if (!transmitting && valid) begin
            shift_register <= { 1'b1, data_in, 1'b0 };
            ready <= 1'b1;
            transmitting <= 1'b1;
            done <= 1'b0;
        end

        if (transmitting && done) begin
            transmitting <= 1'b0;
        end
    end

    always @(posedge bit_clock) begin
        if (!transmitting) begin
            bitcount <= 4'd10;
            tx_pin <= 1'b1;
            done <= 1'b1;
        end else begin
            if (bitcount == 4'h0) begin
                done <= 1'b1;
                tx_pin <= 1'b1;
            end else begin
                tx_pin <= shift_register[0];
                shift_register <= { 1'b0, shift_register[9:1] };
                bitcount <= bitcount - 4'h1;
                done <= 1'b0;
            end
        end
    end
endmodule
