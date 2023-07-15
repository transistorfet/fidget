`define DIR_TO_AD   DIR_OUTPUT_TO_A
`define DIR_FROM_AD   DIR_OUTPUT_TO_B

module computie_bus_receiver #(
    parameter BITWIDTH = 32,
    parameter DEVICE_ADDRESS = 32'h00500000,
    parameter DEVICE_SIG_BITS = 8
) (
    input comm_clock,

    // Internal Interface
    output data_wait,
    output reg [BITWIDTH-1:0] addr_out,
    input [BITWIDTH-1:0] data_in,
    output reg [BITWIDTH-1:0] data_out,

    // Bus Control Signals
    input cb_clk,
    input cb_reset,
    input cb_addr_strobe,
    input cb_data_strobe,
    input cb_read_write,

    // Transceiver Control
    output send_receive,
    output reg addr_oe = 1'b1,
    output reg data_oe = 1'b1,
    output reg data_dir = 1'b0,
    output ctrl_oe,
    output reg ctrl_dir2 = 1'b0,
    output alt_ctrl_oe,
    output alt_ctrl_dir1,
    output alt_ctrl_dir2,
    output al_oe,
    output al_le,

    // Bus Demux
    output reg cb_demux_oe = 1'b0,
    input [BITWIDTH-1:0] cb_from_bus,
    output reg [BITWIDTH-1:0] cb_to_bus = 32'h0
);

    localparam ACTIVE = 1'b0;
    localparam INACTIVE = 1'b1;

    localparam DIR_INPUT = 1'b0;
    localparam DIR_OUTPUT = 1'b1;

    localparam BUS_IDLE = 0;
    localparam BUS_RECV_ADDR = 1;
    localparam BUS_READ_DATA = 2;   // Read relative to the bus signals, so BUS reading from FPGA
    localparam BUS_WRITE_DATA = 3;  // Write relative to the bus signals, so BUS writing to FPGA

    reg [2:0] bus_state = BUS_IDLE;

    // For receiving, the bus direction will always be "RECEIVE"
    assign send_receive = 1'b0;

    // Enable control signal transceivers in the direction of a bus device
    assign ctrl_oe = ACTIVE;
    assign alt_ctrl_oe = ACTIVE;
    assign alt_ctrl_dir1 = DIR_INPUT;
    //assign alt_ctrl_dir2 = 1'b1;

    // Disable the address latch
    assign al_oe = INACTIVE;
    assign al_le = 1'b0;

    always @(negedge cb_clk) begin
        case (bus_state)
            BUS_IDLE: begin
                cb_demux_oe <= 1'b0;
                addr_oe <= INACTIVE;
                data_oe <= INACTIVE;
                data_dir <= DIR_INPUT;

                if (cb_addr_strobe == ACTIVE) begin
                    bus_state <= BUS_RECV_ADDR;
                end
            end

            BUS_RECV_ADDR: begin
                bus_state <= BUS_RECV_ADDR;
                cb_demux_oe <= 1'b0;
                addr_oe <= ACTIVE;
                data_oe <= INACTIVE;
                addr_out <= cb_from_bus;

                if (cb_data_strobe == ACTIVE) begin
                    if (cb_from_bus[BITWIDTH-1:DEVICE_SIG_BITS] != DEVICE_ADDRESS[BITWIDTH-1:DEVICE_SIG_BITS]) begin
                        // If the current device is not being addressing, then return to IDLE
                        bus_state <= BUS_IDLE;
                    end else if (cb_read_write) begin
                        bus_state <= BUS_READ_DATA;
                    end else begin
                        bus_state <= BUS_WRITE_DATA;
                    end
                end
            end

            BUS_READ_DATA: begin
                bus_state <= BUS_READ_DATA;
                cb_demux_oe <= 1'b1;

                // Read from this device to the Bus (Send Data)
                addr_oe <= INACTIVE;
                data_dir <= cb_read_write;
                data_oe <= ACTIVE;

                cb_to_bus <= data_in;

                if (cb_data_strobe == INACTIVE) begin
                    bus_state <= BUS_IDLE;
                end
            end

            BUS_WRITE_DATA: begin
                bus_state <= BUS_WRITE_DATA;
                cb_demux_oe <= 1'b0;

                // Write from the Bus to this device (Receive Data)
                addr_oe <= INACTIVE;
                data_dir <= cb_read_write;
                data_oe <= ACTIVE;

                data_out <= cb_from_bus;

                if (cb_data_strobe == INACTIVE) begin
                    bus_state <= BUS_IDLE;
                end
            end
        endcase
    end
endmodule

