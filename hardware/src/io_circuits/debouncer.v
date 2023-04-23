module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX),
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    // Remove this line once you have created your debouncer

   wire [WRAPPING_CNT_WIDTH-1:0] wrap_out, wrap_in;
   wire                          wrap_max;
   REGISTER_R #(.N(WRAPPING_CNT_WIDTH)) sat_cnt(.q(wrap_out), .d(wrap_in), .rst(wrap_max), .clk(clk));
   assign wrap_max = (wrap_out == SAMPLE_CNT_MAX);
   assign wrap_in = wrap_out + 1;

   wire [WIDTH-1:0]              sync_signal;
   
   synchronizer #(.WIDTH(WIDTH)) sync(.async_signal(glitchy_signal), .clk(clk), .sync_signal(sync_signal));
   
   wire [SAT_CNT_WIDTH-1:0]      saturating_counter [0:WIDTH-1];
   wire [SAT_CNT_WIDTH-1:0]      sat_in [0:WIDTH-1];
   wire [WIDTH-1:0]              sat_max;
   
   genvar                        i;
   generate for(i = 0; i < WIDTH; i = i + 1) begin
      REGISTER_R_CE #(.N(SAT_CNT_WIDTH)) sat_cnt(.q(saturating_counter[i]), .d(sat_in[i]), .rst(~sync_signal[i]), .ce(sync_signal[i] & wrap_max), .clk(clk));
      assign sat_max[i]= (saturating_counter[i] == PULSE_CNT_MAX);
      assign sat_in[i] = sat_max[i]? saturating_counter[i]: saturating_counter[i] + 1;
      assign debounced_signal[i] = sat_max[i];
   end endgenerate 

   
endmodule
