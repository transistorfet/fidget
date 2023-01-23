module usart_tx (
    input clock,
    input [7:0] tx_data,

    input serial_clock,
    input tx_enable,
    output reg tx_pin = 1
);

    reg [1:0] reset = 0;
    reg transmitting = 0;
    reg [3:0] bitcount = 0;
    reg [9:0] shift_register;

    always_ff @(posedge serial_clock)
    begin
        reset[0] <= tx_enable;
        reset[1] <= reset[0];

        if (!transmitting) begin
            if (reset[1]) begin
                shift_register = { 1'b1, tx_data, 1'b0 };
                transmitting = 1'b1;
                bitcount = 10;
            end
        end
        else begin
            if (bitcount == 0)
                transmitting = 1'b0;
            else begin
                tx_pin = shift_register[0];
                shift_register = { 1'b0, shift_register[9:1] };
                bitcount = bitcount - 1;
            end
        end
    end

endmodule
