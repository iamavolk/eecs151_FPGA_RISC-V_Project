module edge_detector #(
    parameter WIDTH = 1
)(
    input clk,
    input [WIDTH-1:0] signal_in,
    output [WIDTH-1:0] edge_detect_pulse
);
    // TODO: implement a multi-bit edge detector that detects a rising edge of 'signal_in[x]'
    // and outputs a one-cycle pulse 'edge_detect_pulse[x]' at the next clock edge
    // Feel free to use as many number of registers you like

    // Remove this line once you create your edge detector

   wire [WIDTH-1:0]    prev, cur;
   REGISTER #(.N(WIDTH)) r1(.q(cur), .d(signal_in), .clk(clk));
   REGISTER #(.N(WIDTH)) r2(.q(prev), .d(cur), .clk(clk));

   assign edge_detect_pulse = cur & ~prev;
   
   // assign edge_detect_pulse = 0;
endmodule
