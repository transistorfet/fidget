/// A FIFO with only one clock
module sync_fifo #(
    parameter DEPTH = 128
) (
    input comm_clock,
    input reset,

    input in_valid,
    output reg in_ready,
    input [7:0] in_data,
    output in_full,

    input out_ready,
    output reg out_valid,
    output reg [7:0] out_data,
    output out_empty
);

    reg [$clog2(DEPTH):0] read = 0;
    reg [$clog2(DEPTH):0] write = 0;
    reg [DEPTH-1:0][7:0] fifo;

    assign out_empty = (read == write);
    assign in_full = (write + 1 == read);

    always @(posedge comm_clock) begin
        out_data <= 8'h00;
        if (reset) begin
            in_ready <= 1'b0;
            out_valid <= 1'b0;
            read <= 0;
            write <= 0;
        end else begin
            in_ready <= 1'b0;
            if (in_valid && !in_ready) begin
                if (!in_full) begin
                    in_ready <= 1'b1;
                    write <= write + 1;
                    fifo[write] <= in_data;
                end
            end

            out_valid <= 1'b0;
            if (out_ready && !out_valid) begin
                if (!out_empty) begin
                    out_valid <= 1'b1;
                    read <= read + 1;
                    out_data <= fifo[read];
                end
            end
        end
    end
endmodule
