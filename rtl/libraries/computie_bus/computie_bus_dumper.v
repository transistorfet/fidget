module computie_bus_dumper #(
    parameter BITWIDTH = 32,
    parameter MODWIDTH = 1,
    parameter DEPTH = 512,
) (
    input comm_clock,

    // Dump Interface
    input dump_start,
    output reg dump_end,
    output reg led,

    // Byte-oriented Output (serial)
    output reg out_valid,
    input out_ready,
    output reg [7:0] out_data,

    // Bus-oriented Input (computie bus)
    output reg record_in_enable,
    output reg [$clog2(DEPTH):0] record_in_max,
    output reg [$clog2(DEPTH):0] record_in_request,
    input [BITWIDTH * 2 + MODWIDTH - 1:0] record_in
);
    localparam DUMP_IDLE = 0;
    localparam DUMP_HEADER = 1;
    localparam DUMP_START_ENTRY = 2;
    localparam DUMP_NUMBER = 3;
    localparam DUMP_SEPARATOR = 4;
    localparam DUMP_END_ENTRY = 5;
    localparam DUMP_FOOTER = 6;

    reg [2:0] dump_state = DUMP_IDLE;
    reg [2:0] dump_digit = 3'd7;
    reg [3:0] dump_value[BITWIDTH / 4];
    reg dump_addr_data = 1'b1;
    reg [$clog2(DEPTH):0] record_in_request = 0;

    always @(posedge comm_clock) begin
        dump_end <= 1'b0;
        record_in_enable <= 1'b0;

        case (dump_state)
            DUMP_IDLE: begin
                if (dump_start) begin
                    record_in_request <= 0;
                    dump_state <= DUMP_HEADER;
                end
            end
            DUMP_HEADER: begin
                out_valid <= 1'b1;
                out_data <= "\n";
                if (out_valid && out_ready) begin
                    record_in_enable <= 1'b1;
                    out_valid <= 1'b0;
                    dump_state <= DUMP_START_ENTRY;
                end
            end
            DUMP_START_ENTRY: begin
                out_valid <= 1'b1;
                out_data <= record_in[BITWIDTH * 2] ? "R" : "W";
                if (out_valid && out_ready) begin
                    out_valid <= 1'b0;
                    { dump_value[7], dump_value[6], dump_value[5], dump_value[4], dump_value[3], dump_value[2], dump_value[1], dump_value[0] }  <= record_in[BITWIDTH * 2 - 1:BITWIDTH];
                    dump_digit <= 3'd7;
                    dump_state <= DUMP_NUMBER;
                    dump_addr_data <= 1'b1;
                end
            end
            DUMP_SEPARATOR: begin
                out_valid <= 1'b1;
                out_data <= ":";
                if (out_valid && out_ready) begin
                    out_valid <= 1'b0;
                    dump_digit <= 3'd7;
                    { dump_value[7], dump_value[6], dump_value[5], dump_value[4], dump_value[3], dump_value[2], dump_value[1], dump_value[0] } <= record_in[BITWIDTH - 1:0];
                    dump_state <= DUMP_NUMBER;
                    dump_addr_data <= 1'b0;
                end
            end
            DUMP_NUMBER: begin
                out_valid <= 1'b1;

                if (dump_value[dump_digit] <= 8'h09) begin
                    out_data <= dump_value[dump_digit] + 8'h30;
                end else begin
                    out_data <= dump_value[dump_digit] + 8'h37;
                end

                if (out_valid && out_ready) begin
                    out_valid <= 1'b0;
                    if (dump_digit == 3'd0) begin
                        if (dump_addr_data) begin
                            dump_state <= DUMP_SEPARATOR;
                        end else begin
                            dump_state <= DUMP_END_ENTRY;
                        end
                    end else begin
                        dump_state <= DUMP_NUMBER;
                        dump_digit <= dump_digit - 3'd1;
                    end
                end
            end
            DUMP_END_ENTRY: begin
                out_valid <= 1'b1;
                out_data <= "\n";
                if (out_valid && out_ready) begin
                    out_valid <= 1'b0;
                    dump_digit <= 0;
                    if (record_in_request == record_in_max) begin
                        dump_state <= DUMP_FOOTER;
                    end else begin
                        dump_state <= DUMP_START_ENTRY;
                        record_in_request <= record_in_request + 1;
                    end
                end
            end
            DUMP_FOOTER: begin
                dump_end <= 1'b1;
                out_valid <= 1'b1;
                out_data <= "\n";
                if (out_valid && out_ready) begin
                    out_valid <= 1'b0;
                    dump_state <= DUMP_IDLE;
                end
            end
        endcase
    end
endmodule
