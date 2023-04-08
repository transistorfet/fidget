module fidget(
    input pin_clk_16M,

    input pin_button1,

    output pin_led1,
    output pin_led2,
    output pin_led3,
    output pin_led4,
);

    assign pin_led1 = output1;
    assign pin_led2 = output2;
    assign pin_led3 = 1'b0;
    assign pin_led4 = !pin_button1;

    reg [31:0] count = 0;
    reg output1;
    reg output2;
    reg output3;
    reg output4;

    always_ff @(negedge pin_clk_16M) begin
        count = count + 1;
        output1 = count[23];
        output2 = count[24];
    end

endmodule
