module synchronizer #(
    parameter WIDTH = 1,
    parameter DEPTH = 1
) (
    input clock,
    input reset,

    input [WIDTH-1:0] in,
    output reg [WIDTH-1:0] out = 0
);

    reg [WIDTH-1:0] fifo [0:DEPTH-1];
    integer i;

    initial begin
        for (i = 0; i < DEPTH; i = i + 1) begin
            fifo[i] = 0;
        end
    end

    always @(posedge clock) begin
        if (reset) begin
            for (i = DEPTH - 1; i >= 0; i = i - 1) begin
                fifo[i] <= 0;
            end
            out <= 0;
        end else begin
            out <= fifo[0];
            for (i = DEPTH - 1; i > 0; i = i - 1) begin
                fifo[i] <= fifo[i - 1];
            end
            fifo[DEPTH-1] <= in;
        end
    end
endmodule
