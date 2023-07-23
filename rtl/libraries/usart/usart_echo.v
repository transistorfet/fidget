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
    output tx_pin
);

    localparam NOP = 0;
    localparam SET_CTRL = 1;
    localparam SET_DATA = 2;

    reg [7:0] data_in = 8'h0;
    wire [7:0] data_out;
    wire tx_done;
    reg tx_valid = 1'b0;
    wire tx_ready;
    reg data_ready = 1'b0;
    reg rx_reset = 1'b0;
    wire rx_valid;
    reg rx_ready = 1'b0;
    wire rx_error;

    usart_tx usart_tx(
        .comm_clock(comm_clock),
        .serial_clock(serial_clock),
        .clocks_per_bit(clocks_per_bit),
        .data_in(data_in),
        .valid(tx_valid),
        .ready(tx_ready),
        .done(tx_done),
        .tx_pin(tx_pin)
    );

    usart_rx usart_rx(
        .comm_clock(comm_clock),
        .serial_clock(serial_clock),
        .clocks_per_bit(clocks_per_bit),
        .reset(rx_reset),
        .data_out(data_out),
        .valid(rx_valid),
        .ready(rx_ready),
        .error(rx_error),
        .rx_pin(rx_pin),
        .rts_pin(rts_pin)
    );

    always @(posedge comm_clock) begin
        tx_valid <= data_ready && !tx_ready;
    end

    always @(posedge comm_clock) begin
        if (rx_valid == 1'b1) begin
            data_in <= data_out;
            rx_ready <= 1'b1;
            data_ready <= 1'b1;
        end else if (tx_ready == 1'b1) begin
            data_ready <= 1'b0;
        end else begin
            rx_ready <= 1'b0;
        end
    end
endmodule
