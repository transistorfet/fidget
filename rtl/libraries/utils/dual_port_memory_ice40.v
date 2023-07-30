module dual_port_memory #(
    parameter WIDTH = 8,
    parameter DEPTH = 512
) (
    input read_clock_enable,
    input read_clock,
    input read_enable,
    input [$clog2(DEPTH)-1:0] read_addr,
    output [WIDTH-1:0] read_data,

    input write_clock_enable,
    input write_clock,
    input write_enable,
    input [$clog2(DEPTH)-1:0] write_addr,
    input [WIDTH-1:0] write_data
);

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram (
        .MASK(16'h0000),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data)
    );

endmodule
