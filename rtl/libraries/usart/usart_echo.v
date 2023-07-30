/// A USART module that transmits to `tx_pin` every byte received on `rx_pin`
///
/// `clock`: A serial-compatible clock, typically 3.6864MHz
/// `clocks_per_bit`: The number to count to in order to produce the baud clock.
///                  Supports as high as 230,200 baud at 3.6864MHz, as low as 9600 baud at 22.1184MHz
module usart_echo(
    input comm_clock,
    input serial_clock,
    input [11:0] clocks_per_bit,

    input rx_pin,
    output rts_pin,
    output tx_pin,
    output rx_led
);

    localparam NOP = 0;
    localparam SET_CTRL = 1;
    localparam SET_DATA = 2;

    wire [7:0] tx_data_in;
    wire [7:0] rx_data_out;
    wire tx_bit_clock;
    wire tx_done;
    wire tx_valid;
    wire tx_ready;
    reg data_ready = 1'b0;
    wire rx_sample_clock;
    reg rx_reset = 1'b0;
    wire rx_valid;
    wire rx_ready;
    wire rx_error;

    assign rx_led = rx_valid;

    usart_rx usart_rx(
        .serial_clock(serial_clock),
        .clocks_per_bit(clocks_per_bit),
        .sample_clock(rx_sample_clock),
        .reset(rx_reset),
        .valid(rx_valid),
        .ready(rx_ready),
        .data_out(rx_data_out),
        .error(rx_error),
        .rx_pin(rx_pin),
        .rts_pin(rts_pin)
    );

/*
    reg tx_valid;
    wire tx_ready;
    reg [7:0] tx_data_in = 8'h00;

    always @(posedge tx_bit_clock) begin
        if (!tx_valid && !tx_ready) begin
            tx_valid <= 1'b1;
            tx_data_in <= tx_data_in + 8'd1;
            if (tx_data_in > 8'h7f) begin
                tx_data_in <= 0;
            end
        end

        if (tx_valid && tx_ready) begin
            tx_valid <= 1'b0;
        end
    end

    reg rx_valid = 1'b0;
    wire rx_ready;
    reg [7:0] rx_data_out = 8'h30;

    always @(posedge comm_clock) begin
        if (!rx_valid && !rx_ready) begin
            rx_valid <= 1'b1;
            rx_data_out <= rx_data_out + 8'h01;
            if (rx_data_out > 8'h7f) begin
                rx_data_out <= 8'h00;
            end
        end

        if (rx_valid && rx_ready) begin
            rx_valid <= 1'b0;
        end
    end
*/

    async_fifo #(
        .DEPTH(128)
    ) fifo (
        .reset(rx_reset),

        .in_clock(rx_sample_clock),
        .in_valid(rx_valid),
        .in_ready(rx_ready),
        .in_data(rx_data_out),
        .in_almost_full(),

        .out_clock(tx_bit_clock),
        .out_valid(tx_valid),
        .out_ready(tx_ready),
        .out_data(tx_data_in),
        .out_almost_empty()
    );

    usart_tx usart_tx(
        .serial_clock(serial_clock),
        .clocks_per_bit(clocks_per_bit),
        .bit_clock(tx_bit_clock),
        .valid(tx_valid),
        .ready(tx_ready),
        .data_in(tx_data_in),
        .done(tx_done),
        .tx_pin(tx_pin)
    );
endmodule
