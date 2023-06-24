/// A USART module that transmits to `tx_pin` every byte received on `rx_pin`
///
/// `clock`: A serial-compatible clock, typically 3.6864MHz
/// `clock_divider`: The number to count to in order to produce the baud clock.
///                  Supports as high as 230,200 baud at 3.6864MHz, as low as 9600 baud at 22.1184MHz
module usart_echo(
    input comm_clock,
    input serial_clock,
    input [11:0] clock_divider,

    output reg bit_clock_x1,
    output reg bit_clock_x16,

    input rx_pin,
    output tx_pin
);

    localparam NOP = 0;
    localparam SET_CTRL = 1;
    localparam SET_DATA = 2;

    //reg bit_clock_x1 = 1'b0;
    //reg bit_clock_x16 = 1'b0;
    reg [8:0] counter_x16 = 8'd0;
    reg [11:0] counter_x1 = 11'd0;

    reg [7:0] data_in = 8'h0;
    wire [7:0] data_out;
    wire tx_done;
    reg latch_in = 1'b0;
    wire tx_ready;
    reg data_ready = 1'b0;
    reg rx_reset = 1'b0;
    wire rx_available;
    wire rx_error;
    reg rx_acknowledge = 1'b0;

    usart_tx usart_tx(
        .bit_clock_x1(bit_clock_x1),
        .data_in(data_in),
        .latch_in(latch_in),
        .ready(tx_ready),
        .done(tx_done),
        .tx_pin(tx_pin)
    );

    usart_rx usart_rx(
        .comm_clock(comm_clock),
        .bit_clock_x16(bit_clock_x16),
        .reset(rx_reset),
        .data_out(data_out),
        .available(rx_available),
        .error(rx_error),
        .acknowledge(rx_acknowledge),
        .rx_pin(rx_pin)
    );

    always @(posedge serial_clock) begin
        if (counter_x16 == clock_divider[11:4] - 8'h1) begin
            counter_x16 <= 8'b0;
            bit_clock_x16 <= 1'b1;
        end else begin
            counter_x16 <= counter_x16 + 8'b1;
            bit_clock_x16 <= 1'b0;
        end

        if (counter_x1 == clock_divider - 12'd1) begin
            counter_x1 <= 12'd0;
            bit_clock_x1 <= 1'b1;
        end else begin
            counter_x1 <= counter_x1 + 12'd1;
            bit_clock_x1 <= 1'b0;
        end
    end

    always @(*) begin
        latch_in <= data_ready && !tx_ready;
    end

    always @(posedge comm_clock) begin
        if (rx_available == 1'b1) begin
            data_in <= data_out;
            rx_acknowledge <= 1'b1;
            data_ready <= 1'b1;
        end else if (tx_ready == 1'b1) begin
            data_ready <= 1'b0;
        end else begin
            rx_acknowledge <= 1'b0;
        end
    end
endmodule
