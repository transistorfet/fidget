module computie_bus_ctrl(
    input clk,

    // Internal Interface
    //output cycle_start,
    //input cycle_hold,
    output reg [BITWIDTH-1:0] addr_out,
    input [BITWIDTH-1:0] data_in,
    output reg [BITWIDTH-1:0] data_out,

    // Bus Control Signals
    input addr_strobe,
    input read_write,

    // Transceiver Control
    output reg send_receive,
    output reg addr_oe,
    output reg data_oe,
    output reg data_dir,

    // Bus Demux
    output demux_oe,
    input [BITWIDTH-1:0] from_bus,
    output reg [BITWIDTH-1:0] to_bus
);

    parameter BITWIDTH = 32;

    localparam BUS_IDLE = 0;
    localparam BUS_RECV_ADDR = 1;
    localparam BUS_READ_DATA = 2;   // Read relative to the bus signals, so BUS reading from FPGA
    localparam BUS_WRITE_DATA = 3;  // Write relative to the bus signals, so BUS writing to FPGA

    reg [2:0] bus_state = BUS_IDLE;

    // For a receiving device, the bus direction will always be "RECEIVE"
    assign send_receive = 1'b0;

    always_ff @(negedge addr_strobe) begin

    end

    always_ff @(posedge clk) begin
        case (bus_state)
            BUS_IDLE: begin
                demux_oe = 1'b0;
                addr_oe = 1'b0;
                data_oe = 1'b0;

                if (!addr_strobe) bus_state <= BUS_RECV_ADDR;
            end
            BUS_RECV_ADDR: begin
                demux_oe = 1'b0;
                addr_oe = 1'b1;
                data_oe = 1'b0;

                addr_out <= from_bus;

                if (read_write) bus_state <= BUS_READ_DATA;
                else bus_state <= BUS_WRITE_DATA;
            end
            BUS_WRITE_DATA: begin
                demux_oe = 1'b0;

                // Write from the Bus to this device
                addr_oe = 1'b0;
                data_dir = read_write;
                data_oe = 1'b1;

                data_out <= from_bus;

                bus_state <= BUS_IDLE;
            end
            BUS_READ_DATA: begin
                demux_oe = 1'b1;

                // Read from this device to the Bus
                addr_oe = 1'b0;
                data_dir = read_write;
                data_oe = 1'b1;

                to_bus <= data_in;

                bus_state <= BUS_IDLE;
            end
        endcase
    end
endmodule

