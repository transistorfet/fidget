module fidget(
    input pin_clk_16M,

    input pin_button1,

    output pin_led1,
    output pin_led2,
    output pin_led3,
    output pin_led4,
);

    assign pin_led1 = 1'b1;
    assign pin_led2 = output1;
    assign pin_led3 = output2;
    assign pin_led4 = pin_button1;

    reg [31:0] count = 0;
    reg output1;
    reg output2;
    reg output3;
    reg output4;

    always_ff @(negedge pin_clk_16M) begin
        count = count + 1;
        output1 = count[24];
        output2 = count[25];
    end

endmodule
