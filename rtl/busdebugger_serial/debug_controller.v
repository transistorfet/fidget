module debug_controller(
    input comm_clock,

    input in_empty,
    output reg in_ready,
    input in_valid,
    input [7:0] in_data,

    // Signal to the record module to start recording
    output record_start,
    input record_done
);

    localparam START_MSG = 2'h0;
    localparam CMD_RECEIVED = 2'h1;
    localparam OPERAND_RECEIVED = 2'h2;
    localparam EXECUTING = 2'h3;

    localparam CMD_RECORD = 8'h30;

    reg [1:0] state = START_MSG;
    reg [7:0] command = 8'h00;

    always @(comm_clock) begin
        case (state)
            START_MSG: begin
                in_ready <= 1'b1;
                if (in_valid) begin
                    command <= in_valid;
                    state <= CMD_RECEIVED;
                end
            end

            CMD_RECEIVED: begin
                if (command == CMD_RECORD) begin
                    
                end
            end
        endcase
    end
endmodule
