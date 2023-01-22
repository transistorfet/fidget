module computie_bus_demux(
    input output_enable,
    inout [BITWIDTH-1:0] pins_ad,

    input [BITWIDTH-1:0] from_bus,
    output [BITWIDTH-1:0] to_bus
);

    parameter BITWIDTH = 32;

    SB_IO #(
        .PIN_TYPE(6'b 1010_01),
        .PULLUP(1'b 0)
    ) ad [BITWIDTH-1:0] (
        .PACKAGE_PIN(pins_ad),
        .OUTPUT_ENABLE(output_enable),
        .D_IN_0(from_bus),
        .D_OUT_0(to_bus)
    );

endmodule
