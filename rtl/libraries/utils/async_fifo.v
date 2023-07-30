/// An dual-clock asynchronous FIFO, optionally using dual port block RAM
///
/// This module should be a safe way of crossing clock domains.  Compiling in the
//// dual_port_memory_ice40.v file will use a block RAM library module internally.
module async_fifo #(
    parameter WIDTH = 8,
    parameter DEPTH = 512,
    parameter ALMOST_FULL = 0,
    parameter ALMOST_EMPTY = 0
) (
    input reset,

    input in_clock,
    input in_valid,
    output reg in_ready = 1'b0,
    input [WIDTH-1:0] in_data,
    output in_almost_full,

    input out_clock,
    output reg out_valid = 1'b0,
    input out_ready,
    output [WIDTH-1:0] out_data,
    output out_almost_empty
);

    reg in_enable = 1'b0;
    reg [$clog2(DEPTH)-1:0] in_pointer = 0;
    wire [$clog2(DEPTH)-1:0] in_pointer_gray;
    wire [$clog2(DEPTH)-1:0] in_pointer_gray_out_clock;
    reg out_enable = 1'b0;
    reg [$clog2(DEPTH)-1:0] out_pointer = 0;
    wire [$clog2(DEPTH)-1:0] out_pointer_gray;
    wire [$clog2(DEPTH)-1:0] out_pointer_gray_in_clock;

    reg out_empty;
    reg in_full;

    dual_port_memory fifo(
        .read_clock_enable(1'b1),
        .read_clock(out_clock),
        .read_enable(out_enable),
        .read_addr(out_pointer),
        .read_data(out_data),
        .write_clock_enable(1'b1),
        .write_clock(in_clock),
        .write_enable(in_enable),
        .write_addr(in_pointer),
        .write_data(in_data)
    );

    assign in_pointer_gray = (in_pointer >> 1'b1) ^ in_pointer;
    assign out_pointer_gray = (out_pointer >> 1'b1) ^ out_pointer;

    synchronizer #(.WIDTH($clog2(DEPTH))) in_sync (
        .clock(in_clock),
        .reset(reset),
        .in(out_pointer_gray),
        .out(out_pointer_gray_in_clock)
    );

    synchronizer #(.WIDTH($clog2(DEPTH))) out_sync (
        .clock(out_clock),
        .reset(reset),
        .in(in_pointer_gray),
        .out(in_pointer_gray_out_clock)
    );

    //assign out_almost_empty = (out_pointer == in_pointer);
    //assign in_almost_full = (in_pointer + 1 == out_pointer);
    assign out_almost_empty = out_empty;
    assign in_almost_full = in_full;

    always @(posedge in_clock) begin
        //in_full <= in_pointer_gray + 1 == out_pointer_gray_in_clock;
        in_full <= in_pointer_gray == { ~out_pointer_gray_in_clock[$clog2(DEPTH) - 1:$clog2(DEPTH) - 2], out_pointer_gray_in_clock[$clog2(DEPTH) - 3:0] };

        if (in_valid && !in_full) begin
            in_enable <= 1'b1;

            if (in_enable) begin
                in_ready <= 1'b1;
            end
        end

        if (in_ready && !in_valid) begin
            in_enable <= 1'b0;
            in_ready <= 1'b0;
            in_pointer <= in_pointer + 'd1;
        end
    end

    always @(posedge out_clock) begin
        out_empty <= out_pointer_gray == in_pointer_gray_out_clock;

        if (!out_empty) begin
            out_enable <= 1'b1;

            if (out_enable) begin
                out_valid <= 1'b1;
            end
        end

        if (out_valid && out_ready) begin
            out_enable <= 1'b0;
            out_valid <= 1'b0;
            out_pointer <= out_pointer + 'd1;
        end
    end
endmodule
