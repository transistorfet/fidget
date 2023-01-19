`include "computie_bus_io.sv"

module fidget(
    input clk_16M,
    input output_enable,
    inout [1:0] pins_ad,
    input [1:0] pins_in,
    output [1:0] pins_out,
);

    reg [1:0] in_data;
    reg [1:0] out_data;

    computie_bus_io bus_pins(
        .output_enable(output_enable),
        .pins_ad(pins_ad),
        .in_data(in_data),
        .out_data(out_data)
    );

    always @(posedge clk_16M) begin
        in_data <= pins_in;
        pins_out <= out_data;
    end

endmodule
 
