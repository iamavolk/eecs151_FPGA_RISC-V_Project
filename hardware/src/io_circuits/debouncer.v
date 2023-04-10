module debouncer #(
    parameter WIDTH              = 1,
    parameter SAMPLE_CNT_MAX     = 62500,
    parameter PULSE_CNT_MAX      = 200,
    parameter WRAPPING_CNT_WIDTH = $clog2(SAMPLE_CNT_MAX) + 1, // 16 bits
    parameter SAT_CNT_WIDTH      = $clog2(PULSE_CNT_MAX) + 1
) (
    input clk,
    input [WIDTH-1:0] glitchy_signal,
    output [WIDTH-1:0] debounced_signal
);
    localparam counter_bitsize = WRAPPING_CNT_WIDTH; // 16 bits
    // TODO: fill in neccesary logic to implement the wrapping counter and the saturating counters
    // Some initial code has been provided to you, but feel free to change it however you like
    // One wrapping counter is required
    // One saturating counter is needed for each bit of glitchy_signal
    // You need to think of the conditions for reseting, clock enable, etc. those registers
    // Refer to the block diagram in the spec

    wire reset_sample_c;
    wire [counter_bitsize-1:0] sample_c_in;
    wire [counter_bitsize-1:0] sample_c_out;
    REGISTER #(WRAPPING_CNT_WIDTH) wrapping_counter (.q(sample_c_out), .d(sample_c_in), .clk(clk));
    assign sample_c_in = sample_c_out + 1;


    wire [WIDTH-1:0] sat_enable;
    wire [WIDTH-1:0] sat_reset;
    wire [SAT_CNT_WIDTH-1:0] sat_in [WIDTH-1:0];
    wire [SAT_CNT_WIDTH-1:0] sat_out [WIDTH-1:0];
    genvar i;

    generate
        for (i=0; i<WIDTH; i=i+1) begin: sat
            REGISTER_R_CE #(SAT_CNT_WIDTH) sat_reg (.q(sat_out[i]), .d(sat_in[i]), .rst(sat_reset[i]), .ce(sat_enable[i]), .clk(clk));
            assign sat_enable[i] = (({16'b0, sample_c_out} == SAMPLE_CNT_MAX) && glitchy_signal[i]);
            not(sat_reset[i], glitchy_signal[i]);
            assign sat_in[i] = ({23'b0, sat_out[i]} == (PULSE_CNT_MAX - 1)) ? (sat_out[i]) : (sat_out[i] + 1);
            assign debounced_signal[i] = ({23'b0, sat_out[i]} == (PULSE_CNT_MAX - 1)) ? 1'b1 : 1'b0;
        end
    endgenerate

    // Remove this line once you have created your debouncer
    //assign debounced_signal = 0;
endmodule
