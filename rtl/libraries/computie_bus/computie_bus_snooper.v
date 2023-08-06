`define DIR_TO_AD   DIR_OUTPUT_TO_A
`define DIR_FROM_AD   DIR_OUTPUT_TO_B

module computie_bus_snooper #(
    parameter BITWIDTH = 32,
    parameter DEPTH = 32
) (
    input comm_clock,

    // Bus Signals
    input cb_clk,
    input cb_reset,
    input cb_addr_strobe,
    input cb_data_strobe,
    input cb_read_write,
    input [BITWIDTH-1:0] cb_addr_data_bus,

    // Bus Transceiver Controls
    output send_receive,
    output reg addr_oe = 1'b1,
    output reg data_oe = 1'b1,
    output data_dir,
    output ctrl_oe,
    output ctrl_dir2,
    output alt_ctrl_oe,
    output alt_ctrl_dir1,
    output alt_ctrl_dir2,
    output al_oe,
    output al_le,

    // Recording Interface
    input record_start,
    output reg record_end,
    input record_trigger,

    // Record Output
    output reg record_out_enable,
    output reg [$clog2(DEPTH):0] record_out_count = 0,
    output [BITWIDTH * 2 + 1 - 1:0] record_out,

    output reg led,
);

    localparam ACTIVE = 1'b0;
    localparam INACTIVE = 1'b1;

    localparam BUS_RESET = 0;
    localparam BUS_WAIT_FOR_START = 1;
    localparam BUS_RECV_DATA = 2;
    localparam BUS_WAIT_FOR_END = 3;
    localparam BUS_BUFFER_FULL = 4;

    reg [2:0] state = BUS_WAIT_FOR_START;

    reg [1:0] out_mod;
    reg [BITWIDTH-1:0] out_address;
    reg [BITWIDTH-1:0] out_data;

    assign record_out = { out_mod, out_address, out_data };

    // For snooping, the bus direction will always be "RECEIVE"
    assign send_receive = 1'b0;
    // For snooping, the direction is always receiving
    assign data_dir = 1'b0;

    // Enable control signal transceivers in the direction of a bus device
    assign ctrl_oe = 1'b0;
    assign ctrl_dir2 = 1'b0;
    assign alt_ctrl_oe = 1'b0;
    assign alt_ctrl_dir1 = 1'b0;
    // This probably caused interference on the bus because it's only supposed to snoop, not be a receiver
    //assign alt_ctrl_dir2 = 1'b1;
    assign alt_ctrl_dir2 = 1'b0;

    // Disable the address latch
    assign al_oe = 1'b1;
    assign al_le = 1'b0;

    always @(negedge cb_clk) begin
        record_out_enable <= 1'b0;

        addr_oe <= INACTIVE;
        data_oe <= INACTIVE;
        case (state)
            BUS_RESET: begin
                record_out_count <= 0;
                addr_oe <= INACTIVE;
                data_oe <= INACTIVE;
                state <= BUS_WAIT_FOR_START;
            end
            BUS_WAIT_FOR_START: begin
                if (cb_addr_strobe == ACTIVE) begin
                    led <= 1'b1;
                    addr_oe <= ACTIVE;
                    data_oe <= INACTIVE;
                    out_address <= cb_addr_data_bus;
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
                    out_data <= cb_addr_data_bus;
                    out_mod <= { 1'b0, cb_read_write };
                    record_out_count <= record_out_count + 1;
                    record_out_enable <= 1'b1;
                    if (record_out_count == DEPTH - 1) begin
                        state <= BUS_BUFFER_FULL;
                    end else begin
                        state <= BUS_WAIT_FOR_START;
                    end
                end
            end
            BUS_BUFFER_FULL: begin
                addr_oe <= INACTIVE;
                data_oe <= INACTIVE;
            end
        endcase
    end
endmodule

