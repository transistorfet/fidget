module dual_port_memory #(
    parameter WIDTH = 8,
    parameter DEPTH = 512
) (
    input write_clock_enable,
    input write_clock,
    input write_enable,
    input [$clog2(DEPTH)-1:0] write_addr,
    input [79:0] write_data,

    input read_clock_enable,
    input read_clock,
    input read_enable,
    input [$clog2(DEPTH)-1:0] read_addr,
    output [79:0] read_data,
);

/*
    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data)
    );
*/

/*
    genvar i;

    generate
        for (i = 0; i < WIDTH / 16; i = i + 1) begin
            SB_RAM40_4K #(
                .READ_MODE(0),
                .WRITE_MODE(0)
            ) ram (
                .MASK(16'h0000),

                .WCLKE(write_clock_enable),
                .WCLK(write_clock),
                .WE(write_enable),
                .WADDR(write_addr),
                .WDATA(write_data[i * 16 + 16 - 1:i * 16]),

                .RCLKE(read_clock_enable),
                .RCLK(read_clock),
                .RE(read_enable),
                .RADDR(read_addr),
                .RDATA(read_data[i * 16 + 16 - 1:i * 16])
            );
        end
    endgenerate
*/

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram0 (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data[15:0]),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data[15:0])
    );

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram1 (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data[31:16]),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data[31:16])
    );

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram2 (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data[47:32]),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data[47:32])
    );

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram3 (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data[63:48]),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data[63:48])
    );

    SB_RAM40_4K #(
        .READ_MODE(0),
        .WRITE_MODE(0)
    ) ram4 (
        .MASK(16'h0000),
        .WCLKE(write_clock_enable),
        .WCLK(write_clock),
        .WE(write_enable),
        .WADDR(write_addr),
        .WDATA(write_data[79:64]),
        .RCLKE(read_clock_enable),
        .RCLK(read_clock),
        .RE(read_enable),
        .RADDR(read_addr),
        .RDATA(read_data[79:64])
    );

endmodule
