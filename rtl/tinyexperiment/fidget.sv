`include "computie_ad_pins.sv"

module fidget(
    input clk_16M,
    input output_enable,
    inout [1:0] pins_ad
);

    computie_ad_pins bus_pins(
        .clk(clk_16M),
        .output_enable(output_enable),
        .pins_ad(pins_ad)
    );

endmodule
 
