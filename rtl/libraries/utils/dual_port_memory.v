module dual_port_memory #(
    parameter WIDTH = 8,
    parameter DEPTH = 512
) (
    input read_clock_enable,
    input read_clock,
    input read_enable,
    input [$clog2(DEPTH)-1:0] read_addr,
    output reg [WIDTH-1:0] read_data = 0,
    input write_clock_enable,
    input write_clock,
    input write_enable,
    input [$clog2(DEPTH)-1:0] write_addr,
    input [WIDTH-1:0] write_data
);

    reg [WIDTH-1:0] memory[0:DEPTH-1];

    always @(posedge read_clock) begin
        if (read_clock_enable && read_enable) begin
            read_data <= memory[read_addr];
        end
    end

    always @(posedge write_clock) begin
        if (write_clock_enable && write_enable) begin
            memory[write_addr] <= write_data;
        end
    end
endmodule
