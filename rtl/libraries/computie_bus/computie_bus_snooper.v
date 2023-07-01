`define DIR_TO_AD   DIR_OUTPUT_TO_A
`define DIR_FROM_AD   DIR_OUTPUT_TO_B

module computie_bus_snooper #(
    parameter BITWIDTH = 32,
    parameter DEPTH = 128
) (
    input comm_clock,

    // Internal Interface
    input record_start,
    output reg record_end,
    input record_trigger,

    input dump_start,
    output dump_end,
    output reg [7:0] data_out,

    // Bus Control Signals
    input cb_clk,
    input cb_addr_strobe,
    input cb_data_strobe,
    input cb_read_write,
    input [BITWIDTH-1:0] cb_addr_data_bus,

    // Transceiver Control
    output send_receive,
    output reg addr_oe,
    output reg data_oe,
    output data_dir
);

    localparam BUS_IDLE = 0;
    localparam BUS_RECV_DATA = 1;
    localparam BUS_WAIT_FOR_DSACK = 2;

    reg [2:0] state = BUS_IDLE;

    reg [DEPTH*BITWIDTH-1:0] address_records = 0;
    reg [DEPTH*BITWIDTH-1:0] data_records = 0;
    reg [$clog2(DEPTH):0] record_count = 0;


    // For snooping, the bus direction will always be "RECEIVE"
    assign send_receive = 1'b0;
    // For snooping, the direction is always receiving
    assign data_dir = 1'b0;

    always @(posedge cb_clk) begin
        if (record_start) begin
            if (record_count >= DEPTH) begin
                record_end <= 1'b1;
            end else begin
                record_end <= 1'b0;

                case (state)
                    BUS_IDLE: begin
                        if (cb_addr_strobe == 1'b0) begin
                            addr_oe <= 1'b1;
                            data_oe <= 1'b0;
                            address_records[record_count] <= cb_addr_data_bus;
                            state <= BUS_RECV_DATA;
                        end
                    end
                    BUS_RECV_DATA: begin
                        if (cb_data_strobe == 1'b0) begin
                            addr_oe <= 1'b0;
                            data_oe <= 1'b1;
                            state <= BUS_WAIT_FOR_DSACK;
                        end
                    end
                    BUS_WAIT_FOR_DSACK: begin
                        data_records[record_count] <= cb_addr_data_bus;
                        record_count <= record_count + 1;
                        state <= BUS_IDLE;
                    end
                endcase
            end
        end
    end

    always @(posedge comm_clock) begin
        if (dump_start) begin
            // TODO dump the records to serial
        end
    end
endmodule

