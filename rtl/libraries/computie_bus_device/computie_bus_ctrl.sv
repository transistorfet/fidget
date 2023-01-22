module computie_bus_ctrl(
    input clk,

    output send_receive,
    output read_write,
    output addr_oe,
    output data_oe,
    output data_dir,

    output demux_oe,
    input [BITWIDTH-1:0] from_bus,
    output [BITWIDTH-1:0] to_bus
);

    parameter BITWIDTH = 32;

    localparam BUS_IDLE = 0;
    localparam BUS_RECV_ADDR = 1;
    localparam BUS_READ_DATA = 2;   // Read relative to the bus signals, so BUS reading from FPGA
    localparam BUS_WRITE_DATA = 3;  // Write relative to the bus signals, so BUS writing to FPGA

    reg [2:0] bus_state;

    always @(posedge clk) begin
        case (bus_state)
            BUS_IDLE: begin
                addr_oe <= 0;
                data_oe <= 0;
            end
            BUS_RECV_ADDR: begin
                addr_oe <= 1;
                data_oe <= 0;

                //to_bus <= shared_bus;

                if (read_write) bus_state <= BUS_READ_DATA;
                else bus_state <= BUS_WRITE_DATA;
            end
            BUS_WRITE_DATA: begin
                addr_oe <= 0;
                data_oe <= 1;

                data_dir <= read_write;
                //data <= shared_bus;

                bus_state <= BUS_IDLE;
            end
            BUS_READ_DATA: begin
                addr_oe <= 0;
                data_oe <= 1;

                data_dir <= read_write;
                //shared_bus <= in_data;

                bus_state <= BUS_IDLE;
            end
        endcase
    end


    /*
    always @(posedge clk) begin
        if (in_send_receive) begin
            // Send from FPGA to BUS
            // TODO this would need a state machine to process the address
            out_send_receive <= in_send_receive;
            out_addr_oe <= 1;
        end else begin
            // Receive into FPGA from BUS
            out_send_receive <= in_send_receive;
            case (
            out_addr_oe <= 1;
        end
    end
    */

endmodule

