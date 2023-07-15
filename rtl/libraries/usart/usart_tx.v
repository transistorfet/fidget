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

    localparam IDLE = 0;
    localparam START_BIT = 1;
    localparam DATA_BIT = 2;
    localparam STOP_BIT = 3;

    reg bit_clock = 1'b0;
    reg [11:0] clock_counter = 12'd0;

    reg [1:0] state = IDLE;
    reg [2:0] bit_counter = 3'd0;
    reg [7:0] data = 0;

    reg start_transmitting = 1'b0;
    reg [1:0] start_transmitting_fifo = 2'b00;
    reg transmitting = 1'b0;
    reg [1:0] transmitting_fifo = 2'b00;
    reg [1:0] done_fifo = 2'b00;

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
        start_transmitting_fifo <= { start_transmitting, start_transmitting_fifo[1] };

        case (state)
            IDLE: begin
                transmitting <= 1'b0;
                done <= 1'b0;
                tx_pin <= 1'b1;
                if (start_transmitting_fifo[0]) begin
                    state <= START_BIT;
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
                done <= 1'b1;
                tx_pin <= 1'b1;
                state <= IDLE;
            end
        endcase
    end

    always @(posedge comm_clock) begin
        done_fifo <= { done, done_fifo[1] };
        transmitting_fifo <= { transmitting, transmitting_fifo[1] };
        ready <= 1'b0;

        if (!start_transmitting && !transmitting_fifo[0] && valid) begin
            start_transmitting <= 1'b1;
            data <= data_in;
        end

        if (start_transmitting && transmitting_fifo[0] && done_fifo[0]) begin
            start_transmitting <= 1'b0;
            ready <= 1'b1;
        end
    end

endmodule
