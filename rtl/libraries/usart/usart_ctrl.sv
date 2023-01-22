module usart_ctrl(
   input clk,

   input write,
   input [2:0] cmd_in,
   input [7:0] data_in,

   //input rx_pin,
   output tx_pin
);

   typedef enum {
      NOP,
      SET_CTRL,
      SET_DATA,
   } usart_cmd;

   reg serial_clock;
   reg [7:0] serial_counter;
   reg [7:0] serial_preset = 138;

   reg tx_enable;
   wire [7:0] tx_data;

   usart_tx usart_tx(
      .clock(clk),
      .tx_enable(tx_enable),
      .tx_data(tx_data),
      .tx_pin(tx_pin),
      .serial_clock(serial_clock),
   );

    always @(posedge clock)
    begin
        serial_counter = serial_counter + 1;
        if (serial_counter == 138)
            serial_counter = 0;
        serial_clock = (serial_counter < 69);
    end

   always @(posedge clk) begin
      if (write)
         case (cmd_in)
            NOP: begin end
            SET_CTRL: begin end
            SET_DATA: begin
               tx_data <= data_in;
               tx_enable <= 1'b1;
            end
         endcase
   end

endmodule
