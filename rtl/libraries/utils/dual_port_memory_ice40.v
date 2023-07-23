module dual_port_memory(
    input read_clock_enable,
    input read_clock,
    input read_enable,
    input [8:0] read_addr,
    output [7:0] read_data,
    input write_clock_enable,
    input write_clock,
    input write_enable,
    input [8:0] write_addr,
    input [7:0] write_data
);

    SB_RAM512x8 ram512x8_inst (
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
