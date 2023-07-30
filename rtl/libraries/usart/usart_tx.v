module usart_tx (
    input serial_clock,
    input [11:0] clocks_per_bit,
    output reg bit_clock = 1'b0,

    input [7:0] data_in,
    input valid,
    output reg ready,

    output reg done,
    output reg tx_pin
);

    localparam IDLE = 0;
    localparam START_BIT = 1;
    localparam DATA_BIT = 2;
    localparam STOP_BIT = 3;

    reg [11:0] clock_counter = 12'd0;

    reg [1:0] state = IDLE;
    reg [2:0] bit_counter = 3'd0;
    reg [7:0] data = 0;

    reg transmitting = 1'b0;

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
        ready <= 1'b0;

        case (state)
            IDLE: begin
                transmitting <= 1'b0;
                done <= 1'b0;
                tx_pin <= 1'b1;
                if (valid) begin
                    state <= START_BIT;
                    data <= data_in;
                end
            end
            START_BIT: begin
                transmitting <= 1'b1;
                done <= 1'b0;
                tx_pin <= 1'b0;
                state <= DATA_BIT;
                bit_counter <= 0;
            end
            DATA_BIT: begin
                transmitting <= 1'b1;
                done <= 1'b0;
                tx_pin <= data[bit_counter];
                if (bit_counter == 3'd7) begin
                    state <= STOP_BIT;
                end else begin
                    state <= DATA_BIT;
                    bit_counter <= bit_counter + 3'd1;
                end
            end
            STOP_BIT: begin
                transmitting <= 1'b1;
                ready <= 1'b1;
                tx_pin <= 1'b1;
                state <= IDLE;
            end
        endcase
    end
endmodule
