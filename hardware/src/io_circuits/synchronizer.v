
module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    wire [WIDTH-1:0] q1_d1;

    REGISTER #(WIDTH) sync_stage_1 (.q(q1_d1), .d(async_signal), .clk(clk));
    REGISTER #(WIDTH) sync_stage_2 (.q(sync_signal), .d(q1_d1), .clk(clk)); 
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    // Remove this line once you create your synchronizer
endmodule
