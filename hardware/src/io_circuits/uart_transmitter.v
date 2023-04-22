module uart_transmitter #(
    parameter CLOCK_FREQ = 125_000_000,
    parameter BAUD_RATE = 115_200)
(
    input clk,
    input reset,

    input [7:0] data_in,
    input data_in_valid,
    output data_in_ready,

    output serial_out
);
    // See diagram in the lab guide
   localparam  SYMBOL_EDGE_TIME    =   CLOCK_FREQ / BAUD_RATE;
   localparam  CLOCK_COUNTER_WIDTH =   $clog2(SYMBOL_EDGE_TIME);
   
   wire    fire;
   assign fire = data_in_valid & data_in_ready;
   
   wire [CLOCK_COUNTER_WIDTH-1:0] clock_counter_value, clock_counter_next;
   reg 				  clock_counter_rst;
   REGISTER_R #(.N(CLOCK_COUNTER_WIDTH)) clock_counter (
							.q(clock_counter_value),
							.d(clock_counter_next),
							.rst(clock_counter_rst),
							.clk(clk)
							);
   assign clock_counter_next = clock_counter_value + 1;
   
   wire [9:0] 			  tx_shift_value;
   reg [9:0] 			  tx_shift_next;
   wire 			  tx_shift_ce;
   REGISTER_R #(.N(10), .INIT(10'b1111111111)) tx_shift (
						       .q(tx_shift_value),
						       .d(tx_shift_next),
						       .rst(reset),
						       .clk(clk)
						       );
   
   wire [3:0] 			  bit_counter_value;
   reg [3:0] 			  bit_counter_next;
   REGISTER_R #(.N(4)) bit_counter (
				    .q(bit_counter_value),
				    .d(bit_counter_next),
				    .rst(reset),
				    .clk(clk)
				  );
   
   always @(*) begin
      clock_counter_rst = 1'b0;
      tx_shift_next = tx_shift_value;
      bit_counter_next = bit_counter_value;
      if(fire) begin
	 clock_counter_rst = 1'b1;
	 tx_shift_next = {1'b1, data_in, 1'b0};
	 bit_counter_next = 4'd10;
      end
      else if(clock_counter_value == SYMBOL_EDGE_TIME - 1) begin
	 clock_counter_rst = 1'b1;
	 tx_shift_next = {1'b1, tx_shift_value[9:1]};
	 if(bit_counter_value != 4'd0) bit_counter_next = bit_counter_value - 4'd1;
      end
   end
   
    assign serial_out = tx_shift_value[0];
    assign data_in_ready = (bit_counter_value == 4'd0);
endmodule
