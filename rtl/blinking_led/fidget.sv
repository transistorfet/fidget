module fidget(
    input pin_clk_16M,

    output pin_led1,
    output pin_led2,
    output pin_led3,
    output pin_led4,
);

    assign pin_led0 = 1'b1;

    reg [23:0] count = 0;
    reg output1;
    reg output2;
    reg output3;
    reg output4;

    always_ff @(negedge pin_clk_16M) begin
        if (count > 24'd16000000) begin
            count = count + 1;
        end else begin
            count = 0;

            output1 = !output1;
            if (output1 == 1)
                output2 = !output2;
        end

        pin_led1 = output1;
        pin_led2 = output2;
    end

endmodule
