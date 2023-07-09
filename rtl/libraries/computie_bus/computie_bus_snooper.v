`define DIR_TO_AD   DIR_OUTPUT_TO_A
`define DIR_FROM_AD   DIR_OUTPUT_TO_B

module computie_bus_snooper #(
    parameter BITWIDTH = 32,
    parameter DEPTH = 32
) (
    input comm_clock,

    // Internal Interface
    input record_start,
    output reg record_end,
    input record_trigger,

    input dump_start,
    output reg dump_end,
    output reg out_valid,
    input out_ready,
    output reg [7:0] out_data,

    // Bus Control Signals
    input cb_clk,
    input cb_addr_strobe,
    input cb_data_strobe,
    input cb_read_write,
    input [BITWIDTH-1:0] cb_addr_data_bus,

    // Transceiver Control
    output send_receive,
    output reg addr_oe = 1'b1,
    output reg data_oe = 1'b1,
    output data_dir,
    output ctrl_oe,
    output alt_ctrl_oe,
    output alt_ctrl_dir1,
    output alt_ctrl_dir2,
    output al_oe,
    output al_le,

    output reg led
);

    localparam ACTIVE = 1'b0;
    localparam INACTIVE = 1'b1;

    localparam BUS_RESET = 0;
    localparam BUS_IDLE = 1;
    localparam BUS_RECV_DATA = 2;
    localparam BUS_WAIT_FOR_END = 3;

    reg [2:0] state = BUS_IDLE;

    reg [BITWIDTH-1:0] address_records[0:DEPTH-1];
    reg [BITWIDTH-1:0] data_records[0:DEPTH-1];
    reg [$clog2(DEPTH):0] record_count = 0;


    // For snooping, the bus direction will always be "RECEIVE"
    assign send_receive = 1'b0;
    // For snooping, the direction is always receiving
    assign data_dir = 1'b0;

    // Enable control signal transceivers in the direction of a bus device
    assign ctrl_oe = 1'b0;
    assign alt_ctrl_oe = 1'b0;
    assign alt_ctrl_dir1 = 1'b0;
    // This probably caused interference on the bus because it's only supposed to snoop, not be a receiver
    //assign alt_ctrl_dir2 = 1'b1;
    assign alt_ctrl_dir2 = 1'b0;

    // Disable the address latch
    assign al_oe = 1'b1;
    assign al_le = 1'b0;

    always @(posedge cb_clk) begin
        //if (record_start) begin
        //    if (record_count >= DEPTH) begin
        //        record_end <= 1'b1;
        //        state <= BUS_RESET;
        //    end else begin
        //        record_end <= 1'b0;
        //    end
        //end

        if (!record_start || record_count == DEPTH) begin
            state <= BUS_RESET;
        end

        addr_oe <= INACTIVE;
        data_oe <= INACTIVE;
        case (state)
            BUS_RESET: begin
                addr_oe <= INACTIVE;
                data_oe <= INACTIVE;
                state <= BUS_IDLE;
            end
            BUS_IDLE: begin
                if (cb_addr_strobe == ACTIVE) begin
                    led <= 1'b1;
                    addr_oe <= ACTIVE;
                    data_oe <= INACTIVE;
                    address_records[record_count] <= cb_addr_data_bus;
                    state <= BUS_RECV_DATA;
                end
            end
            BUS_RECV_DATA: begin
                if (cb_data_strobe == ACTIVE) begin
                    led <= 1'b0;
                    addr_oe <= INACTIVE;
                    data_oe <= ACTIVE;
                    state <= BUS_WAIT_FOR_END;
                end
            end
            BUS_WAIT_FOR_END: begin
                if (cb_data_strobe == INACTIVE) begin
                    addr_oe <= INACTIVE;
                    data_oe <= INACTIVE;
                    data_records[record_count] <= cb_addr_data_bus;
                    record_count <= record_count + 1;
                    state <= BUS_IDLE;
                end
            end
        endcase
    end

    localparam DUMP_START = 0;
    localparam DUMP_NUMBER = 1;
    localparam DUMP_SEPARATOR = 2;
    localparam DUMP_END = 3;

    reg [2:0] dump_state = DUMP_START;
    reg [2:0] dump_digit = 3'd7;
    reg [3:0] dump_value[BITWIDTH / 4];
    reg dump_addr_data = 1'b1;
    reg [$clog2(DEPTH):0] dump_count = 0;

    always @(posedge comm_clock) begin
        out_valid <= 1'b0;

        if (dump_start) begin
            if (dump_count == record_count) begin
                dump_end <= 1'b1;
            end else begin
                dump_end <= 1'b0;
                case (dump_state)
                    DUMP_START: begin
                        out_valid <= 1'b1;
                        out_data <= cb_read_write ? "R" : "W";
                        if (out_ready) begin
                            out_valid <= 1'b0;
                            { dump_value[7], dump_value[6], dump_value[5], dump_value[4], dump_value[3], dump_value[2], dump_value[1], dump_value[0] }  <= address_records[dump_count];
                            dump_digit <= 3'd7;
                            dump_state <= DUMP_NUMBER;
                            dump_addr_data <= 1'b1;
                        end
                    end
                    DUMP_SEPARATOR: begin
                        out_valid <= 1'b1;
                        out_data <= ":";
                        if (out_ready) begin
                            out_valid <= 1'b0;
                            dump_digit <= 3'd7;
                            { dump_value[7], dump_value[6], dump_value[5], dump_value[4], dump_value[3], dump_value[2], dump_value[1], dump_value[0] } <= data_records[dump_count];
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

                        if (out_ready) begin
                            out_valid <= 1'b0;
                            if (dump_digit == 3'd0) begin
                                if (dump_addr_data) begin
                                    dump_state <= DUMP_SEPARATOR;
                                end else begin
                                    dump_state <= DUMP_END;
                                end
                            end else begin
                                dump_state <= DUMP_NUMBER;
                                dump_digit <= dump_digit - 3'd1;
                            end
                        end
                    end
                    DUMP_END: begin
                        out_valid <= 1'b1;
                        out_data <= "\n";
                        if (out_ready) begin
                            out_valid <= 1'b0;
                            dump_digit <= 0;
                            dump_state <= DUMP_START;
                        end
                    end
                endcase
            end
        end
    end
endmodule

