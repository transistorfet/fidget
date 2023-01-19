module computie_ad_pins(
    input clk,
    input output_enable,
    inout [1:0] pins_ad
);

    reg [1:0] in_data;
    reg [1:0] out_data;

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) ad [1:0] (
        .PACKAGE_PIN(pins_ad),
        .OUTPUT_ENABLE(output_enable),
        .D_OUT_0(in_data),
        .D_IN_0(out_data)
    );

/*
    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) ad_1 (
        .PACKAGE_PIN(pin_ad1),
        .OUTPUT_ENABLE(output_enable),
        .D_OUT_0(out_ad_1),
        .D_IN_0(in_ad_1)
    );

    always @(posedge clk) begin
        if (output_enable) begin
            //out_ad_0 <= out_data[0];
            //out_ad_1 <= out_data[1];
        end else begin
            //in_data = {
            //    in_ad_0,
            //    in_ad_1
            //};
        end
    end
*/

endmodule
