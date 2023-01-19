module computie_bus_io(
    input output_enable,
    inout [1:0] pins_ad,

    input [1:0] in_data,
    output [1:0] out_data
);

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) ad [1:0] (
        .PACKAGE_PIN(pins_ad),
        .OUTPUT_ENABLE(output_enable),
        .D_OUT_0(in_data),
        .D_IN_0(out_data)
    );

endmodule
