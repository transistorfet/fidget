 module usart_rx (
    input serial_clock,
    input [11:0] clocks_per_bit,
    output reg sample_clock = 1'b1,
    input reset,

    output reg [7:0] data_out,
    output reg valid = 1'b0,
    input ready,
    output reg error,

    input rx_pin,
    output reg rts_pin
);

    localparam RESET = 3'h0;
    localparam START_BIT = 3'h1;
    localparam DATA_BIT = 3'h2;
    localparam STOP_BIT = 3'h3;
    localparam WAIT_ACK = 3'h4;

    reg [7:0] clock_counter = 8'd0;

    reg [2:0] state = START_BIT;
    reg [3:0] sample_counter = 4'h0;
    reg [2:0] bit_counter = 3'b0;
    reg [7:0] shift_reg = 8'h0;
    reg [1:0] rx_pin_fifo = 2'b0;

    initial begin
        error <= 1'b0;
    end

    always @(posedge serial_clock) begin
        if (clocks_per_bit[11:4] == 8'd0) begin
            sample_clock <= !sample_clock;
        end else if (clock_counter == clocks_per_bit[11:4] - 8'h1) begin
            clock_counter <= 8'b0;
            sample_clock <= 1'b1;
        end else begin
            clock_counter <= clock_counter + 8'b1;
            sample_clock <= 1'b0;
        end
    end

    always @(posedge sample_clock) begin
        rx_pin_fifo = { rx_pin, rx_pin_fifo[1] };

        if (reset == 1'b1) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                state <= START_BIT;
                sample_counter <= 0;
                shift_reg <= 8'b0;
                bit_counter <= 0;
                error <= 1'b0;
                rts_pin <= 1'b1;
            end

            START_BIT: begin
                if (rx_pin_fifo[0] == 1'b0) begin
                    if (sample_counter == 4'h7) begin
                        state <= DATA_BIT;
                        sample_counter <= 0;
                    end else begin
                        state <= START_BIT;
                        sample_counter <= sample_counter + 4'h1;
                    end
                end else begin
                    state <= START_BIT;
                    sample_counter <= 0;
                end

                bit_counter <= 0;
                shift_reg <= 8'b0;
                error <= 1'b0;
                rts_pin <= 1'b0;
            end

            DATA_BIT: begin
                if (sample_counter == 4'hF) begin
                    shift_reg <= { rx_pin_fifo[0], shift_reg[7:1] };
                    sample_counter <= 0;
                    if (bit_counter == 3'h7) begin
                        state <= STOP_BIT;
                        bit_counter <= 3'b0;
                    end else begin
                        state <= DATA_BIT;
                        bit_counter <= bit_counter + 4'h1;
                    end
                end else begin
                    shift_reg <= shift_reg;
                    sample_counter <= sample_counter + 4'h1;
                    state <= DATA_BIT;
                    bit_counter <= bit_counter;
                end

                error <= 1'b0;
                rts_pin <= 1'b0;
            end

            STOP_BIT: begin
                if (sample_counter == 4'hF) begin
                    if (rx_pin_fifo[0] == 1'b1) begin
                        valid <= 1'b1;
                        data_out <= shift_reg;
                    end else begin
                        error <= 1'b1;
                    end

                    state <= WAIT_ACK;
                    sample_counter <= 1'b0;
                end else begin
                    state <= STOP_BIT;
                    sample_counter <= sample_counter + 4'h1;
                end

                bit_counter <= 4'h0;
            end

            WAIT_ACK: begin
                if (ready) begin
                    valid <= 1'b0;
                    state <= START_BIT;
                end
            end
        endcase
    end
endmodule
