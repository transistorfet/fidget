 module usart_rx (
    input comm_clock,
    input bit_clock_x16,
    input reset,

    output reg [7:0] data_out,
    output reg available,
    output reg error,
    input acknowledge,

    input rx_pin
);

    localparam RESET = 2'h0;
    localparam START_BIT = 2'h1;
    localparam DATA_BIT = 2'h2;
    localparam STOP_BIT = 2'h3;

    reg [1:0] state = START_BIT;
    reg [3:0] counter = 4'h0;
    reg [2:0] bit_counter = 3'b0;
    reg [7:0] shift_reg = 8'h0;
    reg [1:0] rx_pin_fifo = 2'b0;
    reg success = 1'b0;
    reg failure = 1'b0;
    reg acknowledge_reg = 1'b0;

    initial begin
        available <= 1'b0;
        error <= 1'b0;
    end

    always @(posedge bit_clock_x16) begin
        rx_pin_fifo = { rx_pin, rx_pin_fifo[1] };

        if (reset == 1'b1) begin
            state = RESET;
        end

        case (state)
            RESET: begin
                state <= START_BIT;
                counter <= 0;
                shift_reg <= 8'b0;
                bit_counter <= 0;
                data_out <= 8'h0;
                success <= 1'b0;
                failure <= 1'b0;
            end

            START_BIT: begin
                if (rx_pin_fifo[0] == 1'b0) begin
                    if (counter == 4'h7) begin
                        state <= DATA_BIT;
                        counter <= 0;
                    end else begin
                        state <= START_BIT;
                        counter <= counter + 4'h1;
                    end
                end else begin
                    state <= START_BIT;
                    counter <= 0;
                end

                bit_counter <= 0;
                shift_reg <= 8'b0;
                data_out <= 8'h0;
                success <= 1'b0;
                failure <= 1'b0;
            end

            DATA_BIT: begin
                if (counter == 4'hF) begin
                    shift_reg <= { rx_pin_fifo[0], shift_reg[7:1] };
                    counter <= 0;
                    if (bit_counter == 3'h7) begin
                        state <= STOP_BIT;
                        bit_counter <= 3'b0;
                    end else begin
                        state <= DATA_BIT;
                        bit_counter <= bit_counter + 4'h1;
                    end
                end else begin
                    shift_reg <= shift_reg;
                    counter <= counter + 4'h1;
                    state <= DATA_BIT;
                    bit_counter <= bit_counter;
                end

                data_out <= 8'h0;
                success <= 1'b0;
                failure <= 1'b0;
            end

            STOP_BIT: begin
                if (counter == 4'hF) begin
                    state <= START_BIT;
                    counter <= 1'b0;

                    if (rx_pin_fifo[0] == 1'b1) begin
                        success <= 1'b1;
                    end else begin
                        failure <= 1'b1;
                    end
                end else begin
                    state <= STOP_BIT;
                    counter <= counter + 4'h1;
                end

                bit_counter <= 4'h0;
                data_out <= shift_reg;
            end
        endcase
    end

    always @(posedge comm_clock) begin
        if (acknowledge && !acknowledge_reg) begin
            acknowledge_reg <= 1'b1;
            available <= 1'b0;
            error <= 1'b0;
        end else if (!acknowledge_reg) begin
            available <= success;
            error <= failure;
        end

        if (acknowledge_reg == 1'b1 && state == DATA_BIT) begin
            acknowledge_reg <= 1'b0;
        end
    end

endmodule
