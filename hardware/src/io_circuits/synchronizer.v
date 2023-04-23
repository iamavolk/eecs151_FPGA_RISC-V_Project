module synchronizer #(parameter WIDTH = 1) (
    input [WIDTH-1:0] async_signal,
    input clk,
    output [WIDTH-1:0] sync_signal
);
    // TODO: Create your 2 flip-flop synchronizer here
    // This module takes in a vector of WIDTH-bit asynchronous
    // (from different clock domain or not clocked, such as button press) signals
    // and should output a vector of WIDTH-bit synchronous signals
    // that are synchronized to the input clk

    // Remove this line once you create your synchronizer

   wire [WIDTH-1:0]    tmp;
   
   REGISTER #(.N(WIDTH)) r1(.q(tmp), .d(async_signal), .clk(clk));
   REGISTER #(.N(WIDTH)) r2(.q(sync_signal), .d(tmp), .clk(clk));

endmodule
